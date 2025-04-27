//-----------------------------------------------------------------------------
// Overview: Supports triggering a respawn beacon dynamically in the world.
// Tombstone respawn is very similar functionally, so it shares a lot of
// the same script logic.
//-----------------------------------------------------------------------------
global function MobileRespawnBeacon_Init
global function OnWeaponActivate_mobile_respawn
global function OnWeaponDeactivate_mobile_respawn
global function OnWeaponPrimaryAttack_mobile_respawn
global function OnWeaponPrimaryAttackAnimEvent_mobile_respawn
global function GetRespawnStationUseTime_Mobile
//global function MobileRespawn_SetDeployPositionValidationFunc

#if SERVER
global function RespawnBeaconStartUse_Mobile
global function RespawnBeaconStopUse_Mobile
global function RespawnUserTeam_Mobile
global function RespawnBeacon_SpawnMobileBeacon
global function RespawnBeacon_AddCallback_OnMobileRespawnBeaconDeployTriggered
#endif

#if SERVER && DEVELOPER
global function DEV_Spawn_MobileRespawnBeacon
#endif // SERVER && DEVELOPER
const string VOID_RING_PROP_SCRIPTNAME = "void_ring"

//-----------------------------------------------------------------------------
// Variables
//-----------------------------------------------------------------------------
global const string MOBILE_RESPAWN_BEACON_WEAPON_REF = "mp_ability_mobile_respawn_beacon"

const string MOBILE_RESPAWN_BEACON_STARTUP_SOUND = "Survival_MobileRespawnBeacon_Startup"
const string MOBILE_RESPAWN_INTERACT_PULSATE_SOUND = "Survival_RespawnEquippedBeacon_Full_Extended" // "Survival_RespawnEquippedBeacon_Full"

const asset MOBILE_RESPAWN_BEACON_MODEL = $"mdl/props/mobile_respawn_beacon/mobile_respawn_beacon_animated.rmdl"
const asset MOBILE_RESPAWN_BEACON_EFFECT = $"P_mrb_holo"
const asset MOBILE_RESPAWN_BEACON_AR_DROP_POINT_FX = $"P_ar_loot_drop_point"
const asset MOBILE_RESPAWN_BEACON_AB_FX = $"P_mrb_afterburner"
const asset MOBILE_RESPAWN_BEACON_AB_LIGHTS_FX = $"P_mrb_ab_lights"
const asset MOBILE_RESPAWN_BEACON_COUNTDOWN_PULSE_FX = $"P_mrb_countdown_pulse"
const asset MOBILE_RESPAWN_BEACON_SMOKE_TRAIL = $"droppod_trail_smoke_linger"
const bool MOBILE_RESPAWN_BEACON_DEBUG_DRAW = false
const float MOBILE_RESPAWN_BEACON_DESTROY_PROP_RADIUS = 25 	// Distance around the landing mbr where non player entities will be destroyed - made small so less likely to kill the player
const int MOBILE_RESPAWN_BEACON_BAD_AIRSPACE_RADIUS = 150 	// Don't allow another beacon to go in this location
const string MOBILE_RESPAWN_BEACON_IMPACT_TABLE = "mobile_respawn_beacon"
const float MOBILE_RESPAWN_BEACON_SLOPED_LANDING_LIMIT = 0.3 	// Slope > this value triggers a closed landing

const string MOBILE_RESPAWN_BEACON_MOVER_SCRIPTNAME = "mobile_respawn_beacon_mover"

struct
{
	bool mobileRespawnDeployed

	table< entity, vector > savedSlopeNormal
	#if SERVER
		table<entity, entity> countdownPulseFX
		array< void functionref(entity) > Callbacks_OnMobileRespawnBeaconDeployTriggered
	#endif

	//CarePackagePlacementInfo functionref( entity ) deployPositionValidationFunc
} file

//-----------------------------------------------------------------------------
// Functions
//-----------------------------------------------------------------------------
void function MobileRespawnBeacon_Init()
{
	//PrecacheScriptString( MOBILE_RESPAWN_BEACON_SCRIPTNAME )

	SURVIVAL_Loot_RegisterConditionalCheck( MOBILE_RESPAWN_BEACON_WEAPON_REF, MobileRespawn_ConditionalCheck )
	PrecacheModel( MOBILE_RESPAWN_BEACON_MODEL )
	PrecacheParticleSystem( MOBILE_RESPAWN_BEACON_EFFECT )
	PrecacheParticleSystem( MOBILE_RESPAWN_BEACON_AR_DROP_POINT_FX )
	PrecacheParticleSystem( MOBILE_RESPAWN_BEACON_AB_FX )
	PrecacheParticleSystem( MOBILE_RESPAWN_BEACON_AB_LIGHTS_FX )
	PrecacheParticleSystem( MOBILE_RESPAWN_BEACON_COUNTDOWN_PULSE_FX )
	PrecacheParticleSystem( MOBILE_RESPAWN_BEACON_SMOKE_TRAIL )
	PrecacheImpactEffectTable( MOBILE_RESPAWN_BEACON_IMPACT_TABLE )
	PrecacheImpactEffectTable( "mobile_respawn_dust" )
	RegisterSignal( "MobileBeaconLanded" )
	//MobileRespawn_SetDeployPositionValidationFunc( GetCarePackagePlacementInfo )

	#if CLIENT
		RegisterSignal( "MobileRespawnPlacement" )
	#endif
}

