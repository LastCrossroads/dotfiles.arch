local UEHelpers = require("UEHelpers")

RegisterKeyBind(Key.F1, {}, function()
    local main_menu = FindFirstOf("UMG_MainMenu_C")

    if main_menu then
      local visibility = main_menu:GetVisibility()
      main_menu:SetVisibility(visibility ~= 1 and 1)
    end

    local inst = FindFirstOf("CACA_BigScreen_B12Flat_C")
    inst.UI_Screen.Text = ""
    inst.UI_Screen.WritingText = ""
    
    local camera = UEHelpers:GetPlayerController().PlayerCameraManager
    local cam_loc = camera:GetCameraLocation()
    local cam_rot = camera:GetCameraRotation()
    local fov = camera:GetFOVAngle()
    print(string.format(
      "Camera at (%.3f, %.3f, %.3f), rot (%.3f, %.3f, %.3f), FOV %.3f\n",
      cam_loc.X, cam_loc.Y, cam_loc.Z,
      cam_rot.Pitch, cam_rot.Yaw, cam_rot.Roll,
      fov
    ))

    local origin = {X=0.0, Y=0.0, Z=0.0}
    local extent = {X=0.0, Y=0.0, Z=0.0}
    inst:GetActorBounds(false, origin, extent, true)
    local rotation = inst:K2_GetActorRotation()
    local location = inst:K2_GetActorLocation()
    print(string.format(
      "Screen at (%.3f, %.3f, %.3f), extent (%.3f, %.3f, %.3f), rot (%.3f, %.3f, %.3f), loc (%.3f, %.3f, %.3f)\n",
      origin.X, origin.Y, origin.Z,
      extent.X, extent.Y, extent.Z,
      rotation.Pitch, rotation.Yaw, rotation.Roll,
      location.X, location.Y, location.Z
    ))
    
    local wind_sound = FindObject("SoundWave", "amb_wind_menu_loop_01")
    wind_sound.Volume = 0
    
    local player = FindAllOf("LevelSequencePlayer")[1]
    player:JumpToSeconds(0)

end)


NotifyOnNewObject("/Script/LevelSequence.LevelSequencePlayer", function(s_player)
    local s_name = s_player:GetFullName()
    if not s_name:find("Gamemenu_anim.AnimationPlayer", 1, true) then
      return
    end

    ExecuteInGameThread(function()
      local screenAsset = LoadAsset("/Game/Team/Alex/B12Flat_BPs_Alex/CACA_BigScreen_B12Flat.CACA_BigScreen_B12Flat_C")
      if not screenAsset then
        print("Couldn't get screen asset\n")
        return
      end

      local world = s_player:GetWorld()
      if not world then
        print("Couldn't get world\n")
        return
      end

      local loc = { X = 590, Y = 130, Z = -120 }
      local rot = { Pitch = 10, Yaw = 120, Roll = -20 }

      local spawned = world:SpawnActor(screenAsset, loc, rot)
      if not spawned then
        print("Couldn't spawn asset\n")
      end
      
    end)
  return true
end)
