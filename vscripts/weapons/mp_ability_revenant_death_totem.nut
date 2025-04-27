global function MpAbilityRevenantDeathTotem_Init
global function DeathTotem_PlayerCanRecall
global function OnWeaponAttemptOffhandSwitch_ability_revenant_death_totem
global function OnWeaponActivate_ability_revenant_death_totem
global function OnWeaponDeactivate_ability_revenant_death_totem
global function DoesPlayerHaveDeathProtection
global function OnWeaponPrimaryAttack_ability_revenant_death_totem

#if CLIENT
	global function OnCreateClientOnlyModel_ability_revenant_death_totem
#endif

#if SERVER
	global function DeathTotem_RecallPlayer
	global function DeathTotem_OnShadowHealthExhausted
	global function SetShadowAbilitiesSkin
	global function ShadowSquadCancelCharacterSkin
	global function ShadowSquadApplyCharacterSkin
	global function CancelDeathTotemForPlayer
	global function DeathTotem_RemoveTotem
#endif //SERVER

const string ABILITY_USED_MOD = "ability_used_mod"
const string DEATH_TOTEM_MOVER_SCRIPTNAME = "death_totem_mover"

//Totem
const asset DEATH_TOTEM_TOTEM_MDL = $"mdl/props/revenant_totem/revenant_totem.rmdl"//"mdl/props/caustic_gas_tank/caustic_gas_tank.rmdl"
const asset DEATH_TOTEM_RADIUS_MDL = $"mdl/weapons_r5/ability_mark_recall/ability_mark_recall_ar_radius.rmdl"

const asset DEATH_TOTEM_RADIUS_FX = $"P_death_totem_init"
const asset DEATH_TOTEM_SHADOW_BODY_FX = $"P_Bshadow_body"
const asset DEATH_TOTEM_SHADOW_MARKER_FX = $"P_death_shadow_marker"
const asset DEATH_TOTEM_SHADOW_RECALL_FX = $"P_death_shadow_recall"
const asset DEATH_TOTEM_SHADOW_EYE_FX = $"P_BShadow_eye"
const asset DEATH_TOTEM_SHADOW_DEATH_FX = $"P_BShadow_death"
const asset DEATH_TOTEM_SHADOW_TIMER_FX = $"P_Bshadow_timer"
const asset DEATH_TOTEM_FX = $"P_death_totem"
const asset DEATH_TOTEM_FLASH_FX = $"P_death_totem_flash"
const string ULTIMATE_ACTIVE_MOD_STRING = "ultimate_active"
const string SIGNAL_TELEPORTED = "Teleported"
const string HIGHLIGHT_FRIENDLY_PLAYER_DECOY = "friendly_player_decoy"
const asset DEATH_TOTEM_GROUND_FX = $"P_death_totem_ground"

//Markers
const asset DEATH_TOTEM_BASE_MDL = $"mdl/Weapons/sentry_shield/sentry_shield_proj.rmdl"

const float DEATH_TOTEM_DESYNC_WARNING_INTERVAL = 2.0
const float DEATH_TOTEM_DISTORTION_RANGE_MIN_SQR = 2500 * 2500
const float DEATH_TOTEM_DISTORTION_RANGE_MAX_SQR = 3000 * 3000

const float DEATH_TOTEM_OUT_OF_RANGE_DESYNC_TIME = 5.0

//TOTEM VARS
const float DEATH_TOTEM_TOTEM_HEALTH = 150
global const string DEATH_TOTEM_TARGETNAME = "death_totem"
global const string DEATH_TOTEM_RECALL_SIGNAL = "DeathTotem_DeathTotemed"
global const string DEATH_TOTEM_WEAPON_NAME = "mp_ability_revenant_death_totem"

//DEATH PROTECTION VARS
const float DEATH_TOTEM_DURATION = 30.0 //Function like lifeline totem - Doesn't go away until last person who has used it isn't linked.
const int DEATH_TOTEM_MAX_SHADOW_HEALTH_AMOUNT = 100
const int DEATH_TOTEM_DEATH_PROTECTION_RECALL_REVIVE_HEALTH = 50

const float DEATH_TOTEM_EFFECT_DURATION_DEFAULT = 25.0
const float DEATH_TOTEM_EXPIRATION_WARNING_DELAY = 1.75
const float DEATH_TOTEM_EXPIRATION_WARNING_DELAY_3P = 4.0

const DECOY_FX = $"P_flag_fx_foe"

const float SCREEN_FX_STATUS_EFFECT_DURATION = 0.25
const float SCREEN_FX_STATUS_EFFECT_EASE_OUT_TIME = 0.25

#if CLIENT
	const float DEATH_TOTEM_COLOR_CORRECTION_RANGE_MIN_SQR = 2500 * 2500
	const float DEATH_TOTEM_COLOR_CORRECTION_RANGE_MAX_SQR = 3000 * 3000
	const asset DEATH_TOTEM_TELEPORT_SCREEN_FX = $"P_training_teleport_FP"
	const asset DEATH_TOTEM_SHADOW_SCREEN_FX = $"P_Bshadow_screen"
#endif //CLIENT

const float IDEAL_TOTEM_DISTANCE = 72.0


//DEBUG
const bool DEATH_TOTEM_DEBUG = false

struct DeathTotemPlacementInfo
{
	vector origin
	vector normal
	entity parentTo
}

struct TotemData
{
	#if SERVER
		int scriptManagedPlayerArrayID
	#endif //SERVER
	array<entity> markedPlayerArray //array of players who have already used this totem.
}

struct RecallData
{
	vector origin
	vector angles
	vector velocity
	entity holoMarker
	entity holoRadius
	entity holoRadiusUpper
	entity holoBase
	int    statusEffectID
	bool   wasCrouched
	bool   wasInContextAction
	entity totemProxy
}

struct
{
	#if SERVER
		table < entity, RecallData > markedLocation
	#endif //SERVER

	table < entity, TotemData > totemData
	float deathTotemBuffDuration 				= DEATH_TOTEM_EFFECT_DURATION_DEFAULT
	bool  showEndOfBuffFX 						= true
	bool  revenant_totem_has_distance_limit		= true

	#if CLIENT
		bool hasMark = false
		bool hideUsePromptOverride = false
		var  deathProtectionStatusRui
	#endif //CLIENT
} file

void function MpAbilityRevenantDeathTotem_Init()
{
	PrecacheModel( DEATH_TOTEM_BASE_MDL )
	PrecacheModel( DEATH_TOTEM_RADIUS_MDL )
	PrecacheModel( DEATH_TOTEM_TOTEM_MDL )
	PrecacheParticleSystem( DEATH_TOTEM_FX )
	PrecacheParticleSystem( DEATH_TOTEM_FLASH_FX )
	PrecacheParticleSystem( DEATH_TOTEM_GROUND_FX )
	PrecacheParticleSystem( DEATH_TOTEM_RADIUS_FX )
	PrecacheParticleSystem( DEATH_TOTEM_SHADOW_EYE_FX )
	PrecacheParticleSystem( DEATH_TOTEM_SHADOW_DEATH_FX )
	PrecacheParticleSystem( DEATH_TOTEM_SHADOW_MARKER_FX )
	PrecacheParticleSystem( DEATH_TOTEM_SHADOW_RECALL_FX )
	PrecacheParticleSystem( DEATH_TOTEM_SHADOW_BODY_FX )
	PrecacheParticleSystem( DEATH_TOTEM_SHADOW_TIMER_FX )

	RegisterSignal( SIGNAL_TELEPORTED )

	RegisterSignal( "DeathTotem_ChangePlayerStance" )
	RegisterSignal( DEATH_TOTEM_RECALL_SIGNAL )
	RegisterSignal( "DeathTotem_ForceEnd" )
	RegisterSignal( "DeathTotem_Deploy" )
	RegisterSignal( "DeathTotem_EndShadowScreenFx" )
	RegisterSignal( "TotemDestroyed" )
	RegisterSignal( "DeathTotem_PreRecallPlayer" )
	RegisterSignal( "DeathTotem_Cancel" )
	RegisterSignal( "DeathTotem_RemoveWallClimbDisables" )

	#if CLIENT
		PrecacheParticleSystem( DEATH_TOTEM_TELEPORT_SCREEN_FX )
		PrecacheParticleSystem( DEATH_TOTEM_SHADOW_SCREEN_FX )
		StatusEffect_RegisterEnabledCallback( eStatusEffect.death_totem_visual_effect, DeathTotem_StartVisualEffect )
		StatusEffect_RegisterDisabledCallback( eStatusEffect.death_totem_visual_effect, DeathTotem_StopVisualEffect )
		StatusEffect_RegisterEnabledCallback( eStatusEffect.death_totem_recall, DeathTotem_RecallVisualEffect )
		AddCallback_OnPlayerChangedTeam( DeathTotem_ChangedTeamHUDUpdate )
		AddCallback_PlayerClassChanged( DeathTotem_OnPlayerClassChanged )

		AddCreateCallback( "prop_script", DeathTotem_OnTotemCreated )
	#endif //CLIENT

	#if SERVER
		Bleedout_AddCallback_CleanupUtilitySlot( DeathTotem_CleanupWeaponOnBleedout )
	#endif

	var revenant_totem_has_distance_limit = GetWeaponInfoFileKeyField_Global( "mp_ability_revenant_death_totem", "revenant_totem_has_distance_limit" )
	if( revenant_totem_has_distance_limit != null )
		file.revenant_totem_has_distance_limit = bool( expect int( revenant_totem_has_distance_limit ) )
		
	var revenant_totem_buff_use_ending_fx = GetWeaponInfoFileKeyField_Global( "mp_ability_revenant_death_totem", "revenant_totem_buff_use_ending_fx" )
	if( revenant_totem_buff_use_ending_fx != null )
		file.showEndOfBuffFX = bool( expect int( revenant_totem_buff_use_ending_fx ) )	
		
	var revenant_totem_buff_duration = GetWeaponInfoFileKeyField_Global( "mp_ability_revenant_death_totem", "revenant_totem_buff_duration" )
	if( revenant_totem_buff_duration != null )
		file.deathTotemBuffDuration = expect float( revenant_totem_buff_duration )

}


