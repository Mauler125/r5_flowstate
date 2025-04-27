global function MpWeaponMountedTurretWeapon_Init
global function OnWeaponActivate_weapon_mounted_turret_weapon
global function OnWeaponDeactivate_weapon_mounted_turret_weapon
global function OnWeaponPrimaryAttack_weapon_mounted_turret_weapon
global function OnWeaponStartZoomIn_weapon_mounted_turret_weapon
global function OnWeaponStartZoomOut_weapon_mounted_turret_weapon
global function OnWeaponReload_weapon_mounted_turret_weapon
global function OnAnimEvent_weapon_mounted_turret_weapon
global function OnWeaponZoomFOVToggle_weapon_mounted_turret_weapon
global function OnAnimEvent_weapon_mobile_hmg


#if SERVER
global function MountedTurretWeapon_Play1pDamageFX
global function MountedTurretWeapon_Stop1pDamageFX
global function MountedTurretWeapon_SetPlayerLastSaidTurretChatterTime
#endif

#if CLIENT
global function OnClientAnimEvent_weapon_mounted_turret_weapon
#endif

global const string MOUNTED_TURRET_WEAPON_NAME = "mp_weapon_mounted_turret_weapon"

// Audio
const string TURRET_BUTTON_PRESS_SOUND_1P = "weapon_sheilaturret_triggerpull"
const string TURRET_BUTTON_PRESS_SOUND_3P = "weapon_sheilaturret_triggerpull_3p"
const string TURRET_BARREL_SPIN_LOOP_1P = "weapon_sheilaturret_motorloop_1p"
const string TURRET_BARREL_SPIN_LOOP_3P = "Weapon_sheilaturret_MotorLoop_3P"
const string TURRET_WINDUP_1P = "weapon_sheilaturret_windup_1p"
const string TURRET_WINDUP_3P = "weapon_sheilaturret_windup_3p"
const string TURRET_WINDDOWN_1P = "weapon_sheilaturret_winddown_1P"
const string TURRET_WINDDOWN_3P = "weapon_sheilaturret_winddown_3P"
const string TURRET_RELOAD_3P = "weapon_sheilaturret_reload_generic_comp_3p"
const string TURRET_RELOAD_RAMPART_3P = "weapon_sheilaturret_reload_rampart_comp_3p"
                    
const string TURRET_RELOAD_RAMPART_UPGRADE_3P = "weapon_sheilaturret_reload_rampart_comp_upgraded_3p"
      
const string TURRET_RELOAD = "weapon_sheilaturret_reload_rampart_null"
const string TURRET_FIRED_LAST_SHOT_1P = "weapon_sheilaturret_lastshot_1p"
const string TURRET_FIRED_LAST_SHOT_3P = "weapon_sheilaturret_lastshot_3p"
const string TURRET_DISMOUNT_1P = "weapon_sheilaturret_dismount_1p"
const string TURRET_SIGHT_FLIP_UP_1P = "weapon_sheilaturret_sightflipup"
const string TURRET_SIGHT_FLIP_DOWN_1P = "weapon_sheilaturret_sightflipdown"

const string TURRET_DRAWFIRST_1P = "weapon_sheilaturret_drawfirst_1p"
const string TURRET_DRAW_1P = "weapon_sheilaturret_draw_1p"

// Dialogue
const float GLOBAL_TURRET_CHATTER_DEBOUNCE = 7.0
const float SUSTAINED_FIRE_QUIP_CHANCE = 0.15

// FX
const TURRET_1P_DAMAGE_FX_ATTACH	= "__illumPosition"
const TURRET_DAMAGE_FX_1P			= $"P_ramp_tur_dmg_FP"
const TURRET_LASER_1P				= $"P_wpn_lasercannon_aim_long"

struct
{
	int turret1pDamageFxIndex = -1

	#if SERVER
	entity turret1pDamageFxEnt = null
	table< entity, bool > hasBeenFired
	table< entity, float > playerLastSaidTurretChatterTime
	#endif