//void function MobileRespawn_SetDeployPositionValidationFunc( CarePackagePlacementInfo functionref( entity ) validationFunc )
//{
//	file.deployPositionValidationFunc = validationFunc
//}

void function OnWeaponActivate_mobile_respawn( entity weapon )
{
	entity ownerPlayer = weapon.GetWeaponOwner()
	Assert( ownerPlayer.IsPlayer() )

	#if CLIENT

		if ( ownerPlayer == GetLocalViewPlayer() )
		{
			RunUIScript( "CloseSurvivalInventoryMenu" )
		}

		string name = weapon.GetWeaponClassName()

			{
				OnBeginPlacingMobileRespawn( weapon, ownerPlayer )

				if ( !InPrediction() ) //Stopgap fix for Bug 146443
					return
			}
	#endif // CLIENT

	int skinIndex = weapon.GetSkinIndexByName( "mobile_respawn_beacon_clacker" )
	if ( skinIndex != -1 )
		weapon.SetSkin( skinIndex )
}

void function OnWeaponDeactivate_mobile_respawn( entity weapon )
{
	entity ownerPlayer = weapon.GetWeaponOwner()
	Assert( ownerPlayer.IsPlayer() )

	#if CLIENT
		SetBeaconDeployed( false )
		OnEndPlacingMobileRespawn( ownerPlayer )
		if ( !InPrediction() ) //Stopgap fix for Bug 146443
			return
	#endif
}

#if SERVER
void function AutoEquipInventoryItem( entity takeWeapon, entity ownerPlayer )
{
	wait 0.2
	ownerPlayer.TakeWeaponByEnt( takeWeapon )

	// We need to call this so the mobile respawn beacon can be taken out of the slot (it stays linked to the hotkey otherwise)
	// It also re-populates the slot with an ordnance.
	waitthread SURVIVAL_AutoEquipOrdnanceFromInventory( ownerPlayer, false )
	ownerPlayer.SetActiveWeaponBySlot( eActiveInventorySlot.mainHand, WEAPON_INVENTORY_SLOT_PRIMARY_2 )
	Remote_CallFunction_Replay( ownerPlayer, "ServerCallback_RefreshInventoryAndWeaponInfo" )
}
#endif

var function OnWeaponPrimaryAttack_mobile_respawn( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity ownerPlayer = weapon.GetWeaponOwner()
	Assert( ownerPlayer.IsPlayer() )

	CarePackagePlacementInfo placementInfo = GetCarePackagePlacementInfo( ownerPlayer )

	if ( placementInfo.failed )
		return 0

	#if SERVER
		vector origin = placementInfo.origin
		vector angles = placementInfo.angles

		string name = weapon.GetWeaponClassName()

		{
			thread RespawnBeacon_SpawnMobileBeacon( origin, angles, placementInfo.surfaceNormal, ownerPlayer )
		}
		foreach ( callbackFunc in file.Callbacks_OnMobileRespawnBeaconDeployTriggered )
			callbackFunc( ownerPlayer )

		PlayerUsedOffhand( ownerPlayer, weapon, false, null, {pos = origin} )
	#else
		SetBeaconDeployed( true )
		PlayerUsedOffhand( ownerPlayer, weapon )

		if ( weapon.GetWeaponPrimaryClipCount() <= 1 ) // Because after this we will have no more ammo
		{
			ownerPlayer.Signal( "MobileRespawnPlacement" )
		}
	#endif

	#if SERVER
		TryPlayWeaponBattleChatterLine( ownerPlayer, weapon )

		//LiveAPI_SendInventoryActionWeapon( eLiveAPI_EventTypes.inventoryUse, ownerPlayer, weapon )
		thread AutoEquipInventoryItem( weapon, ownerPlayer )
	#endif

	int ammoReq = weapon.GetAmmoPerShot()
	return ammoReq
}

#if SERVER
void function RespawnBeacon_AddCallback_OnMobileRespawnBeaconDeployTriggered( void functionref(entity) callbackFunc )
{
	Assert( !file.Callbacks_OnMobileRespawnBeaconDeployTriggered.contains( callbackFunc ), "Already added " + string( callbackFunc ) + " with RespawnBeacon_AddCallback_OnMobileRespawnBeaconDeployTriggered" )
	file.Callbacks_OnMobileRespawnBeaconDeployTriggered.append( callbackFunc )
}
#endif // SERVER