bool function OnWeaponAttemptOffhandSwitch_ability_revenant_death_totem( entity weapon )
{
	return true
}

#if CLIENT
void function OnCreateClientOnlyModel_ability_revenant_death_totem( entity weapon, entity model, bool validHighlight )
{
	if ( validHighlight )
		DeployableModelHighlight( model )
	else
		DeployableModelInvalidHighlight( model )
}
#endif

var function OnWeaponPrimaryAttack_ability_revenant_death_totem( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	// Check for valid spot
	/*if ( !weapon.ObjectPlacementHasValidSpot() )
	{
		weapon.DoDryfire()
		return 0
	}*/

	entity ownerPlayer = weapon.GetWeaponOwner()
	Assert( ownerPlayer.IsPlayer() )

	PlayerUsedOffhand( ownerPlayer, weapon )
	/*bool serverOrPredicted = IsServer() || (InPrediction() && IsFirstTimePredicted())
	if ( serverOrPredicted )
	{
		weapon.AddMod( ABILITY_USED_MOD )
		weapon.AddMod( ULTIMATE_ACTIVE_MOD_STRING )
	}*/

	thread DeathTotem_DisableWallClimbWhileDeployingTotem( ownerPlayer, weapon )

	#if SERVER
		PlayBattleChatterLineToSpeakerAndTeam( ownerPlayer, "bc_super" )
		weapon.w.wasFired = true
		//LockWeaponsAndMelee( ownerPlayer )

		vector origin = ownerPlayer.GetOrigin()
		vector angles = ownerPlayer.GetAngles()
		//entity parentTo = weapon.GetParent()
		thread DeathTotem_DeployTotem( ownerPlayer, origin, angles ) // Place your object in some utility function as normal using object placement's final positional data

		if ( DEATH_TOTEM_DEBUG )
			DebugDrawAxis( origin, angles )
	#endif

	return weapon.GetAmmoPerShot()
}

void function DeathTotem_DisableWallClimbWhileDeployingTotem( entity ownerPlayer, entity weapon )
{
	ownerPlayer.EndSignal( "OnDestroy", "OnDeath" )
	weapon.EndSignal( "DeathTotem_RemoveWallClimbDisables", "OnDestroy" )

	int wallClimbID = StatusEffect_AddEndless( ownerPlayer, eStatusEffect.disable_wall_run, 1.0 )
	int doubleJumpID =  StatusEffect_AddEndless( ownerPlayer, eStatusEffect.disable_double_jump, 1.0 )
	int wallHangID = StatusEffect_AddEndless( ownerPlayer, eStatusEffect.disable_automantle_hang, 1.0 )

	OnThreadEnd
	(
		void function() : ( ownerPlayer, wallHangID, wallClimbID, doubleJumpID )
		{
			if( !IsValid( ownerPlayer ) )
				return

			bool serverOrPredicted = IsServer() || ( InPrediction() && IsFirstTimePredicted() )

			if ( serverOrPredicted )
			{
				if ( StatusEffect_GetSeverity( ownerPlayer, eStatusEffect.disable_wall_run ) > 0.0 )
					StatusEffect_Stop( ownerPlayer, wallClimbID )

				if ( StatusEffect_GetSeverity( ownerPlayer, eStatusEffect.disable_double_jump ) > 0.0 )
					StatusEffect_Stop( ownerPlayer, doubleJumpID )

				if ( StatusEffect_GetSeverity( ownerPlayer, eStatusEffect.disable_automantle_hang ) > 0.0 )
					StatusEffect_Stop( ownerPlayer, wallHangID )
			}
		}
	)

	WaitForever()
}

#if SERVER
void function DeathTotem_DeployTotem( entity owner, vector origin, vector angles )
{
	if ( !IsValid( owner ) )
		return

	owner.Signal( "DeathTotem_Deploy" )
	owner.EndSignal( "DeathTotem_Deploy", "DeathTotem_Cancel", "CleanUpPlayerAbilities" )

	vector groundFXNormal = AnglesToUp( angles )
	TraceResults groundTrace = TraceLine( origin, origin - <0, 0, 30>, owner, TRACE_MASK_SOLID )
	if ( groundTrace.fraction < 1.0 && groundTrace.surfaceNormal != <0, 0, 0> )
		groundFXNormal = groundTrace.surfaceNormal
	vector offsetOrigin = origin + <0, 0, 20>
	int team      = owner.GetTeam()
	angles = AnglesCompose( angles, <0, 60, 0> )
	entity totemProxy = CreatePropScript( DEATH_TOTEM_TOTEM_MDL, offsetOrigin, angles, 0 )
	totemProxy.DisableHibernation()
	totemProxy.SetMaxHealth( 100 )
	totemProxy.SetHealth( 100 )
	totemProxy.SetDamageNotifications( true )
	totemProxy.SetDeathNotifications( false )
	totemProxy.SetScriptName( DEATH_TOTEM_TARGETNAME )
	totemProxy.SetBlocksRadiusDamage( false )
	SetTargetName( totemProxy, DEATH_TOTEM_TARGETNAME )
	totemProxy.EndSignal( "OnDestroy" )
	totemProxy.EndSignal( "TotemDestroyed" )
	totemProxy.SetBossPlayer( owner )
	totemProxy.RemoveFromAllRealms()
	totemProxy.AddToOtherEntitysRealms( owner )
	SetTeam( totemProxy, team )
	totemProxy.Minimap_AlwaysShow( team, null )

	// If we are in a mode where we allow communication between players near each other that are on the same team (but not the same squad); show the icon to nearby teammates
//	AllianceProximity_SetMinimapAlwaysShow_ForAlliance( team, totemProxy, owner )

	totemProxy.Minimap_SetAlignUpright( true )
	totemProxy.Minimap_SetZOrder( MINIMAP_Z_OBJECT - 1 )
	totemProxy.SetTakeDamageType( DAMAGE_YES )
	totemProxy.kv.contents = int( totemProxy.kv.contents ) & ~CONTENTS_TITANCLIP // So hover vehicles don't collide with them
	totemProxy.SetIgnorePredictedTriggerTypes( TT_JUMP_PAD  ) // So it ignores jump pads placed underneath later
	SetVisibleEntitiesInConeQueriableEnabled( totemProxy, false )

	thread TrapDestroyOnRoundEnd( owner, totemProxy )	// Get rid of this

	totemProxy.SetOrigin( offsetOrigin )
	totemProxy.SetOwner( owner )
	//totemProxy.SetNeverCrush( true )
	/*if ( IsValid( parentTo ) )
	{
		totemProxy.SetParent( parentTo )
	}*/
	//Register totem so that it is detected by sonar.
	totemProxy.Highlight_Enable()
	AddSonarDetectionForPropScript( totemProxy )

	entity mover
	{
		mover = totemProxy
	}

	entity fx             = StartParticleEffectOnEntity_ReturnEntity( totemProxy, GetParticleSystemIndex( DEATH_TOTEM_FX ), FX_PATTACH_POINT_FOLLOW, totemProxy.LookupAttachment( "FX_CENTER" ) )
	entity groundFx       = StartParticleEffectInWorld_ReturnEntity( GetParticleSystemIndex( DEATH_TOTEM_GROUND_FX ), origin, <90, 0, 0> + VectorToAngles( groundFXNormal ) )
	groundFx.SetParent( mover )

	//Create Totem Data
	TotemData totemData
	totemData.scriptManagedPlayerArrayID = CreateScriptManagedEntArray()
	file.totemData[ totemProxy ] <- totemData

	OnThreadEnd
	(
		void function() : ( owner, totemProxy, mover, fx, groundFx )
		{
			if ( IsValid( owner ) )
			{
				if ( owner.e.activeUltimateTraps.contains( totemProxy ) )
				{
					for ( int i = owner.e.activeUltimateTraps.len() - 1; i >= 0 ; i-- )
					{
						if ( owner.e.activeUltimateTraps[i] == totemProxy )
						{
							owner.e.activeUltimateTraps.remove( i )
						}
					}
				}

				entity offhandWeapon = owner.GetOffhandWeapon( OFFHAND_ULTIMATE )
				if ( IsValid( offhandWeapon ) )
					offhandWeapon.RemoveMod( ULTIMATE_ACTIVE_MOD_STRING )

				if ( IsValid( totemProxy ) )
				{
					int arrayID                = file.totemData[ totemProxy ].scriptManagedPlayerArrayID
					array<entity> totemPlayers = GetScriptManagedEntArray( arrayID )
					foreach ( entity totemPlayer in totemPlayers )
					{
						totemPlayer.Signal( "DeathTotem_ForceEnd" )
					}
					totemProxy.UnsetUsable()
				}

				if ( IsValid( fx ) )
				{
					fx.ClearParent()
					EffectStop( fx )
				}
				if ( IsValid( groundFx ) )
				{
					groundFx.ClearParent()
					EffectStop( groundFx )
				}
			}

			thread DeathTotem_RemoveTotem( totemProxy, mover )
		}
	)

	totemProxy.e.isBusy = true

	totemProxy.Anim_PlayOnly( "prop_revenant_totem_deploy" )
	EmitSoundOnEntityToTeam( totemProxy, "Revenant_Totem_Spawn", team )
	EmitSoundOnEntityToEnemies( totemProxy, "Revenant_Totem_Spawn_Enemy", team )

	WaittillAnimDone( totemProxy )

	StartParticleEffectOnEntity( totemProxy, GetParticleSystemIndex( DEATH_TOTEM_FLASH_FX ), FX_PATTACH_POINT_FOLLOW, totemProxy.LookupAttachment( "FX_CENTER" ) )

	totemProxy.Anim_PlayOnly( "prop_revenant_totem_idle" )
	EmitSoundOnEntityToTeam( totemProxy, "Revenant_Totem_Loop", team )
	EmitSoundOnEntityToEnemies( totemProxy, "Revenant_Totem_Loop_Enemy", team )

	AddEntityCallback_OnDamaged( totemProxy, DeathTotem_OnTotemDamaged )
	AddEntityCallback_OnPostDamaged( totemProxy, DeathTotem_OnTotemPostDamaged )
	totemProxy.SetTakeDamageType( DAMAGE_YES )
	totemProxy.SetTouchTriggers( true )
	totemProxy.SetCanBeMeleed( true )
	totemProxy.kv.solid = SOLID_CYLINDER
	thread Totem_CheckForGeoIntersection( totemProxy )

	StartParticleEffectOnEntity( totemProxy, GetParticleSystemIndex( DEATH_TOTEM_RADIUS_FX ), FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID )
	Highlight_SetOwnedHighlight( totemProxy, "sp_friendly_hero" )
	Highlight_SetFriendlyHighlight( totemProxy, "sp_friendly_hero" )
	totemProxy.SetUsable()
	totemProxy.AddUsableValue( USABLE_BY_TEAMMATES | USABLE_BY_ENEMIES | USABLE_BLOCK_CONTINUOUS_USE | USABLE_CUSTOM_HINTS ) //Update hint text every server frame so that we can keep unique client texts up to date.
	totemProxy.SetUsePrompts( "#DEATH_TOTEM_TOTEM_USE", "#DEATH_TOTEM_TOTEM_USE" )
	//SetCallback_CanUseEntityCallback_Retail( totemProxy, DeathTotem_CanUseTotem )
	AddCallback_OnUseEntity_ClientServer( totemProxy, DeathTotem_OnTotemUse )

	totemProxy.e.isBusy = false
	totemProxy.e.canBurn = true
	totemProxy.EnableAttackableByAI( AI_PRIORITY_NO_THREAT, 0, AI_AP_FLAG_NONE )

	owner.e.activeUltimateTraps.insert( 0, totemProxy )

	float endTime       = Time() + DEATH_TOTEM_DURATION
	bool totemHasPeople = false
	while ( Time() < endTime || totemHasPeople )
	{
		int arrayID                = file.totemData[ totemProxy ].scriptManagedPlayerArrayID
		array<entity> totemPlayers = GetScriptManagedEntArray( arrayID )
		totemHasPeople = totemPlayers.len() > 0
		WaitFrame()
	}
}

