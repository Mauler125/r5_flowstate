global function InitDevMenu
global function SetupDevCommand
global function SetupDevFunc
global function SetupDevMenu
global function RepeatLastDevCommand
global function UpdatePrecachedSPWeapons
global function ServerCallback_OpenDevMenu
global function RunCodeDevCommandByAlias
global function DEV_InitCodeDevMenu
global function UpdateCheatsState
global function AddLevelDevCommand
global function ChangeToThisMenu
global function UpdateDevMenuButtons
global function OnDevButton_Activate
global function OnDevButton_GetFocus
global function OnDevButton_LoseFocus
global function BackOnePage_Activate
global function RepeatLastCommand_Activate
global function ClearCodeDevMenu
global function PushPageHistory
global function AddUICallback_OnDevMenuLoaded
global function GetCheatsState

const string DEV_MENU_NAME = "[LEVEL]"

struct DevMenuPage
{
	void functionref()      devMenuFunc
	void functionref( var ) devMenuFuncWithOpParm
	var                     devMenuOpParm
}

struct DevCommand
{
	string                  label
	string                  command
	var                     opParm
	void functionref( var ) func
	bool                    isAMenuCommand = false
}

struct
{
	array<DevMenuPage> pageHistory = []
	array<string>      pagePath = []
	DevMenuPage &      currentPage
	var                header
	array<var>         buttons
	array<table>       actionBlocks
	array<DevCommand>  devCommands
	DevCommand&        lastDevCommand
	bool               lastDevCommandAssigned
	string             lastDevCommandLabel
	string             lastDevCommandLabelInProgress
	bool               precachedWeapons
	DevCommand& focusedCmd
	bool        focusedCmdIsAssigned
	var footerHelpTxtLabel
	bool                      initializingCodeDevMenu = false
	string                    codeDevMenuPrefix = DEV_MENU_NAME + "/"
	table<string, DevCommand> codeDevMenuCommands
	array<void functionref()>                   OnDevMenuLoaded
	array<DevCommand> levelSpecificCommands = []
	bool cheatsState
} file

void function InitDevMenu( var newMenuArg )
{
	var menu = GetMenu( "DevMenu" )
	AddMenuEventHandler( menu, eUIEvent.MENU_OPEN, OnOpenDevMenu )

	file.header = Hud_GetChild( menu, "MenuTitle" )
	file.buttons = GetElementsByClassname( menu, "DevButtonClass" )
	foreach ( button in file.buttons )
	{
		Hud_AddEventHandler( button, UIE_CLICK, OnDevButton_Activate )
		Hud_AddEventHandler( button, UIE_GET_FOCUS, OnDevButton_GetFocus )
		Hud_AddEventHandler( button, UIE_GET_FOCUS, OnDevButton_LoseFocus )
		RuiSetString( Hud_GetRui( button ), "buttonText", "" )
		Hud_SetEnabled( button, false )
	}

	AddMenuFooterOption( menu, LEFT, BUTTON_B, true, "%[B_BUTTON|]% Back", "Back" )
	AddMenuEventHandler( menu, eUIEvent.MENU_NAVIGATE_BACK, BackOnePage_Activate )
	AddMenuFooterOption( menu, LEFT, BUTTON_Y, true, "%[Y_BUTTON|]% Repeat Last Dev Command:", "Repeat Last Dev Command:", RepeatLastCommand_Activate )
	file.footerHelpTxtLabel = GetElementsByClassname( menu, "FooterHelpTxt" )[0]

	RegisterSignal( "DEV_InitCodeDevMenu" )
	AddUICallback_LevelLoadingFinished( DEV_InitCodeDevMenu )
	AddUICallback_LevelShutdown( ClearCodeDevMenu )
}

void function OnOpenDevMenu()
{
	file.pageHistory.clear()
	file.pagePath.clear()
	file.currentPage.devMenuFunc = null
	file.currentPage.devMenuFuncWithOpParm = null
	file.currentPage.devMenuOpParm = null
	file.lastDevCommandLabelInProgress = ""
	SetDevMenu_MP()
}