	#if CLIENT
		int laserFXHandle = -1
	#endif

} file

void function MpWeaponMountedTurretWeapon_Init()
{
	RegisterWeaponForUse( MOUNTED_TURRET_WEAPON_NAME )
	//RegisterAdditionalMainWeapon( MOUNTED_TURRET_WEAPON_NAME )

	PrecacheParticleSystem( TURRET_LASER_1P )
	PrecacheParticleSystem( $"P_muzzleflash_laserturret" )
	PrecacheParticleSystem( $"P_muzzleflash_laserturret" )
	PrecacheParticleSystem( $"P_muzzleflash_laserturret" )
	file.turret1pDamageFxIndex = PrecacheParticleSystem( TURRET_DAMAGE_FX_1P )

	RegisterSignal( "DeactivateMountedTurret" )
}

void function OnWeaponActivate_weapon_mounted_turret_weapon( entity weapon )
{
	OnWeaponActivate_weapon_basic_bolt( weapon )

#if CLIENT
	if ( InPrediction() && IsFirstTimePredicted() )
#endif
	{
		//weapon.SetTargetingLaserEnabled( false )
	}

#if SERVER
	entity weaponOwner = weapon.GetOwner()
	weaponOwner.LockWeaponChange()
	DisableOffhandWeapons( weaponOwner )

	if ( ! ( weapon in file.hasBeenFired ) )
		file.hasBeenFired[weapon] <- false

	//if ( IsValid( weaponOwner.p.mountedTurretEnt ) && weaponOwner.p.mountedTurretEnt.GetHealth() <= weaponOwner.p.mountedTurretEnt.GetMaxHealth() / 2.0 )
	{
		//MountedTurretWeapon_Play1pDamageFX( weapon )
	}

	int clipCount = weapon.GetWeaponPrimaryClipCount()
	int lastCount = clipCount//MountedTurretPlaceable_GetLastAmmoCount( weaponOwner.p.mountedTurretEnt )
	int newAmmoCount = maxint( clipCount, lastCount )
	newAmmoCount = minint( newAmmoCount, weapon.GetWeaponPrimaryClipCountMax() )
	//weapon.SetWeaponPrimaryClipCount_MaintainReloadProgress( newAmmoCount )

	TryPlayTurretChatterLine( weaponOwner, "bc_rampart_getOnHMG" )

	                    
	//if( weaponOwner.HasPassive( ePassives.PAS_GUNNER ) && weaponOwner.HasPassive( ePassives.PAS_PAS_UPGRADE_TWO ) ) // upgrade_rampart_fast_reloads
	{
		//weapon.AddMod( "upgrade_ult_one" )
	}
       
#endif // SERVER

#if CLIENT
	if( IsValid ( GetCompassRui() ) && IsValid( weapon.GetOwner() ) )
	{
		if( weapon.GetOwner() == GetLocalClientPlayer() )
		{
			//RuiSetBool( GetCompassRui(), "showCompassAreaModifier", true )
			//RuiTrackFloat( GetCompassRui(), "viewConeMin", weapon.GetOwner(), RUI_TRACK_VIEWCONE_MINYAW )
			//RuiTrackFloat( GetCompassRui(), "viewConeMax", weapon.GetOwner(), RUI_TRACK_VIEWCONE_MAXYAW )
		}
	}
#endif

	#if SERVER
                       
                                           
        
	#endif
}

