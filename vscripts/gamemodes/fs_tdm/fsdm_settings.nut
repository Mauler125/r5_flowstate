//So ideally, don't change this if you don't want prediction to be fucked. Open a PR on Flowstate repo if you have feedback for these vars <3 Cafe
global const table TRUE_TF2_SETTINGS = 
{
	//["acceleration"] = 10.0,
	["airacceleration"] = 500.0,
	//["airspeed"] = 60,
	["antiMultiJumpHeightFrac"] = 1.0,
	["automantle"] = 1.0,
	["automantle_enable"] = 1.0,
	["doublejump"] = 1.0,
	["gravityscale"] = 0.75,
	["impactSpeed"] = 380.0,
	["jumpheight"] = 60.0,
	["landslowdownduration"] = 0.0,
	["leech_range"] = 64.0,
	["skip_speed_reduce"] = 0.0,
	["Slidejumpheight"] = 90.0,
	["slideRequiredStartSpeed"] = 200.0,
	["slideSpeedBoostCap"] = 9999999.0,
	["slidedecel"] = 50.0,
	["slidevelocitydecay"] = 0.7,
	["stepheight"] = 18.0,
	["superjumpHorzSpeed"] = 180.0,
	["superjumpMaxHeight"] = 60.0,
	["superjumpMinHeight"] = 60.0,
	["wallrun"] = 1.0,
	["wallrunAccelerateHorizontal"] = 1400.0,
	["wallrunAccelerateVertical"] = 360.0,
	["wallrunJumpInputDirSpeed"] = 75.0,
	["wallrunJumpOutwardSpeed"] = 205.0,
	["wallrunJumpUpSpeed"] = 230.0,
	["wallrunMaxSpeedHorizontal"] = 340.0,
	["wallrunMaxSpeedVertical"] = 225.0,
	["wallrun_timeLimit"] = 1.75,
	["ziplineSpeed"] = 600.0,
	["skip_speed_retain"] = 99999.0,
	["slide_boost_cooldown"] = 2.0,
	["speed"] = 162.5,
	["sprintspeed"] = 243.0,
	["grapple_shootVel"] = 3000.0,
	["grapple_speedRampMax_human"] = 800.0,
	["wallrun_maxViewTilt"] = 15.0,
	["sprintViewOffset"] = -6.0,
	["sprintStartDelay"] = 0.2,
	["sprintStartDuration"] = 0.8,
	["sprintStartFastDuration"] = 0.2,
	["sprintEndDuration"] = 0.15,
	["sprinttiltMaxRoll"] = 2.0,
	["grapple_windowCheckDist"] = 150.0,
	["grapple_detachLengthMin"] = 33.0,
	["grapple_detachLengthMax"] = 50.0,
	["grapple_detachAwaySpeed"] = 500.0,
	["grapple_gravityFracMin"] = 0.25,
	["grapple_gravityFracMax"] = 0.7,
	["grapple_detachVerticalBoost"] = 200.0,
	["grapple_detachVerticalMaxSpeed"] = 200.0,
	["grapple_detachSpeedLoss"] = 300.0,
	["grapple_detachSpeedLossMin"] = 430.0,
	["grapple_detachLowSpeedThreshold"] = 250.0,
	["grapple_detachLowSpeedTime"] = 1.5,
	["grapple_detachLowSpeedWallTime"] = 1.2,
	["grapple_detachLowSpeedGroundTime"] = 0.7,
	["grapple_impactVerticalBoost"] = 300.0,
	["grapple_impactVerticalMaxSpeed"] = 300.0,
	["grapple_power_regen_delay"] = 3.0,
	["grapple_power_regen_rate"] = 3.0,
	["grapple_airSpeedMax"] = 420.0,
	["grapple_airAccel"] = 650.0,
	["wallrun_allowed_wall_dist"] = 13.0,
	["wallrun_allowed_wall_dist_wallhang"] = 18.0,
	["wallrun_gravityRampUpTime"] = 0.7,
	["wallrun_sameWallHeight"] = 0.0,
	["wallrun_upWallBoost"] = 250.0,
	["wallrun_hangTimeLimit"] = 25.0,
	["zipline_use_range"] = 120.0
}