void function UpdateDevMenuButtons()
{
	file.devCommands.clear()

	if ( file.initializingCodeDevMenu )
		return

	string titleText = "Developer Menu"
	foreach ( string pageName in file.pagePath )
	{
		titleText += " > " + pageName
	}
	Hud_SetText( file.header, titleText )

	if ( file.currentPage.devMenuOpParm != null )
		file.currentPage.devMenuFuncWithOpParm( file.currentPage.devMenuOpParm )
	else
		file.currentPage.devMenuFunc()

	foreach ( index, button in file.buttons )
	{
		int buttonID = int( Hud_GetScriptID( button ) )
		if ( buttonID < file.devCommands.len() )
		{
			RuiSetString( Hud_GetRui( button ), "buttonText", file.devCommands[buttonID].label )
			Hud_SetEnabled( button, true )
		}
		else
		{
			RuiSetString( Hud_GetRui( button ), "buttonText", "" )
			Hud_SetEnabled( button, false )
		}
		if ( buttonID == 0 )
			Hud_SetFocused( button )
	}

	RefreshRepeatLastDevCommandPrompts()
}

void function ChangeToThisMenu( void functionref() menuFunc )
{
	if ( file.initializingCodeDevMenu )
	{
		menuFunc()
		return
	}
	PushPageHistory()
	file.currentPage.devMenuFunc = menuFunc
	file.currentPage.devMenuFuncWithOpParm = null
	file.currentPage.devMenuOpParm = null
	UpdateDevMenuButtons()
}

void function ChangeToThisMenu_WithOpParm( void functionref( var ) menuFuncWithOpParm, var opParm = null )
{
	if ( file.initializingCodeDevMenu )
	{
		menuFuncWithOpParm( opParm )
		return
	}
	PushPageHistory()
	file.currentPage.devMenuFunc = null
	file.currentPage.devMenuFuncWithOpParm = menuFuncWithOpParm
	file.currentPage.devMenuOpParm = opParm
	UpdateDevMenuButtons()
}

void function SetupDevCommand( string label, string command )
{
	if ( command.slice( 0, 5 ) == "give " )
		command = "give_server " + command.slice( 5 )

	DevCommand cmd
	cmd.label = label
	cmd.command = command
	file.devCommands.append( cmd )

	if ( file.initializingCodeDevMenu )
	{
		string codeDevMenuAlias = file.codeDevMenuPrefix + label
		DevMenu_Alias_DEV( codeDevMenuAlias, command )
	}
}

void function SetupDevFunc( string label, void functionref( var ) func, var opParm = null )
{
	DevCommand cmd
	cmd.label = label
	cmd.func = func
	cmd.opParm = opParm
	file.devCommands.append( cmd )

	if ( file.initializingCodeDevMenu )
	{
		string codeDevMenuAlias   = file.codeDevMenuPrefix + label
		string codeDevMenuCommand = format( "script_ui RunCodeDevCommandByAlias( \"%s\" )", codeDevMenuAlias )
		file.codeDevMenuCommands[codeDevMenuAlias] <- cmd
		DevMenu_Alias_DEV( codeDevMenuAlias, codeDevMenuCommand )
	}
}

void function SetupDevMenu( string label, void functionref( var ) func, var opParm = null )
{
	DevCommand cmd
	cmd.label = (label + "  ->")
	cmd.func = func
	cmd.opParm = opParm
	cmd.isAMenuCommand = true
	file.devCommands.append( cmd )

	if ( file.initializingCodeDevMenu )
	{
		string codeDevMenuPrefix = file.codeDevMenuPrefix
		file.codeDevMenuPrefix += label + "/"
		cmd.func( cmd.opParm )
		file.codeDevMenuPrefix = codeDevMenuPrefix
	}
}

void function OnDevButton_Activate( var button )
{
	if ( level.ui.disableDev )
	{
		Warning( "Dev commands disabled on matchmaking servers." )
		return
	}
	int buttonID   = int( Hud_GetScriptID( button ) )
	DevCommand cmd = file.devCommands[buttonID]

	if ( cmd.isAMenuCommand )
	{
		string menuName = cmd.label.slice( 0, cmd.label.len() - 3 )
		file.pagePath.append( menuName )
	}
	RunDevCommand( cmd, false )
}

void function OnDevButton_GetFocus( var button )
{
	file.focusedCmdIsAssigned = false
	int buttonID = int( Hud_GetScriptID( button ) )
	if ( buttonID >= file.devCommands.len() || file.devCommands[buttonID].isAMenuCommand )
		return

	file.focusedCmd = file.devCommands[buttonID]
	file.focusedCmdIsAssigned = true
}

void function OnDevButton_LoseFocus( var button )
{
}