void function OnWeaponDeactivate_weapon_mounted_turret_weapon( entity weapon )
{
	weapon.StopWeaponSound( TURRET_BARREL_SPIN_LOOP_1P )
	weapon.StopWeaponSound( TURRET_BARREL_SPIN_LOOP_3P )
	weapon.StopWeaponSound( TURRET_BUTTON_PRESS_SOUND_1P )
	weapon.StopWeaponSound( TURRET_BUTTON_PRESS_SOUND_3P )
	StopSoundOnEntity( weapon, TURRET_WINDUP_1P )
	StopSoundOnEntity( weapon, TURRET_WINDUP_3P )
	StopSoundOnEntity( weapon, TURRET_WINDDOWN_1P )
	StopSoundOnEntity( weapon, TURRET_RELOAD_3P )
	StopSoundOnEntity( weapon, TURRET_RELOAD_RAMPART_3P )
	                    
		StopSoundOnEntity( weapon, TURRET_RELOAD_RAMPART_UPGRADE_3P )
       

#if SERVER
	MountedTurretWeapon_Stop1pDamageFX()
	//entity parentTurret = weapon.GetParentTurretEnt()
	//if( IsValid( parentTurret ) )
	{
		//MountedTurretPlaceable_SetLastAmmoCount( parentTurret, weapon.GetWeaponPrimaryClipCount() )
	}

	                    
	if( weapon.HasMod( "upgrade_ult_one" ) )
	{
		weapon.RemoveMod( "upgrade_ult_one" )
	}
       
#endif // SERVER

	entity weaponOwner = weapon.GetOwner()

	if ( !IsValid( weaponOwner ) )
		return

	StopSoundOnEntity( weaponOwner, TURRET_DRAWFIRST_1P )
	StopSoundOnEntity( weaponOwner, TURRET_DRAW_1P )

#if SERVER
	weaponOwner.UnlockWeaponChange()
	EnableOffhandWeapons( weaponOwner )
#endif // SERVER

#if CLIENT
	SetTurretVMLaserEnabled( weapon, false )

	if ( weaponOwner == GetLocalViewPlayer() )
	{
		EmitSoundOnEntity( weaponOwner, TURRET_DISMOUNT_1P )
	}

	if ( IsValid( GetCompassRui() ) )
	{
		if ( weaponOwner == GetLocalClientPlayer() )
		{
			//RuiSetBool( GetCompassRui(), "showCompassAreaModifier", false )
			//RuiSetFloat( GetCompassRui(), "viewConeMin", 0 )
			//RuiSetFloat( GetCompassRui(), "viewConeMax", 0 )
		}
	}
#endif // CLIENT

	weaponOwner.Signal( "DeactivateMountedTurret" )

#if CLIENT
	if ( InPrediction() && IsFirstTimePredicted() )
#endif
	{
		//weapon.SetTargetingLaserEnabled( false )
	}

	#if SERVER
                       
                                             
        
	#endif
}


void function OnWeaponStartZoomIn_weapon_mounted_turret_weapon( entity weapon )
{
	entity weaponOwner = weapon.GetWeaponOwner()

	if ( !IsValid( weaponOwner ) )
		return

	float zoomFrac = weaponOwner.GetZoomFrac()
	float zoomTimeIn = weapon.GetWeaponSettingFloat( eWeaponVar.zoom_time_in )

	#if SERVER
		EmitSoundOnEntityExceptToPlayerWithSeek( weapon, weaponOwner, TURRET_WINDUP_3P, zoomFrac * zoomTimeIn )
	#endif
	#if CLIENT
		if ( weaponOwner == GetLocalViewPlayer() )
		{
			EmitSoundOnEntityWithSeek( weapon, TURRET_WINDUP_1P, zoomFrac * zoomTimeIn )

			if ( !InPrediction() || IsFirstTimePredicted() )
			{
				SetTurretVMLaserEnabled( weapon, true )
			}
		}
	#endif

#if CLIENT
	if ( InPrediction() && IsFirstTimePredicted() )
#endif
	{
		//weapon.SetTargetingLaserEnabled( true )
	}
}