void function DeathTotem_CleanupWeaponOnBleedout( entity player )
{
	if( !IsValid( player ) )
		return

	entity weapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand )
	if( IsValid( weapon ) && weapon.GetWeaponClassName() == DEATH_TOTEM_WEAPON_NAME && weapon.w.wasFired )
	{
		UnlockWeaponsAndMelee_Retail( player, DEATH_TOTEM_WEAPON_NAME )
		weapon.w.wasFired = false
	}
}

void function Totem_CheckForGeoIntersection( entity totemProxy )
{
	Assert ( IsNewThread(), "Must be threaded off." )
	totemProxy.EndSignal( "OnDestroy" )

	float startTime = Time()

	for( ; ; )
	{
		array<entity> ignoreEnts = GetPlayerArray_Alive()
		ignoreEnts.append( totemProxy )

		vector startPos = totemProxy.GetOrigin()
		vector endPos   = startPos + totemProxy.GetUpVector()

		TraceResults results = TraceHull( startPos, endPos, <-8, -8, 0>, <8, 8, 32>, ignoreEnts, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER, totemProxy.GetUpVector() )
		if ( results.startSolid )
		{
			if ( DEATH_TOTEM_DEBUG )
			{
				DebugDrawBox( startPos, <-8,-8,0>, <8,8,32>,  100, 0, 0, 1, 3.0 )
				PrintTraceResults( results )
			}

			entity hitEnt = results.hitEnt
			if ( IsValid( hitEnt ) )
			{
				string hitEntClassname = hitEnt.GetClassName()

				if ( hitEntClassname == "worldspawn"
				|| hitEntClassname == "phys_bone_follower"
				|| hitEntClassname == "func_brush"
				|| hitEntClassname == "script_mover"
				|| hitEntClassname == "func_brush_lightweight"
				|| hitEntClassname == "prop_dynamic"
				)
				{
					if ( Time() - startTime < 0.2 )
					{
						entity owner = totemProxy.GetBossPlayer()
						if ( IsValid( owner ) )
						{
							entity weapon = owner.GetOffhandWeapon( OFFHAND_ULTIMATE )
							if ( IsValid( weapon ) )
							{
								//PIN_PlayerItemDestruction( owner, ITEM_DESTRUCTION_TYPES.REV_TOTEM, { location = results.endPos, hitClass = hitEntClassname } )
								weapon.w.wasCharged = true

								//OnWeaponDeactivate callback will be called before this thread if ult is disabled by silence as it is spawning, meaning that wasCharged would not have been set to true yet and the ammo will be consumed.
								//Inside the OnWeaponDeactivate callback we only set ammo back to 0 if weapon.w.wasCharged == false.
								//So when ults are disabled, refund here instead as we've missed the OnWeaponDeactivate callback.  May be worth revisiting this with the larger "ult refund" pass.
								weapon.SetWeaponPrimaryClipCount( weapon.GetWeaponPrimaryClipCountMax() )
							}
							else
							{
								Warning( "Rev ult being destroyed immediately after creation, player is valid but weapon is not!  Location = <%.2f, %.2f, %.2f>", results.endPos.x, results.endPos.y, results.endPos.z )
							}
						}
					}

					waitthread DeathTotem_RemoveTotem( totemProxy, null )
					break
				}
			}
		}
		else
		{
			if ( DEATH_TOTEM_DEBUG )
				DebugDrawBox( results.endPos, <-8,-8,0>, <8,8,32>, 100, 0, 0, 1, 0.3 )
		}

		WaitTime( 0.3 )
	}
}

void function DeathTotem_RemoveTotem( entity totemProxy, entity mover )
{
	OnThreadEnd
	(
		void function () : ( mover, totemProxy )
		{
			if ( IsValid( mover ) )
			{
				mover.Destroy()
			}
			if ( IsValid( totemProxy ) )
			{
				delete file.totemData[ totemProxy ]
				totemProxy.Destroy()
			}
		}
	)

	if ( IsValid( totemProxy ) )
	{
		totemProxy.EndSignal( "OnDestroy" )
		totemProxy.SetTakeDamageType( DAMAGE_NO )
		totemProxy.NotSolid()
		StopSoundOnEntity( totemProxy, "Revenant_Totem_Loop" )
		StopSoundOnEntity( totemProxy, "Revenant_Totem_Loop_Enemy" )
		if ( totemProxy.GetHealth() > 1 && !totemProxy.IsDissolving() ) //Dissolving means it was destroyed by an EMP
		{
			totemProxy.Anim_PlayOnly( "prop_revenant_totem_shutdown" )
			EmitSoundOnEntity( totemProxy, "Revenant_Totem_End" )
		}
		else
		{
			totemProxy.Anim_PlayOnly( "prop_revenant_totem_destroy" )
			EmitSoundOnEntity( totemProxy, "Revenant_Totem_End" )
		}
		Highlight_ClearOwnedHighlight( totemProxy )
		Highlight_ClearFriendlyHighlight( totemProxy )
		thread PROTO_FadeModelAlphaOverTime( totemProxy, 1.0 )
		WaittillAnimDone( totemProxy )

		//waitthread PROTO_FadeModelAlphaOverTime( totemProxy, 1.0 )
	}
}

void function DeathTotem_OnTotemDamaged( entity totemProxy, var damageInfo )
{
	entity attacker = DamageInfo_GetAttacker( damageInfo )
	if ( !IsValid( attacker ) )
		return

	int trapTeam     = totemProxy.GetTeam()
	int attackerTeam = attacker.GetTeam()
	entity owner = totemProxy.GetOwner()

	if ( IsFriendlyTeam( attackerTeam, trapTeam ) && attacker != owner )
	{
		DamageInfo_ScaleDamage( damageInfo, 0.0 )
		return
	}

	entity inflictor = DamageInfo_GetInflictor( damageInfo )
	if ( !IsValid( inflictor ) )
		return

	//Check team of inflictor, this is to cover cases like caustic barrels.
	int inflictorTeam = inflictor.GetTeam()
	if ( IsFriendlyTeam( inflictorTeam, trapTeam ) && inflictor != owner && inflictor.GetOwner() != owner )
	{
		DamageInfo_ScaleDamage( damageInfo, 0.0 )
		return
	}
}

void function DeathTotem_OnTotemPostDamaged( entity totemProxy, var damageInfo )
{
	entity attacker = DamageInfo_GetAttacker( damageInfo )
	if ( !IsValid( attacker ) )
		return

	int trapTeam = totemProxy.GetTeam()
	entity owner = totemProxy.GetOwner()

	int damage = int( DamageInfo_GetDamage( damageInfo ) )
	if ( damage <= 0 )
		return

	int health = totemProxy.GetHealth()
	if ( damage > health )
	{
		DamageInfo_ScaleDamage( damageInfo, 0.0 )
		totemProxy.SetHealth( 1 )
		totemProxy.SetTakeDamageType( DAMAGE_NO )

		if ( IsAlive( owner ) && attacker != owner )
		{
			PlayBattleChatterLineToSpeakerAndTeam( owner, "bc_totemDestroyed" )
		}
		else if ( !IsAlive( owner ) )
		{
			array <entity> totemTeammates = GetPlayerArrayOfTeam_Alive( trapTeam )
			if ( totemTeammates.len() > 0 )
			{
				totemTeammates.randomize()
				PlayBattleChatterLineToSpeakerAndTeam( totemTeammates[0], "bc_totemDestroyed" )
			}
		}

		totemProxy.Signal( "TotemDestroyed" )
	}

	int damageFlags = DamageInfo_GetCustomDamageType( damageInfo )
	if ( attacker.IsPlayer() && !IsBitFlagSet( damageFlags, DF_MELEE ) )
	{
		attacker.NotifyDidDamage( totemProxy, 0, DamageInfo_GetDamagePosition( damageInfo ), damageFlags,
			damage, DamageInfo_GetDamageFlags( damageInfo ) | DF_NO_HITBEEP,
			DamageInfo_GetHitGroup( damageInfo ), DamageInfo_GetWeapon( damageInfo ), DamageInfo_GetDistFromAttackOrigin( damageInfo ) )
	}
}

