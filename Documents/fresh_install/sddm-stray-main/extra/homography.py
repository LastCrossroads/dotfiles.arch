import numpy as np
import cv2

def compute_intrinsics_from_hfov(fov_x_deg, w, h):
    fov_x = np.deg2rad(fov_x_deg)
    fx = w / (2 * np.tan(fov_x / 2))
    fy = fx
    cx, cy = w/2, h/2
    K = np.array([[fx,  0, cx],
                  [ 0, fy, cy],
                  [ 0,  0,  1]], dtype=np.float32)
    return K

def euler_to_matrix(pitch, yaw, roll):
    # Invert the x and y axes to match opencv's coordinate system
    p = -np.deg2rad(pitch)
    y =  np.deg2rad(yaw)
    r = -np.deg2rad(roll)

    Rx = np.array([[1,         0,          0],
                   [0,  np.cos(r), -np.sin(r)],
                   [0,  np.sin(r),  np.cos(r)]], dtype=np.float32)
    Ry = np.array([[ np.cos(p), 0, np.sin(p)],
                   [         0, 1,         0],
                   [-np.sin(p), 0, np.cos(p)]], dtype=np.float32)
    Rz = np.array([[ np.cos(y), -np.sin(y), 0],
                   [ np.sin(y),  np.cos(y), 0],
                   [         0,           0, 1]], dtype=np.float32)

    return Rz @ Ry @ Rx

def project(world_pts, cam_pos, R_cam, K):

    P_uc = R_cam @ (world_pts.T - cam_pos.reshape(3,1))

    # Map unreal axes to opencv
    M = np.array([[0, 1,  0],
                  [0, 0, -1],
                  [1, 0,  0]], dtype=np.float32)
    P_cc = M @ P_uc

    # Project into image
    P_img = K @ P_cc
    P_img /= P_img[2:3, :]
    return P_img[:2, :].T  # (N,2)

if __name__ == "__main__":
    width, height = 1920, 1080

    # Camera    
    fov = 61.421
    cam_pos = np.array([249.0,   0.0,    0.0], dtype=np.float32)
    cam_pitch, cam_yaw, cam_roll = 0.0, 0.0, 0.0

    # Screen
    origin = np.array([610.975, 137.437, -72.896], dtype=np.float32)
    obj_pitch, obj_yaw, obj_roll = 5.129, 120.475, -28.277
    extent = np.array([84.6, 2.62, 47.1], dtype=np.float32)

    K = compute_intrinsics_from_hfov(fov, width, height)
    R_cam = euler_to_matrix(cam_pitch, cam_yaw, cam_roll)
    R_obj = euler_to_matrix(obj_pitch, obj_yaw, obj_roll)

    local_corners = np.array([
        [-extent[0], +extent[1], +extent[2]],  # top‑left
        [+extent[0], +extent[1], +extent[2]],  # top‑right
        [+extent[0], +extent[1], -extent[2]],  # bottom‑right
        [-extent[0], +extent[1], -extent[2]],  # bottom‑left
    ], dtype=np.float32)
    
    world_corners = (R_obj @ local_corners.T).T + origin

    # Project 3d onto 2d
    dst_px = project(world_corners, cam_pos, R_cam, K)

    # Make the homography K independant
    invK = np.linalg.inv(K)
    # Make homogeneous pixels
    dst_h = np.hstack([dst_px, np.ones((dst_px.shape[0],1), dtype=np.float32)])
    # Map to normalized plane
    dst_norm_h = (invK @ dst_h.T).T
    dst_norm = dst_norm_h[:, :2] / dst_norm_h[:, 2:3]

    # Map uv to pixel coordinates
    ran = [extent[0] * 10, extent[2] * 10] # bring it to [846; 471]
    uv = np.array([
        [0, 0],
        [ran[0], 0],
        [ran[0], ran[1]],
        [0,      ran[1]]
    ], dtype=np.float32)
    H, _ = cv2.findHomography(uv, dst_norm)
    print("Homography H:\n", H)