var function OnWeaponPrimaryAttackAnimEvent_mobile_respawn(entity ent, WeaponPrimaryAttackParams params)
{
	// Reminder note:
	// There is an AE_WPN_PRIMARYATTACK event in attack_mrb_seq.  Without this "empty function" we get an error:
	// Unhandled weapon primary attack callback OnWeaponPrimaryAttack AnimEvent for '' weapon 'mp_ability_mobile_respawn'
	//
	// Q: Why not remove that event?
	// A: B/c really we should be triggering on AE_WPN_PRIMARYATTACK rather than the standard PrimaryAttack callback,
	// but we run into an error if we enable the anim event and disable the standard PrimaryAttack.
	//
	// There is a devwarning in code:
	//	   if ( !this->IsOffhandWeapon() && !weapInfo->isTossWeapon ) // Toss weapons may use anim event CBs for attack, so it's normal for CBs to be missing
	//			DevWarning( "`Unhandled weapon primary attack callback %s for '%s' weapon '%s'\n", g_scriptCBInfo[scriptCB].name, this->GetWeaponClass(), this->GetWeaponName() );
	// ...that fires if you don't implement the standard PrimaryAttack callback.
	//
	// Setting the fire_mode to offhand to avoid the assert triggers a runtime fatal assert as there
	// are assumptions in the fire_mode for ordnances (of which the mrb is considered as one).
	// And mrb is part of the grenade/ordnance slot until a future spot for gadgets can be found.
	//
	// Q: Why not implement it here and leave PrimaryAttack empty?
	// A: 1) The standard PrimaryAttack has had alot more testing over PrimaryAttackAnimEvent.
	//	  2) PrimaryAttackAnimEvent will only work with the currently not-great override found in CL 482698 (only until a more permanent home is found).  If that change is undone then the anim won't play and the beacon will break.
	//	  3) Lifeline's care package also uses the standard PrimaryAttack.

	// Q: Why doesn't Lifeline's care package trigger the same assert?
	// A: The carepackage ability's fire_mode is set to offhand (which it can do, and mrb cannot until it is out of the ordnance slot).

	return 0 // Or we will decrement too many shots from our clip (i.e. one from PrimaryAttack and one from PrimaryAttackAnimEvent).
}

#if SERVER
entity function _SpawnMobileBeacon( vector origin, vector angles, asset modelAsset, string targetName )
{
	entity respawnChamber = CreatePropScript_NoDispatchSpawn( modelAsset, origin, angles, 6 )
	SetTargetName( respawnChamber, targetName )

		respawnChamber.SetScriptName( MOBILE_RESPAWN_BEACON_SCRIPTNAME ) //Update to allow Tombstone version like above if desired

	respawnChamber.SetCanBeMeleed( false )
	//respawnChamber.SetScriptPropFlags( SPF_OBJECT_PLACEMENT_SPECIAL_IGNORE )
	DispatchSpawn( respawnChamber )

	return respawnChamber
}
#endif // SERVER

float function GetRespawnStationUseTime_Mobile( entity ent )
{
	return 7.0
}

#if CLIENT
void function OnEndPlacingMobileRespawn( entity player )
{
	if ( player != GetLocalViewPlayer() )
		return

	player.Signal( "MobileRespawnPlacement" )
}
#endif // CLIENT

#if CLIENT
void function SetBeaconDeployed( bool state )
{
	file.mobileRespawnDeployed = state
}
#endif // CLIENT

#if CLIENT
entity function CreateProxy( asset modelName )
//TODO: Needs work if we do different turret models
{
	entity modelEnt = CreateClientSidePropDynamic( <0, 0, 0>, <0, 0, 0>, modelName )
	modelEnt.kv.renderamt = 255
	modelEnt.kv.rendermode = 3
	modelEnt.kv.rendercolor = "255 255 255 255"

	modelEnt.Anim_Play( "ref" )
	modelEnt.Hide()

	return modelEnt
}
#endif // CLIENT

#if CLIENT
void function DestroyProxy( entity ent )
{
	Assert( IsNewThread(), "Must be threaded off" )
	ent.EndSignal( "OnDestroy" )

	if ( file.mobileRespawnDeployed )
		wait 0.225

	ent.Destroy()
}
#endif // CLIENT

bool function MobileRespawn_ConditionalCheck( string ref, entity player )
{
	return false
}

// Enbables quick-deploy MRB.
bool function MobileRespawnBeacon_PLV_FastMRB_Enabled()
{
	bool fastMRB_Enabled = GetCurrentPlaylistVarBool( "mobilerespawnbeacon_fastmrb_enabled", false )
	return( fastMRB_Enabled )
}

string function MobileRespawnBeacon_PLV_FastMRB_SpawnInType()
{
	// "default" == default respawn function ( dropship )
	// If Freespawns exists, anything given other than "default" will be passed to Freespawns as the spawnInType:
	// 		"skydive" == skydive.
	// 		"droppod" == droppod.

	string spawnType = "default"

	return( spawnType )
}

#if SERVER
void function RespawnBeacon_SpawnMobileBeacon( vector origin, vector angles, vector surfaceNormal, entity owner = null )
{
	thread SpawnMobileBeacon_Sequence( origin, angles, surfaceNormal, owner )
}
#endif