bool function DeathTotem_OnShadowHealthExhausted( entity player )
{
	if ( DeathTotem_PlayerCanRecall( player ) )
	{
		player.SetHealth( player.p.savedTotemHealth )
		thread DeathTotem_RecallPlayer( player )

		return true // Save the player from death
	}

	return false // Do not save the player from death
}

void function DeathTotem_RecallPlayer( entity player )
{
	Assert( DeathTotem_PlayerCanRecall( player ), "Player does not have marked location to recall to." )
	player.EndSignal( "OnDestroy" )
	vector startOrigin      = player.GetOrigin()
	vector recallAngles     = file.markedLocation[ player ].angles
	entity recallHoloMarker = file.markedLocation[ player ].holoMarker
	entity totemProxy       = file.markedLocation[ player ].totemProxy
	bool wasCrouched        = file.markedLocation[ player ].wasCrouched
	//vector velocity         = file.markedLocation[ player ].velocity
	vector totemOrigin      = totemProxy.GetOrigin()
	vector recallOrigin     = (IsValid( recallHoloMarker ) ? recallHoloMarker.GetOrigin() : totemOrigin)

	//If the player is reviving a teammate, force end synced animation before attempting to return player to totem.
	Bleedout_ReviveForceStop( player )

	//Detach Any Sticky Entities on character
	foreach( ent in GetChildren( player ) )
	{
		if ( IsValid( ent ) && ent.IsProjectile() )
		{
			ent.ClearParent()
			ent.SetPhysics( MOVETYPE_FLYGRAVITY )
		}
	}

	player.p.totemRecallTime = Time()

	thread CreateShadowToRecallLocation( player, player.GetWorldSpaceCenter(), recallOrigin + <0, 0, 40> )

	EmitSoundOnEntityOnlyToPlayer( player, player, "DeathProtection_ReturnToTotem_Start_1p" )
	EmitSoundAtPositionExceptToPlayer( TEAM_ANY, startOrigin, player, "DeathProtection_ReturnToTotem_Start_3p" )
	PlayBattleChatterLineToSpeakerAndTeam( player, "bc_totemReturn" )


	// =============== GROSS ==================
	// we really should come up with a bettter
	// way to have death totem clear players from random positions
	// ========================================

	                
		//if player is crafting, wait for detach
		if ( player.GetParent() != null && player.GetParent().GetScriptName() == "crafting_workbench_cluster" )
			player.WaitSignal( "CraftingPlayerDetached" )
       

	PreparePlayerForPositionReset( player )

	//if this is after player.Signal( "DeathTotem_PreRecallPlayer" ), then ValkUlt_DeployToPeakStateForValk will end as it has it as a thread endSignal.
	//This will make a call to Player_EndSkywardLaunch, so any checks in here for Player_IsSkywardLaunching will not pass.
	player.Signal( "DeathTotem_PreRecallPlayer" )
	player.Signal( "PhaseTunnel_CancelPhaseTunnelUse" ) // in case SetOrigin puts you in a phase tunnel

	if ( StatusEffect_GetSeverity( player, eStatusEffect.placing_phase_tunnel )  > 0)
		player.Signal( "PhaseTunnel_CancelPlacement" )

	if ( player.IsGrappleActive() )
		player.GrappleDetach()

	// =============== END GROSS ==============

	//PlayerMelee_ClearPlayerAsLungeTarget( player, true )

	if ( wasCrouched )
	{
		thread DeathTotem_CrouchPlayer( player )
		// force ducks a player to test them while crouching since force crouch doesn't update player hullsize until next frame

	}
	else
	{
		thread DeathTotem_StandPlayer( player )
		//If we would recall to a spot where we are stuck in geo, put us in a safe location.
	}

	vector playerStartLoc = player.GetOrigin()
	if ( DEATH_TOTEM_DEBUG )
	{
		DebugDrawSphere( playerStartLoc, 10, 0,255,125,false, 5.0 )
		DebugDrawSphere( totemOrigin, 5, 0,255,125,false, 5.0 )
		DebugDrawSphere( recallOrigin, 10, 0,255,125,false, 5.0 )
	}

	bool safeSpotSuccess = PutPlayerInSafeSpot( player, ( IsValid( totemProxy  ) ? totemProxy : null ), null, recallOrigin, recallOrigin )

	if ( !safeSpotSuccess )
	{
		Warning( "WARNING Death Totem Player Recalled [" + player + "] failed to be placed using PutEntityInSafeSpot to recallOrigin")
		player.SetOrigin( totemOrigin )
	}

	float distSqrFromRecallPos = DistanceSqr( player.GetOrigin(), recallOrigin )
	if ( distSqrFromRecallPos >= ( 20*20 ) )
	{
		float dist = sqrt( distSqrFromRecallPos )
		Warning( "WARNING Death Totem Player Recalled [" + player + "] was " + dist + " units from RecallOrigin!")
		printt( "\t Info below:\n" + "\t StartPos: " + playerStartLoc + "\n" + "\t totemOrigin: " + totemOrigin + "\n" + "\t recallOrigin: " + recallOrigin + "\n" + "\t wasCrouched: " + wasCrouched + "\n")
	}

	if ( DEATH_TOTEM_DEBUG )
	{
		float dist = sqrt( distSqrFromRecallPos )
		printt( "Death Totem Player Recalled was " + dist + " units from RecallOrigin" )
		DebugDrawSphere( player.GetOrigin(), 20, 0,255,125,false, 5.0 )
		DebugDrawLine( playerStartLoc, player.GetOrigin(), 0,255,125,false, 5.0 )

	}

	player.SetAngles( recallAngles )

	player.SetVelocity( <0,0,0> )

	float moveSlowAmount = GetCurrentPlaylistVarFloat( "revenant_totem_recall_slow_amount", 0.9 )
	float moveSlowDuration = GetCurrentPlaylistVarFloat( "revenant_totem_recall_slow_duration", 1.5 )
	float moveSlowEaseOut = GetCurrentPlaylistVarFloat( "revenant_totem_recall_slow_easeOut", 0.5 )

	if ( moveSlowAmount > 0 && moveSlowDuration > 0 )
		StatusEffect_AddTimed( player, eStatusEffect.move_slow, moveSlowAmount, moveSlowDuration, moveSlowEaseOut )

	StatusEffect_AddTimed( player, eStatusEffect.death_totem_recall, 1.0, SCREEN_FX_STATUS_EFFECT_DURATION, SCREEN_FX_STATUS_EFFECT_EASE_OUT_TIME )
	//ScreenFade( player, 0, 0, 0, 255, 0.25, 0.25, (FFADE_IN | FFADE_PURGE) )

	//SetEntityIsBurning( player, false )
	player.Server_InvalidateLagCompensationRecords() // EXTREMELY DANGEROUS - Talk to Code before using!!!
	player.Signal( DEATH_TOTEM_RECALL_SIGNAL )

	thread DeathTotem_InvincibilityFramesAfterRecall( player )

//	EndPlayerSkyDive( player )
	Signal( player, SIGNAL_TELEPORTED )
}

void function DeathTotem_InvincibilityFramesAfterRecall( entity player )
{
	EndSignal( player, "OnDestroy", "CleanUpPlayerAbilities" )

	OnThreadEnd
	(
		void function() : ( player )
		{
			if ( IsValid( player ) )
				player.ClearInvulnerable()
		}
	)

	player.SetInvulnerable()

	wait SCREEN_FX_STATUS_EFFECT_DURATION
}

void function CreateShadowToRecallLocation( entity player, vector startPosition, vector endPosition )
{
	entity mover = CreateScriptMover_NEW( DEATH_TOTEM_MOVER_SCRIPTNAME + "__shadow_recallMover", startPosition )
	mover.SetOrigin( startPosition )
	mover.RemoveFromAllRealms()
	mover.AddToOtherEntitysRealms( player )

	entity fx = StartParticleEffectOnEntity_ReturnEntity( mover, GetParticleSystemIndex( DEATH_TOTEM_SHADOW_RECALL_FX ), FX_PATTACH_POINT_FOLLOW, mover.LookupAttachment( "REF" ) )
	EmitSoundOnEntityExceptToPlayer( mover, player, "DeathProtection_ReturnToTotem_Travel_3p" )

	wait 0.1

	float duration = 0.5
	mover.NonPhysicsMoveTo( endPosition, duration, 0.0, 0.0 )

	wait duration

	// fx.Destroy()
	mover.Destroy()
}