void function RunDevCommand( DevCommand cmd, bool isARepeat )
{
	if ( !isARepeat && !cmd.isAMenuCommand )
	{
		file.lastDevCommand = cmd
		file.lastDevCommandAssigned = true
		string pathString = ""
		foreach ( int i, pageName in file.pagePath )
		{
			pathString += pageName + " > "
		}
		pathString += cmd.label
		file.lastDevCommandLabel = pathString
		RefreshRepeatLastDevCommandPrompts()
	}

	if ( cmd.command != "" )
	{
		ClientCommand( cmd.command )
		if ( IsLobby() )
		{
			CloseAllMenus()
			AdvanceMenu( GetMenu( "LobbyMenu" ) )
		}
	}
	else
	{
		cmd.func( cmd.opParm )
	}
}

void function PushPageHistory()
{
	DevMenuPage page = file.currentPage
	if ( page.devMenuFunc != null || page.devMenuFuncWithOpParm != null )
		file.pageHistory.push( clone page )
}

void function BackOnePage_Activate()
{
	if ( file.pageHistory.len() == 0 )
	{
		CloseActiveMenu( true )
		return
	}
	if ( file.pagePath.len() > 0 )
		file.pagePath.pop()

	file.currentPage = file.pageHistory.pop()
	UpdateDevMenuButtons()
}

void function RepeatLastCommand_Activate( var button )
{
	RepeatLastDevCommand( null )
}

void function RepeatLastDevCommand( var _ )
{
	if ( !file.lastDevCommandAssigned )
		return
	RunDevCommand( file.lastDevCommand, true )
}

void function RefreshRepeatLastDevCommandPrompts()
{
	string newText = ""
	if ( file.lastDevCommandAssigned )
		newText = file.lastDevCommandLabel
	else
		newText = "<none>"

	if ( AreOnDefaultDevCommandMenu() )
		file.lastDevCommandLabelInProgress = ""

	Hud_SetText( file.footerHelpTxtLabel, newText )
}

bool function AreOnDefaultDevCommandMenu()
{
	return file.currentPage.devMenuFunc == SetupDefaultDevCommandsMP
}

void function UpdateCheatsState( bool cheatsState )
{
	file.cheatsState = cheatsState
}

bool function GetCheatsState()
{
	return file.cheatsState
}

void function AddUICallback_OnDevMenuLoaded( void functionref() callback )
{
	if ( !file.OnDevMenuLoaded.contains( callback ) )
		file.OnDevMenuLoaded.append( callback )
}

void function ServerCallback_OpenDevMenu()
{
	AdvanceMenu( GetMenu( "DevMenu" ) )
}

void function DEV_InitCodeDevMenu()
{
	thread DEV_InitCodeDevMenu_Internal()
}

void function DEV_InitCodeDevMenu_Internal()
{
	Signal( uiGlobal.signalDummy, "DEV_InitCodeDevMenu" )
	EndSignal( uiGlobal.signalDummy, "DEV_InitCodeDevMenu" )

	while ( !IsFullyConnected() || !IsItemFlavorRegistrationFinished() )
		WaitFrame()

	file.initializingCodeDevMenu = true
	DevMenu_Alias_DEV( DEV_MENU_NAME, "" )
	DevMenu_Rm_DEV( DEV_MENU_NAME )
	OnOpenDevMenu()
	file.initializingCodeDevMenu = false
}

void function ClearCodeDevMenu()
{
	DevMenu_Alias_DEV( DEV_MENU_NAME, "" )
	DevMenu_Rm_DEV( DEV_MENU_NAME )
}

void function AddLevelDevCommand( string label, string command )
{
	string codeDevMenuAlias = DEV_MENU_NAME + "/" + label
	DevMenu_Alias_DEV( codeDevMenuAlias, command )

	DevCommand cmd
	cmd.label = label
	cmd.command = command
	file.levelSpecificCommands.append( cmd )
}

void function RunCodeDevCommandByAlias( string alias )
{
	RunDevCommand( file.codeDevMenuCommands[alias], false )
}

string function GetCharacterNameFromDEV_name( string DEV_name )
{
	string prefix = "character_"
	return split( DEV_name.slice( prefix.len() ), " " )[ 0 ]
}