#if SERVER
void function SpawnMobileBeacon_Sequence( vector origin, vector angles, vector surfaceNormal, entity owner )
{
	bool fastMRB_Enabled = MobileRespawnBeacon_PLV_FastMRB_Enabled()

	// First determine if we are on a slope or not
	float slope = fabs( surfaceNormal.x  ) + fabs( surfaceNormal.y ) // this seems to work because the vector is normalized to 1  and z of 1 is perfectly upright
	bool isSlopeLanding = ( slope > MOBILE_RESPAWN_BEACON_SLOPED_LANDING_LIMIT )

	array<int> realmsToAdd = IsValid( owner ) ? owner.GetRealms() : [ eRealms.DEFAULT ]

	#if DEVELOPER
		if ( MOBILE_RESPAWN_BEACON_DEBUG_DRAW )
		{
			vector anglesOnSurface = AnglesOnSurface( surfaceNormal, AnglesToForward( angles ) )
			vector forward = AnglesToForward( angles ) // This is on the Y
			vector newUpDir = AnglesToUp( anglesOnSurface ) // This is going to come back out as placementInfo.surfaceNormal
			float dot = DotProduct( newUpDir , AnglesToUp(angles) )
			DebugDrawText( origin, format( "Angle: %1.2f|Slope: %1.2f", RadToDeg( acos(dot) ), slope ), true, 60 )
		}
	#endif

	// Setup dynamic and static then attach
	entity respawnBeacon = CreatePropDynamic( MOBILE_RESPAWN_BEACON_MODEL, origin + <0, 0, 20000>, angles, 6 )
	entity beaconMover = CreateScriptMover_NEW( MOBILE_RESPAWN_BEACON_MOVER_SCRIPTNAME, respawnBeacon.GetOrigin(), respawnBeacon.GetAngles() )
	respawnBeacon.SetParent( beaconMover )
	respawnBeacon.Anim_PlayOnly( "mobile_respawn_beacon_closed" ) // Set it up to be the closed position
	respawnBeacon.SetCollisionAllowed( false ) // Don't allow collision while it's falling.

	if ( IsValid( owner ) )
		SetTeam( respawnBeacon, owner.GetTeam() )

	respawnBeacon.RemoveFromAllRealms()
	beaconMover.RemoveFromAllRealms()

	foreach(  realm in realmsToAdd )
	{
		respawnBeacon.AddToRealm( realm )
		beaconMover.AddToRealm( realm )
	}

	//beaconMover.Hide()

	// Setup all FX that exist for the lifetime of the respawnBeacon
	entity threatIndicator = CreateThreatIndicator( origin + <0, 0, 48>, eThreatIndicatorID.GRENADE_INDICATOR_GENERIC, 160.0 )
	int markerIndex = GetParticleSystemIndex( MOBILE_RESPAWN_BEACON_AR_DROP_POINT_FX ) // AR Marker
	entity markerFx = StartParticleEffectInWorld_ReturnEntity( markerIndex, origin, angles )

	threatIndicator.RemoveFromAllRealms()
	markerFx.RemoveFromAllRealms()
	foreach(  realm in realmsToAdd )
	{
		threatIndicator.AddToRealm( realm )
		markerFx.AddToRealm( realm )
	}

	EmitSoundAtPosition( TEAM_UNASSIGNED, origin, "Survival_MobileRespawnBeacon_Marker", beaconMover )
	EmitSoundOnEntity( beaconMover, "Survival_MobileRespawnBeacon_Launch" )
	EmitSoundOnEntity( beaconMover, "Survival_MobileRespawnBeacon_Incoming" )

	// Start the movement of the BeaconMover
	float TotalTimeToLand = 16.0 // This is the total time we expect for the beacon to make it from the sky to the ground and settle
	string LandingAnim_Name = isSlopeLanding ? "mobile_respawn_beacon_slope_land" : "mobile_respawn_beacon_land"
	float LandingAnim_Duration = respawnBeacon.GetSequenceDuration( LandingAnim_Name )
	float LandingAnim_StartTime = TotalTimeToLand - LandingAnim_Duration // We subtract the landing animation so the total time the player sees visually is our total desired time (TotalTimeToLand)
	Assert( LandingAnim_StartTime > 0.0 )
	CreateAirdropBadPlace( respawnBeacon, origin, MOBILE_RESPAWN_BEACON_BAD_AIRSPACE_RADIUS )  // Prevent placement of beacons too close together while it's coming down
	#if DEVELOPER
		if ( MOBILE_RESPAWN_BEACON_DEBUG_DRAW )
		{
			 DebugDrawCylinder( origin, <270.0, 0.0, 0.0>, MOBILE_RESPAWN_BEACON_BAD_AIRSPACE_RADIUS, 2.0, 255,0,0, true, TotalTimeToLand )
			DebugDrawAngles( origin, angles, TotalTimeToLand )
			//DebugDrawText( origin, format( "Angle: %1.2f|Slope: %1.2f", DotProduct( AnglesToUp(origin), <1, 0 ,0> ), fabs(angles.x) + fabs(angles.y) ), true, TotalTimeToLand )
		}
	#endif
	float moveTime = fastMRB_Enabled ? 1.0 : LandingAnim_StartTime
	beaconMover.NonPhysicsMoveTo( origin, moveTime, 0.0, 0.0 ) // Note: From this point on the mover will update separate to this function

	if( !fastMRB_Enabled )
	{
		thread SpawnMobileBeacon_Sequence_PrelandingFX_Thread( respawnBeacon, origin, angles, LandingAnim_StartTime )
		wait LandingAnim_StartTime
	}

	// Start the landing animation
	// Note: BeaconMover has landed.  Now we are just visually playing a landing anim.
	thread SpawnMobileBeacon_SetupPushAway_Thread( respawnBeacon, origin )
	thread SpawnMobileBeacon_Sequence_LandingFX_Thread( respawnBeacon, origin, LandingAnim_Duration )
	respawnBeacon.Anim_Play( LandingAnim_Name )
	StopSoundOnEntity( beaconMover, "Survival_MobileRespawnBeacon_Incoming" )
	EmitSoundOnEntity( beaconMover, "Survival_MobileRespawnBeacon_Burst" )

	// Wait until The Beacon has touched ground (this is some time before the animation completes - the animation will still play its settling animation)
	const float TimeBeforeEndToEnableCollision = 2.1
	wait LandingAnim_Duration - TimeBeforeEndToEnableCollision
	SpawnMobileBeacon_ClearLandingZone( respawnBeacon, origin ) // Clear out everyone below us
	respawnBeacon.SetCollisionAllowed( true ) // Turn on the collision just before landing to avoid there being a period where we haven't the pushaway and the respawnChamber hasn't spawned in yet with collision.
	Signal( respawnBeacon, "MobileBeaconLanded" ) // Visually, the beacon has landed
	EffectStop( markerFx )
	threatIndicator.Destroy()

	// Wait the remaining time of the landing animation to fully complete
	wait TimeBeforeEndToEnableCollision
	entity respawnChamber = _SpawnMobileBeacon( origin, angles, MOBILE_RESPAWN_BEACON_MODEL, MOBILE_RESPAWN_BEACON_TARGETNAME ) // Spawn the actual prop that the player can interact with
	respawnChamber.RemoveFromAllRealms()
	foreach(  realm in realmsToAdd )
		respawnChamber.AddToRealm( realm )

	if ( IsValid( owner ) )
		SetTeam( respawnChamber, owner.GetTeam() )

	/*if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_FIRING_RANGE ) )
	{
		if ( IsValid(owner) )
		{
			FiringRange_AddToPermanentDeployableQuota( respawnChamber, owner )
		}
		else
		{
			AddStagingCleanupEnt ( respawnChamber )
		}
	}*/

	CreateAirdropBadPlace( respawnChamber, origin, MOBILE_RESPAWN_BEACON_BAD_AIRSPACE_RADIUS ) // Prevent two respawn beacons from being placed too close to each other
	if ( isSlopeLanding )
		respawnChamber.Anim_PlayOnly( "mobile_respawn_beacon_slope_idle" ) // Sloped resting pose
	else
		respawnChamber.Anim_PlayOnly( "mobile_respawn_beacon_idle" ) // Resting pose
	StopSoundAtPosition( origin, "Survival_MobileRespawnBeacon_Marker" )
	int fxId 	= GetParticleSystemIndex( MOBILE_RESPAWN_BEACON_EFFECT )
	entity fx   = StartParticleEffectOnEntityWithPos_ReturnEntity( respawnChamber, fxId, FX_PATTACH_POINT_FOLLOW_NOROTATE, respawnChamber.LookupAttachment( "HOLO" ), <0,0,0>, <-90,0,0>)
	EmitSoundOnEntity( respawnChamber, MOBILE_RESPAWN_BEACON_STARTUP_SOUND )
	beaconMover.Destroy() // Destroy the fake beacon (the respawnChamber is what is interacted with)

	// Cache slope info for destruction
	if ( isSlopeLanding )
	{
		file.savedSlopeNormal[respawnChamber] <- surfaceNormal
	}

	// TODO: If fastMRB, auto-activated it.
	if( fastMRB_Enabled )
	{
		string mrbSpawnStyle = MobileRespawnBeacon_PLV_FastMRB_SpawnInType()

		switch( mrbSpawnStyle )
		{


			case "default":
			default:
				void functionref( entity ent, entity player, ExtendedUseSettings settings ) successFunc = RespawnBeacon_GetSuccessFunc( respawnChamber )
				ExtendedUseSettings settings
				successFunc( respawnChamber, owner, settings )
				break
		}
	}
}