void function DeathTotem_PlayerRecallCleanup( entity player )
{
	StartParticleEffectOnEntity( player, GetParticleSystemIndex( DEATH_TOTEM_SHADOW_DEATH_FX ), FX_PATTACH_POINT, player.LookupAttachment( "CHESTFOCUS" ) )

	int statusID = file.markedLocation[ player ].statusEffectID
	StatusEffect_Stop( player, statusID )

	entity totemProxy = file.markedLocation[ player ].totemProxy
	if ( totemProxy in file.totemData )
	{
		int arrayID = file.totemData[ totemProxy ].scriptManagedPlayerArrayID
		RemoveFromScriptManagedEntArray( arrayID, player )
	}

	entity holoMarker = file.markedLocation[ player ].holoMarker
	if ( IsValid( holoMarker ) )
		holoMarker.Decoy_Die()
	entity holoRadius = file.markedLocation[ player ].holoRadius
	if ( IsValid( holoRadius ) )
		holoRadius.Destroy()
	entity holoRadiusUpper = file.markedLocation[ player ].holoRadiusUpper
	if ( IsValid( holoRadiusUpper ) )
		holoRadiusUpper.Destroy()
	entity holoBase = file.markedLocation[ player ].holoBase
	if ( IsValid( holoBase ) )
		holoBase.Destroy()

	delete file.markedLocation[ player ]
}

void function DeathTotem_CreateHoloPilotRecallMarker( entity player, RecallData data, entity totemProxy )
{
	float stickPercentToRun = 1.0

	//CreateAnimatedPlayerDecoy
	entity decoy = player.CreatePlayerDecoy( $"", $"", -1, -1, stickPercentToRun, false )
	decoy.SetCollisionAllowed( false )
	decoy.SetMaxHealth( 50 )
	decoy.SetHealth( 50 )
	decoy.SetTakeDamageType( DAMAGE_NO )
	decoy.SetOwner( player )
	decoy.SetCanBeMeleed( false )
	decoy.SetTimeout( -1 )
	decoy.kv.VisibilityFlags = ENTITY_VISIBLE_TO_NOBODY
	decoy.SetParent( totemProxy )

	DeathTotem_SetupDecoy( player, decoy )

	entity base = CreatePropDynamic( DEATH_TOTEM_BASE_MDL, decoy.GetOrigin(), decoy.GetAngles(), 0 )
	base.DisableHibernation()
	base.SetOwner( player )
	base.kv.VisibilityFlags = ENTITY_VISIBLE_TO_EVERYONE
	//DropToGround( base )
	base.Hide()

	TraceResults traceResults = TraceLine( base.GetOrigin(), base.GetOrigin() + <0, 0, -100>, [base, decoy, player], TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_NONE )
	if ( EntityShouldStick( base, traceResults.hitEnt ) && !traceResults.hitEnt.IsWorld() )
		base.SetParent( traceResults.hitEnt )

	//Model that visualizes the max mark recall radius.
	entity markRadius = CreateEntity( "prop_dynamic" )
	markRadius.SetValueForModelKey( DEATH_TOTEM_RADIUS_MDL )
	markRadius.kv.VisibilityFlags = ENTITY_VISIBLE_TO_OWNER
	markRadius.kv.solid = 0 // 0 = no collision, 2 = bounding box, 6 = use vPhysics, 8 = hitboxes only
	markRadius.kv.fadedist = -1
	markRadius.kv.renderamt = 255
	markRadius.kv.rendercolor = "255 255 255"

	// hack: Setting origin twice. SetOrigin needs to happen before DispatchSpawn, otherwise the prop may not touch triggers
	markRadius.SetOrigin( base.GetOrigin() )

	DispatchSpawn( markRadius )
	// hack: Setting origin twice. SetOrigin needs to happen after DispatchSpawn, otherwise origin is snapped to nearest whole unit
	markRadius.SetOrigin( totemProxy.GetOrigin() )
	markRadius.SetAngles( <0, 0, 0> )
	markRadius.SetOwner( player )
	markRadius.SetParent( totemProxy )

	entity markRadiusUpper = CreateEntity( "prop_dynamic" )
	markRadiusUpper.SetValueForModelKey( DEATH_TOTEM_RADIUS_MDL )
	markRadiusUpper.kv.VisibilityFlags = ENTITY_VISIBLE_TO_OWNER
	markRadiusUpper.kv.solid = 0 // 0 = no collision, 2 = bounding box, 6 = use vPhysics, 8 = hitboxes only
	markRadiusUpper.kv.fadedist = -1
	markRadiusUpper.kv.renderamt = 255
	markRadiusUpper.kv.rendercolor = "255 255 255"

	// hack: Setting origin twice. SetOrigin needs to happen before DispatchSpawn, otherwise the prop may not touch triggers
	markRadiusUpper.SetOrigin( base.GetOrigin() )

	DispatchSpawn( markRadiusUpper )
	// hack: Setting origin twice. SetOrigin needs to happen after DispatchSpawn, otherwise origin is snapped to nearest whole unit
	markRadiusUpper.SetOrigin( totemProxy.GetOrigin() )
	markRadiusUpper.SetAngles( <0, 0, 180> )
	markRadiusUpper.SetOwner( player )
	markRadiusUpper.SetParent( totemProxy )

	if ( file.revenant_totem_has_distance_limit )
	{
		thread DeathTotem_MarkEndOnDistanceUpdate( player, totemProxy ) //Desync and destroy mark if player moves too far.
	}
	else
	{
		markRadius.Hide()
		markRadiusUpper.Hide()
	}

	data.holoMarker = decoy
	data.holoRadius = markRadius
	data.holoRadiusUpper = markRadiusUpper
	data.holoBase = base
}

void function DeathTotem_SetupDecoy( entity player, entity decoy )
{
	decoy.SetDeathNotifications( false )
	decoy.SetPassThroughThickness( 0 )
	decoy.SetNameVisibleToOwner( false )
	decoy.SetNameVisibleToFriendly( false )
	decoy.SetNameVisibleToEnemy( false )
	decoy.SetFlickerRate( 1.0 )
	decoy.SetDecoyRandomPulseRateMax( 0.5 ) //pulse amount per second
	decoy.SetFadeDistance( DECOY_FADE_DISTANCE )
	decoy.SetNoTarget( true )
	decoy.SetNoTargetSmartAmmo( true )
	decoy.SetTitle( "#WPN_DEATH_TOTEM_TITLE" )
	//decoy.SetHasMovement( false )

	int friendlyTeam = decoy.GetTeam()
	//decoy.decoy.loopingSounds = [ "holopilot_loop" ]

	Highlight_SetFriendlyHighlight( decoy, HIGHLIGHT_FRIENDLY_PLAYER_DECOY )
	Highlight_SetOwnedHighlight( decoy, HIGHLIGHT_FRIENDLY_PLAYER_DECOY )
	decoy.e.hasDefaultEnemyHighlight = player.e.hasDefaultEnemyHighlight
	SetDefaultMPEnemyHighlight( decoy )

	int attachID = decoy.LookupAttachment( "CHESTFOCUS" )

	var childEnt = player.FirstMoveChild()
	while ( childEnt != null )
	{
		expect entity( childEnt )

		bool isBattery      = false
		bool createHologram = false
		switch ( childEnt.GetClassName() )
		{
			case "item_titan_battery":
			{
				isBattery = true
				createHologram = true
				break
			}

			case "item_flag":
			{
				createHologram = true
				break
			}
		}

		asset modelName = childEnt.GetModelName()
		if ( createHologram && modelName != $"" && childEnt.GetParentAttachment() != "" )
		{
			entity decoyChildEnt = CreatePropDynamic( modelName, <0, 0, 0>, <0, 0, 0>, 0 )
			decoyChildEnt.Highlight_SetInheritHighlight( true )
			decoyChildEnt.SetParent( decoy, childEnt.GetParentAttachment() )

			thread DeathTotem_DecoyFlagFX( decoy, decoyChildEnt )
		}

		childEnt = childEnt.NextMovePeer()
	}

	entity holoPilotTrailFXFriendly = StartParticleEffectOnEntity_ReturnEntity( decoy, GetParticleSystemIndex( DEATH_TOTEM_SHADOW_MARKER_FX ), FX_PATTACH_POINT_FOLLOW, attachID )

	decoy.decoy.fxHandles.append( holoPilotTrailFXFriendly )
	decoy.SetFriendlyFire( false )
	decoy.SetKillOnCollision( false )
}