void function PrecacheWeaponsIfNecessary()
{
	if ( file.precachedWeapons )
		return

	file.precachedWeapons = true
	CloseAllMenus()

	DisablePrecacheErrors()
	wait 0.1
	ClientCommand( "script PrecacheSPWeapons()" )
	wait 0.1
	ClientCommand( "script_client PrecacheSPWeapons()" )
	wait 0.1
	RestorePrecacheErrors()

	AdvanceMenu( GetMenu( "DevMenu" ) )
}

void function UpdatePrecachedSPWeapons()
{
	file.precachedWeapons = true
}

void function ChangeToThisMenu_PrecacheWeapons( void functionref() menuFunc )
{
	if ( file.initializingCodeDevMenu )
	{
		menuFunc()
		return
	}
	waitthread PrecacheWeaponsIfNecessary()
	PushPageHistory()
	file.currentPage.devMenuFunc = menuFunc
	file.currentPage.devMenuFuncWithOpParm = null
	file.currentPage.devMenuOpParm = null
	UpdateDevMenuButtons()
}

void function ChangeToThisMenu_PrecacheWeapons_WithOpParm( void functionref( var ) menuFuncWithOpParm, var opParm = null )
{
	if ( file.initializingCodeDevMenu )
	{
		menuFuncWithOpParm( opParm )
		return
	}
	waitthread PrecacheWeaponsIfNecessary()
	PushPageHistory()
	file.currentPage.devMenuFunc = null
	file.currentPage.devMenuFuncWithOpParm = menuFuncWithOpParm
	file.currentPage.devMenuOpParm = opParm
	UpdateDevMenuButtons()
}

void function SetDevMenu_MP()
{
	if ( file.initializingCodeDevMenu )
	{
		SetupDefaultDevCommandsMP()
		return
	}
	PushPageHistory()
	file.currentPage.devMenuFunc = SetupDefaultDevCommandsMP
	UpdateDevMenuButtons()
}

void function SetDevMenu_SurvivalCharacter( var _ )
{
	thread ChangeToThisMenu( SetupChangeSurvivalCharacterClass )
}

void function SetupChangeSurvivalCharacterClass()
{
	array<ItemFlavor> characters = clone GetAllCharacters()
	characters.sort( int function( ItemFlavor a, ItemFlavor b ) {
		if ( Localize( ItemFlavor_GetLongName( a ) ) < Localize( ItemFlavor_GetLongName( b ) ) ) return -1
		if ( Localize( ItemFlavor_GetLongName( a ) ) > Localize( ItemFlavor_GetLongName( b ) ) ) return 1
		return 0
	} )
	foreach( ItemFlavor character in characters )
	{
		SetupDevFunc( Localize( ItemFlavor_GetLongName( character ) ), void function( var unused ) : ( character ) {
			DEV_RequestSetItemFlavorLoadoutSlot( LocalClientEHI(), Loadout_CharacterClass(), character )
		} )
	}
}