#endif // SERVER

#if SERVER
void function SpawnMobileBeacon_Sequence_PrelandingFX_Thread( entity respawnBeacon, vector origin, vector angles, float LandingAnimStartTime )
{
	// We run the FX in parallel with the beaconmover so fx's waits cannot delay when
	// we can start the landing animation.

	// If respawnBeacon gets prematurely destroyed, don't keep playing effects
	EndSignal( respawnBeacon, "OnDestroy" )

	float totalTimeRemaining = LandingAnimStartTime
	wait 0.2
	totalTimeRemaining -= 0.2

	// Start smoke trail FX
	int smokeFxId = GetParticleSystemIndex( MOBILE_RESPAWN_BEACON_SMOKE_TRAIL )
	entity smokeFX = StartParticleEffectOnEntityWithPos_ReturnEntity ( respawnBeacon, smokeFxId, FX_PATTACH_POINT_FOLLOW_NOROTATE, respawnBeacon.LookupAttachment( "BASE" ), <0,0,0>, <0,0,0>)

	Assert( totalTimeRemaining - 0.4 >= 0.4 )
	wait ( totalTimeRemaining - 0.4 )
	totalTimeRemaining = 0.4

	// Start jetwash FX
	PlayImpactFXTable( origin, respawnBeacon, "mobile_respawn_dust" )
	EmitSoundOnEntity( respawnBeacon, "Survival_MobileRespawnBeacon_Jetwash" )

	Assert( totalTimeRemaining - 0.2 >= 0.2 )
	wait ( totalTimeRemaining - 0.2 )
	totalTimeRemaining -= 0.2

	// Restart thrusters just before landing sequence starts and stop smoke trail
	int abFxId = GetParticleSystemIndex( MOBILE_RESPAWN_BEACON_AB_FX )
	entity abFX1 = StartParticleEffectOnEntityWithPos_ReturnEntity( respawnBeacon, abFxId, FX_PATTACH_POINT_FOLLOW_NOROTATE, respawnBeacon.LookupAttachment( "THRUSTER_1" ), <0,0,0>, <90,0,0>)
	entity abFX2 = StartParticleEffectOnEntityWithPos_ReturnEntity( respawnBeacon, abFxId, FX_PATTACH_POINT_FOLLOW_NOROTATE, respawnBeacon.LookupAttachment( "THRUSTER_2" ), <0,0,0>, <90,0,0>)
	entity abFX3 = StartParticleEffectOnEntityWithPos_ReturnEntity( respawnBeacon, abFxId, FX_PATTACH_POINT_FOLLOW_NOROTATE, respawnBeacon.LookupAttachment( "THRUSTER_3" ), <0,0,0>, <90,0,0>)
	entity abFX4 = StartParticleEffectOnEntityWithPos_ReturnEntity( respawnBeacon, abFxId, FX_PATTACH_POINT_FOLLOW_NOROTATE, respawnBeacon.LookupAttachment( "THRUSTER_4" ), <0,0,0>, <90,0,0>)
	int abLightsFxId = GetParticleSystemIndex( MOBILE_RESPAWN_BEACON_AB_LIGHTS_FX )
	entity abLightsFX = StartParticleEffectOnEntityWithPos_ReturnEntity( respawnBeacon, abLightsFxId, FX_PATTACH_POINT_FOLLOW_NOROTATE, respawnBeacon.LookupAttachment( "BASE" ), <0,0,0>, <90,0,0>)
	EffectStop( smokeFX )

	wait totalTimeRemaining

	// -----------------------------------------------
	// AT THIS POINT WE HAVE STARTED THE LANDING ANIM.
	// -----------------------------------------------
	// We made it this far without being prematurely killed so the beacon is still alive.

	wait 1.3 // Some time after landing anim has started...

	// Stop afterburners
	EffectStop( abFX1 )
	EffectStop( abFX2 )
	EffectStop( abFX3 )
	EffectStop( abFX4 )
	EffectStop( abLightsFX )
}
#endif // SERVER

