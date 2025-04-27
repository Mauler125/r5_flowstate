global function MpWeapon3030_Init

global function OnWeaponActivate_weapon_3030
global function OnWeaponDeactivate_weapon_3030
global function OnWeaponChargeLevelIncreased_weapon_3030
global function OnWeaponChargeEnd_weapon_3030
global function OnWeaponPrimaryAttack_weapon_3030
global function OnProjectileCollision_weapon_3030
global function OnWeaponReload_weapon_3030
global function OnWeaponReadyToFire_weapon_3030
#if CLIENT
global function OnClientAnimEvent_weapon_3030
#endif

const string ADS_MOD = "in_ads"
const string CHARGED_MOD = "charged"
const string ADS_THINK_THREAD_ABORT_SIGNAL = "ads_think_abort"
const float ADS_MOD_ZOOM_FRAC_REQUIRED = 0.5

const string HAMMER_THREAD_ABORT_SIGNAL = "hammer_thread_abort"
const string HAMMER_OPEN_CL_ANIM_EVENT = "weapon_3030_open_hammer"
const float HAMMER_CLOSE_LERP_TIME = 0.0
const float HAMMER_OPEN_LERP_TIME = 0.0

const int SEGMENTED_SPEED_RELOAD_COUNT = 3

struct
{
	EnergyChargeWeaponData chargeWeaponData
} file

void function MpWeapon3030_Init()
{
	RegisterSignal( ADS_THINK_THREAD_ABORT_SIGNAL )
	RegisterSignal( HAMMER_THREAD_ABORT_SIGNAL )
}

void function OnWeaponActivate_weapon_3030( entity weapon )
{
	#if SERVER
		entity player = weapon.GetWeaponOwner()
		if ( !IsValid( player ) )
			return

		Dev_PrintMessage( player, "CAUTION: Unfinished Weapon Equipped!", "This weapon is unfinished and not ready to use. Can cause visual glitches, script errors or engine crashes. Proceed with caution." )

		if ( weapon.HasMod( CHARGED_MOD ) )
			weapon.RemoveMod( CHARGED_MOD )

		thread ADSThinkThread( player, weapon )
	#endif
	#if CLIENT
		if ( InPrediction() )
		{
			if ( weapon.GetWeaponPrimaryClipCount() == 0 )
			{
				thread CloseHammerThread( weapon, true )
			}
			else
			{
				thread OpenHammerThread( weapon, true )
			}
		}
	#endif

	//thread ShatterRounds_UpdateShatterRoundsThink( weapon )
	#if SERVER
	//if( weapon.HasMod( SHATTER_ROUNDS_HOPUP_MOD ) )
		//thread ShatterRounds_ADSThink ( player, weapon )
	//else
		//weapon.RemoveMod( SHATTER_ROUNDS_HIPFIRE_MOD )
	#endif




}

void function OnWeaponDeactivate_weapon_3030( entity weapon )
{
	#if SERVER
		weapon.Signal( ADS_THINK_THREAD_ABORT_SIGNAL )
		weapon.RemoveMod( ADS_MOD )
	#endif
	#if CLIENT
		if ( InPrediction() )
		{
			weapon.Signal( HAMMER_THREAD_ABORT_SIGNAL )
		}
		//weapon.Signal( SHATTER_ROUNDS_THINK_END_SIGNAL )

		#if SERVER
		//weapon.Signal( SHATTER_ROUNDS_ADS_THINK_THREAD_ABORT_SIGNAL )
		#endif
	#endif



}

#if SERVER
void function ADSThinkThread( entity player, entity weapon )
{
	AssertIsNewThread()
	player.EndSignal( "OnDeath" )
	weapon.EndSignal( "OnDestroy" )
	weapon.EndSignal( ADS_THINK_THREAD_ABORT_SIGNAL )

	OnThreadEnd(
		function() : ( player, weapon )
		{
			if ( IsValid( weapon ) )
				weapon.RemoveMod( ADS_MOD )
		}
	)

	while ( true )
	{
		if ( !IsValid( weapon ) || !IsValid( player ) )
			return

		if ( weapon.IsWeaponInAds() && player.GetZoomFrac() >= ADS_MOD_ZOOM_FRAC_REQUIRED )
		{
			if ( !weapon.HasMod( ADS_MOD ) )
				weapon.AddMod( ADS_MOD )
		}
		else if ( weapon.HasMod( ADS_MOD ) )
		{
			weapon.RemoveMod( ADS_MOD )
		}

		float chargeFrac = weapon.GetWeaponChargeFraction()
		weapon.SetSoundCodeControllerValue( chargeFrac )

		WaitFrame()
	}
}