void function SetupDefaultDevCommandsMP()
{
	RunClientScript( "DEV_SendCheatsStateToUI" )

	foreach ( callback in file.OnDevMenuLoaded )
		callback()

	if ( GetCheatsState() )
	{
		SetupDevMenu( "Equip Legend Abilities", SetDevMenu_Abilities )
		SetupDevMenu( "Equip Custom Abilities", SetDevMenu_CustomAbilities )
		SetupDevMenu( "Equip Weapons", SetDevMenu_Weapons )

		if ( IsSurvivalMenuEnabled() )
		{
			SetupDevMenu( "Change Character", SetDevMenu_SurvivalCharacter )
			SetupDevMenu( "Survival", SetDevMenu_Survival )
			SetupDevMenu( "Survival: Weapons", SetDevMenu_SurvivalLoot, "main_weapon" )
			SetupDevMenu( "Survival: Attachments", SetDevMenu_SurvivalLoot, "attachment" )
			SetupDevMenu( "Survival: Helmets", SetDevMenu_SurvivalLoot, "helmet" )
			SetupDevMenu( "Survival: Armors", SetDevMenu_SurvivalLoot, "armor" )
			SetupDevMenu( "Survival: Backpacks", SetDevMenu_SurvivalLoot, "backpack" )
			SetupDevMenu( "Survival: Incap Shields", SetDevMenu_SurvivalLoot, "incapshield" )
			string itemsString = "ordnance ammo health custom_pickup data_knife"
			SetupDevMenu( "Survival: Consumables", SetDevMenu_SurvivalLoot, itemsString )
		}

		if ( GetCurrentPlaylistVarBool( "custom_loot", true ) )
		{
			SetupDevMenu( "Custom: Weapons (All)", SetDevMenu_SurvivalLoot, "weapon_custom" )
			SetupDevMenu( "Custom: Attachments", SetDevMenu_SurvivalLoot, "attachment_custom" )
		}

		SetupDevMenu( "Respawn Player(s)", SetDevMenu_RespawnPlayers )
		SetupDevCommand( "Recharge Abilities", "recharge" )
		SetupDevMenu( "Spawn NPC at Crosshair [Friendly]", SetDevMenu_AISpawnFriendly )
		SetupDevMenu( "Spawn NPC at Crosshair [Enemy]", SetDevMenu_AISpawnEnemy )
		SetupDevCommand( "Toggle NoClip", "noclip" )
		SetupDevCommand( "Toggle Skybox View", "script thread ToggleSkyboxView()" )
		SetupDevCommand( "Toggle HUD", "ToggleHUD" )
		SetupDevCommand( "Start Skydive", "script thread SkydiveTest()" )
		SetupDevCommand( "Spawn Deathbox", "SpawnDeathboxAtCrosshair" )
		SetupDevCommand( "Summon Players to player 0", "script summonplayers()" )
		SetupDevCommand( "Enable God Mode", "script EnableDemigod( gp()[0] )" )
		SetupDevCommand( "Disable God Mode", "script DisableDemigod( gp()[0] )" )
		SetupDevCommand( "Toggle Third Person Mode", "ToggleThirdPerson" )
		SetupDevMenu( "Prototypes", SetDevMenu_Prototypes )
		SetupDevMenu( "More...", SetDevMenu_MoreCommands )
	}
	else
	{
		SetupDevCommand( "Cheats are disabled! Type 'sv_cheats 1' in console to enable dev menu if you're the server admin.", "empty" )
	}
}

void function SetDevMenu_Weapons( var _ )
{
	thread ChangeToThisMenu( SetupRetailWeapons )
}

void function SetupRetailWeapons()
{
	SetupDevCommand( "Marksman Rifle: G7 Scout", "give mp_weapon_g2" )
	SetupDevCommand( "Marksman: Triple Take", "give mp_weapon_doubletake" )
	SetupDevCommand( "", "give blank" )
	SetupDevCommand( "Light Machine Gun: Devotion", "give mp_weapon_esaw" )
	SetupDevCommand( "Light Machine Gun: L-Star", "give mp_weapon_lstar" )
	SetupDevCommand( "Light Machine Gun: Spitfire", "give mp_weapon_lmg" )
	SetupDevCommand( "", "give blank" )
	SetupDevCommand( "Sniper: Charge Rifle", "give mp_weapon_defender" )
	SetupDevCommand( "Sniper: Longbow", "give mp_weapon_dmr" )
	SetupDevCommand( "Sniper: Sentinel", "give mp_weapon_sentinel" )
	SetupDevCommand( "", "give blank" )
	SetupDevCommand( "Pistol: P2020", "give mp_weapon_semipistol" )
	SetupDevCommand( "Pistol: RE-45", "give mp_weapon_autopistol" )
	SetupDevCommand( "Pistol: Wingman", "give mp_weapon_wingman" )
	SetupDevCommand( "Submachine Gun: Alternator", "give mp_weapon_alternator_smg" )
	SetupDevCommand( "Submachine Gun: Prowler", "give mp_weapon_pdw" )
	SetupDevCommand( "Submachine Gun: R-99", "give mp_weapon_r97" )
	SetupDevCommand( "Submachine Gun: Volt SMG", "give mp_weapon_volt_smg" )
	SetupDevCommand( "", "give blank" )
	SetupDevCommand( "Assault Rifle: Flatline", "give mp_weapon_vinson" )
	SetupDevCommand( "Assault Rifle: Hemlok", "give mp_weapon_hemlok" )
	SetupDevCommand( "Assault Rifle: R-301", "give mp_weapon_rspn101" )
	SetupDevCommand( "Assault Rifle:  Havoc AR", "give mp_weapon_energy_ar" )
	SetupDevCommand( "", "give blank" )
	SetupDevCommand( "Shotgun: EVA-8 Auto", "give mp_weapon_shotgun" )
	SetupDevCommand( "Shotgun: Mastiff", "give mp_weapon_mastiff" )
	SetupDevCommand( "Shotgun: Mozambique", "give mp_weapon_shotgun_pistol" )
	SetupDevCommand( "", "give blank" )
	SetupDevCommand( "Crate: Triple Take", "give mp_weapon_doubletake_crate crate optic_ranged_aog_variable" )
	SetupDevCommand( "Crate: Peacekeeper", "give mp_weapon_energy_shotgun_crate crate optic_cq_hcog_classic shotgun_bolt_l4" )
	SetupDevCommand( "Crate: Kraber", "give mp_weapon_sniper" )
}