void function OnWeaponStartZoomOut_weapon_mounted_turret_weapon( entity weapon )
{
	weapon.StopWeaponSound( TURRET_BARREL_SPIN_LOOP_1P )
	weapon.StopWeaponSound( TURRET_BARREL_SPIN_LOOP_3P )
	weapon.StopWeaponSound( TURRET_BUTTON_PRESS_SOUND_1P )
	weapon.StopWeaponSound( TURRET_BUTTON_PRESS_SOUND_3P )
	StopSoundOnEntity( weapon, TURRET_WINDUP_1P )
	StopSoundOnEntity( weapon, TURRET_WINDUP_3P )

	entity weaponOwner = weapon.GetWeaponOwner()
	entity turretEnt = weaponOwner.GetActiveWeapon( eActiveInventorySlot.mainHand )

	if ( !IsValid( weaponOwner ) )
		return

	float zoomFrac = weaponOwner.GetZoomFrac()
	float zoomOutTime = weapon.GetWeaponSettingFloat( eWeaponVar.zoom_time_out )

	if ( IsValid( turretEnt ) )
	{
		#if SERVER
			EmitSoundOnEntityExceptToPlayerWithSeek( turretEnt, weaponOwner, TURRET_WINDDOWN_3P, (1 - zoomFrac) * zoomOutTime )
		#endif
		#if CLIENT
			SetTurretVMLaserEnabled( weapon, false )

			if ( weaponOwner == GetLocalViewPlayer() )
				EmitSoundOnEntityWithSeek( turretEnt, TURRET_WINDDOWN_1P, (1 - zoomFrac) * zoomOutTime )
		#endif
	}

#if CLIENT
	if ( InPrediction() && IsFirstTimePredicted() )
#endif
	{
		//weapon.SetTargetingLaserEnabled( false )
	}
}

var function OnWeaponPrimaryAttack_weapon_mounted_turret_weapon( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity weaponOwner = weapon.GetOwner()

	if ( !IsValid( weaponOwner ) )
		return 0


	if ( weapon.IsWeaponInAds() && weaponOwner.GetZoomFrac() >= 1.0 )
	{
		// Dialogue
		#if SERVER
			if ( weapon.GetWeaponPrimaryClipCount() == ( weapon.GetWeaponPrimaryClipCountMax() / 2 ) )
				TryPlayTurretChatterLine( weaponOwner, "bc_rampart_clipHalfFull" )

			if ( weapon.GetShotCount() >= 20 && weapon.GetShotCount() % 20 == 0 && RandomFloat( 1.0 ) < SUSTAINED_FIRE_QUIP_CHANCE )
				TryPlayTurretChatterLine( weaponOwner, "bc_rampart_sustainedFire" )
		#endif // SERVER

		// Audio
		if ( weapon.GetWeaponPrimaryClipCount() == 1 )
		{
			#if SERVER
				EmitSoundOnEntityExceptToPlayer( weapon, weaponOwner, TURRET_FIRED_LAST_SHOT_3P )
			#elseif CLIENT
				if ( weaponOwner == GetLocalViewPlayer() )
					EmitSoundOnEntity( weapon, TURRET_FIRED_LAST_SHOT_1P )
			#endif
		}

		// Refund
		if ( weapon.GetWeaponPrimaryClipCount() == weapon.GetWeaponPrimaryClipCountMax() )
		{
			#if SERVER
				//MountedTurretPlaceable_SetEligibleForRefund( weaponOwner.p.mountedTurretEnt, false )
				file.hasBeenFired[ weapon ] <- true
			#elseif CLIENT
				entity turretEnt = GetPlaceableTurretEntForPlayer( weaponOwner )
				//if ( IsValid( turretEnt ) )
					//MountedTurretPlaceable_SetEligibleForRefund( GetPlaceableTurretEntForPlayer( weaponOwner ), false )
			#endif
		}

		//	Rampart unique tracker
		#if SERVER
			entity literalWeaponOwner = weapon.GetWeaponOwner()
			if ( IsValid( literalWeaponOwner ) )
			{
				//entity turretEntity = literalWeaponOwner.GetTurret()
				//if ( IsValid( turretEntity ) )
				{
					//entity turretOwner = turretEntity.GetOwner()
					//if ( IsValid( turretOwner ) )
					{
						//StatsHook_RampartUltimate_OnBulletFired( turretOwner )
					}
				}
			}
		#endif

		return OnWeaponPrimaryAttack_weapon_basic_bolt( weapon, attackParams )
	}
	else
	{
		return 0
	}
}