global const table TRUE_TF2_SETTINGS_HIGH_AIRACCEL = 
{
	//["acceleration"] = 10.0,
	["airacceleration"] = 9000.0, //increase air accel
	//["airspeed"] = 60.0,
	["antiMultiJumpHeightFrac"] = 1.0,
	["automantle"] = 0.0, //disable auto mantle
	["automantle_enable"] = 0.0,
	["doublejump"] = 1.0,
	["gravityscale"] = 0.75,
	["impactSpeed"] = 380.0,
	["jumpheight"] = 60.0,
	["landslowdownduration"] = 0.0,
	["leech_range"] = 64.0,
	["skip_speed_reduce"] = 0.0,
	["Slidejumpheight"] = 90.0,
	["slideRequiredStartSpeed"] = 200.0,
	["slideSpeedBoostCap"] = 9999999.0,
	["slidedecel"] = 50.0,
	["slidevelocitydecay"] = 0.7,
	["stepheight"] = 18.0,
	["superjumpHorzSpeed"] = 180.0,
	["superjumpMaxHeight"] = 60.0,
	["superjumpMinHeight"] = 60.0,
	["wallrun"] = 1.0,
	["wallrunAccelerateHorizontal"] = 1400.0,
	["wallrunAccelerateVertical"] = 360.0,
	["wallrunJumpInputDirSpeed"] = 75.0,
	["wallrunJumpOutwardSpeed"] = 205.0,
	["wallrunJumpUpSpeed"] = 230.0,
	["wallrunMaxSpeedHorizontal"] = 340.0,
	["wallrunMaxSpeedVertical"] = 225.0,
	["wallrun_timeLimit"] = 1.75,
	["ziplineSpeed"] = 600.0,
	["skip_speed_retain"] = 99999.0,
	["slide_boost_cooldown"] = 2.0,
	["speed"] = 162.5,
	["sprintspeed"] = 243.0,
	["grapple_shootVel"] = 3000.0,
	["grapple_speedRampMax_human"] = 800.0,
	["wallrun_maxViewTilt"] = 15.0,
	["sprintViewOffset"] = -6.0,
	["sprintStartDelay"] = 0.2,
	["sprintStartDuration"] = 0.8,
	["sprintStartFastDuration"] = 0.2,
	["sprintEndDuration"] = 0.15,
	["sprinttiltMaxRoll"] = 2.0,
	["grapple_windowCheckDist"] = 150.0,
	["grapple_detachLengthMin"] = 33.0,
	["grapple_detachLengthMax"] = 50.0,
	["grapple_detachAwaySpeed"] = 500.0,
	["grapple_gravityFracMin"] = 0.25,
	["grapple_gravityFracMax"] = 0.7,
	["grapple_detachVerticalBoost"] = 200.0,
	["grapple_detachVerticalMaxSpeed"] = 200.0,
	["grapple_detachSpeedLoss"] = 300.0,
	["grapple_detachSpeedLossMin"] = 430.0,
	["grapple_detachLowSpeedThreshold"] = 250.0,
	["grapple_detachLowSpeedTime"] = 1.5,
	["grapple_detachLowSpeedWallTime"] = 1.2,
	["grapple_detachLowSpeedGroundTime"] = 0.7,
	["grapple_impactVerticalBoost"] = 300.0,
	["grapple_impactVerticalMaxSpeed"] = 300.0,
	["grapple_power_regen_delay"] = 3.0,
	["grapple_power_regen_rate"] = 3.0,
	["grapple_airSpeedMax"] = 420.0,
	["grapple_airAccel"] = 650.0,
	["wallrun_allowed_wall_dist"] = 13.0,
	["wallrun_allowed_wall_dist_wallhang"] = 18.0,
	["wallrun_gravityRampUpTime"] = 0.7,
	["wallrun_sameWallHeight"] = 0.0,
	["wallrun_upWallBoost"] = 250.0,
	["wallrun_hangTimeLimit"] = 25.0,
	["zipline_use_range"] = 120.0,
	["grapple_accel_human"] = 1800.0, //buff grapple
	["grapple_decel_human"] = 200.0, //buff grapple
	["grapple_speedRampMin_human"] = 400.0, //buff grapple
	["grapple_speedRampTime_human"] = 1.0 //buff grapple
}