void function SetDevMenu_Throwables( var _ )
{
	thread ChangeToThisMenu( SetupThrowables )
}

void function SetupThrowables()
{
	SetupDevCommand( "Grenade: Arc Star", "give mp_weapon_grenade_emp" )
	SetupDevCommand( "Grenade: Frag", "give mp_weapon_frag_grenade" )
	SetupDevCommand( "Grenade: Thermite", "give mp_weapon_thermite_grenade" )
}

void function SetDevMenu_Survival( var _ )
{
	thread ChangeToThisMenu( SetupSurvival )
}

void function SetupSurvival()
{
	SetupDevCommand( "Toggle Training Completed", "script GP().SetPersistentVar( \"trainingCompleted\", (GP().GetPersistentVarAsInt( \"trainingCompleted\" ) == 0 ? 1 : 0) )" )
	SetupDevCommand( "Enable Survival Dev Mode", "playlist survival_dev" )
	SetupDevCommand( "Disable Match Ending", "mp_enablematchending 0" )
	SetupDevCommand( "Enable Match Ending", "mp_enablematchending 1" )
	SetupDevCommand( "Drop Care Package R1", "script thread AirdropForRound( gp()[0].GetOrigin(), gp()[0].GetAngles(), 0, null )" )
	SetupDevCommand( "Drop Care Package R2", "script thread AirdropForRound( gp()[0].GetOrigin(), gp()[0].GetAngles(), 1, null )" )
	SetupDevCommand( "Drop Care Package R3", "script thread AirdropForRound( gp()[0].GetOrigin(), gp()[0].GetAngles(), 2, null )" )
	SetupDevCommand( "Force Circle Movement", "script thread FlagWait( \"DeathCircleActive\" );script svGlobal.levelEnt.Signal( \"DeathField_ShrinkNow\" );script FlagClear( \"DeathFieldPaused\" )" )
	SetupDevCommand( "Pause Circle Movement", "script FlagSet( \"DeathFieldPaused\" )" )
	SetupDevCommand( "Unpause Circle Movement", "script FlagClear( \"DeathFieldPaused\" )" )
	SetupDevCommand( "Bleedout Debug Mode", "script FlagSet( \"BleedoutDebug\" )" )
	SetupDevCommand( "Disable Loot Drops on Death", "script FlagSet( \"DisableLootDrops\" )" )
	SetupDevCommand( "Drop My Death Box", "script thread SURVIVAL_Death_DropLoot_Internal( gp()[0], null, 100, true )" )
}

void function SetDevMenu_Abilities( var _ )
{
	thread ChangeToThisMenu( SetupAbilities )
}

void function SetupAbilities()
{
	SetupDevCommand( "Bangalore Tactical", "give mp_weapon_grenade_bangalore" )
	SetupDevCommand( "Bangalore Ultimate", "give mp_weapon_grenade_creeping_bombardment" )
	SetupDevCommand( "Bloodhound Tactical", "give mp_ability_area_sonar_scan" )
	SetupDevCommand( "Bloodhound Ultimate", "give mp_ability_hunt_mode" )
	SetupDevCommand( "Caustic Tactical", "give mp_weapon_dirty_bomb" )
	SetupDevCommand( "Caustic Ultimate", "give mp_weapon_grenade_gas" )
	SetupDevCommand( "Crypto Tactical", "give mp_ability_crypto_drone" )
	SetupDevCommand( "Crypto Ultimate", "give mp_ability_crypto_drone_emp" )
	SetupDevCommand( "Gibraltar Tactical", "give mp_weapon_bubble_bunker" )
	SetupDevCommand( "Gibraltar Ultimate", "give mp_weapon_grenade_defensive_bombardment" )
	SetupDevCommand( "Lifeline Tactical", "give mp_weapon_deployable_medic" )
	SetupDevCommand( "Lifeline Ultimate", "give mp_ability_care_package" )
	SetupDevCommand( "Mirage Tactical", "give mp_ability_holopilot" )
	SetupDevCommand( "Mirage Ultimate", "give mp_ability_mirage_ultimate" )
	SetupDevCommand( " ", "give dontgiveanything" )
	SetupDevCommand( "Octane Tactical", "give mp_ability_heal" )
	SetupDevCommand( "Octane Ultimate", "give mp_weapon_jump_pad" )
	SetupDevCommand( "Pathfinder Tactical", "give mp_ability_grapple" )
	SetupDevCommand( "Pathfinder Ultimate", "give mp_weapon_zipline" )
	SetupDevCommand( "Wattson Tactical", "give mp_weapon_tesla_trap" )
	SetupDevCommand( "Wattson Ultimate", "give mp_weapon_trophy_defense_system"  )
	SetupDevCommand( "Wraith Tactical", "give mp_ability_phase_walk" )
	SetupDevCommand( "Wraith Ultimate", "give mp_weapon_phase_tunnel" )
	SetupDevCommand( "Revenant Tactical", "give mp_ability_silence" )
	SetupDevCommand( "Revenant Ultimate", "give mp_ability_revenant_death_totem" )
}