#if SERVER
void function SpawnMobileBeacon_Sequence_LandingFX_Thread( entity respawnBeacon, vector origin, float LandingAnimDuration )
{
	// We run the FX in parallel with Animation so the wait's can't delay animation timing
	// These FX are not triggered from the animation because we don't know if we can trigger
	// impact FX from the sequence.
	EndSignal( respawnBeacon, "OnDestroy" )

	wait (LandingAnimDuration - 2.2)

	// Impact FX
	PlayImpactFXTable( origin, respawnBeacon, MOBILE_RESPAWN_BEACON_IMPACT_TABLE )
	entity shake = CreateShake( origin, 8, 150, 1.0, 4000 )
	shake.RemoveFromAllRealms()
	shake.AddToOtherEntitysRealms( respawnBeacon )
	// Cam shake with impact
	shake.kv.spawnflags = 4 // SF_SHAKE_INAIR

	// -----------------------------------------------
	// AT THIS POINT WE HAVE ENDED THE LANDING ANIM.
	// -----------------------------------------------
}
#endif // SERVER

#if SERVER
void function SpawnMobileBeacon_SetupPushAway_Thread( entity beaconPod, vector landingPos )
{
	Assert( IsNewThread(), "Must be threaded off" )

	// Detect entities to be pushed away - this radius is larger than the ones
	// to clear beneath the beacon.
	entity pushAwayTrigger = CreateEntity( "trigger_cylinder" )
	pushAwayTrigger.RemoveFromAllRealms()
	pushAwayTrigger.AddToOtherEntitysRealms( beaconPod )
	pushAwayTrigger.SetRadius( 100 )
	pushAwayTrigger.SetAboveHeight( 256 )
	pushAwayTrigger.SetBelowHeight( 16 ) // Need this because the player or entity can sink into the ground a tiny bit and we check player feet not half height
	pushAwayTrigger.SetOrigin( landingPos)
	pushAwayTrigger.SetEnterCallback( SpawnMobileBeacon_PushAway_Callback )
	DispatchSpawn( pushAwayTrigger )

	// Re-enable this to see the cylinder of prop destruction
	#if DEVELOPER
		if ( MOBILE_RESPAWN_BEACON_DEBUG_DRAW )
		{
			DebugDrawCylinder( pushAwayTrigger.GetOrigin() - <0.0, 0.0, pushAwayTrigger.GetBelowHeight()>, <270.0, 0.0, 0.0>, pushAwayTrigger.GetRadius(), pushAwayTrigger.GetAboveHeight() + pushAwayTrigger.GetBelowHeight(), 255,255,255, true, 3.0 )
		}
	#endif

	// Catch an entity in the trigger right away
	pushAwayTrigger.SearchForNewTouchingEntity()

	EndSignal( beaconPod, "OnDestroy" )
	EndSignal( pushAwayTrigger, "OnDestroy" )

	OnThreadEnd(
		function () : ( pushAwayTrigger )
		{
			if ( IsValid( pushAwayTrigger ) )
				pushAwayTrigger.Destroy()
		}
	)

	beaconPod.WaitSignal( "MobileBeaconLanded" )
}
#endif // SERVER