//Handles case in which mark recall user is kill with a recall point active.
void function DeathTotem_HandleUserDeathOrDesync( entity player, entity totemProxy )
{
	Assert ( IsNewThread(), "Must be threaded off." )
	player.EndSignal( "OnDestroy", "OnDeath", DEATH_TOTEM_RECALL_SIGNAL )
	player.EndSignal( "DeathTotem_ForceEnd", "CleanUpPlayerAbilities" )
	totemProxy.EndSignal( "OnDestroy" )

	player.EnterShadowForm()
	player.p.savedTotemHealth = minint( DEATH_TOTEM_DEATH_PROTECTION_RECALL_REVIVE_HEALTH, player.GetHealth() )
	int currentHealth = player.GetHealth()
	int shadowHealth  = minint( currentHealth, DEATH_TOTEM_MAX_SHADOW_HEALTH_AMOUNT )
	if ( shadowHealth != currentHealth )
		player.SetHealth( shadowHealth )

	AddEntityCallback_OnShadowHealthExhausted( player, DeathTotem_OnShadowHealthExhausted )

	ShadowSquadApplyCharacterSkin( player )

	entity FX_BODY
	FX_BODY = StartParticleEffectOnEntity_ReturnEntity( player, GetParticleSystemIndex( DEATH_TOTEM_SHADOW_BODY_FX ), FX_PATTACH_POINT_FOLLOW, player.LookupAttachment( "CHESTFOCUS" ) )
	FX_BODY.kv.VisibilityFlags = ENTITY_VISIBLE_TO_FRIENDLY | ENTITY_VISIBLE_TO_ENEMY
	FX_BODY.SetOwner( player )

	entity FX_EYE_L
	if ( player.LookupAttachment( "EYE_L" ) > 0 )
	{
		FX_EYE_L = StartParticleEffectOnEntity_ReturnEntity( player, GetParticleSystemIndex( DEATH_TOTEM_SHADOW_EYE_FX ), FX_PATTACH_POINT_FOLLOW, player.LookupAttachment( "EYE_L" ) )
		FX_EYE_L.kv.VisibilityFlags = ENTITY_VISIBLE_TO_FRIENDLY | ENTITY_VISIBLE_TO_ENEMY
		FX_EYE_L.SetOwner( player )
	}

	entity FX_EYE_R
	if ( player.LookupAttachment( "EYE_R" ) > 0 )
	{
		FX_EYE_R = StartParticleEffectOnEntity_ReturnEntity( player, GetParticleSystemIndex( DEATH_TOTEM_SHADOW_EYE_FX ), FX_PATTACH_POINT_FOLLOW, player.LookupAttachment( "EYE_R" ) )
		FX_EYE_R.kv.VisibilityFlags = ENTITY_VISIBLE_TO_FRIENDLY | ENTITY_VISIBLE_TO_ENEMY
		FX_EYE_R.SetOwner( player )
	}

	EmitSoundOnEntityExceptToPlayer( player, player, "DeathProtection_Activate_3p" ) // 3p Activate
	EmitSoundOnEntityToTeamExceptPlayer( player, "DeathProtection_Loop_3p", player.GetTeam(), player )
	EmitSoundOnEntityToEnemies( player, "DeathProtection_Loop_3p_Enemy", player.GetTeam() )

	OnThreadEnd
	(
		void function() : ( player, FX_BODY, FX_EYE_L, FX_EYE_R )
		{
			if ( IsValid( FX_BODY ) )
			{
				FX_BODY.ClearParent()
				EffectStop( FX_BODY )
			}
			if ( IsValid( FX_EYE_L ) )
			{
				FX_EYE_L.ClearParent()
				EffectStop( FX_EYE_L )
			}
			if ( IsValid( FX_EYE_R ) )
			{
				FX_EYE_R.ClearParent()
				EffectStop( FX_EYE_R )
			}
			if ( IsValid( player ) )
			{
				ShadowSquadCancelCharacterSkin( player )

				if ( player in file.markedLocation )
				{
					DeathTotem_PlayerRecallCleanup( player )
				}

				StopSoundOnEntity( player, "DeathProtection_Loop_3p" ) // 3p loop
				StopSoundOnEntity( player, "DeathProtection_Loop_3p_Enemy" ) // 3p loop
				EmitSoundOnEntityExceptToPlayer( player, player, "DeathProtection_End_3p" ) // 3p deactivate
				player.LeaveShadowForm()
				RemoveEntityCallback_OnShadowHealthExhausted( player, DeathTotem_OnShadowHealthExhausted )
				player.Signal( "DeathTotem_ForceEnd" )
			}
		}
	)
	float waitDurationBeforeWarning = file.deathTotemBuffDuration - DEATH_TOTEM_EXPIRATION_WARNING_DELAY_3P
	Assert(waitDurationBeforeWarning > 0, "Warning delay can't be more than total death totem duration")
	wait waitDurationBeforeWarning

	if ( file.showEndOfBuffFX )
	{
		entity FX_TIMER = StartParticleEffectOnEntity_ReturnEntity( player, GetParticleSystemIndex( DEATH_TOTEM_SHADOW_TIMER_FX ), FX_PATTACH_POINT_FOLLOW, player.LookupAttachment( "CHESTFOCUS" ) )
		EffectSetControlPointVector( FX_TIMER, 1, <4,0,0> )
		FX_TIMER.SetOwner( player )
		FX_TIMER.kv.VisibilityFlags = (ENTITY_VISIBLE_TO_FRIENDLY | ENTITY_VISIBLE_TO_ENEMY)

		EmitSoundOnEntityExceptToPlayer( player, player, "DeathProtection_WarningToEnd_3p" )

		OnThreadEnd
		(
			void function() : ( FX_TIMER )
			{
				if ( IsValid( FX_TIMER ) )
				{
					FX_TIMER.ClearParent()
					EffectStop( FX_TIMER )
				}
			}
		)
	}

	wait DEATH_TOTEM_EXPIRATION_WARNING_DELAY_3P - DEATH_TOTEM_EXPIRATION_WARNING_DELAY

	EmitSoundOnEntityOnlyToPlayer( player, player, "DeathProtection_WarningToEnd_1p" ) // 1p death protection is about to end warning sound
	wait DEATH_TOTEM_EXPIRATION_WARNING_DELAY
}



#if SERVER
void function ShadowSquadApplyCharacterSkin( entity player )
{
	                            
		// Don't want shadow shader in this mode
		//if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_SHADOW_ARMY ) )
			//return
       

	//////////////////////////////////////////////
	// Switch to base character model for Legend
	/////////////////////////////////////////////
	ItemFlavor character = LoadoutSlot_GetItemFlavor( ToEHI( player ),  Loadout_CharacterClass() )
	ItemFlavor skin = GetDefaultItemFlavorForLoadoutSlot( ToEHI( player ), Loadout_CharacterSkin( character ) )
	CharacterSkin_Apply( player, skin )

	//////////////////////////////////////
	// Apply the shadow skin material if we have it
	//////////////////////////////////////

	SetShadowAbilitiesSkin( player )
}
#endif //SERVER


#if SERVER
void function SetShadowAbilitiesSkin( entity player )
{
	int skinIdx = player.GetSkinIndexByName( "ShadowSqaud" )
	if ( skinIdx > 0 )
	{
		player.SetSkin( skinIdx )
		player.SetCamo( 0 )
	}
	else //otherwise just tint the player full black till we get the skin
	{
		player.kv.rendercolor = <0, 0, 0>
	}
}
#endif //SERVER



#if SERVER
void function ShadowSquadCancelCharacterSkin( entity player )
{
	ItemFlavor character = LoadoutSlot_GetItemFlavor( ToEHI( player ),  Loadout_CharacterClass() )
	LoadoutEntry skinSlot = Loadout_CharacterSkin( character )
	ItemFlavor skin = LoadoutSlot_GetItemFlavor( ToEHI( player ), skinSlot )

	player.kv.rendercolor = "255 255 255 255"
	CharacterSkin_Apply( player, skin )
}
#endif //SERVER

void function DeathTotem_CrouchPlayer( entity player )
{
	Assert ( IsNewThread(), "Must be threaded off." )
	Signal( player, "DeathTotem_ChangePlayerStance" )
	EndSignal( player, "OnDeath", "DeathTotem_ChangePlayerStance" )
	
	/*int forceCrouchHandle = player.PushForcedStance( FORCE_STANCE_CROUCH )
	OnThreadEnd(
		function() : ( player, forceCrouchHandle )
		{
			if ( IsValid( player ) )
			{
				player.RemoveForcedStance( forceCrouchHandle )
			}
		}
	)*/
	
	player.ForceCrouch()
	
	OnThreadEnd
	(
		void function() : ( player )
		{
			if( IsValid( player ) )
				player.UnforceCrouch()
		}
	)
	
	wait 0.2
}

void function DeathTotem_StandPlayer( entity player )
{
	Assert ( IsNewThread(), "Must be threaded off." )
	Signal( player, "DeathTotem_ChangePlayerStance" )
	EndSignal( player, "OnDeath", "DeathTotem_ChangePlayerStance", "CleanUpPlayerAbilities" )
	/*int forceStandHandle = player.PushForcedStance( FORCE_STANCE_STAND )
	OnThreadEnd(
		function() : ( player, forceStandHandle )
		{
			if ( IsValid( player ) )
			{
				player.RemoveForcedStance( forceStandHandle )
			}
		}
	)*/
	
	player.ForceStand()
	
	OnThreadEnd
	(
		void function() : ( player )
		{
			if( IsValid( player ) )
				player.UnforceStand()
		}
	)
	
	wait 0.2
}



void function DeathTotem_MarkEndOnDistanceUpdate( entity player, entity totemProxy )
{
	Assert ( IsNewThread(), "Must be threaded off." )

	player.EndSignal( "OnDeath", "OnDestroy", DEATH_TOTEM_RECALL_SIGNAL )
	player.EndSignal( "DeathTotem_ForceEnd", "CleanUpPlayerAbilities" )
	totemProxy.EndSignal( "OnDestroy" )

	float lastInRangeTime = Time()

	OnThreadEnd
	(
		void function() : ( player )
		{
			if ( IsValid( player ) )
				StopSoundOnEntity( player, "DeathProtection_ExpirationWarning_1p" ) //
		}
	)

	bool soundStarted = false
	while ( true )
	{
		WaitFrame()
		int attachID  = player.LookupAttachment( "HEADFOCUS" )
		vector origin = player.GetAttachmentOrigin( attachID )
		float distSqr = Distance2DSqr( origin, totemProxy.GetOrigin() ) //2D distance squared

		if ( distSqr >= DEATH_TOTEM_DISTORTION_RANGE_MIN_SQR )
		{
			if ( !soundStarted )
			{
				EmitSoundOnEntityOnlyToPlayer( player, player, "DeathProtection_ExpirationWarning_1p" )
				soundStarted = true
			}

			//If we are out of range for too long, desync the mark
			//Note: if the player runs father out of range they will desync faster.
			float desyncTime = GraphCapped( distSqr, DEATH_TOTEM_DISTORTION_RANGE_MIN_SQR, DEATH_TOTEM_DISTORTION_RANGE_MAX_SQR, DEATH_TOTEM_OUT_OF_RANGE_DESYNC_TIME, 0.0 )
			if ( lastInRangeTime + desyncTime < Time() )
			{
				player.Signal( "DeathTotem_ForceEnd" )
			}
		}
		else
		{
			lastInRangeTime = Time()
			StopSoundOnEntity( player, "DeathProtection_ExpirationWarning_1p" )
			soundStarted = false
		}
	}
}