#endif //SERVER

#if CLIENT
void function OnClientAnimEvent_weapon_3030( entity weapon, string name )
{
	GlobalClientEventHandler( weapon, name )

	if ( name == HAMMER_OPEN_CL_ANIM_EVENT )
	{
		thread OpenHammerThread( weapon, false )
	}
}

void function CloseHammerThread( entity weapon, bool skipLerp )
{
	weapon.Signal( HAMMER_THREAD_ABORT_SIGNAL )

	entity player = weapon.GetWeaponOwner()
	if ( !IsValid( player ) )
		return

	player.EndSignal( "OnDeath" )
	weapon.EndSignal( "OnDestroy" )
	weapon.EndSignal( HAMMER_THREAD_ABORT_SIGNAL )

	float startTime = Time()
	float endTime   = startTime + HAMMER_CLOSE_LERP_TIME

	while( true )
	{
		float poseParam = GraphCapped( Time(), startTime, endTime, 0.0, 1.0 )
		poseParam = (skipLerp) ? 1.0 : poseParam
		//weapon.LookupPoseParameterIndex( poseParam )
		WaitFrame()
	}
}

void function OpenHammerThread( entity weapon, bool skipLerp )
{
	weapon.Signal( HAMMER_THREAD_ABORT_SIGNAL )

	entity player = weapon.GetWeaponOwner()
	if ( !IsValid( player ) )
		return

	player.EndSignal( "OnDeath" )
	weapon.EndSignal( "OnDestroy" )
	weapon.EndSignal( HAMMER_THREAD_ABORT_SIGNAL )

	float startTime = Time()
	float endTime   = startTime + HAMMER_OPEN_LERP_TIME

	while( true )
	{
		float poseParam = GraphCapped( Time(), startTime, endTime, 1.0, 0.0 )
		poseParam = (skipLerp) ? 0.0 : poseParam
		//weapon.SetScriptPoseParam0( poseParam )
		WaitFrame()
	}
}
#endif
bool function OnWeaponChargeLevelIncreased_weapon_3030( entity weapon )
{
	if (weapon.GetWeaponChargeLevel() == 2)
	{
		if ( !weapon.HasMod( CHARGED_MOD ) )
			weapon.AddMod( CHARGED_MOD )
	}

	return EnergyChargeWeapon_OnWeaponChargeLevelIncreased( weapon, file.chargeWeaponData )
}

void function OnWeaponChargeEnd_weapon_3030( entity weapon )
{
	if ( weapon.HasMod( CHARGED_MOD ) )
		weapon.RemoveMod( CHARGED_MOD )

	EnergyChargeWeapon_OnWeaponChargeEnd( weapon, file.chargeWeaponData )
}

var function OnWeaponPrimaryAttack_weapon_3030( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	bool ignoreSpread = true//weapon.HasMod( SHATTER_ROUNDS_HIPFIRE_MOD )
	weapon.FireWeapon_Default( attackParams.pos, attackParams.dir, 1.0, 1.0, ignoreSpread )
	#if CLIENT
		if ( InPrediction() )
		{
			thread CloseHammerThread( weapon, false )
		}
	#endif
	return weapon.GetWeaponSettingInt( eWeaponVar.ammo_per_shot )
}

void function OnProjectileCollision_weapon_3030( entity projectile, vector pos, vector normal, entity hitEnt, int hitBox, bool isCritical, bool isPassthrough )
{



}

void function OnWeaponReload_weapon_3030( entity weapon, int milestoneIndex )
{
	int reloadCount = weapon.GetScriptInt0( )

	if ( reloadCount >= SEGMENTED_SPEED_RELOAD_COUNT )
	{
		weapon.AddMod ("segmented_speed_load")
	}

	weapon.SetScriptInt0( reloadCount + 1 )
}

void function OnWeaponReadyToFire_weapon_3030( entity weapon )
{
	if ( weapon.HasMod( "segmented_speed_load" ) )
	{
		if ( !weapon.IsReloading() )
		{
			weapon.RemoveMod( "segmented_speed_load" )
		}
	}
	if ( !weapon.IsReloading() )
	{
		weapon.SetScriptInt0( 0 )
	}
}