#if SERVER
void function SpawnMobileBeacon_PushAway_Callback( entity trigger, entity ent )
{
	if ( ent.DoesShareRealms( trigger ) )
	{
		// Push players away

		/*if ( ent.IsPlayer() || EntIsHoverVehicle( ent ) )
		{
			thread SpawnMobileBeacon_PushAway_Thread( trigger, ent )
		}*/
	}
}
#endif // SERVER

#if SERVER
void function SpawnMobileBeacon_PushAway_Thread( entity trigger, entity ent )
{
	EndSignal( trigger, "OnDestroy" )
	EndSignal( ent, "OnDestroy" )

	while( trigger.IsTouching( ent ) )
	{
		vector v = Normalize( ent.GetOrigin() - trigger.GetOrigin() )

		v = Normalize( <v.x,v.y,0> )

		if ( Length( v ) < 0.5 )
			v = <1,0,0>

		ent.SetVelocity( v*200 )
		WaitFrame()
	}
}
#endif // SERVER

#if SERVER
void function SpawnMobileBeacon_ClearLandingZone( entity respawnBeacon, vector landingPos )
{
	DropPod_ClearLandingZone( landingPos, respawnBeacon, MOBILE_RESPAWN_BEACON_DESTROY_PROP_RADIUS, MOBILE_RESPAWN_BEACON_DESTROY_PROP_RADIUS, MOBILE_RESPAWN_BEACON_DEBUG_DRAW )
}
#endif

#if SERVER
void function RespawnBeaconStartUse_Mobile( entity ent, entity player, ExtendedUseSettings settings )
{
	RespawnBeaconStartUse_Common( ent, player, settings )

	// Start Countdown Pulse FX
	int pulseFxId  = GetParticleSystemIndex( MOBILE_RESPAWN_BEACON_COUNTDOWN_PULSE_FX )
	file.countdownPulseFX[ ent ] <- StartParticleEffectInWorld_ReturnEntity( pulseFxId, ent.GetOrigin(), <-90,0,0> )
	EmitSoundOnEntity( ent, MOBILE_RESPAWN_INTERACT_PULSATE_SOUND )
}
#endif // SERVER

#if SERVER
void function RespawnBeaconStopUse_Mobile( entity ent, entity player, ExtendedUseSettings settings )
{
	RespawnBeaconStopUse_Common( ent, player )

	StopSoundOnEntity( ent, MOBILE_RESPAWN_INTERACT_PULSATE_SOUND )

	//Stop Pulse FX
	if( IsValid( file.countdownPulseFX[ ent ] ) )
	{
		EffectStop( file.countdownPulseFX[ ent ] )
	}
	delete file.countdownPulseFX[ ent ]
}
#endif // SERVER