global const table TRUE_TF2_SETTINGS_LOW_GRAV = 
{
	//["acceleration"] = 10,
	["airacceleration"] = 500.0,
	//["airspeed"] = 60.0,
	["antiMultiJumpHeightFrac"] = 1.0,
	["automantle"] = 1.0,
	["automantle_enable"] = 1.0,
	["doublejump"] = 1.0,
	["gravityscale"] = 0.4,
	["impactSpeed"] = 380.0,
	["jumpheight"] = 60.0,
	["landslowdownduration"] = 0.0,
	["leech_range"] = 64.0,
	["skip_speed_reduce"] = 0.0,
	["Slidejumpheight"] = 90.0,
	["slideRequiredStartSpeed"] = 200.0,
["slideSpeedBoostCap"] = 9999999.0,
["slidedecel"] = 50.0,
["slidevelocitydecay"] = 0.7,
["stepheight"] = 18.0,
["superjumpHorzSpeed"] = 180.0,
["superjumpMaxHeight"] = 60.0,
["superjumpMinHeight"] = 60.0,
["wallrun"] = 1.0,
["wallrunAccelerateHorizontal"] = 1400.0,
["wallrunAccelerateVertical"] = 360.0,
["wallrunJumpInputDirSpeed"] = 75.0,
["wallrunJumpOutwardSpeed"] = 205.0,
["wallrunJumpUpSpeed"] = 230.0,
["wallrunMaxSpeedHorizontal"] = 340.0,
["wallrunMaxSpeedVertical"] = 225.0,
["wallrun_timeLimit"] = 1.75,
["ziplineSpeed"] = 600.0,
["skip_speed_retain"] = 99999.0,
["slide_boost_cooldown"] = 2.0,
["speed"] = 162.5,
["sprintspeed"] = 243.0,
["grapple_shootVel"] = 3000.0,
["grapple_speedRampMax_human"] = 800.0,
["wallrun_maxViewTilt"] = 15.0,
["sprintViewOffset"] = -6.0,
["sprintStartDelay"] = 0.2,
["sprintStartDuration"] = 0.8,
["sprintStartFastDuration"] = 0.2,
["sprintEndDuration"] = 0.15,
["sprinttiltMaxRoll"] = 2.0,
["grapple_windowCheckDist"] = 150.0,
["grapple_detachLengthMin"] = 33.0,
["grapple_detachLengthMax"] = 50.0,
["grapple_detachAwaySpeed"] = 500.0,
["grapple_gravityFracMin"] = 0.25,
["grapple_gravityFracMax"] = 0.7,
["grapple_detachVerticalBoost"] = 200.0,
["grapple_detachVerticalMaxSpeed"] = 200.0,
["grapple_detachSpeedLoss"] = 300.0,
["grapple_detachSpeedLossMin"] = 430.0,
["grapple_detachLowSpeedThreshold"] = 250.0,
["grapple_detachLowSpeedTime"] = 1.5,
["grapple_detachLowSpeedWallTime"] = 1.2,
["grapple_detachLowSpeedGroundTime"] = 0.7,
["grapple_impactVerticalBoost"] = 300.0,
["grapple_impactVerticalMaxSpeed"] = 300.0,
["grapple_power_regen_delay"] = 3.0,
["grapple_power_regen_rate"] = 3.0,
["grapple_airSpeedMax"] = 420.0,
["grapple_airAccel"] = 650.0,
["wallrun_allowed_wall_dist"] = 13.0,
["wallrun_allowed_wall_dist_wallhang"] = 18.0,
["wallrun_gravityRampUpTime"] = 0.7,
["wallrun_sameWallHeight"] = 0.0,
["wallrun_upWallBoost"] = 250.0,
["wallrun_hangTimeLimit"] = 25.0,
["zipline_use_range"] = 120.0
}

global const table CSGO_MOVEMENT = 
{
	["acceleration"] = 550.0,
	["airacceleration"] = 225.0,
	["airspeed"] = 30.0,
	["antiMultiJumpHeightFrac"] = 1.0,
	["automantle"] = 0.0,
	["automantle_enable"] = 0.0,
	["climbEnabled"] = 0.0,
	["climbheight"] = 0.1,
	["gravityscale"] = 1.25,
	["jumpheight"] = 55.0,
	["player_slideBoostEnabled"] = 0.0,
	["skip_speed_reduce"] = 0.0,
	["skip_time"] = 0.0,
	["slideRequiredStartSpeed"] = 9999999.0,
	["slideRequiredStartSpeedAir"] = 9999999.0,
	["slideSpeedBoost"] = 0.0,
	["slideSpeedBoostCap"] = 0.0,
	["slideVelocityDecay"] = 0.0,
	["superjumpMinHeight"] = 0.0,
	["wallrun"] = 0.0
}

