<img src="./readme/preview.gif" width="100%" />

<p align="center">
  <a href="#installation">Installation</a> •
  <a href="#usage">Usage</a> •
  <a href="#customization">Customization</a>
</p>

# Installation

### Dependencies

- [`sddm >= 0.21.0`](https://github.com/sddm/sddm)
- [`qt6 >= 6.8`](https://doc.qt.io/qt-6/index.html)
- [`qt6-svg >= 6.8`](https://doc.qt.io/qt-6/qtsvg-index.html)
- [`qt6-multimedia >= 6.8`](https://doc.qt.io/qt-6/qtmultimedia-index.html)

### Copy from repo into ```sddm/themes```

```bash
git clone --depth 1 https://github.com/Bqrry4/sddm-stray.git && cd sddm-stray
sudo cp -r theme/ /usr/share/sddm/themes/stray
```

### Edit ```/etc/sddm.conf```

```bash
#...
[Theme]
Current=stray
#...
```

# Usage

This theme is keyboard oriented, with the following mappings.

| Keymap            | Action        |
| -------------     | ------------- |
| Alt / Shift+Alt   | Switch to next/previous Session |
| Tab / Shift+Tab   | Switch to next/previous User    |
| Meta+R | Reboot   |
| Meta+P | PowerOff |
| Enter  | Submit Login             |

# Customization

Basic customization can be done by modifying [```theme.conf```](./theme/theme.conf).

> [!IMPORTANT]  
> Only the sessions listed in [`Components/sessions.js`](./theme/Components/sessions.js) will be shown.  
> One can use [`extra/ls_sessions.sh`](./extra/ls_sessions.sh) to check the existing sessions with their specific names.

## Modding

As this is based on the Stray game, it is possible to mod it and make a different version of the background.

Since there’s no straightforward way to export the scene, you’ll need to record it manually (it's a 1:40 duration loop).

### Basic setup

1. Install [`UE4SS`](https://github.com/UE4SS-RE/RE-UE4SS)
2. Copy the `extra/SddmHelperMod` into your Stray's UE4SS installation's `Mods` directory.
3. When in the Main Menu, press F1 to reset the animation to the beginning for recording.

> [!NOTE]  
> If changing the theme's video to a different source, the [Components/timestamps.js](./theme/Components/timestamps.js) should be updated.

### Changing screen object position

1. Set the desired location and rotation values in [`SddmHelperMod/Scripts/main.lua`](./extra/SddmHelperMod/Scripts/main.lua).

```lua
local loc = ...
local rot = ...
```

2. While in the game, press F1 to dump the modified origin and rotation of the screen's bounding box to `UE4SS.log`.
3. Set the new values and recompute the homography matrix using [`extra/homography.py`](./extra/homography.py).

```python
# Screen
origin = ...
obj_pitch, obj_yaw, obj_roll = ...
```
4. Update the [`Components/LoginScreen.qml`](./theme/Components/LoginScreen.qml) with the new matrix:
```bash
/* Normalized homography */
let Hn = /*...*/
```

### Customizing the Scene
> [!TIP]  
> For the cat model the easiest way is to take one from `nexusmods`.

It is possible to change the background to display something custom instead of the Stray logo. Quick tutorial:

1. Use [`repak`](https://github.com/trumank/repak) on `Hk_project/Content/Paks/Hk_project-WindowsNoEditor.pak` to unpack the assets.
2. Locate the following assets in the extracted directory:

```
Hk_project/Content/Data/Textures/GUI/
    ├── StartScreen_Logo_alpha.uasset  
    └── StartScreen_Logo_alpha02.uasset
```

3. Use [`UE4-DDS-Tools`](https://github.com/matyalatte/UE4-DDS-Tools) to:
   - Export the textures from `.uasset`.
   - Edit them.
   - Inject the modified texture back into the .uasset files.
4. Create the `Hk_project-WindowsNoEditor_ScreenLogo/Hk_project/Content/Data/Textures/GUI/` folder structure and place the new modified `.uassets` inside.
5. Repack the folder into a .pak and place it in `Hk_project/Content/Paks`.