void function SetDevMenu_CustomAbilities( var _ )
{
	ChangeToThisMenu( SetupCustomAbilities )
}

void function SetupCustomAbilities()
{
	SetupDevCommand( "Tf2: Pulse Blade", "give mp_weapon_grenade_sonar" )
	SetupDevCommand( "Tf2: Amped Wall", "give mp_weapon_deployable_cover" )
	SetupDevCommand( "Tf2: Electric Smoke", "give mp_weapon_grenade_electric_smoke" )
	SetupDevCommand( "Dev: 3Dash", "give mp_ability_3dash" )
	SetupDevCommand( "Dev: Cloak", "give mp_ability_cloak" )
	SetupDevCommand( "Dev: Concussive Breach", "give mp_weapon_concussive_breach" )
	SetupDevCommand( "Dev: Flashbang Grenade", "give mp_weapon_grenade_flashbang" )
	SetupDevCommand( "Dev: Riot Shield", "give mp_ability_riot_shield" )
	SetupDevCommand( "Dev: Malestrom Javelin", "give mp_ability_maelstrom_javelin" )
	SetupDevCommand( "Dev: Spotter Sight", "give mp_ability_spotter_sight" )
	SetupDevCommand( "Dev: Loot Compass", "give mp_ability_loot_compass" )
	SetupDevCommand( "Dev: Ground Slam", "give mp_ability_ground_slam" )
	SetupDevCommand( "Dev: Debris Trap", "give mp_weapon_debris_trap" )
	SetupDevCommand( "Dev: Grenade Barrier", "give mp_weapon_grenade_barrier" )
	SetupDevCommand( "Dev: Cover Wall", "give mp_weapon_cover_wall_proto" )
	SetupDevCommand( "Dev: Split Timeline", "give mp_ability_split_timeline" )
	SetupDevCommand( "Dev: Sonic Shout", "give mp_ability_sonic_shout" )
	SetupDevCommand( "Dev: Haunt", "give mp_ability_haunt" )
	SetupDevCommand( "Dev: Dodge Roll", "give mp_ability_dodge_roll" )
}

void function SetDevMenu_AISpawnFriendly( var _ )
{
	thread ChangeToThisMenu( SetupFriendlyNPC )
}

void function SetupFriendlyNPC()
{
	SetupDevCommand( "Friendly NPC: Gunship", "script DEV_SpawnGunshipAtCrosshair(gp()[0].GetTeam())" )
	SetupDevCommand( "Friendly NPC: Dummie",  "script DEV_SpawnDummyAtCrosshair(gp()[0].GetTeam())" )
	SetupDevCommand( "Friendly NPC: Plasma Drone", "script DEV_SpawnPlasmaDroneAtCrosshair(gp()[0].GetTeam())" )
	SetupDevCommand( "Friendly NPC: Rocket Drone", "script DEV_SpawnRocketDroneAtCrosshair(gp()[0].GetTeam())" )
	SetupDevCommand( "Friendly NPC: Loot Tick", "script SpawnLootTickAtCrosshair()" )
	SetupDevCommand( "Friendly NPC: Prowler", "script DEV_SpawnProwlerAtCrosshair(gp()[0].GetTeam())" )
	SetupDevCommand( "Friendly NPC: Marvin", "script DEV_SpawnMarvinAtCrosshair(gp()[0].GetTeam())" )
	SetupDevCommand( "Friendly NPC: Spider", "script DEV_SpawnSpiderAtCrosshair(gp()[0].GetTeam())" )
	SetupDevCommand( "Friendly NPC: Infected", "script DEV_SpawnInfectedSoldierAtCrosshair(gp()[0].GetTeam())" )
	SetupDevCommand( "Friendly NPC: Tick", "script DEV_SpawnExplosiveTickAtCrosshair(gp()[0].GetTeam())" )
}