global const table CSGO_MOVEMENT_HIGH_AIRACCEL = 
{
	["acceleration"] = 550.0,
	["airacceleration"] = 9000.0,
	["airspeed"] = 30.0,
	["antiMultiJumpHeightFrac"] = 1.0,
	["automantle"] = 0.0,
	["automantle_enable"] = 0.0,
	["climbEnabled"] = 0.0,
	["climbheight"] = 0.1,
	["gravityscale"] = 1.25,
	["jumpheight"] = 55.0,
	["player_slideBoostEnabled"] = 0.0,
	["skip_speed_reduce"] = 0.0,
	["skip_time"] = 0.0,
	["slideRequiredStartSpeed"] = 9999999.0,
	["slideRequiredStartSpeedAir"] = 9999999.0,
	["slideSpeedBoost"] = 0.0,
	["slideSpeedBoostCap"] = 0.0,
	["slideVelocityDecay"] = 0.0,
	["superjumpMinHeight"] = 0.0,
	["wallrun"] = 0.0
}

global const table SURF_SETTINGS = 
{
	["airacceleration"] = 6000.0,
	["acceleration"] = 10.0,
	["airspeed"] = 60.0
}

global const table HL1_MOVEMENT = 
{
	["acceleration"] = 550.0,
	["airacceleration"] = 1200.0,
	["airspeed"] = 30.0,
	["antiMultiJumpHeightFrac"] = 1.0,
	["automantle"] = 0.0,
	["automantle_enable"] = 0.0,
	["climbEnabled"] = 0.0,
	["climbheight"] = 0.1,
	["gravityscale"] = 1.25,
	["jumpheight"] = 55.0,
	["player_slideBoostEnabled"] = 0.0,
	["skip_speed_reduce"] = 0.0,
	["slideRequiredStartSpeed"] = 9999999.0,
	["slideRequiredStartSpeedAir"] = 9999999.0,
	["slideSpeedBoost"] = 0.0,
	["slideSpeedBoostCap"] = 0.0,
	["slideVelocityDecay"] = 0.0,
	["superjumpMinHeight"] = 0.0,
	["wallrun"] = 0.0
}

global const table HALO_MOVEMENT_NEW = 
{
	["acceleration"] = 550.0,
	["airStrafeAcceleration"] = 0.0,
	["airStrafeEnabled"] = 0.0,
	["airStrafeTaperFinish"] = 0.01,
	["airStrafeTaperStart"] = 0.01,
	["airacceleration"] = 0.0,
	["airspeed"] = 0.0,
	["antiMultiJumpHeightFrac"] = 1.0,
	["automantle"] = 0.0,
	["automantle_enable"] = 0.0,
	["climbEnabled"] = 0.0,
	["climbheight"] = 0.0,
	["glideEnabled"] = 0.0,
	["glideRedirectJumpHeightFinishOffset"] = 0.0,
	["glideRedirectJumpHeightStartOffset"] = 0.0,
	["glideRedirectSideways"] = 0.0,
	["glideStrafe"] = 0.0,
	["glideStrafeTaperFinish"] = 0.0,
	["glideStrafeTaperStart"] = 0.0,
	["gravityscale"] = 0.7,
	["jumpheight"] = 65.0,
	["landslowdownduration"] = 0.0,
	["player_slideBoostEnabled"] = 0.0,
	["speed"] = 162.5,
	["sprintspeed"] = 243.0,
	["skip_speed_retain"] = 99999.0,
	["skip_speed_reduce"] = 0.0,
	["skip_time"] = 0.0,
	["slideRequiredStartSpeed"] = 9999999.0,
	["slideRequiredStartSpeedAir"] = 9999999.0,
	["slideSpeedBoost"] = 0.0,
	["slideSpeedBoostCap"] = 0.0,
	["slideVelocityDecay"] = 0.0,
	["superjumpCanUseAfterWallrun"] = 0.0,
	["superjumpMinHeight"] = 0.0,
	["wallrun"] = 0.0
}