void function OnWeaponReload_weapon_mounted_turret_weapon( entity weapon, int milestoneIndex )
{
	#if SERVER

		int reloadTimeLateVar = -1
		switch ( milestoneIndex )
		{
			case 1:
				reloadTimeLateVar = eWeaponVar.reload_time_late1
				break
			case 2:
				reloadTimeLateVar = eWeaponVar.reload_time_late2
				break
			case 3:
				reloadTimeLateVar = eWeaponVar.reload_time_late3
				break
			case 4:
				reloadTimeLateVar = eWeaponVar.reload_time_late4
				break
			case 5:
				reloadTimeLateVar = eWeaponVar.reload_time_late5
				break
		}

		float seekTime
		seekTime = ( reloadTimeLateVar > -1 ) ? weapon.GetWeaponSettingFloat( eWeaponVar.reload_time ) - weapon.GetWeaponSettingFloat( reloadTimeLateVar ) : 0.0

		/*if ( weapon.HasMod( GUNNER_MOD_NAME ) )
		{
			                    
			entity weaponOwner = weapon.GetWeaponOwner()
			if ( !IsValid( weaponOwner ) )
				return

			if ( PlayerHasPassive( weaponOwner, ePassives.PAS_PAS_UPGRADE_TWO ) ) // upgrade_rampart_fast_reloads
				EmitSoundOnEntityExceptToPlayerWithSeek( weapon, weapon.GetOwner(), TURRET_RELOAD_RAMPART_UPGRADE_3P, seekTime )
			else
         
				EmitSoundOnEntityExceptToPlayerWithSeek( weapon, weapon.GetOwner(), TURRET_RELOAD_RAMPART_3P, seekTime )
		}
		else*/
			EmitSoundOnEntityExceptToPlayerWithSeek( weapon, weapon.GetOwner(), TURRET_RELOAD_3P, seekTime )
	#endif
}

void function OnAnimEvent_weapon_mounted_turret_weapon( entity weapon, string eventName )
{
#if CLIENT
	//if ( !weapon.IsPredicted() )
		//return
#endif

	switch ( eventName )
	{
		case "rampart_turret_button_press":
			weapon.EmitWeaponSound_1p3p( TURRET_BUTTON_PRESS_SOUND_1P, TURRET_BUTTON_PRESS_SOUND_3P )
			break
		case "rampart_turret_spin_up":
			weapon.EmitWeaponSound_1p3p( TURRET_BARREL_SPIN_LOOP_1P, TURRET_BARREL_SPIN_LOOP_3P )
			break
		default:
			return
	}
}

void function OnWeaponZoomFOVToggle_weapon_mounted_turret_weapon( entity weapon, float targetFOV )
{
	#if CLIENT
	if ( weapon.GetOwner() != GetLocalViewPlayer() )
		return

	if ( targetFOV == weapon.GetWeaponSettingFloat( eWeaponVar.zoom_fov ) ) // base zoom
	{
		EmitSoundOnEntity( weapon, TURRET_SIGHT_FLIP_DOWN_1P )
		StopSoundOnEntity( weapon, TURRET_SIGHT_FLIP_UP_1P )
	}
	else // zoom in
	{
		EmitSoundOnEntity( weapon, TURRET_SIGHT_FLIP_UP_1P )
		StopSoundOnEntity( weapon, TURRET_SIGHT_FLIP_DOWN_1P )
	}
	#endif
}