void function SetDevMenu_AISpawnEnemy( var _ )
{
	thread ChangeToThisMenu( SetupEnemyNPC )
}

void function SetupEnemyNPC()
{
	SetupDevCommand( "Enemy NPC: Gunship", "script DEV_SpawnGunshipAtCrosshair()" )
	SetupDevCommand( "Enemy NPC: Dummie", "script DEV_SpawnDummyAtCrosshair()" )
	SetupDevCommand( "Enemy NPC: Plasma Drone", "script DEV_SpawnPlasmaDroneAtCrosshair()" )
	SetupDevCommand( "Enemy NPC: Rocket Drone", "script DEV_SpawnRocketDroneAtCrosshair()" )
	SetupDevCommand( "Enemy NPC: Legend", "script DEV_SpawnLegendAtCrosshair()" )
	SetupDevCommand( "Enemy NPC: Prowler", "script DEV_SpawnProwlerAtCrosshair()" )
	SetupDevCommand( "Enemy NPC: Marvin", "script DEV_SpawnMarvinAtCrosshair()" )
	SetupDevCommand( "Enemy NPC: Spider", "script DEV_SpawnSpiderAtCrosshair()" )
	SetupDevCommand( "Enemy NPC: Infected", "script DEV_SpawnInfectedSoldierAtCrosshair()" )
	SetupDevCommand( "Enemy NPC: Tick", "script DEV_SpawnExplosiveTickAtCrosshair()" )
}

void function SetDevMenu_RespawnPlayers( var _ )
{
	ChangeToThisMenu( SetupRespawnPlayersDevMenu )
}

void function SetupRespawnPlayersDevMenu()
{
	SetupDevCommand( "Respawn me", "respawn" )
	SetupDevCommand( "Respawn all players", "respawn all" )
	SetupDevCommand( "Respawn all dead players", "respawn alldead" )
	SetupDevCommand( "Respawn random player", "respawn random" )
	SetupDevCommand( "Respawn random dead player", "respawn randomdead" )
	SetupDevCommand( "Respawn bots", "respawn bots" )
	SetupDevCommand( "Respawn dead bots", "respawn deadbots" )
	SetupDevCommand( "Respawn my teammates", "respawn allies" )
	SetupDevCommand( "Respawn my enemies", "respawn enemies" )
}

void function SetDevMenu_Prototypes( var _ )
{
	thread ChangeToThisMenu( SetupPrototypesDevMenu )
}

void function SetupPrototypesDevMenu()
{
	SetupDevCommand( "Toggle Akimbo With Current Weapon", "script DEV_ToggleAkimboWeapon(gp()[0])" )
	SetupDevCommand( "Toggle Akimbo With Holstered Weapon", "script DEV_ToggleAkimboWeaponAlt(gp()[0])" )
	SetupDevCommand( "Developer: Cubemap Viewer", "give weapon_cubemap" )
	SetupDevCommand( "Change to Shadow", "script DEV_GiveShadowZombieAbilities( GP() )" )
	SetupDevCommand( "Change back from Shadow to Legend", "script RemoveShadowZombieAbilities(gp()[0])" )
}

void function SetDevMenu_MoreCommands( var _ )
{
	ChangeToThisMenu( SetupMoreCommandsDevMenu )
}

void function SetupMoreCommandsDevMenu()
{
	SetupDevCommand( "Enable Infinite Ammo", "script DEV_ToggleInfiniteAmmo()" )
	SetupDevCommand( "Disable Infinite Ammo", "script DEV_ToggleInfiniteAmmo( false )" )
}

void function SetDevMenu_SurvivalLoot( var categories )
{
	thread ChangeToThisMenu_WithOpParm( SetupSurvivalLoot, categories )
}

void function SetupSurvivalLoot( var categories )
{
	printt( "SetupSurvivalLoot called with categories:", categories )
}