#if SERVER
void function RespawnUserTeam_Mobile( entity ent, entity playerUser, ExtendedUseSettings settings )
{
	// TODO: If fastMRB, do special freespawns skydive.

	if ( !RespawnUserTeam_Common( ent, playerUser ) )
		return

	PIN_Interact( playerUser, "mobile_respawn_beacon", ent.GetOrigin() )

	// Play destruction animation and effects
	ent.UnsetUsable() // So you can't interact with it - but this gets stomped because of a bug.  Setting it here for intent anyways.

	bool isOnSlope = ent in file.savedSlopeNormal
	string destructionSequence = isOnSlope ? "mobile_respawn_beacon_slope_destruction" : "mobile_respawn_beacon_destruction"
	float duration = ent.GetSequenceDuration( destructionSequence )
	entity beaconMover = null

	// Spawn a placeholder that will allow us to destroy the interactable one and all hud-related items with it.
	// We send an empty target name as some checks only look to see if the entity has a respawn-related target name, causing
	// it to still be usable by things like crypto's drone when it is in the deconstruction animation
	entity beaconPlaceholder = _SpawnMobileBeacon( ent.GetOrigin(), ent.GetAngles(), MOBILE_RESPAWN_BEACON_MODEL, "" )
	beaconPlaceholder.UnsetUsable()

	if ( isOnSlope )
	{
		vector surfaceNormal = file.savedSlopeNormal[ent]
		delete file.savedSlopeNormal[ent]

		//vector rotatedBeaconAngles = AnglesOnSurface( surfaceNormal, AnglesToForward( ent.GetAngles() ) ) // This keeps the yaw of the mrb in the orientation that it landed, but then it can destroy itself 'upward' rather than down towards gravity
		// What we actually want is for there to be yaw so we can orient the beacon in the direction of the slope
		vector slopeFwd = Normalize( surfaceNormal - <0, 0, 1> )
		vector rotatedBeaconAngles = AnglesOnSurface( surfaceNormal, slopeFwd ) // This changes the yaw of the mrb to be in the direction of the slope

		beaconMover = CreateScriptMover_NEW( MOBILE_RESPAWN_BEACON_MOVER_SCRIPTNAME, beaconPlaceholder.GetOrigin(), ent.GetAngles() )
		beaconPlaceholder.SetParent( beaconMover )
		beaconMover.Hide()
		beaconMover.NonPhysicsRotateTo( rotatedBeaconAngles, 0.25, 0, 0 )
	}

	array<entity> childrenOfOldEntity = GetChildren( ent )
	array< entity > childrenToDrop

	foreach (entity child in childrenOfOldEntity)
	{
		if ( IsValid ( child ) )
		{
			entity voidRing = FindScriptNameInChildren( child, VOID_RING_PROP_SCRIPTNAME )
			if ( IsValid( voidRing ) )
			{
				child.ClearParent()
				childrenToDrop.append ( voidRing )
				continue
			}

			entity deathBox = FindTargetNameInChildren( child, DEATH_BOX_TARGETNAME )
			if ( IsValid ( deathBox ) )
			{
				child.ClearParent()
				childrenToDrop.append( deathBox )
			}
		}
	}

	ent.Destroy()
	beaconPlaceholder.Anim_PlayOnly( destructionSequence )

	wait duration

	if ( IsValid( beaconPlaceholder ) )
	{
		beaconPlaceholder.ClearParent() // So we can play dissolve without the beaconMover destroying us prematurely
		beaconPlaceholder.Dissolve( ENTITY_DISSOLVE_NONE, <0,0,0>, 1000 )
	}

	if ( beaconMover != null )
		beaconMover.Destroy()

	while ( IsValid( beaconPlaceholder ) && beaconPlaceholder.IsDissolving() )
		WaitFrame()

	foreach ( child in childrenToDrop )
	{
		if ( IsValid( child ) )
			FakePhysicsThrow_Retail( child.GetOwner(), child, <0, 0, 0>, false )
	}


}
#endif // SERVER

#if CLIENT
void function MobileRespawnPlacement( entity weapon, entity player, asset modelName )
{
	weapon.EndSignal( "OnDestroy" )
	player.EndSignal( "OnDeath" )
	player.EndSignal( "MobileRespawnPlacement" )

	entity beacon = CreateProxy( modelName )
	beacon.EnableRenderAlways()
	beacon.Show()
	DeployableModelHighlight( beacon )

	OnThreadEnd(
		function() : ( beacon )
		{
			if ( IsValid( beacon ) )
				thread DestroyProxy( beacon )

			HidePlayerHint( "#MOBILE_RESPAWN_HINT" )
		}
	)

	AddPlayerHint( 3.0, 0.25, $"", "#MOBILE_RESPAWN_HINT" )

	while ( true )
	{
		CarePackagePlacementInfo placementInfo = GetCarePackagePlacementInfo( player )

		beacon.SetOrigin( placementInfo.origin )
		beacon.SetAngles( placementInfo.angles )

		if ( !placementInfo.failed )
			DeployableModelHighlight( beacon )
		else
			DeployableModelInvalidHighlight( beacon )

		if ( placementInfo.hide )
			beacon.Hide()
		else
			beacon.Show()

		WaitFrame()
	}
}
#endif // CLIENT

#if CLIENT
void function OnBeginPlacingMobileRespawn( entity weapon, entity player )
{
	if ( player != GetLocalViewPlayer() )
		return

	thread MobileRespawnPlacement( weapon, player, MOBILE_RESPAWN_BEACON_MODEL )
}
#endif // CLIENT

#if SERVER && DEVELOPER
void function DEV_Spawn_MobileRespawnBeacon( entity player )
{
	CarePackagePlacementInfo placementInfo = GetCarePackagePlacementInfo( player )

	vector origin = placementInfo.origin
	vector angles = placementInfo.angles
	vector surfNormal = placementInfo.surfaceNormal

	RespawnBeacon_SpawnMobileBeacon( origin, angles, surfNormal, player )
}
#endif // SERVER && DEVELOPER