global const table HALO_MOVEMENT = 
{
	["acceleration"] = 550.0,
	["airStrafeAcceleration"] = 0.0,
	["airStrafeEnabled"] = 0.0,
	["airStrafeTaperFinish"] = 0.01,
	["airStrafeTaperStart"] = 0.01,
	["airacceleration"] = 0.0,
	["airspeed"] = 0.0,
	["speed"] = 185.0,
	// ["sprintspeed"] = 210.0,//43.0,
	["antiMultiJumpHeightFrac"] = 1.0,
	["automantle"] = 0.0,
	["automantle_enable"] = 0.0,
	["climbEnabled"] = 0.0,
	["climbheight"] = 0.0,
	["glideEnabled"] = 0.0,
	["glideRedirectJumpHeightFinishOffset"] = 0.0,
	["glideRedirectJumpHeightStartOffset"] = 0.0,
	["glideRedirectSideways"] = 0.0,
	["glideStrafe"] = 0.0,
	["glideStrafeTaperFinish"] = 0.0,
	["glideStrafeTaperStart"] = 0.0,
	["gravityscale"] = 0.7,
	["jumpheight"] = 65.0,
	["landslowdownduration"] = 0.0,
	["player_slideBoostEnabled"] = 0.0,
	["skip_speed_reduce"] = 0.0,
	["skip_time"] = 0.0,
	["slideRequiredStartSpeed"] = 9999999.0,
	["slideRequiredStartSpeedAir"] = 9999999.0,
	["slideSpeedBoost"] = 0.0,
	["slideSpeedBoostCap"] = 0.0,
	["slideVelocityDecay"] = 0.0,
	["superjumpCanUseAfterWallrun"] = 0.0,
	["superjumpMinHeight"] = 0.0,
	["wallrun"] = 0.0
}

global const table SUPERGLIDE_BOOST_SETTINGS = 
{
	["airacceleration"] = 1000.0,
	["player_slideBoostEnabled"] = 1.0,
	["player_slideBoostCooldown"] = 0.01,
	["slideRequiredStartSpeedAir"] = 0.01,
	["slideRequiredStartSpeed"]= 0.01,
	["slideSpeedBoostCap"] = 2500.0,
	["slideSpeedBoost"] = 2500.0
}

global const table INSTAGIB_PLAYER_SETTINGS = 
{
	["acceleration"] = 550.0,
	["airacceleration"] = 1000.0,
	["airspeed"] = 150.0,
	["automantle_enable"] = 1.0,
	["doublejump"] = 0.0,
	["gravityscale"] = 0.85,
	["impactSpeed"] = 380.0,
	["jumpheight"] = 120.0,
	["landslowdownduration"] = 0.0,
	["leech_range"] = 64.0,
	["slidedecel"] = 50.0,
	["slidevelocitydecay"] = 0.7,
	["stepheight"] = 18.0,
	["superjumpHorzSpeed"] = 180.0,
	["superjumpMaxHeight"] = 60.0,
	["superjumpMinHeight"] = 60.0,
	["wallrun"] = 0.0,
	["wallrunAccelerateHorizontal"] = 1500.0,
	["wallrunAccelerateVertical"] = 360.0,
	["wallrunJumpInputDirSpeed"] = 80.0,
	["wallrunJumpOutwardSpeed"] = 205.0,
	["wallrunJumpUpSpeed"] = 230.0,
	["wallrunMaxSpeedHorizontal"] = 420.0,
	["wallrunMaxSpeedVertical"] = 225.0,
	["wallrun_timeLimit"] = 1.75,
	["ziplineSpeed"] = 600.0,
	["skip_time"] = 0.0,
	["antiMultiJumpHeightFrac"] = 1.0
}

global const table HAVEFUN_PLAYER_SETTINGS = 
{
	["airacceleration"] = 3000.0,
	["airspeed"] = 1000.0,
	["automantle_enable"] = 1.0,
	["doublejump"] = 0.0,
	["gravityscale"] = 0.35,
	["impactSpeed"] = 380.0,
	["jumpheight"] = 1000.0,
	["landslowdownduration"] = 0.0,
	["leech_range"] = 64.0,
	["stepheight"] = 18.0,
	["ziplineSpeed"] = 600.0,
	["wallrun"] = 0.0,
	["slidedecel"] = 50.0,
	["slidevelocitydecay"] = 0.7,
	["sprintspeed"] = 1000.0,
	["speed"] = 800.0,
	["superjumpMinHeight"] = 60.0,
	["superjumpMaxHeight"] = 60.0,
	["superjumpHorzSpeed"] = 180.0,
	["wallrun_timeLimit"] = 1.75,
	["wallrunJumpOutwardSpeed"] = 205.0,
	["wallrunJumpUpSpeed"] = 230.0,
	["wallrunJumpInputDirSpeed"] = 80.0,
	["wallrunMaxSpeedVertical"] = 225.0,
	["wallrunMaxSpeedHorizontal"] = 420.0,
	["wallrunAccelerateVertical"] = 360.0,
	["wallrunAccelerateHorizontal"] = 1500.0
}