void function OnAnimEvent_weapon_mobile_hmg( entity weapon, string eventName )
{
#if CLIENT
	//if ( !weapon.IsPredicted() )
		//return
#endif

	switch ( eventName )
	{
		case "rampart_turret_mobile_button_press":
			weapon.EmitWeaponSound_1p3p( TURRET_BUTTON_PRESS_SOUND_1P, TURRET_BUTTON_PRESS_SOUND_3P )
			break
		case "rampart_turret_mobile_spin_up":
			weapon.EmitWeaponSound_1p3p( TURRET_BARREL_SPIN_LOOP_1P, TURRET_BARREL_SPIN_LOOP_3P )
			break
		default:
			return
	}
}

#if SERVER
void function MountedTurretWeapon_Play1pDamageFX( entity weapon )
{
	entity vm = weapon.GetWeaponViewmodel()

	if ( IsValid( file.turret1pDamageFxEnt ) )
		EffectStop( file.turret1pDamageFxEnt )

	file.turret1pDamageFxEnt = StartParticleEffectOnEntityWithPos_ReturnEntity( vm, file.turret1pDamageFxIndex, FX_PATTACH_POINT_FOLLOW, vm.LookupAttachment( TURRET_1P_DAMAGE_FX_ATTACH ), <0, 0, 0>, <0, 0, 0> )
	if ( IsValid( file.turret1pDamageFxEnt )  )
		file.turret1pDamageFxEnt.SetStopType( "destroyImmediately" )
}

void function MountedTurretWeapon_Stop1pDamageFX()
{
	if ( IsValid( file.turret1pDamageFxEnt ) )
		EffectStop( file.turret1pDamageFxEnt )

	file.turret1pDamageFxEnt = null
}

void function MountedTurretWeapon_SetPlayerLastSaidTurretChatterTime( entity player, float time )
{
	file.playerLastSaidTurretChatterTime[player] <- time
}

void function TryPlayTurretChatterLine( entity player, string line )
{
	if ( !PlayerIsEligibleToPlayTurretChatter( player ) )
		return

	PlayBattleChatterLineToSpeakerAndTeam( player, line )
	MountedTurretWeapon_SetPlayerLastSaidTurretChatterTime( player, Time() )

}

bool function PlayerIsEligibleToPlayTurretChatter( entity player )
{
	if ( !IsValid( player ) )
		return false

	if ( ! ( GetPlayerVoice( player ) == "rampart" ) )
		return false

	return !( player in file.playerLastSaidTurretChatterTime ) || ( Time() - file.playerLastSaidTurretChatterTime[player] > GLOBAL_TURRET_CHATTER_DEBOUNCE )
}
#endif

#if CLIENT
void function OnClientAnimEvent_weapon_mounted_turret_weapon( entity weapon, string eventName )
{
	GlobalClientEventHandler( weapon, eventName )

	OnAnimEvent_weapon_mounted_turret_weapon( weapon, eventName )
	//OnClientAnimEvent_weapon_basic_bolt( weapon, eventName )

	if ( eventName == "muzzle_flash" )
		weapon.PlayWeaponEffect( $"wpn_muzzleflash_snp_hmn_FP", $"", "muzzle_flash" )
}

void function SetTurretVMLaserEnabled( entity weapon, bool enabled )
{
	if ( !IsValid( weapon ) )
		return

	entity vm = weapon.GetWeaponViewmodel()

	int fxid = GetParticleSystemIndex( TURRET_LASER_1P )

	if ( enabled )
	{
		if ( file.laserFXHandle > -1 )
			SetTurretVMLaserEnabled( weapon, false )

		file.laserFXHandle = StartParticleEffectOnEntityWithPos( vm, fxid, FX_PATTACH_POINT_FOLLOW, vm.LookupAttachment( "LASER" ), <0,0,0>, <0,0,0> )
	}
	else
	{
		if ( file.laserFXHandle > -1 )
		{
			EffectStop( file.laserFXHandle, true, true )
			file.laserFXHandle = -1
		}
	}

}

entity function GetPlaceableTurretEntForPlayer( entity player )
{
	//if ( player.GetParent().GetScriptName() == MOUNTED_TURRET_PLACEABLE_SCRIPT_NAME )
		//return player.GetParent()

	return null
}
#endif // CLIENT