void function DeathTotem_DecoyFlagFX( entity decoy, entity decoyChildEnt )
{
	decoy.EndSignal( "OnDeath" )
	decoy.EndSignal( "CleanupFXAndSoundsForDecoy" )

	SetTeam( decoyChildEnt, decoy.GetTeam() )
	entity flagTrailFX
	if ( decoyChildEnt.LookupAttachment( "fx_end" ) > 0 ) //using a defensive fix instead of investigating because I think we're going to remove everything related to the decoy.
	{
		flagTrailFX = StartParticleEffectOnEntity_ReturnEntity( decoyChildEnt, GetParticleSystemIndex( DECOY_FX ), FX_PATTACH_POINT_FOLLOW, decoyChildEnt.LookupAttachment( "fx_end" ) )
		flagTrailFX.kv.VisibilityFlags = ENTITY_VISIBLE_TO_ENEMY
	}

	OnThreadEnd
	(
		void function() : ( flagTrailFX, decoyChildEnt )
		{
			if ( IsValid( flagTrailFX ) )
				flagTrailFX.Destroy()

			if ( IsValid( decoyChildEnt ) )
				decoyChildEnt.Destroy()
		}
	)

	WaitForever()
}

#endif // SERVER

void function DeathTotem_UseTotem( entity player, entity totemProxy )
{
	if ( !DeathTotem_PlayerCanRecall( player ) )
		DeathTotem_MarkLocation( player, totemProxy )
}


void function DeathTotem_MarkLocation( entity player, entity totemProxy )
{
	Assert( !DeathTotem_PlayerCanRecall( player ), "Player already has marked location." )

	int statusEffectID = StatusEffect_AddTimed( player, eStatusEffect.death_totem_visual_effect, 1.0, file.deathTotemBuffDuration, 0.0 )

	#if SERVER
		if ( player.IsMantling() )
			player.ClearTraverse()

		int arrayID = file.totemData[ totemProxy ].scriptManagedPlayerArrayID
		Assert( !ScriptManagedEntArrayContains( arrayID, player ), "Player is already marked on this totem" )
		AddToScriptManagedEntArray( arrayID, player )

		RecallData data
		data.origin = player.GetOrigin()
		data.angles = player.GetAngles()
		data.velocity = player.GetVelocity()
		data.wasCrouched = player.IsCrouched()
		data.wasInContextAction = player.ContextAction_IsActive()
		data.statusEffectID = statusEffectID
		data.totemProxy = totemProxy
		DeathTotem_CreateHoloPilotRecallMarker( player, data, totemProxy )
		file.markedLocation[ player ] <- data

		if ( DEATH_TOTEM_DEBUG )
		{
			DebugDrawSphere( data.origin, 10, 255, 100, 0, false, DEATH_TOTEM_EFFECT_DURATION_DEFAULT )
			DebugDrawText( data.origin, (data.wasCrouched ? "Standing" : "Crouched"), false, DEATH_TOTEM_EFFECT_DURATION_DEFAULT )
		}

		thread DeathTotem_HandleUserDeathOrDesync( player, totemProxy )
	#endif // SERVER
}


bool function DeathTotem_PlayerCanRecall( entity player )
{
	bool canRecall = false
	#if SERVER
		canRecall = ( player in file.markedLocation && IsAlive( player ) )
	#else
		canRecall = file.hasMark && IsAlive( player )
	#endif //SERVER

	return canRecall
}


bool function DeathTotem_CanUseTotem( entity player, entity ent, int useFlags )
{
	if ( !IsValid( player ) )
		return false

	if ( DeathTotem_PlayerCanRecall( player ) )
		return false

	if ( Bleedout_IsBleedingOut( player ) )
		return false

	if ( player.IsPhaseShifted() )
		return false

	array <entity> activeWeapons = player.GetAllActiveWeapons()
	if ( activeWeapons.len() == 1 )
	{
		entity activeWeapon = activeWeapons[0]
		if ( IsValid( activeWeapon ) )
		{
			if ( IsBitFlagSet( activeWeapon.GetWeaponTypeFlags(), WPT_CONSUMABLE ) )
				return false
		}
	}

	return true
}


void function DeathTotem_OnTotemUse( entity totemProxy, entity player, int useInputFlags )
{
	if ( IsBitFlagSet( useInputFlags, USE_INPUT_DEFAULT ) )
	{
		bool canPlayerRecall = DeathTotem_PlayerCanRecall( player )

		//If the player has already used this totem and recalled, do not let them use it again.
		if ( file.totemData[ totemProxy ].markedPlayerArray.contains( player ) && !canPlayerRecall )
			return

		if ( !canPlayerRecall )
			file.totemData[ totemProxy ].markedPlayerArray.append( player )

		DeathTotem_UseTotem( player, totemProxy )

		#if CLIENT
			thread HideUsePromptOverrideThink( player )
		#endif
	}
}

#if CLIENT
//Client effects for the ultimate are triggered on the status effect callback, this results in there being a small delay where the use prompt flickers incorrect text.
void function HideUsePromptOverrideThink( entity player )
{
	player.EndSignal( "OnDestroy" )

	file.hideUsePromptOverride = true

	wait 2.0

	file.hideUsePromptOverride = false
}

void function DeathTotem_OnTotemCreated( entity ent )
{
	if ( ent.GetTargetName() == DEATH_TOTEM_TARGETNAME )
	{
		//Create Totem Data
		TotemData totemData
		file.totemData[ ent ] <- totemData

		//SetCallback_CanUseEntityCallback( ent, DeathTotem_CanUseTotem )
		AddCallback_OnUseEntity_ClientServer( ent, DeathTotem_OnTotemUse )
		AddEntityCallback_GetUseEntOverrideText( ent, DeathTotem_UseTextOverride )
		AddEntityDestroyedCallback( ent, DeathTotem_OnTotemDestroyed )
	}
}

string function DeathTotem_UseTextOverride( entity ent )
{
	entity player = GetLocalViewPlayer()
	if ( DeathTotem_PlayerCanRecall( player ) )
	{
		return ""
	}
	else
	{
		if ( file.hideUsePromptOverride )
			return ""
		else if ( file.totemData[ ent ].markedPlayerArray.contains( player ) )
			return "#DEATH_TOTEM_TOTEM_USED"
		else
			return "#DEATH_TOTEM_TOTEM_USE"
	}

	return ""
}

void function DeathTotem_OnTotemDestroyed( entity totem )
{
	// Need to make sure we don't show the ultimate in the "active" state, particularly if the totem was placed in geo and we got immediately refunded
	// That logic is all server-side though, so we're force-setting the weapon state state to be charging, so it can later become newly active
	if ( IsValid( totem ) && totem.GetBossPlayer() == GetLocalViewPlayer() )
		UltimateWeaponStateSet( eUltimateState.CHARGING )
}

void function DeathTotem_StartVisualEffect( entity ent, int statusEffect, bool actuallyChanged )
{
	if ( !actuallyChanged )
		return

	RefreshTeamDeathTotemHUD()

	if ( ent != GetLocalViewPlayer() )
		return

	if ( !IsValid( ent ) )
		return

	//Create Visual Rui with remaining time for Death Protection

	file.hasMark = true
	file.deathProtectionStatusRui = CreateFullscreenRui( $"ui/death_protection_status.rpak" )

	//RuiSetFloat( file.deathProtectionStatusRui, "maxDuration", file.deathTotemBuffDuration )
	RuiTrackFloat( file.deathProtectionStatusRui, "timeRemaining", ent, RUI_TRACK_STATUS_EFFECT_TIME_REMAINING, eStatusEffect.death_totem_visual_effect )
	//RuiTrackInt( file.deathProtectionStatusRui, "gameState", null, RUI_TRACK_SCRIPT_NETWORK_VAR_GLOBAL_INT, GetNetworkedVariableIndex( "gameState" ) )


	entity cockpit = ent.GetCockpit()
	if ( !IsValid( cockpit ) )
		return

	thread ShadowScreenFXThink( ent, cockpit )
}

void function DeathTotem_OnPlayerClassChanged( entity player )
{
	RefreshTeamDeathTotemHUD()
}

void function DeathTotem_ChangedTeamHUDUpdate( entity player, int oldTeam, int newTeam )
{
	RefreshTeamDeathTotemHUD()
}

void function RefreshTeamDeathTotemHUD()
{
	entity localViewPlayer  = GetLocalViewPlayer()
	array<entity> teammates = GetPlayerArrayOfTeam( localViewPlayer.GetTeam() )
	foreach ( ent in teammates )
	{
		if ( StatusEffect_GetSeverity( ent, eStatusEffect.death_totem_visual_effect ) == 0.0 )
			continue

		if ( ent == localViewPlayer )
		{
			//SetCustomPlayerInfoShadowFormState( localViewPlayer, true )
			SetCustomPlayerInfoColor( localViewPlayer, <245, 81, 35 > )
			SetCustomPlayerInfoTreatment( localViewPlayer, $"rui/hud/revenant_shadow_effects/player_info_shadow_mode" )
		}
		else
		{
			//SetUnitFrameShadowFormState( ent, true )
			SetUnitFrameCustomColor( ent, <245, 81, 35 > )
		}
	}
}

void function DeathTotem_StopVisualEffect( entity ent, int statusEffect, bool actuallyChanged )
{
	if ( !actuallyChanged )
		return

	entity localViewPlayer = GetLocalViewPlayer()

	if ( !IsValid( localViewPlayer ) )
		return

	if ( localViewPlayer.GetTeam() == ent.GetTeam() )
	{
		if ( ent == localViewPlayer )
		{
			//SetCustomPlayerInfoShadowFormState( localViewPlayer, false )
			ClearCustomPlayerInfoColor( localViewPlayer )
			ClearCustomPlayerInfoTreatment( localViewPlayer )
		}
		else
		{
			SetUnitFrameShadowFormState( ent, false )
			ClearUnitFrameCustomColor( ent )
		}
	}

	if ( ent != GetLocalViewPlayer() )
		return

	//Destroy Visual Rui with remaining time for Death Protection
	if ( file.deathProtectionStatusRui != null )
		RuiDestroyIfAlive( file.deathProtectionStatusRui )
	file.deathProtectionStatusRui = null

	file.hasMark = false
	ent.Signal( "DeathTotem_EndShadowScreenFx" )
}

void function ShadowScreenFXThink( entity player, entity cockpit )
{
	player.EndSignal( "OnDeath" )
	cockpit.EndSignal( "OnDestroy" )

	int fxHandle = StartParticleEffectOnEntity( cockpit, GetParticleSystemIndex( DEATH_TOTEM_SHADOW_SCREEN_FX ), FX_PATTACH_ABSORIGIN_FOLLOW, -1 )
	EffectSetIsWithCockpit( fxHandle, true )
	vector controlPoint = <1, 1, 1>
	EffectSetControlPointVector( fxHandle, 1, controlPoint )

	EmitSoundOnEntity( player, "DeathProtection_Activate_1p" ) // 1p activation sound
	EmitSoundOnEntity( player, "DeathProtection_Loop_1p" )  // 1p looping sound

	player.WaitSignal( "DeathTotem_EndShadowScreenFx" )

	StopSoundOnEntity( player, "DeathProtection_Loop_1p" )
	EmitSoundOnEntity( player, "DeathProtection_End_1p" ) // 1p end sound
	if ( EffectDoesExist( fxHandle ) )
		EffectStop( fxHandle, false, true )
}

void function DeathTotem_RecallVisualEffect( entity ent, int statusEffect, bool actuallyChanged )
{
	if ( !actuallyChanged )
		return

	if ( ent != GetLocalViewPlayer() )
		return

	thread DeathTotem_PlayRecallScreenFX( ent )
}

void function DeathTotem_PlayRecallScreenFX( entity clientPlayer )
{
	Assert ( IsNewThread(), "Must be threaded off." )
	clientPlayer.EndSignal( "OnDeath" )
	clientPlayer.EndSignal( "OnDestroy" )

	entity player = GetLocalViewPlayer()
	int indexD    = GetParticleSystemIndex( DEATH_TOTEM_TELEPORT_SCREEN_FX )
	int fxID      = -1

	if ( IsValid( player.GetCockpit() ) )
	{
		fxID = StartParticleEffectOnEntityWithPos( player, indexD, FX_PATTACH_ABSORIGIN_FOLLOW, -1, player.EyePosition(), <0, 0, 0> )
		EffectSetIsWithCockpit( fxID, true )
		EffectSetControlPointVector( fxID, 1, <1.0, 999, 0> )
	}

	OnThreadEnd
	(
		void function() : ( clientPlayer, fxID )
		{
			if ( IsValid( clientPlayer ) )
			{
				if ( fxID > -1 )
				{
					EffectStop( fxID, false, true )
				}
			}
		}
	)

	wait 0.25
}
#endif //CLIENT

void function OnWeaponActivate_ability_revenant_death_totem( entity weapon )
{
	entity weaponOwner = weapon.GetWeaponOwner()

	bool serverOrPredicted = IsServer() || ( InPrediction() && IsFirstTimePredicted() )
	if ( serverOrPredicted )
	{
		weapon.RemoveMod( ABILITY_USED_MOD )
	}

	#if SERVER
		vector angles = FlattenAngles( VectorToAngles( weaponOwner.GetViewVector() ) )
		TryPlayWeaponBattleChatterLine( weaponOwner, weapon )
		weapon.w.wasCharged = false
		weapon.w.wasFired = false
	#endif
}


void function OnWeaponDeactivate_ability_revenant_death_totem( entity weapon )
{
	entity ownerPlayer = weapon.GetWeaponOwner()
	Assert( ownerPlayer.IsPlayer() )
	weapon.Signal( "DeathTotem_RemoveWallClimbDisables" )

	#if SERVER
		if( weapon.w.wasFired )
		{
			UnlockWeaponsAndMelee_Retail( ownerPlayer, DEATH_TOTEM_WEAPON_NAME )
			weapon.w.wasFired = false
		}
	#endif
}


#if SERVER
void function CancelDeathTotemForPlayer( entity player )
{
	player.Signal( "DeathTotem_Cancel" )
}
#endif

bool function DoesPlayerHaveDeathProtection( entity player )
{
	return StatusEffect_GetSeverity( player, eStatusEffect.death_totem_visual_effect ) > 0.0 
}

//TODO: Add a minimum angle check to try to spawn the Totem slightly in front of you even when looking down.
DeathTotemPlacementInfo function CalculateDeathTotemPosition( entity weaponOwner, entity totemProxy )
{
	vector startPos   = weaponOwner.GetWorldSpaceCenter()
	vector viewVector = weaponOwner.GetViewVector()
	if ( viewVector.z >= 0 )
		viewVector = FlattenVec( viewVector )

	vector upVector      = weaponOwner.GetUpVector()
	vector downVector    = upVector * - 1
	vector forwardVector = weaponOwner.GetForwardVector()
	float dot            = downVector.Dot( viewVector )
	float angle          = DotToAngle( dot )
	float idealDistance  = IDEAL_TOTEM_DISTANCE
	vector velocity      = weaponOwner.GetVelocity()
	float velocityDot    = forwardVector.Dot( weaponOwner.GetVelocity() )
	if ( velocityDot > 0 )
		idealDistance += GraphCapped( velocityDot, 0, 300, 0, IDEAL_TOTEM_DISTANCE * 2 )
	float height   = startPos.z - weaponOwner.GetOrigin().z
	float maxAngle = RAD_TO_DEG * atan( idealDistance / height )
	if ( angle > maxAngle )
	{
		viewVector = ClampViewVectorToMaxAngle( downVector, viewVector, maxAngle )
		angle = maxAngle
	}
	float magnitude           = idealDistance / deg_sin( angle )
	//TraceResults traceResults = TraceLine( startPos, startPos + viewVector * magnitude, [weaponOwner], TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_NONE )
	vector totemBoundMins = totemProxy.GetBoundingMins()
	vector totemBoundMaxs = totemProxy.GetBoundingMaxs()
	float rx = totemBoundMaxs.x - totemBoundMins.x
	float ry = totemBoundMaxs.y - totemBoundMins.y
	float diameter = max( rx, ry )
	float dx = (diameter - rx) * 0.5
	float dy = (diameter - ry) * 0.5
	totemBoundMins = < totemBoundMins.x - dx, totemBoundMins.y - dy, totemBoundMins.z >
	totemBoundMaxs = < totemBoundMaxs.x + dx, totemBoundMaxs.y + dy, totemBoundMaxs.z >

	TraceResults traceResults = TraceHull( startPos, startPos + viewVector * magnitude, totemBoundMins, totemBoundMaxs, [weaponOwner, totemProxy], TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER )
	DebugDrawSphere( traceResults.endPos, 16.0, 0,255,0, true, 15.0, 2 )
	bool isUpwardSlope        = (IsValid( traceResults.hitEnt ) && traceResults.hitEnt.IsWorld()) && forwardVector.Dot( traceResults.surfaceNormal ) < -0.05
	if ( isUpwardSlope )
	{
		float slopeAngle   = 180 - RAD_TO_DEG * acos( forwardVector.Dot( traceResults.surfaceNormal ) )
		vector slopeVector = ClampViewVectorToMaxAngle( upVector, viewVector, angle )
		traceResults = TraceHull( startPos, startPos + slopeVector * magnitude, totemBoundMins, totemBoundMaxs, [weaponOwner, totemProxy], TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER )
		DebugDrawSphere( traceResults.endPos, 16.0, 0,0,255, true, 15.0, 2 )
	}
	TraceResults traceResultsDown = TraceLine( traceResults.endPos, traceResults.endPos + <0, 0, -150>, [weaponOwner, totemProxy], TRACE_MASK_SOLID_BRUSHONLY, TRACE_COLLISION_GROUP_NONE )
	//TraceResults traceResultsDown = TraceHull( traceResults.endPos, traceResults.endPos + <0,0,-150>, DEATH_TOTEM_BOUND_MINS, DEATH_TOTEM_BOUND_MAXS, [weaponOwner], TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_NONE )
	//TraceResults downResults = TraceHull( fwdResults.endPos, fwdResults.endPos - COVER_WALL_PLACEMENT_TRACE_OFFSET, COVER_WALL_BOUND_MINS, COVER_WALL_BOUND_MAXS, [player, wallModel], TRACE_MASK_SOLID, TRACE_COLLISION_GROUP_NONE )

	DeathTotemPlacementInfo info
	if ( traceResultsDown.hitEnt == null )
	{
		info.origin = weaponOwner.GetOrigin() + forwardVector * 20
		info.parentTo = null
		info.normal = <0, 0, 0>
	}
	else
	{
		DebugDrawSphere( traceResultsDown.endPos, 16.0, 255,0,0, true, 15.0, 2 )
		info.origin = traceResultsDown.endPos
		info.parentTo = null
		info.normal = traceResultsDown.surfaceNormal
	}

	DeployableCollisionParams params
	params.hitEnt = traceResultsDown.hitEnt
	params.normal = traceResultsDown.surfaceNormal
	if ( EntityShouldStickEx( totemProxy, params ) && !traceResultsDown.hitEnt.IsWorld() )
		info.parentTo = traceResultsDown.hitEnt

	return info
}


vector function ClampViewVectorToMaxAngle( vector vec1, vector vec2, float angle )
{
	vector perpendicularVector = CrossProduct( CrossProduct( vec1, vec2 ), vec1 )
	perpendicularVector.Normalize()
	vector newVector = vec1 * deg_cos( angle ) + perpendicularVector * deg_sin( angle )
	return newVector
} 