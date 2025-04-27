//Flowstate 1v1 gamemode -- made by __makimakima__
//Gamemode redesigned and maintained by @CafeFPS & Mkos

// Todo(mk): Needs core loop rewrote

global function isPlayerInRestingList
global function Gamemode1v1_ForceRest
global function INIT_playerChallengesStruct
global function GetScore
global function getSbmmSetting
global function setSbmmSetting
global function getGroupsInProgress
global function getPlayerToGroupMap
global function ClientCommand_Maki_SoloModeRest
global function ClientCommand_mkos_challenge
global function endSpectate
global function Gamemode1v1_Init
global function resetChallenges
global function soloModefixDelayStart
global function isPlayerInWaitingList
global function getWaitingRoomLocation
global function maki_tp_player
global function returnSoloGroupOfPlayer
global function soloModePlayerToWaitingList
global function ForceAllRoundsToFinish_solomode
global function addStatsToGroup
global function RechargePlayerAbilities
global function isCustomWeaponAllowed
global function isPlayerInChallenge
global function Gamemode1v1_SetWaitingRoomRadius
global function Gamemode1v1_FetchNotificationPanelCoordinates
global function Gamemode1v1_FetchNotificationPanelAngles
global function ClientCommand_mkos_IBMM_wait
global function g_bRestEnabled
global function AddEntityCalllback_OnPlayerGamestateChange_1v1
global function RemoveEntityCalllback_OnPlayerGamestateChange_1v1
global function Gamemode1v1_GiveWeapon
global function Gamemode1v1_TakeAll
global function Gamemode1v1_SetAllowLegendSelect
global function Gamemode1v1_SetAllPlayersLegend

//shared with scenarios server script
global function HandleGroupIsFinished
global function deleteWaitingPlayer
global function deleteSoloPlayerResting
global function getAvailableRealmSlotIndex
global function GetUniqueID
global function GivePlayerCustomPlayerModel
global function FS_ClearRealmsAndAddPlayerToAllRealms
global function PlayerRestoreHP_1v1
global function SetIsUsedBoolForRealmSlot
global function FS_SetRealmForPlayer
global function FS_1v1_GetPlayersWaiting
global function FS_1v1_GetPlayersResting
global function isScenariosMode
global function _CleanupPlayerEntities
global function FS_Scenarios_GiveWeaponsToGroup
global function ReloadTactical
global function SetupPlayerReserveAmmo
global function _3v3ModePlayerToRestingList

global function Gamemode1v1_SetPlayerGamestate
global function Gamemode1v1_GetPlayerGamestate
global function RemovePlayerFromGroup

global function Gamemode1v1_SetRestEnabled
global function Gamemode1v1_CreatePanels
global function Gamemode1v1_GetRestEnabled
global function Gamemode1v1_SetWeaponAmmoStackAmount
global function IsCurrentState
global function ValidateBlacklistedWeapons

global typedef PanelTable table<string, entity>
const bool DEBUG_STATE		= false

//DEV 
#if DEVELOPER
	global function DEV_printlegends
	global function DEV_legend
	global function DEV_acceptchal
	global function DEV_allchals
	global function DEV_acceptedchallenges
	global function DEV_GetGamestateRef
	global function DEV_PrintGameStates
	global function DEV_rest
#endif

global struct soloLocStruct
{
	array<LocPair> respawnLocations
	vector Center
	entity Panel //keep current opponent panel //(mk):not used
	string info //(mk): game behavior defining meta data.
	string ids
}

global struct groupStats 
{
	entity player
	string displayname
	float damage = 0
	int hits = 0
	int shots = 0
	int kills = 0
	int deaths = 0
}

global struct soloGroupStruct
{
	int groupHandle
	entity player1
	entity player2
	
	int player1_handle
	int player2_handle
	
	int p1LegendIndex = -1
	int p2LegendIndex = -1
	
	entity ring//ring boundaries
	soloLocStruct &groupLocStruct

	int slotIndex
	bool GROUP_INPUT_LOCKED = false //(mk): lock group to their input
	bool IsFinished = false //player1 or player2 is died, set this to true and soloModeThread() will handle this
	bool IsKeep = false //player may want to play with current opponent,so we will keep this group
	bool cycle = true //(mk): locked 1v1s can choose to cycle spawns
	bool swap = true //(mk): locked 1v1s can have random side they spawn on
	
	bool isValid = false 
	
	float startTime
	table <entity,groupStats> statsRecap
}

global struct soloPlayerStruct
{
	entity player
	int handle
	float queue_time = 0.0 //(mk):marks the time when they queued, to allow checking for same input
	bool IBMM_Timeout_Reached = false //(mk):input based match making timeout 
	bool showWaitingMsg = true
	float waitingTime //players may want to play with random opponent(or a matched opponent), so adding a waiting time after they died can allow server to match proper opponent
	float kd //stored this player's kd to help server match proper opponent
	entity lastOpponent //opponent of last round
	bool IsTimeOut = false
}

global enum e1v1State
{
	INVALID = -1,
	CHARSELECT,
	PREMATCH,
	MATCH_START,
	WAITING,
	SEQUENCE,
	MATCHING,
	RESTING,
	RECAP,
	
	//coaching mode
	WATCHING_FIGHT_REPLAY
}

struct ChallengesStruct
{
	entity player 
	table<int,float> challengers = {} // challenging entity handle, float Time()
	bool isValid
}

//this is fine
global array <soloLocStruct> soloLocations //all respawn location stored here


struct 
{
	int state = 0

	float waitingRoomRadius = 600
	float season_kd_weight
	float current_kd_weight
	float SBMM_kd_difference
	
	//playerHandle -> soloPlayerStruct
	table <int, soloPlayerStruct > soloPlayersWaiting = {} //moved to table for O(1) add/delete/lookup without shifting arrays, looping/scanning

	//playerHandle -> soloGroupStruct
	table< int, soloGroupStruct > playerToGroupMap = {} //map for quick assessment

	//groupHandle -> soloGroupStruct
	table< int, soloGroupStruct > groupsInProgress = {} //group map to group

	//playerHandle -> struct resting
	table< int, bool > soloPlayersResting = {}
	
	bool APlayerHasMessage = false
	
	array< ChallengesStruct > allChallenges
	table< int, entity > acceptedChallenges //(player handle challenger -> player challenged )
	
	array<ItemFlavor> characters
	int minLegendRange = 0
	int maxLegendRange = 10
	
	bool bRestEnabled = false
	
	array< bool > realmSlots
	
	array< string > Weapons
	array< string > WeaponsSecondary
	array< string > LongRangeWeapons
	array< string > LongRangeWeaponsSecondary

	LocPair WaitingRoom
	float restGrace
	
	vector notificationPanel_Coordinates
	vector notificationPanel_Angles
	
	#if DEVELOPER 
		table< string, int > e1v1StateNameToIntMap = {}
		table< int, string > e1v1StateIDToNameMap = {}
	#endif 
	
} file


struct 
{
	array<string> hostSetAttachments
	array<string> Weapons = []
	
	int ibmm_wait_limit = 30
	float default_ibmm_wait = 0
	bool enableChallenges = false
	int groupID = 112250000
	bool bGiveSameRandomLegendToBothPlayers = false
	bool bAllowLegend = false
	bool bAllowAbilities = false
	bool bChalServerMsg = false
	bool bNoCustomWeapons = false
	bool isScenariosMode
	float roundTime
	bool bAllowWeaponsMenu	
	int playerMaxFightDistance = 2000
	int give_weapon_stack_count_amount
	bool player_collision_enabled
	bool player_rest_collision_enabled
	bool allow_legend_select
	bool enableHelmets
	bool giveCharmsWeapons
	bool giveSkinsWeapons
	bool enableCosmetics
	bool bNoPrimary
	bool bNoSecondary
	bool bNoPrimaryLongrange
	bool bNoSecondaryLongrange
	
} settings


global bool mGroupMutexLock
global array<LocPair> g_randomWaitingSpawns
const int MAX_CHALLENGERS = 12

//TODO: unite this in a singular modular framework
const array<string> LEGEND_INDEX_ARRAY = 
[
		"Bangalore", //0
		"Bloodhound", //1
		"Caustic", //2
		"Gibby", //3
		"Lifeline", //4
		"Mirage", //5
		"Octane", //6
		"Pathfinder", //7
		"Wraith", //8
		"Wattson", //9
		"Crypto", //10
		
		"Blisk", //11
		"Fade", //12
		"Amogus", //13
		
		"Rhapsody", //14
		"Ash", //15
		"Jack", //16
		"Loba", //17 --
		"Revenant", //18
		"Ballistic", //19
		"Marvin", //20
		"Pete", //21
	];

//DEV functions
#if DEVELOPER
	void function DEV_printlegends()
	{
		foreach ( char in GetAllCharacters() )
		{
			printt( ItemFlavor_GetHumanReadableRef( char ) )
		}
	}
		
	void function DEV_legend( entity player, int id )
	{
		if( id < GetAllCharacters().len() )
		{
			ItemFlavor select_character = file.characters[ characterslist[ id ] ]
			CharacterSelect_AssignCharacter( ToEHI( player ), select_character )
		}
		else
		{
			SetPlayerCustomModel( player, id )
		}
	}

	void function DEV_acceptchal( entity player )
	{
		array<string> args = ["accept"]
		ClientCommand_mkos_challenge( player, args )
	}

	void function DEV_allchals()
	{
		string printtext = ""
		
		foreach( index, structs in file.allChallenges )
		{
			printtext += "\n\n --- All challenges Index: " + index + " ---\n\n"
			
			printtext += " Struct for player: " + string( structs.player ) + "\n"
			
			foreach( int handle, float ztime in structs.challengers )
			{
				printtext += "Handle: " + handle + " Time:" + ztime
			}
		}
		
		printt( printtext )
	}

	void function DEV_acceptedchallenges()
	{
		foreach( int handle, entity player in file.acceptedChallenges )
		{
			printt( handle, player )
		}
	}

	void function DEV_1v1Init()
	{
		foreach( string key, int value in e1v1State )
		{
			file.e1v1StateNameToIntMap[ key ] <- value 
			file.e1v1StateIDToNameMap[ value ] <- key 
		}
	}

	string function DEV_GetGamestateRef( int e1v1StateEnum )
	{
		if( e1v1StateEnum in file.e1v1StateIDToNameMap )
			return file.e1v1StateIDToNameMap[ e1v1StateEnum ]
			
		return "not found"
	}

	int function DEV_GetGamestateID( string e1v1StateRef )
	{
		if( e1v1StateRef in file.e1v1StateNameToIntMap )
			return file.e1v1StateNameToIntMap[ e1v1StateRef ]
			
		return -1
	}

	void function DEV_PrintGameStates()
	{
		string printmsg = ""
		
		foreach( player in GetPlayerArray() )
		{
			int state = player.e.gamemode1v1State
			printmsg += string( player ) + " State: " + state + " : " + DEV_GetGamestateRef( state ) + " \n"
		}
		
		printt( printmsg )
	}

	void function DEV_rest( entity player = null )
	{
		if( !IsValid( player ) )
			player = p( 0 )
			
		Gamemode1v1_ForceRest( player )
	}

#endif

void function resetChallenges()
{
	foreach ( chalStruct in file.allChallenges )
	{
		if( isChalValid( chalStruct ) )
			chalStruct.challengers.clear()
	}
	
	file.acceptedChallenges.clear()
}

void function AddEntityCalllback_OnPlayerGamestateChange_1v1( entity player, void functionref( entity player, int state ) callbackFunc )
{
	if( !( player.e.onPlayerGamestateChangedCallbacks.contains( callbackFunc ) ) )
		player.e.onPlayerGamestateChangedCallbacks.append( callbackFunc )
}

void function RemoveEntityCalllback_OnPlayerGamestateChange_1v1( entity player, void functionref( entity player, int state ) callbackFunc )
{
	if( player.e.onPlayerGamestateChangedCallbacks.contains( callbackFunc ) )
		player.e.onPlayerGamestateChangedCallbacks.fastremovebyvalue( callbackFunc )
}

void function Gamemode1v1_SetPlayerGamestate( entity player, int state = 0 )
{
	if( player.e.gamemode1v1State != state )
	{
		player.e.gamemode1v1State = state

		foreach( callbackFunc in player.e.onPlayerGamestateChangedCallbacks )
			callbackFunc( player, state )
	}
	#if DEVELOPER && DEBUG_STATE
		else if( !IsCurrentState( player, e1v1State.SEQUENCE ) )
		{
			DumpStack()
			mAssert( false, format( "State was already set to '%s' for %s", DEV_GetGamestateRef( state ), string( player ) ) )
		}
	#endif
}

int function Gamemode1v1_GetPlayerGamestate( entity player )
{
	return player.e.gamemode1v1State
}

bool function IsCurrentState( entity player, int state )
{
	return player.e.gamemode1v1State == state
}

table<int, soloGroupStruct> function getGroupsInProgress()
{
	return file.groupsInProgress
}

table<int, soloGroupStruct> function getPlayerToGroupMap()
{
	return file.playerToGroupMap
}

table<int, soloPlayerStruct> function FS_1v1_GetPlayersWaiting()
{
	return file.soloPlayersWaiting
}

table<int,bool> function FS_1v1_GetPlayersResting()
{
	return file.soloPlayersResting
}

bool function isScenariosMode()
{
	return settings.isScenariosMode
}

void function Gamemode1v1_SetWaitingRoomRadius( float radius )
{
	file.waitingRoomRadius = radius
}

//usage intended for display only queries from scripts, not game logic
float function getSbmmSetting( string setting )
{
	switch(setting)
	{
		case "season_kd_weight":
			return file.season_kd_weight
		case "current_kd_weight":
			return file.current_kd_weight
		case "SBMM_kd_difference":
			return file.SBMM_kd_difference
			
		default:
			return 0.0
	}
	
	unreachable
}

bool function setSbmmSetting( string setting, float value )
{
	switch( setting )
	{
		case "season_kd_weight":
			file.season_kd_weight = value
			return true
			
		case "current_kd_weight":
			file.current_kd_weight = value
			return true
			
		case "SBMM_kd_difference":
			file.SBMM_kd_difference = value
			return true
			
		default:
			return false
	}
	
	unreachable
}

bool function IsPlayerInProgress( int handle )
{
	if ( handle in file.playerToGroupMap )
	{
		if( IsValid( file.playerToGroupMap[ handle ] ) )
			return true
	}
	
	return false 
}

void function EquipHostSetInventoryAttachments( entity player )
{
	foreach ( optic in settings.hostSetAttachments )
		SURVIVAL_AddToPlayerInventory( player, optic )
}

void function SetHostInvetoryAttachments()
{	
	array<string> attachments = []
	string attachmentList = GetCurrentPlaylistVarString( "customAttachments", "" )
	
	if( empty( attachmentList ) )
		return 
		
	try
	{
		attachments = StringToArray( attachmentList )
	}
	catch( e )
	{
		sqerror( "Error: " + e )
	}
	
	int totalAttachments = attachments.len()
	
	#if DEVELOPER
		array<string> attachmentsClone = clone attachments
		attachmentsClone.insert( 0, "===CUSTOM INVENTORY LOADOUT===" )
		print_string_array( attachmentsClone )
	#endif
	
	if( totalAttachments == 0 )
		return
	
	for ( int i = totalAttachments - 1; i >= 0; i-- )
	{
		if( !IsValidAttachment( attachments[i] ) )
		{
			sqerror( "Attachment # " + i + " :\"" + attachments[i] + "\" was invalid and removed." )
			attachments.remove( i )
		}
	}
	
	settings.hostSetAttachments = attachments
	
	if( settings.bAllowWeaponsMenu && !isScenariosMode() )
		AddCallback_OnPlayerWeaponAttachmentChanged( OnWeaponAttachmentChanged )
}

void function INIT_PlaylistSettings()
{
	settings.bGiveSameRandomLegendToBothPlayers		= GetCurrentPlaylistVarBool( "give_random_legend_on_spawn", false )
	settings.bAllowLegend 							= GetCurrentPlaylistVarBool( "give_legend", true )
	settings.bAllowAbilities 						= GetCurrentPlaylistVarBool( "give_legend_tactical", true ) //challenge only
	settings.bChalServerMsg 						= bBotEnabled() ? GetCurrentPlaylistVarBool( "challenge_recap_server_message", true ) : false;
	settings.ibmm_wait_limit 						= GetCurrentPlaylistVarInt( "ibmm_wait_limit", 999 )
	settings.default_ibmm_wait 						= GetCurrentPlaylistVarFloat( "default_ibmm_wait", 3 )
	settings.enableChallenges						= GetCurrentPlaylistVarBool( "enable_challenges", true )
	settings.isScenariosMode						= Playlist() == ePlaylists.fs_scenarios
	settings.bNoCustomWeapons						= GetCurrentPlaylistVarBool( "custom_weapons_challenge_only", false )
	settings.roundTime								= float ( FlowState_RoundTime() )
	settings.bAllowWeaponsMenu						= !FlowState_AdminTgive()
	settings.playerMaxFightDistance					= GetCurrentPlaylistVarInt( "player_max_fight_distance", 2000 )
	settings.give_weapon_stack_count_amount			= GetCurrentPlaylistVarInt( "give_weapon_stack_count_amount", 0 )
	settings.player_collision_enabled				= GetCurrentPlaylistVarBool( "player_collision_enabled", true )
	settings.player_rest_collision_enabled			= GetCurrentPlaylistVarBool( "player_rest_collision_enabled", false )
	settings.allow_legend_select					= GetCurrentPlaylistVarBool( "allow_legend_select", false )
	settings.enableHelmets							= GetCurrentPlaylistVarBool( "enable_helmets", false )
	settings.giveCharmsWeapons 						= GetCurrentPlaylistVarBool( "flowstate_givecharms_weapons", false )
	settings.giveSkinsWeapons 						= GetCurrentPlaylistVarBool( "flowstate_giveskins_weapons", false )
	settings.enableCosmetics 						= GetCurrentPlaylistVarBool( "flowstate_enable_cosmetics", false )
}

bool function isCustomWeaponAllowed()
{
	return !settings.bNoCustomWeapons
}

int function GetUniqueID() 
{
    return ++settings.groupID
}

bool function Fetch_IBMM_Timeout_For_Player( entity player ) 
{
    if ( !IsValid( player ) ) 
		return false

    if ( player.p.handle in file.soloPlayersWaiting ) 
        return file.soloPlayersWaiting[ player.p.handle ].IBMM_Timeout_Reached
	
    return false
}


void function ResetIBMM( entity player ) 
{
    if ( !IsValid( player ) ) 
		return

	int handle = player.p.handle
    if ( handle in file.soloPlayersWaiting ) 
        file.soloPlayersWaiting[ handle ].IBMM_Timeout_Reached = false
	#if DEVELOPER
	else
		printw( "player was not in waiting list:", player )
	#endif
}

void function SetShowWaitingMsg( entity player, bool value ) 
{
    if ( !IsValid( player ) ) 
		return

	int handle = player.p.handle
    if ( handle in file.soloPlayersWaiting ) 
        file.soloPlayersWaiting[ handle ].showWaitingMsg = value
}

//used for display 
string function FetchInputName( entity player )
{
	return player.p.input == 0 ? "MnK" : "Controller";
}

//used for information display
string function GetScore( entity player )
{	
	if ( !IsValid( player ) ) 
		return "INVALID_PLAYER"
	
	float lt_kd = getkd( (player.GetPlayerNetInt( "kills" ) + player.p.season_kills) , (player.GetPlayerNetInt( "deaths" ) + player.p.season_deaths) )
	float cur_kd = getkd( player.GetPlayerNetInt( "kills" ) , player.GetPlayerNetInt( "deaths" )  )
	float score = (  ( lt_kd * file.season_kd_weight ) + ( cur_kd * file.current_kd_weight ) )
	return format( "Player: %s, season KD: %.2f, Current KD: %.2f, Round Score: %.2f ", player.p.name, lt_kd, cur_kd, score )
}

void function INIT_1v1_sbmm()
{
	#if TRACKER && HAS_TRACKER_DLL
		if( bGlobalStats() )
			AddCallback_PlayerDataFullyLoaded( INIT_playerChallengesStruct )
		else 
			AddCallback_OnClientConnected( INIT_playerChallengesStruct )
	#endif
	
	//initialize defaults for SBMM
	if ( bGlobalStats() )
	{
		file.season_kd_weight = GetCurrentPlaylistVarFloat( "season_kd_weight", 0.90 )
		file.current_kd_weight = GetCurrentPlaylistVarFloat( "current_kd_weight", 1.3 )
		file.SBMM_kd_difference = GetCurrentPlaylistVarFloat( "kd_difference", 1.5 )
	} 
	else
	{
		//base values
		file.season_kd_weight = 1
		file.current_kd_weight = 1
		file.SBMM_kd_difference = 3	
	}
}

//(mk): Do not remove the sqerror variants, they are used in Tracker servers to print to console for malconfigurations.
void function ValidateWeaponList( string weaponList, string weaponListContinue, array<string> outputArrayByRef, string slotClass )
{
	if ( weaponList != "" )
	{
		string concatenated = Concatenate( weaponList, weaponListContinue )

        try
        {
			StringToArrayAppend( concatenated, outputArrayByRef )
			
			if( outputArrayByRef[ 0 ] == "~~none~~" )
			{
				switch( slotClass )
				{
					case "primary":
						settings.bNoPrimary = true
						break
					
					case "secondary":
						settings.bNoSecondary = true
						break
					
					case "primaryLongrange":
						settings.bNoPrimaryLongrange = true
						break
					
					case "secondaryLongrange":
						settings.bNoSecondaryLongrange = true
						break
				}
				
				return //exit parsing entire slotClass.
			}
			
			int listLen = outputArrayByRef.len() - 1
			for ( int i = listLen; i >= 0; --i )
			{
				string before = strip( outputArrayByRef[ i ] )
				
				outputArrayByRef[ i ] = ParseWeapon( strip( outputArrayByRef[ i ] ) )
				
				if ( strip( outputArrayByRef[ i ] ) != before )
					sqerror( format( "Weapon %d was invalid and corrected. \n Old:\n \"%s\" \n New: \n \"%s\" \n\n", i, before, strip( outputArrayByRef[ i ] ) ) )
					
				if ( outputArrayByRef[ i ] == "" )
					outputArrayByRef.remove( i )
			}
		}
		catch ( error )
		{
			sqerror( "" + error )
		}
	}
}

void function INIT_HostCustomWeapons()
{	
	//////////////////////////////////////////////////////////////////////////////////////////////////////
	// Regular weapons pool	
	
	ValidateWeaponList
	( 
		GetCurrentPlaylistVarString( "custom_1v1_weapons_primary", "" ),
		GetCurrentPlaylistVarString( "custom_1v1_weapons_primary_continue", "" ), 
		file.Weapons,
		"primary"
	)
		
	ValidateWeaponList
	(
		GetCurrentPlaylistVarString( "custom_1v1_weapons_secondary", "" ), 
		GetCurrentPlaylistVarString( "custom_1v1_weapons_secondary_continue", "" ),
		file.WeaponsSecondary,
		"secondary"
	)
	
	//////////////////////////////////////////////////////////////////////////////////////////////////////
	// Longrange weapons pool
	
	ValidateWeaponList
	( 
		GetCurrentPlaylistVarString( "custom_longrange_primary", "" ),
		GetCurrentPlaylistVarString( "custom_longrange_primary_continue", "" ),
		file.LongRangeWeapons,
		"primaryLongrange"
	)
	
	ValidateWeaponList
	(
		GetCurrentPlaylistVarString( "custom_longrange_secondary", "" ),
		GetCurrentPlaylistVarString( "custom_longrange_secondary_continue", "" ),
		file.LongRangeWeaponsSecondary,
		"secondaryLongrange"
	)
}

bool function IsLockable( entity player1, entity player2 )
{
	if ( player1.p.lock1v1_setting == false || player2.p.lock1v1_setting == false )
		return false
	
	return true
}

int function getTimeOutPlayerAmount() 
{
    int timeOutPlayerAmount = 0
	
    foreach ( playerHandle, eachPlayerStruct in file.soloPlayersWaiting ) 
	{
        if ( IsValid( eachPlayerStruct ) && eachPlayerStruct.IsTimeOut && !eachPlayerStruct.player.p.waitingFor1v1 ) 
		{
            timeOutPlayerAmount++
        }
    }
    return timeOutPlayerAmount
}

entity function getTimeOutPlayer() 
{
    foreach ( playerHandle, eachPlayerStruct in file.soloPlayersWaiting ) 
	{
        if ( eachPlayerStruct.IsTimeOut ) 
		{
			if(!IsValid(eachPlayerStruct) || !IsValid(eachPlayerStruct.player) || eachPlayerStruct.player.p.waitingFor1v1  )
			{
				continue
			}
			
			//string set = eachPlayerStruct.player.p.waitingFor1v1 ? "true" : "false";
			//sqprint(format("TIMEOUTPLAYER IS player: %s setting for waiting is: %s", eachPlayerStruct.player.p.name, set))
            return eachPlayerStruct.player
        }
    }
	
    entity p
	return p
}


LocPair function getWaitingRoomLocation()
{
	return file.WaitingRoom
}

void function SetIsUsedBoolForRealmSlot( int realmID, bool usedState )
{
	try
	{
		if ( !realmID ) { return } //temporary crash fix
		file.realmSlots[ realmID ] = usedState
	}
	catch(e)
	{	
		#if DEVELOPER
			sqprint("SetIsUsedBoolForRealmSlot crash " + e )
		#endif
	}
}

int function getAvailableRealmSlotIndex()
{
	for( int slot = 1; slot < file.realmSlots.len(); slot++ )
	{
		if( !file.realmSlots[ slot ] )
		{
			SetIsUsedBoolForRealmSlot( slot, true )
			return slot
		}
	}

	return -1
}

//p
soloGroupStruct function returnSoloGroupOfPlayer( entity player ) 
{
	soloGroupStruct group	
	
	if( IsValid ( player ) )
	{	
		int handle = player.p.handle
		if ( handle in file.playerToGroupMap ) 
			return file.playerToGroupMap[ handle ]
	}
		
	return group
}

//p
void function addGroup( soloGroupStruct newGroup ) 
{	
	mGroupMutexLock = true
	
		int groupHandle = GetUniqueID()
		
		newGroup.groupHandle = groupHandle
		newGroup.startTime = Time()
		
		#if DEVELOPER
			sqprint(format("adding group: %d", groupHandle ))
		#endif
		
		if( !( groupHandle in file.groupsInProgress ) )
		{
			bool success = true		
			if( IsValid( newGroup.player1 && IsValid( newGroup.player2 ) ) )
			{
				file.playerToGroupMap[ newGroup.player1_handle ] <- newGroup
				#if DEVELOPER
					sqprint( format( "player 1 added to group: %s", newGroup.player1.p.name ))
				#endif
				file.playerToGroupMap[ newGroup.player2_handle ] <- newGroup
				#if DEVELOPER
					sqprint( format( "player 2 added to group: %s", newGroup.player2.p.name ))
				#endif
			}
			else 
			{	
				#if DEVELOPER
					sqerror("FAILURE adding players to group")
				#endif
				success = false
			}
			
			if( success )
			{
				newGroup.isValid = true
				file.groupsInProgress[ groupHandle ] <- newGroup
			}
		}
		else 
		{	
			#if DEVELOPER
				sqerror(format("Logic flow error, group: [%d] already exists", groupHandle))
			#endif
		}
	
	mGroupMutexLock = false
}


void function removeGroupByHandle( int handle )
{
	if ( handle in file.groupsInProgress )
	{	
		#if DEVELOPER
			sqprint(format("Removing group by handle: %d", handle))
		#endif
		delete file.groupsInProgress[ handle ]
	}
	else
	{
		if( !handle )
			sqerror("[removeGroupByHandle] ERROR: handle was null")
		else 
			sqerror(format("[removeGroupByHandle] Handle: \"%d\" does not exist in table: \"file.groupsInProgress\"", handle ))
	}
}

void function removeGroup( soloGroupStruct groupToRemove ) 
{
	mGroupMutexLock = true
	
	int groupHandle = groupToRemove.groupHandle
	int handle1
	int handle2
	
	if ( IsValid( groupToRemove.player1 ) )
		handle1 = groupToRemove.player1.p.handle
		
	if ( IsValid( groupToRemove.player2 ) )
		handle2 = groupToRemove.player2.p.handle
	
	if ( handle1 in file.playerToGroupMap )
	{	
		#if DEVELOPER
			sqprint( format( "deleting player 1 handle: %d from group map", handle1 ) )
		#endif
		delete file.playerToGroupMap[ handle1 ]
	}
		
	if ( handle2 in file.playerToGroupMap )
	{
		#if DEVELOPER
			sqprint(format( "deleting player 2 handle: %d from group map", handle2 ) )
		#endif
		delete file.playerToGroupMap[ handle2 ]
	}
	
	if( groupHandle in file.groupsInProgress )
	{
		#if DEVELOPER
			sqprint( format( "removing group: %d", groupHandle ) )
		#endif
		delete file.groupsInProgress[ groupHandle ]
	}
	else 
	{
		#if DEVELOPER
			sqprint( format( "groupToRemove.groupHandle: %d not in file.groupsInProgress", groupToRemove.groupHandle ) )
		#endif
	}
	
	mGroupMutexLock = false
}

void function endSpectate(entity player)
{
	player.SetSpecReplayDelay( 0 )
	player.SetObserverTarget( null )
	player.StopObserverMode()
	Remote_CallFunction_ByRef( player, "ServerCallback_KillReplayHud_Deactivate" )
    player.MakeVisible()
    player.ClearInvulnerable()
	player.SetTakeDamageType( DAMAGE_YES )
	try
	{
		player.Die( null, null, { damageSourceId = eDamageSourceId.damagedef_despawn } )
	}
	catch (error)
	{}
    RemoveButtonPressedPlayerInputCallback(player, IN_JUMP,endSpectate)
}


bool function IsPlayerInSoloMode( entity player ) 
{
    return ( player.p.handle in file.playerToGroupMap )
}

bool function isPlayerInWaitingList( entity player ) //todo: capital I 
{
	return ( player.p.handle in file.soloPlayersWaiting )
}

bool function isPlayerInRestingList( entity player )
{		
	return ( player.p.handle in file.soloPlayersResting )
}

void function deleteSoloPlayerResting( entity player )
{
	int playerHandle = player.p.handle
	if ( playerHandle in file.soloPlayersResting )
		delete file.soloPlayersResting[ playerHandle ]
}

void function addSoloPlayerResting( int playerHandle )
{
	if( playerHandle in file.soloPlayersResting )
		file.soloPlayersResting[ playerHandle ] = true
	else 
		file.soloPlayersResting[ playerHandle ] <- true
}

void function deleteWaitingPlayer( int handle )
{
	if ( handle in file.soloPlayersWaiting )
		delete file.soloPlayersWaiting[ handle ]
}

void function AddPlayerToWaitingList( soloPlayerStruct playerStruct ) 
{
	if( IsValid( playerStruct.player ) )
		file.soloPlayersWaiting[ playerStruct.player.p.handle ] <- playerStruct
	else
		sqerror( "[AddPlayerToWaitingList] player to add was invalid" )
}

void function Gamemode1v1_ForceRest( entity player )
{
	if( !file.bRestEnabled )
		return
	
	if( !IsValid( player ) ) // || IsCurrentState( player, e1v1State.SEQUENCE ) //potential fix in future.
		return

	int playerHandle = player.p.handle
	if( playerHandle in file.soloPlayersResting )
		return
	
	if( isScenariosMode() )
	{
		FS_Scenarios_ForceRest( player )
	}
	else 
	{
		//soloGroupStruct group = returnSoloGroupOfPlayer( player )
		//group.IsFinished = true
		
		if( isPlayerInWaitingList( player ) )
			deleteWaitingPlayer( playerHandle )
		
		player.p.lastRestUsedTime = Time()
		
		soloModePlayerToRestingList( player )
		
		try
		{
			player.Die( null, null, { damageSourceId = eDamageSourceId.damagedef_despawn } )
		}
		catch (error){}
		
		HolsterAndDisableWeapons_Raw( player )//✓
		//TakeAllWeapons( player )
	}
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////// mkos challenge system  ///////////////////////////////////////
//client command: challenge

bool function ClientCommand_mkos_challenge(entity player, array<string> args)
{
	if ( !CheckRate( player, "chal", COMMAND_RATE_LIMIT, true ) ) 
		return true
		
	if( GetTDMState() != eTDMState.IN_PROGRESS )
	{
		LocalMsg( player, "#FS_GameNotPlaying" )
		return true
	}
	
	if( !settings.enableChallenges )
	{
		LocalMsg( player, "#FS_Challenges_Disabled" )
		return true
	}
	
	if ( args.len() < 1 )
	{
		LocalMsg( player, "#FS_Usage", "#FS_Challenge_usage" )
		return true	
	}
	
	string requestedData = args[ 0 ]
	string param = ""
	
	if ( args.len() >= 2 )
	{
		param = args[1]
	}

	switch( requestedData )
	{
		case "challenge":
		case "chal":
		
			if( args.len() < 2 )
			{
				LocalMsg( player, "#FS_Challenges", "#FS_Challenge_usage_2", eMsgUI.DEFAULT, 30 )
			}
			else 
			{	
				entity challengedPlayer
				
				if ( param == "player" )
				{				
					soloGroupStruct group = returnSoloGroupOfPlayer( player )
					
					if( !IsValid( group.player1 ) )
					{
						LocalMsg( player, "#FS_NotInFight" )
						return true
					}
					
					challengedPlayer = player == group.player1 ? group.player2 : group.player1			
				}
				else 
				{
					challengedPlayer = GetPlayer( param )
				}
				
				if( player == challengedPlayer )
				{
					LocalMsg( player, "#FS_CantChalSelf" )
					return true
				}

				if ( IsValid( challengedPlayer ) )
				{
					int result = addToChallenges( player, challengedPlayer )
					string error = ""
					
					switch( result )
					{
						case 1:
							
							LocalMsg( player, "#FS_ChalSent" )
							LocalMsg( challengedPlayer, "#FS_NEW_REQUEST", "#FS_ChalRequest", eMsgUI.DEFAULT, 10, "", player.p.name )
							
							break
						
						case 2:
							error = "Player has recieved too many challenges";
							break
						
						case 3:
							error = "Too many requests sent, please wait a moment and try again";
							break
						
						case 4:
							error = "Player has disabled 1v1 requests";
							break
							
						case 5:
							error = "Player not initialized";
							break
							
						case 6:
							error = "Too soon, please wait " + ( 10 - Time() ) + " seconds and try again";
					}
					
					if( result > 1 )
						LocalMsg( player, "#FS_FAILED", "", eMsgUI.DEFAULT, 5, "", "Couldn't add challenge: " + error )
					
				}
				else 
				{
					LocalMsg( player, "#FS_InvalidPlayer" )
				}
			}
			
			return true
		
		case "accept":
			
			if( args.len() <= 1 )
			{
				acceptRecentChallenge( player )		
			}
			else 
			{
				entity challenger = GetPlayer( param )
				
				if( !IsValid( challenger ) )
				{
					LocalMsg( player, "#FS_InvalidPlayer" )
					return true
				}
				
				if ( acceptChallenge( player, challenger ) )
				{
					//sqprint("success")
				}
				else 
				{
					//sqprint("failure")
				}
			}
			
			return true
			
		case "list":
		
			if( CheckRate( player, "chal_list", 3.0, true ) )
				return true
		
			string list = listPlayerChallenges( player )
			string title = "CURRENT CHALLENGERS"
			
			Message( player, title, list, 20 )
				
			return true

		case "end":
			
			endLock1v1( player )	
			return true
		
		case "remove":
		
			entity challenger = GetPlayer( param )
			
			if( IsValid( challenger ) )
			{
				if ( removeChallenger( player, challenger.p.handle ) )
					LocalMsg( player, "#FS_RemovedChallenger", "", eMsgUI.DEFAULT, 5, challenger.p.name )
				else 
					LocalMsg( player, "#FS_PlayerNotInChallenges" )
				
				endLock1v1( player, false )
			}
			
			return true 
			
		case "clear":
			
			player.p.waitingFor1v1 = false
			ChallengesStruct chalStruct = getChallengeListForPlayer( player )
			
			if( isChalValid( chalStruct ) )
				chalStruct.challengers.clear()
			
			endLock1v1( player, false )
			LocalMsg( player, "#FS_ChallengersCleared" )
			
			return true
			
		case "revoke":
		
			if( param == "all" )
			{
				int revoked = 0
				string removed = ""
				
				foreach ( revokedFromPlayer in GetPlayerArray() )
				{
					if( IsValid( revokedFromPlayer ) )
					{
						if( removeChallenger( revokedFromPlayer, player.p.handle ) )
						{
							revoked++
							removed += revokedFromPlayer.p.name + "\n"
						}
					}
				}
				
				if ( revoked > 0 )
				{
					endLock1v1( player, false )
					LocalMsg( player, "#FS_RevokedX", "#FS_RevokedFromPlayers", eMsgUI.DEFAULT, 10, revoked.tostring(), removed )
				}
				else 
				{
					LocalMsg( player, "#FS_NoChallengesToRemove" )
				}
				
				return true
			}
			
			entity playerToRevoke = GetPlayer( param )		
			if( IsValid( playerToRevoke ) )
			{
				if( removeChallenger( playerToRevoke, player.p.handle ) )
				{
					if( returnChallengedPlayer( player ) == playerToRevoke )
						endLock1v1( player, false, true )
					
					LocalMsg( player, "#FS_ChalRevoked" )
				}
				else 
				{
					endLock1v1( player, false, false )
					LocalMsg( player, "#FS_PlayerNotInChallenges" )
				}
			}
			else
			{
				LocalMsg( player, "#FS_PlayerQuit" )
			}
			
			return true
			
		case "cycle":
		
			if( !isPlayerInChallenge( player ) )
			{
				LocalMsg( player, "#FS_NotInChal" )
				return true
			}
			
			soloGroupStruct group = returnSoloGroupOfPlayer( player )
			
			if( group.isValid )
			{
				if( group.cycle )
				{
					group.cycle = false
					LocalMsg( group.player1, "#FS_SpawnCycDisabled" )
					LocalMsg( group.player2, "#FS_SpawnCycDisabled" )
				}
				else 
				{
					group.cycle = true
					LocalMsg( group.player1, "#FS_SpawnCycEnabled" )
					LocalMsg( group.player2, "#FS_SpawnCycEnabled" )
				}
			}
			
			return true
			
			
		case "swap":
			
			if( !isPlayerInChallenge( player ) )
			{
				LocalMsg( player, "#FS_NotInChal" )
				return true
			}
			
			soloGroupStruct group = returnSoloGroupOfPlayer( player )		
			if( group.isValid )
			{
				if( group.swap )
				{
					group.swap = false
					LocalMsg( group.player1, "#FS_SpawnSwapDisabled" )
					LocalMsg( group.player2, "#FS_SpawnSwapDisabled" )
				}
				else 
				{
					group.swap = true
					LocalMsg( group.player1, "#FS_SpawnSwapEnabled" )
					LocalMsg( group.player2, "#FS_SpawnSwapEnabled" )
				}
			}
			
			return true
			
		case "legend":
					
			if( !settings.bAllowLegend )
			{
				LocalMsg( player, "#FS_DisabledLegends")
				return true
			}
			
			if( !CheckRate( player, "legend_select", 1, true ) )
				return true
			
			//this param comes as a clientcommand with the legend guid ref
			string param2 = ""
			if( args.len() > 2 )
				param2 = args[2]
			
			if( param == "" || param2 == "" )
			{
				Remote_CallFunction_NonReplay( player, "Gamemode1v1_ForceLegendSelector_Deprecated" )
				return true
			}
			
			// else if( param == "help" )
			// {
				// string legendList = "\n\n\n\n\n\n\n\n\n\n\n";
				
				// int j = 0
				// foreach( legend in LEGEND_INDEX_ARRAY )
				// {
					// legendList += format("%d = %s \n", j, legend)
					// j++;
				// }
				
				// Message( player, "LEGENDS", legendList, 20 )
				// return true
			// }
			

		
			string legend = "undefined";
			int index = -1;
			int indexMapLen = LEGEND_INDEX_ARRAY.len()
			
			// if( IsStringNumeric( param, 0, indexMapLen ) )
			// {
				// index = param.tointeger()
			// }
			// else 
			// {
				// index = -1
				// for( int i = 0; i < indexMapLen; i++ )
				// {
					// if ( LEGEND_INDEX_ARRAY[i].tolower() == param.tolower() )
					// {
						// index = i;
					// }
				// }	
			// }
			
			if( param2 != "" )
			{
				if( IsStringNumeric( param2 ) )
					index = CharacterGuidRefToIndex( param2 )
			}
			
			if( index >= indexMapLen || index < 0 )
			{
				LocalMsg( player, "#FS_InvalidLegend" )
				return true
			}
			
			if( !isPlayerInChallenge( player ) )
			{
				if( settings.allow_legend_select )
				{
					AssignLegendToGroup( index, [ player ] )
					return true
				}
				else 
				{
					LocalMsg( player, "#FS_NotInChal" )
					return true
				}
			}
			
			soloGroupStruct group = returnSoloGroupOfPlayer( player )		
			if( !group.isValid )
				return true
			
			if( group.player1 == player )
			{
				group.p1LegendIndex = index
			}
			else if( group.player2 == player )
			{
				group.p2LegendIndex = index
			}
			
			legend = index != -1 ? LEGEND_INDEX_ARRAY[ index ] : "undefined";
			
			LocalMsg( player, "#FS_PlayingAs", "", eMsgUI.DEFAULT, 5, legend, "" )
			
			if( index <= 10 )
			{
				ItemFlavor select_character = file.characters[ characterslist[ index ] ]
				CharacterSelect_AssignCharacter( ToEHI( player ), select_character )
				
				if( !settings.bAllowAbilities )
					player.TakeOffhandWeapon( OFFHAND_TACTICAL )
			}
			else 
			{
				SetPlayerCustomModel( player, index )
			}
			
			if( settings.bAllowAbilities )
				RechargePlayerAbilities( player, index )
		
			return true 
			
		case "outlist":
		
			string list = ""
			
			foreach( chalplayer in GetPlayerArray() )
			{
				if ( !IsValid( chalplayer ) )
					continue
				
				ChallengesStruct chalStruct = getChallengeListForPlayer( chalplayer )		
				if( isChalValid( chalStruct ) )
				{
					if ( player.p.handle in chalStruct.challengers )
						list += format("Outgoing challenge to: %s \n", chalplayer.p.name )
				}
			}
			
			if( list != "" )
				LocalMsg( player, "#FS_OutgoingChal", "", eMsgUI.DEFAULT, 15, "", list )
			else 
				LocalMsg( player, "#FS_NoOutgoingChal" )
		
			return true
		
		default:
			LocalMsg( player, "#FS_FAILED", "#FS_UnknownCommand" )
			return true
	}
	
	return false
}

void function INIT_playerChallengesStruct( entity player )
{
	#if DEVELOPER
		mAssert( !isChalValid( getChallengeListForPlayer( player ) ), "Chal struct already appended for player %s", string( player ) )
	#endif
	
	ChallengesStruct chalStruct
	chalStruct.player = player
	chalStruct.isValid = true
	file.allChallenges.append( chalStruct )
}

int function addToChallenges( entity challenger, entity challengedPlayer )
{
	ChallengesStruct chalStruct = getChallengeListForPlayer( challengedPlayer )
	
	if( Time() <= 10 )
		return 6
	
	if( !isChalValid( chalStruct ) )
		return 5
	
	if( !challengedPlayer.p.lock1v1_setting )
		return 4
	
	if ( Time() - checkChallengeTime( challenger, challengedPlayer ) <= 10 )
		return 3
	
	if ( chalStruct.challengers.len() >= MAX_CHALLENGERS )
		return 2
	
	//add challenger to table
	int challengerHandle = challenger.p.handle
	if( challengerHandle in chalStruct.challengers )
		chalStruct.challengers[ challengerHandle ] = Time()
	else 
		chalStruct.challengers[ challengerHandle ] <- Time()
	
	return 1
}


bool function isChalValid( ChallengesStruct chalStruct )
{
	return ( chalStruct.isValid && IsValid( chalStruct.player ) )
}


float function checkChallengeTime( entity challenger, entity challengedPlayer )
{
	ChallengesStruct chalStruct = getChallengeListForPlayer( challengedPlayer )
	
	if ( !isChalValid( chalStruct ) )
		return 0.0 
	
	if( challenger.p.handle in chalStruct.challengers )
		return getChallengeListForPlayer( challengedPlayer ).challengers[ challenger.p.handle ]
	
	return 0.0
}


ChallengesStruct function getChallengeListForPlayer( entity player )
{
	ChallengesStruct chalStruct
	
	if( !IsValid( player ) )
		return chalStruct
	
	foreach ( challengeStruct in file.allChallenges )
	{
		if( !IsValid( challengeStruct ) )
			continue
		
		if ( IsValid( challengeStruct.player ) && challengeStruct.player == player )
			return challengeStruct
	}
	
	return chalStruct
}


string function listPlayerChallenges( entity player )
{
	ChallengesStruct chalStruct = getChallengeListForPlayer( player )
	
	string list
	string emphasis
	entity opponent
	
	if( IsPlayerPendingChallenge( player ) || IsPlayerPendingLockOpponent( player ) )
	{
		opponent = returnChallengedPlayer( player )
		
		if( IsValid( opponent ) )
			list += format("***ACTIVE CHALLENGE***:[ %s ]\n\n", opponent.p.name )
	}
	else 
	{
		list += "No active challenge yet... \n\n"
	}
	
	if ( !isChalValid( chalStruct ) )
		return list
	
	if( chalStruct.challengers.len() == 0 )
		list += "No incoming challenges yet..."
	
	foreach ( challenger_eHandle, chalTime in chalStruct.challengers )
	{
		entity challenger = GetEntityFromEncodedEHandle ( challenger_eHandle )
		
		if ( IsValid( challenger ) )		
			list += format("Challenger: %s, Seconds ago: %d \n", challenger.p.name, Time() - chalTime )
		else 
			removeChallenger( player, challenger_eHandle )
	}

	return list
}


bool function removeChallenger( entity player, int challenger_eHandle )
{
	ChallengesStruct chalStruct = getChallengeListForPlayer( player )
	
	if ( !isChalValid( chalStruct ) )
		return false 
	
	if ( challenger_eHandle in chalStruct.challengers )
	{
		delete getChallengeListForPlayer( player ).challengers[ challenger_eHandle ]
		return true
	}
	
	return false
}

bool function acceptChallenge( entity player, entity challenger )
{
	if( !IsValid( challenger ) )
		return false
	
	if( IsPlayerPendingChallenge( player ) || IsPlayerPendingLockOpponent( player ) )
	{
		#if DEVELOPER 
			printt("ALREADY IN CHALLENGE", "do /end or /clear to finish" )
		#endif
		
		LocalMsg( player, "#FS_InChallenge", "#FS_InChallenge_SUBSTR" )
		return false
	} 
	
	if( IsPlayerPendingChallenge( challenger ) || IsPlayerPendingLockOpponent( challenger ) )
	{
		#if DEVELOPER 
			printt("PLAYER ALREADY IN CHALLENGE" )
		#endif
		
		LocalMsg( player, "#FS_PlayerInChal" )
		return false
	}
	
	//sqprint("accepted")
	ChallengesStruct chalStruct = getChallengeListForPlayer( player )
	
	if ( isChalValid( chalStruct ) && challenger.p.handle in chalStruct.challengers )
	{
		file.acceptedChallenges[ player.p.handle ] <- challenger
		removeChallenger( player, challenger.p.handle ) //removes from incoming list	
		SetUpChallengeNotifications( player, challenger )
	}
	else 
	{
		#if DEVELOPER 
			printt("NO CHALLENGES FROM PLAYER", "Maybe revoked? Check with /list")
		#endif 
		
		LocalMsg( player, "#FS_NoChalFromPlayer", "#FS_NoChalFromPlayer_SUBSTR" )
		return false 
	}
	
	return true
}

bool function acceptRecentChallenge( entity player )
{
	if( IsPlayerPendingChallenge( player ) || IsPlayerPendingLockOpponent( player ) )
	{
		#if DEVELOPER 
			printt("ALREADY IN CHALLENGE", "do /end or /clear to finish" )
		#endif
		
		LocalMsg( player, "#FS_InChallenge", "#FS_InChallenge_SUBSTR" )
		return true
	} 
	
	ChallengesStruct chalStruct = getChallengeListForPlayer( player )
	
	if( !isChalValid( chalStruct ) )
		return false
	
	if( chalStruct.challengers.len() <= 0 )
	{
		#if DEVELOPER 
			printt( "NO CHALLENGES", "Maybe revoked? Check with /list" )
		#endif
		
		LocalMsg( player, "#FS_NoChal", "#FS_NoChalFromPlayer_SUBSTR" )
		return false
	}
	
	entity recentChallenger
	int recentChallenger_eHandle = -1	
	float mostRecentTime = 0.0
	
	foreach ( challenger_eHandle, chalTime in chalStruct.challengers )
	{
		mostRecentTime = chalTime 
		
		if( chalTime >= mostRecentTime )
		{
			recentChallenger = GetEntityFromEncodedEHandle( challenger_eHandle )
			recentChallenger_eHandle = challenger_eHandle
		}
	}
		
	if( !IsValid( recentChallenger ) )
	{
		if ( removeChallenger( player, recentChallenger_eHandle ) )
		{
			#if DEVELOPER
				printt( "CHALLENGER QUIT" )
			#endif 
			
			LocalMsg( player, "#FS_ChalQuit" )
		}
		else 
		{
			#if DEVELOPER
				printt("PLAYER NOT IN CHALLENGES" )
			#endif 
			
			LocalMsg( player, "#FS_PlayerNotInChallenges" )
		}
		
		return false
	}
	
	if( !IsValid( recentChallenger ) || IsPlayerPendingChallenge( recentChallenger ) || IsPlayerPendingLockOpponent( recentChallenger ) )
	{
		#if DEVELOPER
			printt( "PLAYER ALREADY IN CHALLENGE", IsValid( recentChallenger ), IsPlayerPendingChallenge( recentChallenger ), IsPlayerPendingLockOpponent( recentChallenger ) )
		#endif 
		
		LocalMsg( player, "#FS_PlayerInChal" )
		return false
	}
	
	#if DEVELOPER 
		printt( "accepting player:", player, "challenger accepted:", recentChallenger )
	#endif
	
	file.acceptedChallenges[ player.p.handle ] <- recentChallenger
	removeChallenger( player, recentChallenger.p.handle )
	SetUpChallengeNotifications( player, recentChallenger )
	
	return true
}

void function SetUpChallengeNotifications( entity player, entity challenger )
{
	player.p.waitingFor1v1 = true 
	challenger.p.waitingFor1v1 = true
	
	LocalMsg( player, "#FS_ChalAccepted" )
	LocalMsg( challenger, "#FS_ChalAccepted" )
	
	player.p.entLastChallenger = challenger
	challenger.p.entLastChallenger = player
	
	SetChallengeNotifications( [ player, challenger ], true )
}

void function SetChallengeNotifications( array<entity> players, bool setting )
{
	foreach ( player in players )
	{
		if( !IsValid( player ) )
			continue 
			
		player.p.challengenotify = setting
		
		if( setting )
			thread ChallengeNotificationsThread( player )
	}
}

bool function endLock1v1( entity player, bool addmsg = true, bool revoke = false )
{
	if( !IsValid ( player ) )
		return false
	
	ClearNotifications( player, eNotify.CHALLENGE )
	int iRemoveOpponent = 0
	entity opponent = getLock1v1OpponentOfPlayer( player )
	entity challenged
	int playerHandle = player.p.handle
	
	if( playerHandle in file.acceptedChallenges )
	{
		delete file.acceptedChallenges[ playerHandle ]
		iRemoveOpponent = 1
	}
	else 
	{
		challenged = returnChallengedPlayer( player )
		
		if ( IsValid( challenged ) )
		{	
			int challenegedHandle = challenged.p.handle
			if( challenegedHandle in file.acceptedChallenges )
			{
				delete file.acceptedChallenges[ challenegedHandle ]
				iRemoveOpponent = 2
			}			
		}
		else 
		{
			if( addmsg )
			{
				LocalMsg( player, "#FS_NoChalToEnd" )
				return true
			}
		}	
	}
	
	if( iRemoveOpponent == 1 && IsValid( opponent ) )
	{
		if( addmsg || revoke )
			LocalMsg( opponent, "#FS_ChalEnded" )
		
		removeChallenger( player, opponent.p.handle )
		player.p.waitingFor1v1 = false
		opponent.p.waitingFor1v1 = false
	}
	
	if ( iRemoveOpponent == 2 && IsValid( challenged ) )
	{
		if( addmsg || revoke )
			LocalMsg( challenged, "#FS_ChalEnded")
		
		removeChallenger( challenged, playerHandle )
		player.p.waitingFor1v1 = false
		challenged.p.waitingFor1v1 = false
	}
	
	if ( iRemoveOpponent > 0 && IsPlayerInProgress( playerHandle ) )
	{
		soloGroupStruct group = returnSoloGroupOfPlayer( player )
		
		if( addmsg )
			LocalMsg( player, "#FS_ChalEnded" )
		
		if( group.isValid )
		{	
			group.IsKeep = false
			//group.IsFinished = true
			
			thread //(mk): without this delay, two calls can happen to rest on same frame, .001 apart. Resting list handles each other opponent causing undefined game behavior when group is still keep.
			(
				void function() : ( group )
				{
					wait 0.1
					
					if( !group.isValid )
						return 
						
					entity player1 = group.player1
					entity player2 = group.player2
					
					if( IsValid( player1 ) && !IsCurrentState( player1, e1v1State.RESTING ) )
						Gamemode1v1_ForceRest( player1 )
					
					WaitFrame()
					
					if( IsValid( player2 ) && !IsCurrentState( player2, e1v1State.RESTING ) )
						Gamemode1v1_ForceRest( player2 ) 
				
					AssignLegendToGroup( FlowState_ChosenCharacter(), [ group.player1, group.player2 ] )
					sendGroupRecapsToPlayers( group )
				}
			)()
		}
	}
	
	if( iRemoveOpponent > 0 )
	{
		entity opp
		
		if( IsValid( opponent ) )
		{
			ClearNotifications( opponent )
			opp = opponent
		}
		else if( IsValid( challenged ) )
		{
			ClearNotifications( challenged )
			opp = challenged
		}
		
		if( addmsg )
			LocalMsg( player, "#FS_ChalEnded" )
		
		ClearNotifications( player )
		SetChallengeNotifications( [ player, opp ], false )
	}
	
	return true
}

bool function IsPlayerPendingChallenge( entity player )
{
	return ( player.p.handle in file.acceptedChallenges )
}

bool function IsPlayerPendingLockOpponent( entity player )
{
	foreach ( challenged, opponent in file.acceptedChallenges )
	{
		if( !IsValid( opponent ) )
			continue
		
		if ( player == opponent )
			return true
	}
	
	return false
}

entity function returnChallengedPlayer( entity player )
{
	int playerHandle = player.p.handle
	entity p
	
	foreach( challenged_eHandle, challenger in file.acceptedChallenges )
	{
		if( !IsValid( challenger ) )
			continue
		
		if ( challenger == player )
		{
			return GetEntityFromEncodedEHandle( challenged_eHandle )
		}
		else if ( challenged_eHandle == playerHandle )
		{
			return challenger
		}
	}
	
	return p
}

entity function getLock1v1OpponentOfPlayer( entity player )
{
	entity p
	
	int playerEHandle = player.p.handle
	if( playerEHandle in file.acceptedChallenges )
	{
		if( IsValid( file.acceptedChallenges[ playerEHandle ] ) )
		{
			if( playerEHandle in file.soloPlayersWaiting )
				return file.acceptedChallenges[ playerEHandle ]
		}
	}
	
	return p
}

void function sendGroupRecapsToPlayers( soloGroupStruct group )
{
	if( !IsValid( group.player1 ) || !IsValid( group.player2 ) )
		return
	
	if ( !( group.player1 in group.statsRecap ) || !( group.player2 in group.statsRecap ) )
		return
	
	groupStats player1 = group.statsRecap[ group.player1 ]
	groupStats player2 = group.statsRecap[ group.player2 ]
	
	string serverMsg = ""
	string winnerName = ""
	string defeatedName = ""
	int winnerKills = 0
	int defeatedDeaths = 0
	bool tied = false
	
	#if TRACKER
		if( settings.bChalServerMsg )
		{
			if( player1.kills > player2.kills )
			{
				winnerName = group.player1.p.name 
				winnerKills = player1.kills
				defeatedName = group.player2.p.name 
				defeatedDeaths = player2.kills
			}
			else if ( player2.kills > player1.kills )
			{
				winnerName = group.player2.p.name 
				winnerKills = player2.kills
				defeatedName = group.player1.p.name 
				defeatedDeaths = player1.kills
			}
			else if ( player1.kills == player2.kills )
			{
				tied = true
				winnerName = group.player1.p.name
				winnerKills = player1.kills
				defeatedName = group.player2.p.name 
				defeatedDeaths = player2.kills
			}
			
			if ( tied )
				serverMsg = winnerName + " tied in a challenge vs " + defeatedName
			else 
				serverMsg = format(" %s won a challenge vs %s,  %d - %d", winnerName, defeatedName, winnerKills, defeatedDeaths )
			
			SendServerMessage( serverMsg + Chat_GetAllEffects()[ "SKULL" ] )
		}
	#endif
	
	groupRecapStats( group.player1, player1.damage, player1.hits, player1.shots, player1.kills, player1.deaths, player2.displayname, player2.damage, player2.hits, player2.shots, player2.kills, player2.deaths, group.startTime ) 
	groupRecapStats( group.player2, player2.damage, player2.hits, player2.shots, player2.kills, player2.deaths, player1.displayname, player1.damage, player1.hits, player1.shots, player1.kills, player1.deaths, group.startTime ) 
}

void function addStatsToGroup( entity player, soloGroupStruct group, float damage, int hits, int shots, bool bIsKill )
{
	if( !IsValid( player ) || !IsValid( group ) ){ return }
	
	if ( !( player in group.statsRecap ) )
	{
		groupStats gS
		group.statsRecap[ player ] <- gS
		group.statsRecap[ player ].player = player 
		group.statsRecap[ player ].displayname = player.p.name
	}
	
	group.statsRecap[ player ].damage += damage
	group.statsRecap[ player ].hits += hits
	group.statsRecap[ player ].shots += shots
	
	if( bIsKill )
		group.statsRecap[ player ].kills++
	else 
		group.statsRecap[ player ].deaths++
}

void function groupRecapStats( entity player, float damage, int hits, int shots, int kills, int deaths, string opponent, float opponentdamage, int opponenthits, int opponentshots, int opponentkills, int opponentdeaths, float startTime ) 
{
    float accuracy = 0.0
    float opponent_accuracy = 0.0
	
    if ( shots > 0.0 ) 
	{
        accuracy = ( hits.tofloat() / shots.tofloat() ) * 100.0
		
        if ( accuracy >= 100.0 ) 
            accuracy = 100.0
    }
	
	float kd = deaths > 0 ? kills.tofloat() / deaths.tofloat() : kills.tofloat()
	float opponentkd = opponentdeaths > 0 ? opponentkills.tofloat() / opponentdeaths.tofloat() : opponentkills.tofloat()
	
    if ( opponentshots > 0.0 ) 
	{
        opponent_accuracy = ( opponenthits.tofloat() / opponentshots.tofloat() ) * 100.0
		
        if ( opponent_accuracy >= 100.0 ) 
            opponent_accuracy = 100.0
    }

	float lasted = Time() - startTime;
    string print_totals = format("\n Fight lasted %d seconds. \n\n\n Your Dmg: %d \n Hits: %d \n Shots %d \n Your Accuracy: %d%% \n Your Kills: %d \n Your Deaths: %d \n Challenge KD: %.2f \n\n\n\n %s's Dmg: %d \n %s's Hits: %d \n %s's Shots %d \n %s's Accuracy: %d%% \n %s's Kills: %d \n %s's Deaths: %d \n %s's Challenge KD: %.2f", lasted, damage, hits, shots, accuracy, kills, deaths, kd, opponent, opponentdamage, opponent, opponenthits, opponent, opponentshots, opponent, opponent_accuracy, opponent, opponentkills, opponent, opponentdeaths, opponent, opponentkd);
 
	if( IsValid( player ) ) //Todo(mk): make ui. send this data to ui
		Message( player, "\n\n\n\n\n\n\n\n\n Recap vs: " + opponent, print_totals, 30 )
}

bool function isPlayerInChallenge( entity player )
{
	soloGroupStruct group = returnSoloGroupOfPlayer( player )
	
	if( !isGroupValid( group ) || !group.IsKeep )
		return false
	
	return true
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////

bool function ClientCommand_Maki_SoloModeRest( entity player, array<string> args )
{
	if( !IsValid( player ) )
		return false
	
	if( Time() < player.p.lastRestUsedTime + 3 || IsCurrentState( player, e1v1State.PREMATCH ) )
	{
		LocalEventMsg( player, "#FS_RESTCOOLDOWN" )
		return false
	}
	
	player.p.lastRestUsedTime = Time()
	
	string restText = "#FS_BASE_RestText";
	string restFlag = ""
	int playerHandle = player.p.handle

	if( playerHandle in file.soloPlayersResting )
	{
		if( player.IsObserver() || IsValid( player.GetObserverTarget() ) )
		{
			player.SetSpecReplayDelay( 0 )
			player.SetObserverTarget( null )
			player.StopObserverMode()
			//Remote_CallFunction_NonReplay(player, "ServerCallback_KillReplayHud_Deactivate")
			Remote_CallFunction_ByRef( player, "ServerCallback_KillReplayHud_Deactivate" )
			player.MakeVisible()
			player.ClearInvulnerable()
			player.SetTakeDamageType( DAMAGE_YES )
		}

		LocalMsg( player, "#FS_MATCHING" )	
		soloModePlayerToWaitingList( player )
		
		// try
		// {
			// player.Die( null, null, { damageSourceId = eDamageSourceId.damagedef_despawn } )
		// }
		// catch (error)
		// {}
	}
	else
	{
		if( IsPlayerInProgress( playerHandle ) )
		{		
			entity opponent
			float timeNow
			bool skip = false
			soloGroupStruct group = returnSoloGroupOfPlayer( player )			
			if( !group.isValid )
				skip = true
			
			if( !skip )
			{
				opponent = player == group.player1 ? group.player2 : group.player1
				timeNow = Time()
			}
			
			if ( !IsValid( opponent ) )
				skip = true
			
			if( !skip )
			{
				DamageEvent event = Tracker_GetCurrentEventForAttackerOnVictim( opponent.p.handle, player.p.handle ) 
				
				float lastHitTime = event.lastHitTimestamp
				
				float difference = ( timeNow - lastHitTime )
				
				bool start_grace_exceeded = false
				
				if( ( timeNow - group.startTime ) > file.restGrace )
					start_grace_exceeded = true
				
				if( difference < file.restGrace || !start_grace_exceeded )
				{	
					float fTryAgainIn
					
					if( start_grace_exceeded )
						fTryAgainIn = file.restGrace - ( timeNow - lastHitTime )
					else 
						fTryAgainIn = file.restGrace - ( timeNow - group.startTime )
					
					string sTryAgain = format( " %d", floor( fTryAgainIn.tointeger() ) )
					#if DEVELOPER
						sqprint(format( "Time was too soon: difference:  %d, file.restGrace: %d ", difference, file.restGrace ))
					#endif
					
					LocalMsg( player, "#FS_SendingToRestAfter", "#FS_TryRestAgainIn", eMsgUI.DEFAULT, 5, "", sTryAgain )
					player.p.rest_request = true
					return true
				}
				else
				{
					#if DEVELOPER
						sqprint( format( "Time was good: difference: %d, file.restGrace: %d ", difference, file.restGrace ) )
					#endif
					
					restText = "#FS_RestGrace"
					restFlag = file.restGrace.tostring()
				}
			}
		}
			
		if ( restFlag == "" )		
			LocalMsg( player, "#FS_YouAreResting", restText )
		else 
			LocalMsg( player, "#FS_YouAreResting", restText, eMsgUI.DEFAULT, 5, "", restFlag )
		
		try
		{
			player.Die( null, null, { damageSourceId = eDamageSourceId.damagedef_despawn } )
		}
		catch (error)
		{

		}
		
		soloModePlayerToRestingList( player )
		
		HolsterAndDisableWeapons_Raw( player ) //✓
		thread respawnInSoloMode( player )
		//TakeAllWeapons( player )
	}

	return true
}

bool function TryProcessRestRequest( entity player )
{
	if( !IsValid( player ) ) //probably unneccessary
		return false
	
	if ( player.p.rest_request )
	{
		player.p.rest_request = false
		Gamemode1v1_ForceRest( player )
		return true
	}
	
	return false
}

entity function getRandomOpponentOfPlayer( entity player )
{
    entity p
	
    if ( !IsValid( player ) ) 
		return p

    array<entity> eligible = []
    foreach ( playerHandle, eachPlayerStruct in file.soloPlayersWaiting )
    {   			
        if ( IsValid( eachPlayerStruct.player ) && player != eachPlayerStruct.player && !eachPlayerStruct.player.p.waitingFor1v1 )
		{
            if ( eachPlayerStruct.player.p.input == player.p.input || ( eachPlayerStruct.IBMM_Timeout_Reached == true && Fetch_IBMM_Timeout_For_Player( player ) == true ) )
                eligible.append(eachPlayerStruct.player)
		}
    }
	
	int count = eligible.len()
	if( count > 0 )
	{
		entity foundOpponent = eligible[ RandomIntRangeInclusive( 0, count - 1 ) ]
		
		if( IsValid( foundOpponent ) )
			return foundOpponent
	}
    
	return p
}



entity function returnOpponentOfPlayer( entity player ) 
{
	soloGroupStruct group = returnSoloGroupOfPlayer( player )
    entity opponent
  
	if ( group.isValid && IsValid( player ) ) 
	{
		if( IsValid( group.player2 ) && IsValid( group.player1 ) )
		{
			if ( player == group.player1 ) 
				opponent = group.player2
			else
				opponent = group.player1
		}
    }
	
    return opponent
}


void function soloModePlayerToWaitingList( entity player )
{
	if( !IsValid( player ) || isPlayerInWaitingList( player ) || IsBotEnt( player ) ) 	
		return
		
	Gamemode1v1_SetPlayerGamestate( player, e1v1State.WAITING )
	
	if( settings.isScenariosMode )
	{
		Remote_CallFunction_NonReplay( player, "FS_Scenarios_TogglePlayersCardsVisibility", false, true )

		if( player.Player_IsFreefalling() )
			Signal( player, "PlayerSkyDive" )

		_CleanupPlayerEntities( player )
		SetTeam( player, TEAM_IMC )

		scenariosGroupStruct ornull playerGroup = FS_Scenarios_ReturnGroupForPlayer( player )	
		if( playerGroup != null )
		{
			expect scenariosGroupStruct( playerGroup )
		
			if( playerGroup.isValid )
			{
				foreach( scenariosTeamStruct team in playerGroup.teams )
				{
					int maxIter = team.players.len() - 1
					
					for( int i = maxIter; i >= 0; i-- )
					{
						entity splayer = team.players[i]
						
						if( !IsValid( splayer ) || splayer == player )
							team.players.remove( i )
					}
				}

				if( player.p.handle in FS_Scenarios_GetPlayerToGroupMap() )
					delete FS_Scenarios_GetPlayerToGroupMap()[ player.p.handle ]
				
				player.SetShieldHealth( 0 )
				player.SetShieldHealthMax( 0 )
				Inventory_SetPlayerEquipment(player, "", "armor")
				Inventory_SetPlayerEquipment(player, "", "backpack")
				Inventory_SetPlayerEquipment(player, "", "incapshield")
				Inventory_SetPlayerEquipment(player, "", "helmet")
				if( IsAlive( player ) )
					player.SetHealth( player.GetMaxHealth() )
			}
		}

		//Remote_CallFunction_NonReplay(player, "Minimap_DisableDraw_Internal")
		Remote_CallFunction_ByRef( player, "Minimap_DisableDraw_Internal" )
		
		ClearRecentDamageHistory( player )
		ClearLastAttacker( player )
		
		TakeAllPassives( player )
		player.SetPlayerNetTime( "FS_Scenarios_currentDeathfieldRadius", 0 )
		player.SetPlayerNetTime( "FS_Scenarios_currentDistanceFromCenter", -1 )
		player.SetPlayerNetTime( "FS_Scenarios_gameStartTime", -1 )

		if( Bleedout_IsBleedingOut( player ) )
			Signal( player, "BleedOut_OnRevive" )

		Signal(player, "InterruptSyncedMelee")
		
		player.SetPlayerNetTime( "FS_Scenarios_timePlayerEnteredInLobby", Time() )
		Remote_CallFunction_ByRef( player, "FS_DestroyCompass" )
	}

	SetPlayerInventory( player, [] ) //clear inventory.
	
	// Clear all equipment slots
	foreach ( slot, slotData in EquipmentSlot_GetAllEquipmentSlots() )
		Inventory_SetPlayerEquipment( player, "", slot )
		
	player.TakeOffhandWeapon( OFFHAND_MELEE )
	player.SetPlayerNetEnt( "FSDM_1v1_Enemy", null )

	soloPlayerStruct playerStruct	
	playerStruct.player = player
	playerStruct.handle = player.p.handle
	
	if( !settings.isScenariosMode && !bIsCoachingMode() )
		playerStruct.waitingTime = Time() + 2

	float season_kd
	float current_kd
	
	// weighted scoring
	season_kd = getkd( ( player.GetPlayerNetInt( "kills" ) + player.p.season_kills), ( player.GetPlayerNetInt( "deaths" ) + player.p.season_deaths ) )
	current_kd = getkd( player.GetPlayerNetInt( "kills" ), player.GetPlayerNetInt( "deaths" )  )	
	playerStruct.kd = ( ( season_kd * file.season_kd_weight ) + ( current_kd * file.current_kd_weight ) )

	playerStruct.lastOpponent = player.p.lastKiller

	playerStruct.queue_time = Time()
	AddPlayerToWaitingList( playerStruct )
	ResetIBMM( player ) //must be after adding to waiting list.
	
	//sqprint(format("Queue time set for %s AT: %f ", playerStruct.player.GetPlayerName(), playerStruct.queue_time ))
	//sqprint(format("Setting player %s inputmode to: %s", player.GetPlayerName(), player.p.inputmode ))
	
	TakeAllWeapons( player )

	//set realms for resting player
	FS_ClearRealmsAndAddPlayerToAllRealms( player )
	
	if( !isScenariosMode() && !bIsCoachingMode() )
		Remote_CallFunction_ByRef( player, "ForceScoreboardFocus" )

	// Check opponent -- (mk):cannot do this here, it will simply result in double calls for both players.
	// entity opponent = returnOpponentOfPlayer( player )
	// if( IsValid( opponent ) )
		// soloModePlayerToWaitingList( opponent )
	
	//检查resting list 是否有该玩家
	deleteSoloPlayerResting( player )

	// if( isScenariosMode() && FS_Scenarios_GetMatchIsEnding() ) (mk): why was this removed..?
		// LocalMsg( player, "#FS_Scenarios_WaitingForRoundEnd", "", eMsgUI.EVENT, max( 1, g_fCurrentRoundEndTime - Time() ) )
	// else 
	
	if( !bIsCoachingMode() )
		LocalMsg( player, "#FS_IN_QUEUE", "", eMsgUI.EVENT, settings.roundTime )

	if( bIsCoachingMode() )
	{
		if( !IsAlive( player ) )
			DecideRespawnPlayer( player, false )

		if( GetPlayerArray().len() == 2 )
		{
			Message_New( player, "Welcome to District's 1v1 Faceoff\n\n Waiting For Admin To Start", 300 )
			Remote_CallFunction_NonReplay(player, "Flowstate_OpenCoachingMenu")
		}
		else
			Message_New( player, "Welcome to District's 1v1 Faceoff\n\n Waiting Another Player To Start", 9999 )
	}
}

void function soloModePlayerToInProgressList( soloGroupStruct newGroup ) 
{
    entity player = newGroup.player1
    entity opponent = newGroup.player2
    
    if ( !IsValid( player ) || !IsValid( opponent ) ) 
        return
	
	if( player == opponent )
	{
		#if DEVELOPER 
			DumpStack()
			mAssert( false, "Tried to add same players to inprogress list." )
		#endif
		// Warning("Try to add same players to InProgress list:" + player.GetPlayerName())
		player.SetPlayerNetEnt( "FSDM_1v1_Enemy", null )
		return
	}
	
	Gamemode1v1_SetPlayerGamestate( player, e1v1State.PREMATCH )
	Gamemode1v1_SetPlayerGamestate( opponent, e1v1State.PREMATCH )
	
    player.SetPlayerNetEnt( "FSDM_1v1_Enemy", opponent )
    opponent.SetPlayerNetEnt( "FSDM_1v1_Enemy", player )
	LocalMsg( player, "#FS_NULL", "", eMsgUI.EVENT, 1 )

    if ( player.p.handle in file.playerToGroupMap || opponent.p.handle in file.playerToGroupMap ) 
	{	
        soloGroupStruct existingGroup = player.p.handle in file.playerToGroupMap ? file.playerToGroupMap[ player.p.handle ] : file.playerToGroupMap[ opponent.p.handle ]	
        
		destroyRingsForGroup( existingGroup )
		
		#if DEVELOPER
			sqprint("remove group request 02")
		#endif
		
		if ( mGroupMutexLock )
		{
			throw "R002"
			return 
		}
		
        removeGroup( existingGroup )

        return
    }

	//not found 
	newGroup.player1 = player
	newGroup.player2 = opponent
		
    deleteWaitingPlayer( player.p.handle )
    deleteWaitingPlayer( opponent.p.handle )
    deleteSoloPlayerResting( player )
    deleteSoloPlayerResting( opponent )
    
    int slotIndex = getAvailableRealmSlotIndex()
	
    if ( slotIndex > -1 ) 
	{
        newGroup.slotIndex = slotIndex
        newGroup.groupLocStruct = soloLocations.getrandom()
		
		if( mGroupMutexLock ) 
		{
			throw "R001"
			return
		}
		
		addGroup( newGroup )
    }
}

void function _3v3ModePlayerToRestingList( entity player )
{
	int playerHandle = player.p.handle
	deleteWaitingPlayer( playerHandle )
	addSoloPlayerResting( playerHandle )
	
	Gamemode1v1_SetPlayerGamestate( player, e1v1State.RESTING )
	LocalMsg( player, "#FS_RESTING", "", eMsgUI.EVENT, settings.roundTime )
}

void function soloModePlayerToRestingList( entity player ) //handles opponent to waiting list.
{
	if( !IsValid( player ) )
		return
	
	player.TakeOffhandWeapon( OFFHAND_MELEE )
	ClearNotifications( player )
	
	player.SetPlayerNetEnt( "FSDM_1v1_Enemy", null )
	deleteWaitingPlayer( player.p.handle )

	soloGroupStruct group = returnSoloGroupOfPlayer( player )
	if( group.isValid )
	{
		if( IsPlayerPendingChallenge( player ) || IsPlayerPendingLockOpponent( player ) )
			endLock1v1( player, true )
	
		entity opponent = returnOpponentOfPlayer( player )

		// if(IsValid(soloLocations[group.slotIndex].Panel)) //Panel in current Location
			// soloLocations[group.slotIndex].Panel.SetSkin(1) //set panel to red(default color)

		destroyRingsForGroup( group )
		
		#if DEVELOPER
			sqprint( "remove group request 03" )
		#endif
		
		if( mGroupMutexLock ) 
		{
			throw "mGroupMutexLock 03"
			return
		}
		
		removeGroup( group ) //销毁这个group

		if( IsValid( opponent ) )//找不到对手		
			soloModePlayerToWaitingList( opponent ) //将对手放回waiting list
	}
	else 
	{
		endLock1v1( player, false )
	}
	
	addSoloPlayerResting( player.p.handle )
	LocalMsg( player, "#FS_RESTING", "", eMsgUI.EVENT, settings.roundTime )
	
	DecideToggleCollision_Rest( player, false )
	Gamemode1v1_SetPlayerGamestate( player, e1v1State.RESTING )
	player.p.rest_request = false
}

void function soloModefixDelayStart( entity player, bool bNextRoundNow = false )
{
	Gamemode1v1_SetPlayerGamestate( player, e1v1State.MATCH_START  )
	AddEntityCallback_OnPlayerRespawned_FireOnce( player, Gamemode1v1_TakeAll )//(mk): probably not needed.
	
	if( settings.isScenariosMode || bNextRoundNow )
		return
	
	if( GetGameState() >= eGameState.Playing )
		wait 7
	else
		wait 12
	
	if( !IsValid( player ) )
		return
	
	if( !isPlayerInRestingList( player ) )
		soloModePlayerToWaitingList( player )
}

const int MAX_REALM = 63

void function FS_SetRealmForPlayer( entity player, int realmIndex )
{
	if( !IsValid( player ) || realmIndex > MAX_REALM ) 
		return 

	player.RemoveFromAllRealms()
	player.AddToRealm( realmIndex )
}

void function FS_ClearRealmsAndAddPlayerToAllRealms( entity player )
{
	if( !IsValid( player ) ) //?
		return

	player.AddToAllRealms()
}

void function destroyRingsForGroup( soloGroupStruct group )
{
	if( !IsValid( group.ring ) ) 
		return
		
	group.ring.Destroy()
}

entity function CreateSmallRingBoundary( vector Center )
{
    vector smallRingCenter = Center
	float smallRingRadius = 2000
	entity smallcircle = CreateEntity( "prop_script" )
	smallcircle.SetValueForModelKey( $"mdl/fx/ar_survival_radius_1x100.rmdl" )
	smallcircle.kv.fadedist = 2000
	smallcircle.kv.modelscale = smallRingRadius
	smallcircle.kv.renderamt = 1
	smallcircle.kv.rendercolor = FlowState_RingColor()
	smallcircle.kv.solid = 0
	smallcircle.kv.VisibilityFlags = ENTITY_VISIBLE_TO_EVERYONE
	// smallcircle.SetOwner(Owner)
	smallcircle.SetOrigin( smallRingCenter )
	smallcircle.SetAngles( <0, 0, 0> )
	smallcircle.NotSolid()
	smallcircle.DisableHibernation()
	smallcircle.RemoveFromAllRealms()

	// smallcircle.Minimap_SetObjectScale( min(smallRingRadius / SURVIVAL_MINIMAP_RING_SCALE, 1) )
	// smallcircle.Minimap_SetAlignUpright( true )
	// smallcircle.Minimap_SetZOrder( 2 )
	// smallcircle.Minimap_SetClampToEdge( true )
	// smallcircle.Minimap_SetCustomState( eMinimapObject_prop_script.OBJECTIVE_AREA )

	DispatchSpawn( smallcircle )

	// foreach ( eachPlayer in GetPlayerArray() )
	// {
	// 	smallcircle.Minimap_AlwaysShow( 0, eachPlayer )
	// }
	return smallcircle
}

entity function createForbiddenZone( vector zoneOrigin, float radius,float AboveHeight = 50,float BelowHeight = 15 )
{
	entity trigger = CreateEntity( "trigger_cylinder" )
	trigger.SetRadius( radius )
	trigger.SetAboveHeight( AboveHeight )
	trigger.SetBelowHeight( BelowHeight )
	trigger.SetOrigin( zoneOrigin )
	trigger.SetEnterCallback(  forbiddenZone_enter )
	trigger.SetLeaveCallback(  forbiddenZone_leave )
	trigger.SearchForNewTouchingEntity()
	// DebugDrawCylinder( trigger.GetOrigin() , < -90, 0, 0 >, radius, trigger.GetAboveHeight(), 0, 165, 255, true, 9999.9 )
	// DebugDrawCylinder( trigger.GetOrigin() , < -90, 0, 0 >, radius, -trigger.GetBelowHeight(), 255, 90, 0, true, 9999.9 )
	DispatchSpawn( trigger )
	return trigger
}

void function forbiddenZoneInit( string mapName )
{
	array<vector> triggerList
	if( mapName == "mp_rr_aqueduct" )
	{
		triggerList = 
		[
			<8693.24,-1103.93,571.29>,
			<-4805,-2543.85,553.75>,
		]
	}
	else
	{
		return
	}
	
	foreach( origin in triggerList )	
		createForbiddenZone( origin,600 )
}

void function forbiddenZone_enter(entity trigger , entity ent)
{
	if( !IsValid( ent ) || !ent.IsPlayer() ) 
		return
		
	HolsterAndDisableWeapons( ent ) //✓
	EntityOutOfBounds( trigger, ent, null, null )
}

void function forbiddenZone_leave(entity trigger , entity ent)
{
	if( !IsValid(ent) || !ent.IsPlayer() ) 
		return
		
	EnableOffhandWeapons( ent )
	DeployAndEnableWeapons( ent ) //✓
	EntityBackInBounds( trigger, ent, null, null )
}

void function maki_tp_player( entity player, LocPair data )
{
	if( !IsValid( player ) ) 
		return
		
	player.SetVelocity( Vector( 0,0,0 ) )
	player.SetAngles( data.angles )
	player.SetOrigin( data.origin )
}

void function PlayerRestoreHP_1v1( entity player, float health, float shields )
{
	if( !IsValid( player ) ) 
		return
	
	if( !IsAlive( player ) ) 
		return

	player.SetHealth( health )
	
	if( settings.enableHelmets )
		Inventory_SetPlayerEquipment(player, "helmet_pickup_lv3", "helmet")
		
		if( shields == 0 )
			Inventory_SetPlayerEquipment(player, "", "armor")
		else if(shields <= 50)
			Inventory_SetPlayerEquipment( player, "armor_pickup_lv1", "armor" )
		else if(shields <= 75)
			Inventory_SetPlayerEquipment( player, "armor_pickup_lv2", "armor" )
		else if(shields <= 100)
			Inventory_SetPlayerEquipment( player, "armor_pickup_lv3", "armor" )
		else if(shields <= 125 )
			Inventory_SetPlayerEquipment( player, "armor_pickup_lv5", "armor" )

	player.SetShieldHealth( shields )
}

bool function isGroupValid( soloGroupStruct group )
{
	if( !group.isValid ) 
		return false
		
	if( !IsValid( group.player1 ) || !IsValid( group.player2 ) ) 
		return false
		
	return true
}

void function respawnInSoloMode( entity player, int respawnSlotIndex = -1 ) //复活死亡玩家和同一个sologroup的玩家
{
	if ( !IsValid( player ) ) 
		return
	
	if ( !player.p.isConnected ) 
		return
	
	// printt("respawnInSoloMode!")
	// Warning("respawn player: " + player.GetPlayerName())

   	if( player.p.isSpectating )
    {
		player.SetPlayerNetInt( "spectatorTargetCount", 0 )
		player.p.isSpectating = false
		player.SetSpecReplayDelay( 0 )
		player.SetObserverTarget( null )
		player.StopObserverMode()
        //Remote_CallFunction_NonReplay(player, "ServerCallback_KillReplayHud_Deactivate")
		Remote_CallFunction_ByRef( player, "ServerCallback_KillReplayHud_Deactivate" )
        player.MakeVisible()
		player.ClearInvulnerable()
		player.SetTakeDamageType( DAMAGE_YES )
    }//disable replay mode

	Remote_CallFunction_ByRef( player, "ForceScoreboardLoseFocus" )

   	if( isPlayerInRestingList( player ) )
	{
		// Warning("resting respawn")
		try
		{
			Gamemode1v1_SetPlayerGamestate( player, e1v1State.SEQUENCE )
			DecideRespawnPlayer( player, false )
		}
		catch( erroree )
		{	
			#if DEVELOPER
				sqprint("Caught an error that would crash the server" + erroree)
			#endif
		}
		
		LocPair waitingRoomLocation = getWaitingRoomLocation()
		if ( !IsValid( waitingRoomLocation ) ) 
			return
		
		GivePlayerCustomPlayerModel( player )
		maki_tp_player( player, waitingRoomLocation )
		player.MakeVisible()
		player.ClearInvulnerable()
		player.SetTakeDamageType( DAMAGE_YES )

		//set realms for resting player
		FS_ClearRealmsAndAddPlayerToAllRealms( player )

		return
	}//玩家在休息模式

	if ( respawnSlotIndex == -1 ) 
		return
	
	try
	{
		Gamemode1v1_SetPlayerGamestate( player, e1v1State.SEQUENCE )
		DecideRespawnPlayer( player, false )
	}
	catch (error)
	{
		#if DEVELOPER
			sqprint("Caught an error that would crash the server")
		#endif
		// Warning("fail to respawn")
	}
	
	soloGroupStruct group = returnSoloGroupOfPlayer( player )
	if( !isGroupValid( group ) )
	{	
		#if DEVELOPER
			sqerror("group was invalid, err 007")
		#endif
		return
	}
	
	GivePlayerCustomPlayerModel( player )
	
	soloLocStruct groupLocStruct = group.groupLocStruct
	maki_tp_player( player, groupLocStruct.respawnLocations[ respawnSlotIndex ] )
	
	wait 0.2 //防攻击的伤害传递止上一条命被到下一条命的玩家上

	if( !IsValid( player ) ) 
		return

	if( Equipment_GetDefaultShieldHP() > 0 && !Flowstate_IsLGDuels() )
	{
		player.SetShieldHealthMax( Equipment_GetDefaultShieldHP() )
		PlayerRestoreHP_1v1( player, 100, player.GetShieldHealthMax().tofloat() )
	} 
	else
	{
		PlayerRestoreHP_1v1( player, 100, 0 )
		Inventory_SetPlayerEquipment( player, "", "armor" )
	}
	
	if( bIsCoachingMode() )
	{
		FS_Coaching_StartRecording( player )
	}
	
	wait 0.1
	ReCheckGodMode( player ) //Todo(mk): fix and remove the need for this.
}

void function _decideLegend( soloGroupStruct group )
{
	if ( !isGroupValid( group ) )
		return
	
	ItemFlavor select_character
	
	if ( group.p1LegendIndex > 0 )
	{
		if( group.p1LegendIndex <= 10 )
		{
			select_character = file.characters[ characterslist[ group.p1LegendIndex ] ]
			CharacterSelect_AssignCharacter( ToEHI( group.player1 ), select_character )
		}
		else 
		{
			SetPlayerCustomModel( group.player1, group.p1LegendIndex )
		}	
	}

	if ( group.p2LegendIndex > 0 )
	{
		if( group.p2LegendIndex <= 10 )
		{
			select_character = file.characters[ characterslist[ group.p2LegendIndex ] ]
			CharacterSelect_AssignCharacter( ToEHI( group.player2 ), select_character )
		}
		else 
		{
			SetPlayerCustomModel( group.player2, group.p2LegendIndex )
		}
	}	
	
	if( !settings.bAllowAbilities )
	{
		group.player1.TakeOffhandWeapon( OFFHAND_TACTICAL )
		group.player2.TakeOffhandWeapon( OFFHAND_TACTICAL )
	}
	else 
	{	
		RechargePlayerAbilities( group.player1, group.p1LegendIndex )
		RechargePlayerAbilities( group.player2, group.p2LegendIndex )
	}
}

void function GivePlayerCustomPlayerModel( entity ent )
{
	if( FlowState_ChosenCharacter() > 10 )
		SetPlayerCustomModel( ent, FlowState_ChosenCharacter() )
}

void function INIT_WeaponsMenu()
{
	AddClientCommandCallback( "CC_MenuGiveAimTrainerWeapon", CC_MenuGiveAimTrainerWeapon ) 
	AddClientCommandCallback( "CC_AimTrainer_SelectWeaponSlot", CC_AimTrainer_SelectWeaponSlot )
	AddClientCommandCallback( "CC_AimTrainer_WeaponSelectorClose", CC_AimTrainer_CloseWeaponSelector )
}

void function INIT_WeaponsMenu_Disabled()
{
	AddClientCommandCallback( "CC_MenuGiveAimTrainerWeapon", MessagePlayer_Disabled ) 
	AddClientCommandCallback( "CC_AimTrainer_SelectWeaponSlot", MessagePlayer_Disabled )
	AddClientCommandCallback( "CC_AimTrainer_WeaponSelectorClose", MessagePlayer_Disabled )
}

bool function MessagePlayer_Disabled( entity player, array<string> args )
{
	LocalEventMsg( player, "#FS_DisabledTDMWeps" )
	return true
}

vector function Gamemode1v1_FetchNotificationPanelCoordinates()
{
	return file.notificationPanel_Coordinates
}

vector function Gamemode1v1_FetchNotificationPanelAngles()
{
	return file.notificationPanel_Angles
}


void function BannerImages_1v1Init()
{
	LocPair main_banner__Coordinates = NewLocPair( Gamemode1v1_FetchNotificationPanelCoordinates(), Gamemode1v1_FetchNotificationPanelAngles() )
	main_banner__Coordinates.origin = main_banner__Coordinates.origin + < 0,0,267 >
	
	vector testOrigin 	= main_banner__Coordinates.origin + <0,0,16> //height offset for player eyes.
	vector testAngles 	= main_banner__Coordinates.angles
	float defaultWidth 	= 480 //todo playlistvar
	float defaultHeight	= 270 //todo playlistvar
	
	LocPair setBannerLoc = NewLocPair( BannerAssets_BannerVisibilityMover( getWaitingRoomLocation().origin, getWaitingRoomLocation().angles, testOrigin, testAngles, defaultWidth, defaultHeight ), testAngles )
	
	BannerAssets_SetAllGroupsFunc
	(
		void function() : ( setBannerLoc, defaultWidth, defaultHeight )
		{
			BannerAssets_RegisterGroup
			(
				"main_banner",
				setBannerLoc,
				defaultWidth,
				defaultHeight,
				.95,
				5
			)
		}
	)
	
	BannerAssets_SetAllAssetsFunc
	(
		void function()
		{
			try
			{
				string assetList = GetCurrentPlaylistVarString( "banner_assets", "" )
				
				if( !empty( assetList ) )
				{	
					array<string> playlistBannerAssets = StringToArray( assetList )
					
					foreach( assetRef in playlistBannerAssets )
					{
						int refID = WorldDrawAsset_AssetRefToID( assetRef )
						
						if( refID != -1 )
						{
							BannerAssets_GroupAppendAsset
							(
								"main_banner",
								refID
							)
						}
						else
						{
							sqerror( format( "Invalid BannerAsset. Skipping asset: '%s'", assetRef ) )
						}
					}
				}
			}
			catch(e)
			{
				sqerror( "ERROR: " + e )
			}
		}
	)
	
	BannerAssets_Init()
}

void function INIT_PregameCallbacks()
{
	float f_wait = settings.default_ibmm_wait
		
	if ( f_wait > 0.0 && f_wait < 3.0 )
	{
		//this shouldn't be defined out, it lets the host know they have an invalid setting
		sqerror( format( "Default IBMM wait time was set as '%.2f' ; must be either 0 or >= 3. Resetting to 3.", f_wait ) )
	}

	//(mk):custom light for custom spawns
	// if( MapName() == eMaps.mp_rr_arena_composite && GetCurrentPlaylistVarBool( "patch_for_dropoff", false ) )
	// {
		// DropoffPatch_Init()
		// AddCallback_SpawnsPostInit( Init_DropoffPatchSpawns )
	// }

	if( Playlist() == ePlaylists.fs_1v1_headshots_only )
	{
		AddCallback_SpawnsSettings
		( 
			void function()
			{
				SpawnSystem_SetCustomPlaylist( "fs_1v1" ) //(mk): this can be set in playlist for simplicity
			}
		)
	}
		
	AddCallback_OnPlayerKilled( Gamemode1v1_OnPlayerKilled )
	AddCallback_OnTdmStateEnter_InProgress( OnMatchStart )
}

void function Gamemode1v1_Init( int eMap )
{
	RegisterSignal( "ChallengeStarted" )
	RegisterSignal( "ChallengeEnded" )
	
	#if DEVELOPER 
		DEV_1v1Init()
	#endif
	
	INIT_PlaylistSettings() // Always first
	INIT_PregameCallbacks()
	INIT_1v1_sbmm()
	INIT_HostCustomWeapons()
	
	if( !isScenariosMode() && !bIsCoachingMode() ) //intertwined D:
	{
		AddClientCommandCallback( "start_in_rest", ClientCommand_mkos_start_in_rest_setting ) 
		AddClientCommandCallback( "wait", ClientCommand_mkos_IBMM_wait )
		AddClientCommandCallback( "lock1v1", ClientCommand_mkos_lock1v1_setting )
		AddClientCommandCallback( "enable_input_banner", ClientCommand_enable_input_banner )
		AddClientCommandCallback( "challenge", ClientCommand_mkos_challenge )
	}
	else if( bIsCoachingMode() )
	{
		//INIT_CC_playeradmins() //(mk): Already called in PIN_Init()
		FS_Init_1v1_Coaching()
	}
	
	if( Playlist() == ePlaylists.fs_lgduels_1v1 )
		Flowstate_LgDuels1v1_Init()
		
	SpawnSystem_InitGamemodeOptions()
		
	SetHostInvetoryAttachments()
	
	if( settings.bAllowWeaponsMenu )
		INIT_WeaponsMenu()
	else 
		INIT_WeaponsMenu_Disabled()

	if( settings.isScenariosMode )
		Init_FS_Scenarios()
	
	file.restGrace = GetCurrentPlaylistVarFloat( "rest_grace", 0.0 )
	
	if( !settings.player_collision_enabled )
		AddCallback_OnPlayerRespawned( DisablePlayerCollision )
	
	file.characters = GetAllCharacters()
	characterslist = [0,1,2,3,4,5,6,7,8,9,10,11,12,13] //TODO(mk): uniform legend system
	Init_ValidLegendRange()
	
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//INIT PRIMARY WEAPON SELECTION
	if ( Flowstate_IsLGDuels() ) //todo fire a SetCallback to set
		file.Weapons = [ "mp_weapon_lightninggun" ]	
	
	if ( file.Weapons.len() == 0 && !settings.bNoPrimary )
	{
		file.Weapons = 
		[
			"mp_weapon_r97 optic_cq_hcog_classic stock_tactical_l1 bullets_mag_l2",	
			"mp_weapon_rspn101 optic_cq_hcog_classic stock_tactical_l1 bullets_mag_l2",
			"mp_weapon_vinson optic_cq_hcog_classic stock_tactical_l1 highcal_mag_l3",
			"mp_weapon_energy_ar optic_cq_hcog_classic stock_tactical_l1 hopup_turbocharger",
			"mp_weapon_volt_smg optic_cq_hcog_classic energy_mag_l1 stock_tactical_l1"
		]
	}
	
	//longrange class primary
	if( file.LongRangeWeapons.len() == 0 && !settings.bNoPrimaryLongrange )
		file.LongRangeWeapons = [ "mp_weapon_g2 optic_cq_hcog_bruiser" ]		

	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//INIT SECONDARY WEAPON SELECTION	
	if ( Flowstate_IsLGDuels() ) 
		file.WeaponsSecondary = [ "mp_weapon_lightninggun" ] //Lg_Duel beta		
	
	if ( file.WeaponsSecondary.len() == 0 && !settings.bNoSecondary )
	{
		file.WeaponsSecondary =
		[
			"mp_weapon_wingman optic_cq_hcog_classic sniper_mag_l1",
			"mp_weapon_energy_shotgun shotgun_bolt_l1",
			"mp_weapon_mastiff shotgun_bolt_l2",
			"mp_weapon_doubletake energy_mag_l3 stock_sniper_l3"	
		]
	}
	
	//longrange class secondary
	if( file.LongRangeWeaponsSecondary.len() == 0 && !settings.bNoSecondaryLongrange )
		file.LongRangeWeaponsSecondary = [ "mp_weapon_sniper" ]
	
	
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Validate final selection to host settings 
	
	ValidateBlacklistedWeapons( file.Weapons )
	ValidateBlacklistedWeapons( file.LongRangeWeapons )	
	ValidateBlacklistedWeapons( file.WeaponsSecondary )
	ValidateBlacklistedWeapons( file.LongRangeWeaponsSecondary )
	
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	
	if( Playlist() == ePlaylists.fs_vamp_1v1 ) //Todo(mk): This should be handled by the mode's script file using AddCallback_SpawnsSettings
		SpawnSystem_SetCustomPlaylist( "fs_1v1" )

	FlagWait( "EntitiesDidLoad" )
	array<SpawnData> allSoloLocations = SpawnSystem_ReturnAllSpawnLocations()
	
	file.notificationPanel_Coordinates = Gamemode1v1_GetNotificationPanel_Coordinates()
	file.notificationPanel_Angles = Gamemode1v1_GetNotificationPanel_Angles()	
	
	if( !ValidateSpawns( allSoloLocations ) )
	{
		SpawnSystem_SetPreferredPak( 1 )
		//SpawnSystem_SetRunCallbacks( false ) //(mk): for this mode, we wont disable re-running callbacks, as they may be needed to customize spawns again. If the gamemode dev has prop spawning or things that should only be done once, they should make sure it's only init once in their logic.
		allSoloLocations = SpawnSystem_ReturnAllSpawnLocations()
		
		//mAssert( ValidateSpawns( allSoloLocations ), "No valid spawns were defined" )
		if( !ValidateSpawns( allSoloLocations ) )
		{
			while( GetTDMState() != eTDMState.IN_PROGRESS )
				WaitFrame()
				
			wait 8
			sqwarning( "No valid spawns defined" )
			
			foreach( player in GetPlayerArray() )
				Message( player, "Map Config Error", "No valid spawns defined." )
			
			#if DEVELOPER 
				mAssert( false, "No valid spawns defined; Release behavior: Tracker_GotoNextMap.  Current Map: %s", GetMapName()  )
				return
			#endif
			
			wait 5
			Tracker_GotoNextMap()
		}
	}
	
	g_randomWaitingSpawns = SpawnSystem_GenerateRandomSpawns( getWaitingRoomLocation().origin, getWaitingRoomLocation().angles, file.waitingRoomRadius, .22, 60 ) //todo(mk): scenarios origin waiting area offset is not centered for polished effect

	if( settings.isScenariosMode )
	{
		int teamAmount = GetCurrentPlaylistVarInt( "fs_scenarios_teamAmount", 3 )	
		string potentialTeamCount = SpawnSystem_GetPakInfoForKey( "teamCount" )	
		
		int spawnPakTeamCount = -1
		if( potentialTeamCount != "_NOTFOUND" )
			spawnPakTeamCount = potentialTeamCount.tointeger()
 
		if( spawnPakTeamCount > SCENARIOS_MAX_ALLOWED_TEAMSIZE )
			mAssert( false, "Configured spawn pak teamCount of \"%s\" exceeds scenarios max allowed teamsize of %d", spawnPakTeamCount, SCENARIOS_MAX_ALLOWED_TEAMSIZE )
		
		for ( int i = 0; i < allSoloLocations.len(); i = i + teamAmount )
		{
			soloLocStruct p	
			for ( int j = 0; j < teamAmount; j++  )
				p.respawnLocations.append( allSoloLocations[ i + j ].spawn )

			p.Center = GetCenterOfCircle( p.respawnLocations )
			
			if( allSoloLocations[i].info != "" )
				p.info = allSoloLocations[i].info
				
			p.ids = " " + i + "," + ( i+1 ) + "," + ( i+2 )
				
			soloLocations.append( p )
		}
	}
	else //1v1
	{
		for ( int i = 0; i < allSoloLocations.len(); i=i+2 )
		{
			soloLocStruct p
		
			p.respawnLocations.append( allSoloLocations[ i ].spawn )
			p.respawnLocations.append( allSoloLocations[ i + 1 ].spawn )

			p.Center = ( allSoloLocations[ i ].spawn.origin + allSoloLocations[ i + 1 ].spawn.origin ) / 2

			if( allSoloLocations[ i ].info != "" )
				p.info = allSoloLocations[ i ].info
				
			p.ids = " " + i + "," + ( i + 1 )

			soloLocations.append( p )
		}
	}

	file.realmSlots.resize( MAX_REALM + 1 )
	file.realmSlots[ 0 ] = true
	
	int realmSlotsLen = file.realmSlots.len()
	for ( int i = 1; i < realmSlotsLen; i++ )
		file.realmSlots[ i ] = false

	if( settings.isScenariosMode )
	{
		forbiddenZoneInit( GetMapName() )
		FS_Scenarios_SetupPanels()
		thread FS_Scenarios_Main_Thread()
		return
	}
	
	// default spawn behavior
	AddCallback_OnPlayerRespawned( Gamemode1v1_OnSpawned )
	
	//challenges cleanup
	AddCallback_OnClientDisconnected( FS_1v1_OnPlayerDisconnected )
	
	//resting room init ///////////////////////////////////////////////////////////////////////////////////////
			
	PanelTable panels = 
	{
		[ "#FS_START_SPEC" ] 			= null,
		[ "#FS_REST_TOGGLE" ] 			= null,
		[ "#FS_IBMM_TOGGLE" ] 			= null,
		[ "#FS_CHAL_TOGGLE" ] 			= null,
		[ "#FS_START_REST_TOGGLE" ] 	= null,
		[ "#FS_INPUT_BANNER" ] 			= null,
		//["add another"] = null,
	};
	
	if( !bIsCoachingMode() )
	{
		Gamemode1v1_CreatePanels( g_waitingRoomPanelLocation.origin, g_waitingRoomPanelLocation.angles, panels )
		DefinePanelCallbacks( panels )
	}

	forbiddenZoneInit( GetMapName() )
	
	thread Gamemode1v1_soloModeThread( getWaitingRoomLocation() )
	
	AddCallback_OnClientConnected
	( 
		void function( entity player )
		{
			// init for IBMM
			Init_IBMM( player )
			
			#if !TRACKER
				INIT_playerChallengesStruct( player ) //normally init after persistence loads
			#endif
			
			if( bIsCoachingMode() )
			{
				if( !IsAlive( player ) )
					DecideRespawnPlayer( player, false )
				
				player.p.playerisready = false
			}
		}
	)
	
	BannerImages_1v1Init()

	if( !bIsCoachingMode() )
	{
		Gamemode1v1_SetRestEnabled()
		AddClientCommandCallback( "rest", ClientCommand_Maki_SoloModeRest )
	}
	else
		Gamemode1v1_SetRestEnabled( false )
}

void function Gamemode1v1_SetRestEnabled( bool value = true )
{
	file.bRestEnabled = value
}

bool function Gamemode1v1_GetRestEnabled()
{
	return file.bRestEnabled
}

void function Gamemode1v1_soloModeThread( LocPair waitingRoom )
{
	FlagWait( "EntitiesDidLoad" )
	
	#if DEVELOPER 
		printt( "Time():", Time(), "championDisplayEndTime:", GetGlobalNetTime( "championDisplayEndTime" ) )
	#endif 
	
	WaitForChampionToFinish()	
	thread soloModeThread( waitingRoom )
}

void function OnWeaponAttachmentChanged( entity player, entity weapon, string modToAdd, string modToRemove )
{
	//(mk):This callbackfunc is only registered when tgive is enabled by host.
	
	//(mk):make sure chal only flag isn't configured.
	if( !isCustomWeaponAllowed() && !isPlayerInChallenge( player ) )
		return 
		
	ClientCommand_SaveCurrentWeapons( player, [] )
}

bool function g_bRestEnabled()
{
	return file.bRestEnabled
}

void function Gamemode1v1_CreatePanels( vector origin, vector angles, table<string, entity> panels )
{
	angles =  < ceil( angles.x ), ceil( angles.y ), ( angles.z * 0 ) > 
	vector baseAngles = angles - <0,90,0> //Normalize( angles )
	
	array<string> keys = []

	foreach ( title, panelEntity in panels )
		keys.append( title )

	float FORWARD_OFFSET = 40
	float SIDE_OFFSET = 100
	float SIDE_ANGLE_ADJUST = 40
	float FAR_OFFSET_INITIAL = 120
	float RIGHT_OFFSET_INITIAL = 80
	float POSITION_INCREMENT = 60

	int panelCount = keys.len()
	vector panelPos
	vector panelAngle

	for ( int i = 0; i < panelCount; ++i )
	{
		if ( i < 2 )
		{
			panelPos = origin + AnglesToForward( baseAngles ) * FORWARD_OFFSET * ( i % 2 == 0 ? 1 : -1 )
			panelAngle = baseAngles
		}
		else if ( i < 4 )
		{
			panelPos = origin + AnglesToForward( baseAngles ) * SIDE_OFFSET * ( i % 2 == 0 ? -1 : 1 ) + AnglesToRight( baseAngles ) * 25
			panelAngle = baseAngles + <0, SIDE_ANGLE_ADJUST * ( i % 2 == 0 ? 1 : -1 ), 0>
		}
		else
		{
			int groupIndex = ( i - 4 ) / 2
			float rightOffset = RIGHT_OFFSET_INITIAL + POSITION_INCREMENT * groupIndex;
			panelPos = origin + AnglesToForward( baseAngles ) * FAR_OFFSET_INITIAL * ( i % 2 == 0 ? -1 : 1 ) + AnglesToRight( baseAngles ) * rightOffset
			panelAngle = baseAngles + <0, 90 * ( i % 2 == 0 ? 1 : -1 ), 0>
		}

		entity panel = CreateFRButton( panelPos, panelAngle, keys[i] )
		panels[ keys[i] ] = panel
	}
}

void function DefinePanelCallbacks( PanelTable panels )
{
    // Resting room panel
    AddCallback_OnUseEntity( panels["#FS_START_SPEC"], void function( entity panel, entity user, int input )
    {
        if ( !IsValid( user ) ) 
			return
			
		if( !CheckRate( user ) )
			return 
        
		if ( !isPlayerInRestingList( user ) )
        {
            LocalMsg( user, "#FS_MustBeInRest", "#FS_MustBeInRest_SUBSTR" )
            return
        }
        
		if ( GetTDMState() != eTDMState.IN_PROGRESS )
        {
            LocalMsg( user, "#FS_GameNotPlaying" )
            return
        }

        try
        {
            array<entity> enemiesArray = GetPlayerArray_AliveConnected()
            enemiesArray.fastremovebyvalue( user )
            
            #if TRACKER
				entity messageBot = GetMessageBotEnt()
				if ( bBotEnabled() && IsValid( messageBot ) && IsAlive( messageBot ) )
					enemiesArray.fastremovebyvalue( messageBot )
            #endif
			
			if ( enemiesArray.len() == 0 )
			{
				LocalMsg( user, "#FS_NO_PLAYERS_TO_SPEC" )
				return
			}
            
            entity specTarget = enemiesArray.getrandom()

            user.p.isSpectating = true
            user.SetPlayerNetInt( "spectatorTargetCount", GetPlayerArray().len() )
            user.SetObserverTarget( specTarget )
            user.SetSpecReplayDelay( 0.5 )
            user.StartObserverMode( OBS_MODE_IN_EYE )
            thread CheckForObservedTarget( user )
            user.p.lastTimeSpectateUsed = Time()

            LocalMsg( user, "#FS_JumpToStopSpec" )

            user.MakeInvisible()
        }
        catch ( e )
        {
			#if DEVELOPER 
				printw( "Error:", e )
			#endif
		}
        
        AddButtonPressedPlayerInputCallback( user, IN_JUMP, endSpectate )
    })

    // IBMM button
    AddCallback_OnUseEntity( panels["#FS_IBMM_TOGGLE"], void function( entity panel, entity user, int input )
    {			
        if ( !IsValid( user ) ) 
			return
		
		if( !CheckRate( user ) )
			return 
        
        if ( user.p.IBMM_grace_period > 0 )
        {
            user.p.IBMM_grace_period = 0
            SavePlayerData( user, "wait_time", 0.0 )
            LocalMsg( user, "#FS_IBMM_Any" )
        }
        else
        {   
            if ( settings.ibmm_wait_limit >= 3 )
            {   
                if ( settings.default_ibmm_wait == 0 )
                {
                    user.p.IBMM_grace_period = 3
                    SavePlayerData( user, "wait_time", 3.0 )
                }
                else
                {
                    SetDefaultIBMM( user )
                }
                
                LocalMsg( user, "#FS_IBMM_SAME" )
            }
            else 
            {
                LocalMsg( user, "#FS_SettingNotAllowed" )
            }
        }
    })

    // Lock 1v1 button
    AddCallback_OnUseEntity( panels["#FS_CHAL_TOGGLE"], void function( entity panel, entity user, int input )
    {
        if ( !IsValid( user ) ) 
			return
			
		if( !CheckRate( user ) )
			return 
        
        if ( user.p.lock1v1_setting == true )
        {
            user.p.lock1v1_setting = false
            SavePlayerData( user, "lock1v1_setting", false )
            LocalMsg( user, "#FS_ChalDisabled" )
        }
        else
        {   
            user.p.lock1v1_setting = true
            SavePlayerData( user, "lock1v1_setting", true )
            LocalMsg( user, "#FS_ChalEnabled" )
        }
    })

    // Start in rest setting button
    AddCallback_OnUseEntity( panels["#FS_START_REST_TOGGLE"], void function( entity panel, entity user, int input )
    {
        if ( !IsValid( user ) ) 
			return
			
		if( !CheckRate( user ) )
			return 
        
        if ( user.p.start_in_rest_setting == true )
        {
            user.p.start_in_rest_setting = false
            SavePlayerData( user, "start_in_rest_setting", false )
            LocalMsg( user, "#FS_StartInRestDisabled" )
        }
        else
        {   
            user.p.start_in_rest_setting = true
            SavePlayerData( user, "start_in_rest_setting", true )
            LocalMsg( user, "#FS_StartInRestEnabled" )
        }
    })

    // Toggle input banner button
    AddCallback_OnUseEntity( panels["#FS_INPUT_BANNER"], void function( entity panel, entity user, int input )
    {
        if ( !IsValid( user ) ) 
			return
			
		if( !CheckRate( user ) )
			return 
        
        if ( user.p.enable_input_banner == true )
        {
            user.p.enable_input_banner = false
            SavePlayerData( user, "enable_input_banner", false )
            LocalMsg( user, "#FS_InputBannerDisabled" )
        }
        else
        {   
            user.p.enable_input_banner = true
            SavePlayerData( user, "enable_input_banner", true )
            LocalMsg( user, "#FS_InputBannerEnabled" )
        }
    })

    // Rest button
    AddCallback_OnUseEntity( panels["#FS_REST_TOGGLE"], void function(entity panel, entity user, int input )
    {
        if ( !IsValid( user ) ) 
			return     
			
        ClientCommand_Maki_SoloModeRest( user, [] )
    })
	
	
	//(mk):Designers: Define your custom panel behavior here
	//...
	
}

void function Gamemode1v1_OnSelectedLegend( ItemFlavor character )
{
	
}

bool function ValidateSpawns( array<SpawnData> allSoloLocations )
{
	string warningmsg = "Incorrectly configured spawns in " + FILE_NAME()
	
	if( allSoloLocations.len() == 0 )
	{
		Warning( "No valid spawns found! Trying default pak" )
		return false
	}
	
	if( g_bIs1v1GameType() && !IsEven( allSoloLocations.len() ) )
	{
		Warning( warningmsg + " ( locpair must be an even amount )" )
		allSoloLocations.resize(0)
		return false
	}
	else if( settings.isScenariosMode ) //(scenarios)
	{
		int modeTeamCount = FS_Scenarios_GetScenariosTeamCount()
		if( ( allSoloLocations.len() % modeTeamCount ) != 0 ) 
		{
			Warning( warningmsg + " ( locpair must be multiples of " + modeTeamCount + " )" )
			allSoloLocations.resize(0)
			return false
		}
	}
	
	return true
}

void function soloModeThread( LocPair waitingRoomLocation )
{
	//printt("solo mode thread start!")

	string Text5 = "#FS_OpponentDisconnect"
	
	wait 8
	
	for( ; ; )
	{
		WaitFrame()
		
		if( GetScoreboardShowingState() )
			continue
			
		if( GetChampionShowingState() )
			continue
		
		//遍历等待队列 - cycle waiting queue
		foreach ( playerHandle, playerInWaitingStruct in file.soloPlayersWaiting )
		{
			if ( !IsValidPlayer( playerInWaitingStruct.player ) )
				continue

			if ( Time() - playerInWaitingStruct.queue_time > playerInWaitingStruct.player.p.IBMM_grace_period )
				playerInWaitingStruct.IBMM_Timeout_Reached = true
			else
				playerInWaitingStruct.IBMM_Timeout_Reached = false

			//timeout preferred matchmaking 

			if ( !bIsCoachingMode() && playerInWaitingStruct.waitingTime < Time() && !playerInWaitingStruct.IsTimeOut && IsValid(playerInWaitingStruct.player))
			{
				playerInWaitingStruct.IsTimeOut = true;
			}
		}//foreach

		//遍历游玩队列
		array<soloGroupStruct> groupsToRemove
		bool quit
		bool removed
		
		foreach ( groupHandle, group in file.groupsInProgress ) 
		{
			quit = false
			removed = false

			if( !group.isValid )
				removed = true
			
			if ( !removed && group.IsFinished ) //this round has been finished //
			{
				SetIsUsedBoolForRealmSlot( group.slotIndex, false )									
				destroyRingsForGroup( group )
				
				bool player1Rested = false
				if ( IsValid( group.player1 ) )
				{
					player1Rested = TryProcessRestRequest( group.player1 )
					if( !player1Rested )
						soloModePlayerToWaitingList( group.player1 )		
				}
					
				if ( IsValid( group.player2 ) )
				{
					if( !TryProcessRestRequest( group.player2 ) && !player1Rested )
						soloModePlayerToWaitingList( group.player2 )
				}
				
				#if DEVELOPER
					sqprint("remove group request 04")
				#endif
				
				while( mGroupMutexLock ) 
				{
					#if DEVELOPER
						sqprint("Waiting for lock to release R004")
					#endif
					WaitFrame() 
				}
				
				groupsToRemove.append( group )
				quit = true
			}
			
			if ( !removed && group.IsKeep ) 
			{
				if ( IsValid( group.player1 ) && IsValid( group.player2 ) && ( !IsAlive( group.player1 ) || !IsAlive( group.player2 ) ) ) 
				{
					int p1 = 0
					int p2 = 1
					
					if( group.cycle )
						group.groupLocStruct = soloLocations.getrandom()	
					
					if( group.swap )
					{
						p1 = CoinFlip() ? 1 : 0		
						p2 = p1 == 0 ? 1 : 0
					}
					
					bool nowep = false
					
					_CleanupPlayerEntities( group.player1 )
					_CleanupPlayerEntities( group.player2 )
					
					//This block is important to prevent exploits
					{				
						if ( TryProcessRestRequest( group.player1 ) )	
							nowep = true
						else 				
							thread respawnInSoloMode( group.player1, p1 )				
						
						//if no wep is true, player 1 rested, which handles player 2's state.
						if ( !nowep && TryProcessRestRequest( group.player2 ) ) 
							nowep = true
						else if ( !nowep )	
							thread respawnInSoloMode( group.player2, p2 )
						
						if( !nowep ) //don't give this group weapons if either player rested.				
							GiveWeaponsToGroup( [ group.player1, group.player2 ], group )	
					}
				}//keep
			}
			
			if ( !IsValid( group.player1 ) || !IsValid( group.player2 ) ) 
			{	
				//printt("solo player quit!!!!!")
				if ( !removed && IsValid( group.player1 ) ) 
				{
					// #if TRACKER //moved to tracker file.
						// Tracker_AddDamageEventsToDeleteQueue( group.player1_handle, group.player2_handle )
					// #endif
					
					if( !TryProcessRestRequest( group.player1 ) )
					{					
						soloModePlayerToWaitingList( group.player1 ) //back to waiting list
						LocalMsg( group.player1, Text5 )
					}
				}

				if ( !removed && IsValid( group.player2 ) ) 
				{
					// #if TRACKER //moved to tracker file.
						// Tracker_AddDamageEventsToDeleteQueue( group.player2_handle, group.player1_handle )
					// #endif
					
					if( !TryProcessRestRequest( group.player2 ) )
					{						
						soloModePlayerToWaitingList( group.player2 ) //back to waiting list
						LocalMsg( group.player2, Text5 )
					}
				}
				
				if( !removed )
					SetIsUsedBoolForRealmSlot( group.slotIndex, false )
				
				#if DEVELOPER
					sqprint("remove group request 05")
				#endif
				
				groupsToRemove.append( group )
				quit = true
			}
			
			//检测乱跑的脑残
			if( !removed && !quit )
			{
				soloLocStruct groupLocStruct = group.groupLocStruct
				vector Center = groupLocStruct.Center
				array<entity> players = [ group.player1, group.player2 ]
				
				foreach ( eachPlayer in players )
				{
					if ( eachPlayer.IsPhaseShifted() )
						continue

					if( Distance2D( eachPlayer.GetOrigin(), Center ) > settings.playerMaxFightDistance ) //检测乱跑的脑残
					{
						Remote_CallFunction_Replay( eachPlayer, "ServerCallback_PlayerTookDamage", 0, <0, 0, 0>, DF_BYPASS_SHIELD | DF_DOOMED_HEALTH_LOSS, eDamageSourceId.deathField, 0 )
						eachPlayer.TakeDamage( 1, null, null, { scriptType = DF_BYPASS_SHIELD | DF_DOOMED_HEALTH_LOSS, damageSourceId = eDamageSourceId.deathField } )
					}
				}
			}
		}//foreach
		
		foreach ( group in groupsToRemove )
		{	
			#if DEVELOPER
				sqprint(format("arrayloop: Removing group: %d", group.groupHandle ))
			#endif 
			while( mGroupMutexLock ) 
			{	
				#if DEVELOPER
					sqprint("Waiting for lock to release arrayloop") //no mutex print has ever happened in tests but its still possible
				#endif
				WaitFrame() 
			}
			
			removeGroup( group )
		}

		//遍历休息队列
		foreach ( restingPlayerHandle, restingStruct in file.soloPlayersResting )
		{
			if( !restingPlayerHandle )
			{	
				sqerror("Null handle")
					continue
			}
			
			entity restingPlayerEntity = GetEntityFromEncodedEHandle( restingPlayerHandle )
			
			if( !IsValid( restingPlayerEntity ) ) 
				continue

			if( !IsAlive( restingPlayerEntity ) )	
				thread respawnInSoloMode( restingPlayerEntity )
		}

		foreach ( player in GetPlayerArray() )
		{
			if( !IsValid( player ) ) 
				continue
			
			if( IsPlayerInSoloMode( player ) )
				continue
			
			#if !DEVELOPER 
				if( Distance2D( player.GetOrigin(), waitingRoomLocation.origin ) > file.waitingRoomRadius )
				{
					maki_tp_player( player, g_randomWaitingSpawns.getrandom() ) //waiting player should be in waiting room,not battle area
					HolsterAndDisableWeapons_Raw( player ) //(mk): dirty fix I wanted to avoid.
				}
				
			if( !isPlayerInRestingList( player ) && !isPlayerInWaitingList( player ) )
				soloModePlayerToWaitingList( player ) //(mk): dirty patch
			#endif
		}
		

		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		//开始匹配
		
		if( file.soloPlayersWaiting.len() < 2 ) //等待队列人数不足,无法开始匹配
		{
			foreach ( playerHandle, solostruct in file.soloPlayersWaiting )
			{						
				if ( solostruct.showWaitingMsg == true && !solostruct.player.p.challengenotify )
				{
					if( !IsValid( solostruct.player ) )
						continue
					
					Gamemode1v1_NotifyPlayer( solostruct.player, eNotify.WAITING, "#FS_WAITING_PANEL" )
					
					SetShowWaitingMsg( solostruct.player, false ) //prevent looped signals
					file.APlayerHasMessage = true 	//thread should remove waiting for msg..
				}
			}

			continue		
		}  
		else if ( file.APlayerHasMessage ) 
		{
			foreach ( player in GetPlayerArray() )
			{
				if ( !IsValid( player ) )
					continue
				
				ClearNotifications( player, eNotify.WAITING )
				SetShowWaitingMsg( player, true )
			}
			
			file.APlayerHasMessage = false;
		}

		// printt("------------------more than 2 player in solo waiting array,matching------------------")
		
		if( bIsCoachingMode() )
		{
			//Coaching mode, we should wait until admin decides to start
			
			//Open menu with recordings list, wait until amdin presses "start new"

			foreach ( player in GetPlayerArray() )
			{
				if ( !IsValid( player ) )
					continue
				
				if( !player.p.playerisready )
				{
					Message_New( player, "Welcome to District's 1v1 Faceoff\n\n Waiting For Admin To Start", 300 )
					
					player.p.playerisready = true
					
					Remote_CallFunction_NonReplay(player, "Flowstate_OpenCoachingMenu")
				}
			}

			while( !GetStartNewGameBool() && GetPlayerArray_Alive().len() == 2)
				WaitFrame()

			SetStartNewGameBool( false )
			
			//check if there are still two players, if not, continue..
			if( GetPlayerArray_Alive().len() < 2 )
			{
				foreach ( player in GetPlayerArray() )
				{
					if ( !IsValid( player ) )
						continue
					
					player.p.playerisready = false
				}
				continue
			}
			
			//NEW COACHING 1V1 GAME HAS STARTED, INMINENT..

			//close menu
			
			foreach ( player in GetPlayerArray() )
			{
				if ( !IsValid( player ) )
					continue
				
				Remote_CallFunction_NonReplay(player, "Flowstate_CloseCoachingMenu")
				Message_New( player, "STARTING RECORDED 1V1 MATCH", 3 )
				player.p.playerisready = false
			}			
			
			wait 3
		}
		
		soloGroupStruct newGroup
		entity opponent
		bool bMatchFound = false
		//优先处理超时玩家
		//player1:超时的玩家,player2:随机从等待队列里找一个玩家
		
		//check challenges first
		foreach ( playerHandle, eachPlayerStruct in file.soloPlayersWaiting ) //找player1
		{
			if( !IsValid( eachPlayerStruct ) )
				continue		
			
			entity playerSelf = eachPlayerStruct.player
			bool player_IBMM_timeout = eachPlayerStruct.IBMM_Timeout_Reached		
			
			//challenge system

			if( !bIsCoachingMode() && IsPlayerPendingChallenge( playerSelf ) )
			{
				entity Lock1v1Opponent = getLock1v1OpponentOfPlayer( playerSelf )		
				if ( IsValid( Lock1v1Opponent ) )
				{
					newGroup.player1 = playerSelf
					newGroup.player2 = Lock1v1Opponent
					
					newGroup.IsKeep = true
					newGroup.player1.p.waitingFor1v1 = false 
					newGroup.player2.p.waitingFor1v1 = false
					
					LocalMsg( newGroup.player1, "#FS_ChalStarted" )
					LocalMsg( newGroup.player2, "#FS_ChalStarted" )
					
					newGroup.player1.Signal( "ChallengeStarted" )
					newGroup.player2.Signal( "ChallengeStarted" )
					
					bMatchFound = true
					break
				}
				else 
				{
					#if DEVELOPER 
						sqprint( "waiting for lockmatch TIMEOUT matching" )
					#endif 
					
					continue //(mk): these guys are still waiting for each other
				}
			}
		}
	
		if( !bMatchFound && getTimeOutPlayerAmount() > 0 )//存在已经超时的玩家
		{
			//sqprint("TIME OUT MATCHING")
			// Warning("Time out matching")
			newGroup.player1 = getTimeOutPlayer()  //获取超时的玩家
			if( IsValid( newGroup.player1 ) )//存在超时等待玩家
			{
				//sqprint("Player 1 found: " + newGroup.player1.GetPlayerName() + " waiting for same input or IBMM grace period time out")
				opponent = getRandomOpponentOfPlayer( newGroup.player1 )
				
				//(mk):
				if( IsValid( opponent ) )
				{
					ClearNotifications( newGroup.player1, eNotify.MATCHING )
					newGroup.player2 = opponent	
				} 
				else
				{
					Gamemode1v1_NotifyPlayerOnce( newGroup.player1, eNotify.MATCHING, "#FS_MATCHING_FOR", FetchInputName( newGroup.player1 ) )
				}
							
			}
		}//超时玩家处理结束
		else if ( !bMatchFound )//不存在已超时玩家,正常按照kd匹配
		{	
			// Warning("Normal matching")
			foreach ( playerHandle, eachPlayerStruct in file.soloPlayersWaiting ) //找player1
			{	
				if( !IsValid( eachPlayerStruct ) )
					continue		
				
				entity playerSelf = eachPlayerStruct.player
				bool player_IBMM_timeout = eachPlayerStruct.IBMM_Timeout_Reached
				float selfKd = eachPlayerStruct.kd
				table <entity,float> properOpponentTable
				
				foreach ( opponentHandle, eachOpponentPlayerStruct in file.soloPlayersWaiting ) //找player2
				{					
					entity eachOpponent = eachOpponentPlayerStruct.player
					float opponentKd = eachOpponentPlayerStruct.kd
					bool opponent_IBMM_timeout = eachOpponentPlayerStruct.IBMM_Timeout_Reached
					
					if( IsPlayerPendingChallenge( eachOpponent ) || IsPlayerPendingLockOpponent( eachOpponent ) )
					{
						//sqprint("waiting for lockmatch main matching")
						continue //these guys are trying to lock with each other
					}
					
					//(mk): this makes sure we don't compare same player as opponent during matchmaking
					if( !IsValid( eachOpponent ) || playerSelf == eachOpponent )//过滤非法对手
						continue
						
					if( !bIsCoachingMode() && fabs(selfKd - opponentKd) > file.SBMM_kd_difference ) //过滤kd差值
						continue
						
					properOpponentTable[ eachOpponent ] <- fabs( selfKd - opponentKd )
					
					//(mk): keep building a list of candidates who are not timed out with same input

					if( !bIsCoachingMode() && playerSelf.p.input != eachOpponent.p.input && ( player_IBMM_timeout == false || opponent_IBMM_timeout == false ) )
					{
						//sqprint("Waiting for input match...");
						continue		
					}
				}

				float lowestKd = 999
				entity bestOpponent
				entity scondBestOpponent//防止bestOpponent是上一局的对手
				
				foreach (opponentt,kd in properOpponentTable)
				{
					if( bIsCoachingMode() )
					{
						bestOpponent = opponentt
					}
					
					if(kd < lowestKd)
					{
						scondBestOpponent = bestOpponent
						bestOpponent = opponentt
						lowestKd = kd
					}
				}

				entity lastOpponent = eachPlayerStruct.lastOpponent

				if(!IsValid(bestOpponent)) continue//没找到最合适玩家,为下一位玩家匹配
				
				if( bIsCoachingMode() )
				{
					newGroup.player1 = playerSelf
					newGroup.player2 = bestOpponent
					break			
				}
				else if( (bestOpponent != lastOpponent && Fetch_IBMM_Timeout_For_Player( bestOpponent ) == true && Fetch_IBMM_Timeout_For_Player( playerSelf ) == true ) || ( bestOpponent != lastOpponent && Fetch_IBMM_Timeout_For_Player( playerSelf ) == false && Fetch_IBMM_Timeout_For_Player( bestOpponent ) == false && playerSelf.p.input == bestOpponent.p.input ) ) //最合适玩家是上局对手,用第二合适玩家代替
				{				
						bool inputresult = playerSelf.p.input == bestOpponent.p.input ? true : false
						
						//sqprint(format("Player found: ibmm timeout: %s, INputs are same?: ", Fetch_IBMM_Timeout_For_Player(bestOpponent), inputresult  ));
						// Warning("Best opponent, kd gap: " + lowestKd)
						newGroup.player1 = playerSelf
						newGroup.player2 = bestOpponent			
					
						break			
				}
				else if ( IsValid( scondBestOpponent ) && scondBestOpponent != lastOpponent && Fetch_IBMM_Timeout_For_Player( playerSelf ) == true && Fetch_IBMM_Timeout_For_Player( scondBestOpponent ) == true || IsValid( scondBestOpponent ) && scondBestOpponent != lastOpponent && Fetch_IBMM_Timeout_For_Player( playerSelf ) == false && Fetch_IBMM_Timeout_For_Player( scondBestOpponent ) == false && playerSelf.p.input == scondBestOpponent.p.input )
				{				
						//bool inputresult = playerSelf.p.input == scondBestOpponent.p.input ? true : false;
						//sqprint(format("Player found: ibmm timeout: %s, INputs are same?: ", Fetch_IBMM_Timeout_For_Player(scondBestOpponent), inputresult  ));
					
						// Warning("Secondary opponent, kd gap: " + lowestKd)
						newGroup.player1 = playerSelf
						newGroup.player2 = scondBestOpponent
						
						break	
				}
				else
				{
					// Warning("Only last opponent found, waiting for time out")
					continue //上局对手是最合适玩家,且没有第二合适对手,开始为下一位玩家匹配
				}
			}//foreach
		}//else

		if ( bMatchFound && !IsValid( newGroup.player1 ) || !IsValid( newGroup.player2 ) ) 
		{
			SetIsUsedBoolForRealmSlot( newGroup.slotIndex, false )
			
			if ( IsValid( newGroup.player1 ) ) 
				soloModePlayerToWaitingList( newGroup.player1 )
			
			if ( IsValid( newGroup.player2 ) ) 
				soloModePlayerToWaitingList( newGroup.player2 )
			
			continue
		}
		
		//don't pair players if they are waiting for their chal player
		if( !newGroup.player1.p.waitingFor1v1 && !newGroup.player2.p.waitingFor1v1 )
		{		
			//already matched two players
			array<entity> players = [newGroup.player1,newGroup.player2]
		
			//set handles to group for cleanup on invalid player 
			newGroup.player1_handle = newGroup.player1.p.handle
			newGroup.player2_handle = newGroup.player2.p.handle
		
			if( GroupIsLockable( newGroup ) )
				newGroup.GROUP_INPUT_LOCKED = true
			else
				newGroup.GROUP_INPUT_LOCKED = false
			
			soloModePlayerToInProgressList( newGroup )
			ArrayRemoveInvalid( players )
			
			if( players.len() != 2 )
				continue

			foreach ( index, eachPlayer in players )
			{
				LocalEventMsg( eachPlayer, "", "", 1 ) //reset in queue msg
				EnableOffhandWeapons( eachPlayer )
				thread respawnInSoloMode( eachPlayer, index )
			}
			
			GiveWeaponsToGroup( players, newGroup )

			FS_SetRealmForPlayer( newGroup.player1, newGroup.slotIndex )
			FS_SetRealmForPlayer( newGroup.player2, newGroup.slotIndex )		
			
			string ibmmLockTypeToken = "";
			
			if ( newGroup.GROUP_INPUT_LOCKED == true )
			{
				thread InputWatchdog( newGroup.player1, newGroup.player2, newGroup )
				ibmmLockTypeToken = "#FS_InputLocked";
			}
			else 
			{ 	
				ibmmLockTypeToken = "#FS_CouldNotLock";
			}
			
			//check for player 1's lock setting and that group isnt locked
			if ( newGroup.player1.p.IBMM_grace_period <= 0 && newGroup.GROUP_INPUT_LOCKED == false )
				ibmmLockTypeToken = "#FS_AnyInput"
			
			//message player 1
			if( newGroup.player1.p.enable_input_banner && !bMatchFound )
				IBMM_Notify( newGroup.player1, ibmmLockTypeToken, newGroup.player2.p.input )
			
			//check for player 2 lock setting
			if ( newGroup.player2.p.IBMM_grace_period <= 0 && newGroup.GROUP_INPUT_LOCKED == false )
				ibmmLockTypeToken = "#FS_AnyInput";
			
			//msg player 2
			if( newGroup.player2.p.enable_input_banner && !bMatchFound )
				IBMM_Notify( newGroup.player2, ibmmLockTypeToken, newGroup.player1.p.input )
				
		} //not waiting
		
		array<int> deletions // player_eHandle
		
		//cleanup lock1v1 table
		foreach( player1_eHandle, player2 in file.acceptedChallenges ) 
		{
			entity player1 = GetEntityFromEncodedEHandle( player1_eHandle )
			bool bPlayer1Valid = IsValid( player1 ) 
			bool bPlayer2Valid = IsValid( player2 ) 
			
			if ( !bPlayer1Valid || !bPlayer2Valid ) 
			{		
				if( bPlayer1Valid )
					player1.p.waitingFor1v1 = false
				
				if( bPlayer2Valid )
					player2.p.waitingFor1v1 = false
				
				deletions.append( player1_eHandle )
			}
		}
		
		deletions = ArrayUniqueInt( deletions )
		if( deletions.len() > 0 )
		{
			foreach( playerKey in deletions ) 
			{
				if( playerKey in file.acceptedChallenges )
					delete file.acceptedChallenges[ playerKey ]
			}
			
			deletions.resize(0)
		}
	}//for( ; ; ) -- main loop

	OnThreadEnd
	(
		function() : (  )
		{
			// Warning(Time() + "Solo thread is down!!!!!!!!!!!!!!!")
			GameRules_ChangeMap( GetMapName(), GameRules_GetGameMode() )
		}
	)

}//thread

void function FS_1v1_OnPlayerDisconnected( entity player )
{
	#if DEVELOPER
		printt( "[+] OnPlayerDisconnected 1v1 -", player )
	#endif
	
	//Challenges
	int playerHandle = player.p.handle
	entity opponent = returnChallengedPlayer( player )
	
	if( IsValid( opponent ) )
		endLock1v1( opponent )
	
	// if( playerHandle in file.acceptedChallenges ) //potential B1D
		// delete file.acceptedChallenges[ playerHandle ]
	
	foreach( index, zstruct in file.allChallenges )
	{
		if( player == zstruct.player )
			file.allChallenges.fastremove( index )
	}

	foreach ( _, playerInWaitingStruct in file.soloPlayersWaiting ) //(mk): _ is waiting struct playerHandle, not used here.
	{
		if ( playerInWaitingStruct.handle == playerHandle )
		{
			deleteWaitingPlayer( playerHandle )
			break
		}
	}

	if( playerHandle in file.playerToGroupMap )
		delete file.playerToGroupMap[ playerHandle ]
}

void function RemovePlayerFromGroup( entity player )
{
	//If player was in a match, remove. Cafe
	if( player.p.handle in file.playerToGroupMap )
	{
		delete file.playerToGroupMap[ player.p.handle ]
	}
}
//mkos input watch

void function InputWatchdog( entity player, entity opponent, soloGroupStruct group )
{
	#if DEVELOPER
		sqprint( format( "THREAD FOR GROUP STARTED - Waiting for input to change" ) )
	#endif
	
	EndSignal( player, "InputChanged", "OnDeath", "OnDisconnected" )
	EndSignal( opponent, "InputChanged", "OnDeath", "OnDisconnected" )
	
	OnThreadEnd
	(
		function() : ( player, opponent, group )
		{
			#if DEVELOPER
				sqprint( "INPUT WATCHDOG THREAD FOR GROUP ENDED" )
			#endif
			
			if ( IsValid( player ) && IsValid( opponent ) && player.p.input != opponent.p.input )
			{
				entity culprit = player.p.lastInputChangeTime > opponent.p.lastInputChangeTime ? player : opponent		
				array<entity> players = [ player, opponent ]
				
				string infoString
				foreach( pl in players )
				{
					infoString = pl == culprit ? "#FS_YOUR" : pl.p.name
					Remote_CallFunction_ByRef( pl, "ForceScoreboardLoseFocus" )			
					LocalMsg( pl, "#FS_INPUT_CHANGED", "#FS_INPUT_CHANGED_SUBSTR", eMsgUI.DEFAULT, 3, "", infoString, "weapon_vortex_gun_explosivewarningbeep" )
				}
			
				if( group.isValid )
					group.IsFinished = true
			}
		}
	)

	WaitForever()
}

void function GiveWeaponsToGroup( array<entity> players, soloGroupStruct groupRef )
{
	HandleOpponentInfo( groupRef )
	//printw( "giving weapons for players: ", players[0], players[1] )
	thread function () : ( players, groupRef )
	{	
		foreach( player in players )
		{
			if( !IsValid( player ) )
				continue

			TakeAllWeapons( player )
			DecideToggleCollision_Rest( player, true )
			Gamemode1v1_SetPlayerGamestate( player, e1v1State.MATCHING )
		}
		//(mk): could set up end signals on players for OnDestroy. 
		wait 0.2
		
		string primaryWeaponWithAttachments
		string secondaryWeaponWithAttachments
		string spawnClass = groupRef.groupLocStruct.info
		
		//(mk): add more classes if desired, configure spawns with spawn tool "info"
		switch( spawnClass )
		{
			case "longrange":
			
				if( !settings.bNoPrimaryLongrange )
					primaryWeaponWithAttachments = file.LongRangeWeapons.getrandom()
					
				if( !settings.bNoSecondaryLongrange )
					secondaryWeaponWithAttachments = file.LongRangeWeaponsSecondary.getrandom() 		
			break
			
			default:
			
				if( !settings.bNoPrimary )
					primaryWeaponWithAttachments = ReturnRandomPrimaryMetagame_1v1()
					
				if( !settings.bNoSecondary )
					secondaryWeaponWithAttachments = ReturnRandomSecondaryMetagame_1v1()
			break
		}
		
		int random_character_index 
		ItemFlavor random_character
		
		if ( settings.bGiveSameRandomLegendToBothPlayers )
		{
			random_character_index = RandomIntRangeInclusive( 0, characterslist.len() - 1 )
			
			if( random_character_index <= 10 )
				random_character = file.characters[ characterslist[ random_character_index ] ]
		}

		ArrayRemoveInvalid( players ) //(mk): we waited above	
		if( players.len() != 2 )
			return
		
		bool bInChallenge = false
		soloGroupStruct group = returnSoloGroupOfPlayer( players[0] )
		
		if( !isGroupValid( group ) )
			return
		
		if( group.IsKeep )
			bInChallenge = true
		
		foreach( player in players )
		{		
			if ( settings.bGiveSameRandomLegendToBothPlayers && random_character_index <= 10 && !bIsCoachingMode() )
				CharacterSelect_AssignCharacter( ToEHI( player ), random_character )
			
			DeployAndEnableWeapons_Raw( player )//✓
			
			//re-enable for inventory. 
			Survival_SetInventoryEnabled( player, true )		
			SetPlayerInventory( player, [] )
			EquipHostSetInventoryAttachments( player )
			Inventory_SetPlayerEquipment( player, "backpack_pickup_lv3", "backpack")
			
			if ( ( settings.bNoCustomWeapons && !bInChallenge ) || !( player.p.name in weaponlist ) )//avoid give weapon twice if player saved his guns   //Todo(mk): change to eHandle
			{
				TakeAllWeapons( player )

				if( !empty( primaryWeaponWithAttachments ) )
					GivePrimaryWeapon_1v1( player, primaryWeaponWithAttachments, WEAPON_INVENTORY_SLOT_PRIMARY_0 )
				
				if( !empty( secondaryWeaponWithAttachments ) )
					GivePrimaryWeapon_1v1( player, secondaryWeaponWithAttachments, WEAPON_INVENTORY_SLOT_PRIMARY_1 )		
			}
			else
			{
				thread LoadCustomWeapon( player ) 
			}

			player.TakeNormalWeaponByIndexNow( WEAPON_INVENTORY_SLOT_PRIMARY_2 )
			player.TakeOffhandWeapon( OFFHAND_MELEE )
			
			if ( !Flowstate_IsLGDuels() ) //TODO: set bool during init based on array of game modes where melee is allowed, repeat for more. 
			{	
				player.GiveWeapon( "mp_weapon_melee_survival", WEAPON_INVENTORY_SLOT_PRIMARY_2, [] )
				player.GiveOffhandWeapon( "melee_pilot_emptyhanded", OFFHAND_MELEE, [] )
			}
		}
		
		if( bInChallenge )
			_decideLegend( group )	
	}()
}


const array<string> STANDARD_INV_LOOT = ["health_pickup_combo_small", "health_pickup_health_small"]
void function FS_Scenarios_GiveWeaponsToGroup( array<entity> players )
{
	#if DEVELOPER 
		printt( "FS_Scenarios_GiveWeaponsToGroup" )
	#endif

	if( players.len() == 0 )
		return

	scenariosGroupStruct ornull group = FS_Scenarios_ReturnGroupForPlayer( players[0] ) 
	
	if( group == null )
		return
	
	expect scenariosGroupStruct( group )
	
	if( !group.isValid  )
		return
	
	EndSignal( group.dummyEnt, "FS_Scenarios_GroupFinished" )
	//WaitSignal( group.dummyEnt, "FS_Scenarios_GroupIsReady" )

	foreach( player in players )
	{
		if( !IsValid( player ) )
			continue

		TakeAllWeapons(player)
		Survival_SetInventoryEnabled( player, true )
		SetPlayerInventory( player, [] ) //clear

		if( !FS_Scenarios_GetInventoryEmptyEnabled() )
		{
			string primaryWeaponWithAttachments = ReturnRandomPrimaryMetagame_1v1()
			string secondaryWeaponWithAttachments = ReturnRandomSecondaryMetagame_1v1()
		
			EquipHostSetInventoryAttachments( player )
			GivePrimaryWeapon_1v1( player, primaryWeaponWithAttachments, WEAPON_INVENTORY_SLOT_PRIMARY_0 )
			GivePrimaryWeapon_1v1( player, secondaryWeaponWithAttachments, WEAPON_INVENTORY_SLOT_PRIMARY_1 )
		}

		//RechargePlayerAbilities( player )
		TakeAllPassives( player ) //passives given after legend selection

		player.TakeOffhandWeapon( OFFHAND_SLOT_FOR_CONSUMABLES )
		player.GiveOffhandWeapon( CONSUMABLE_WEAPON_NAME, OFFHAND_SLOT_FOR_CONSUMABLES, [] )

		foreach( item in STANDARD_INV_LOOT )
			SURVIVAL_AddToPlayerInventory( player, item, 2 )

		//Remote_CallFunction_NonReplay( player, "Minimap_EnableDraw_Internal" )
		Remote_CallFunction_ByRef( player, "Minimap_EnableDraw_Internal" )
	
		player.TakeNormalWeaponByIndexNow( WEAPON_INVENTORY_SLOT_PRIMARY_2 )
		player.TakeOffhandWeapon( OFFHAND_MELEE )
		player.GiveWeapon( "mp_weapon_melee_survival", WEAPON_INVENTORY_SLOT_PRIMARY_2, [] )
		player.GiveOffhandWeapon( "melee_pilot_emptyhanded", OFFHAND_MELEE, [] )	
	}
}

void function Gamemode1v1_GiveWeapon( entity player, string weapon, int slot  ) //global exposed
{
	GivePrimaryWeapon_1v1( player, weapon, slot )
}

void function GivePrimaryWeapon_1v1( entity player, string weapon, int slot ) //not global
{
	array<string> Data = split(weapon, " ")
	string weaponclass = Data[ 0 ]
	
	if( weaponclass == "tgive" ) 
		return
	
	array<string> Mods
	foreach( string mod in Data )
	{
		mod = strip( mod )
		if( mod != "" && mod != weaponclass )
		    Mods.append( mod )
	}

	entity weaponNew = player.GiveWeapon( weaponclass, slot, Mods, false )
	//entity weaponNew = player.GiveWeapon_NoDeploy( weaponclass , slot, Mods, false )

	int ammoType = weaponNew.GetWeaponAmmoPoolType()

	if( InfiniteAmmoEnabled() )
	{
		player.AmmoPool_SetCapacity( 65535 )
		player.AmmoPool_SetCount( ammoType, 9999 )
	}
	else if( settings.give_weapon_stack_count_amount )
	{	
		player.AmmoPool_SetCapacity( SURVIVAL_MAX_AMMO_PICKUPS )
		SetupPlayerReserveAmmo( player, weaponNew )
	}

	player.ClearFirstDeployForAllWeapons()
	player.DeployWeapon()

	if( weaponNew.UsesClipsForAmmo() )
		weaponNew.SetWeaponPrimaryClipCount( weaponNew.GetWeaponPrimaryClipCountMax() )	

	if( settings.enableCosmetics )
	{
		ItemFlavor ornull weaponSkinOrNull = null
		array<string> fsCharmsToUse = [ "SAID00701640565", "SAID01451752993", "SAID01334887835", "SAID01993399691", "SAID00095078608", "SAID01439033541", "SAID00510535756", "SAID00985605729" ]
		int chosenCharm = ConvertItemFlavorGUIDStringToGUID( fsCharmsToUse.getrandom() )
		ItemFlavor ornull weaponCharmOrNull = settings.giveCharmsWeapons == false ? null : GetItemFlavorByGUID( chosenCharm )
		ItemFlavor ornull weaponFlavor = GetWeaponItemFlavorByClass( weapon )

		if( weaponFlavor != null )
		{
			array<int> weaponLegendaryIndexMap = FS_ReturnLegendaryModelMapForWeaponFlavor( expect ItemFlavor( weaponFlavor ) )
			if( settings.giveSkinsWeapons && weaponLegendaryIndexMap.len() > 1  )
				weaponSkinOrNull = GetItemFlavorByGUID( weaponLegendaryIndexMap[RandomIntRangeInclusive(1,weaponLegendaryIndexMap.len()-1)] )
		}

		WeaponCosmetics_Apply( weaponNew, weaponSkinOrNull, weaponCharmOrNull )
	}
}

string function ReturnRandomPrimaryMetagame_1v1()
{	
	return file.Weapons.getrandom()
}

string function ReturnRandomSecondaryMetagame_1v1()
{	
	return file.WeaponsSecondary.getrandom()
}

void function ForceAllRoundsToFinish_solomode()
{
	foreach( player in GetPlayerArray() )
	{
		if( !IsValid( player ) ) 
			continue
		
		Gamemode1v1_SetPlayerGamestate( player, e1v1State.SEQUENCE )
		
		try
		{
			if( player.p.isSpectating )
			{
				player.SetPlayerNetInt( "spectatorTargetCount", 0 )
				player.p.isSpectating = false
				player.SetSpecReplayDelay( 0 )
				player.SetObserverTarget( null )
				player.StopObserverMode()
				Remote_CallFunction_ByRef( player, "ServerCallback_KillReplayHud_Deactivate" )
				player.MakeVisible()
				player.ClearInvulnerable()
				player.SetTakeDamageType( DAMAGE_YES )
			}
		}
		catch(e420){}
		
		soloGroupStruct group = returnSoloGroupOfPlayer( player ) 		
		if( group.isValid )
		{
			destroyRingsForGroup( group )		
			group.IsFinished = true //tell solo thread this round has finished
		}
		
		if( isPlayerInWaitingList( player ) )
			continue
		
		soloModePlayerToWaitingList( player )
		FS_ClearRealmsAndAddPlayerToAllRealms( player )
	}
	
	foreach( challengeStruct in file.allChallenges )
	{
		if( !isChalValid( challengeStruct ) )
			continue	
			
		endLock1v1( challengeStruct.player )
	}
	
	if( GetCurrentRound() > 0 )
	{
		file.soloPlayersWaiting = {}
		file.groupsInProgress = {}
		file.playerToGroupMap = {}
		ClearAllNotifications()
	}
}

void function ClearAllNotifications()
{
	foreach ( player in GetPlayerArray() )
	{
		if( !IsValid( player ) )
			continue 
			
		ClearNotifications( player )
	}
}

vector function Gamemode1v1_GetNotificationPanel_Coordinates()
{
	if( Playlist() == ePlaylists.fs_lgduels_1v1 && MapName() == eMaps.mp_rr_canyonlands_staging )
		return file.WaitingRoom.origin + <0,-200,130> 
	
	return g_waitingRoomPanelLocation.origin + <0,0,155>
}

vector function Gamemode1v1_GetNotificationPanel_Angles()
{	
	return g_waitingRoomPanelLocation.angles
}

void function ChallengeNotificationsThread( entity player )
{
	entity opponent = player.p.entLastChallenger	
	Assert( IsValid( opponent ), "Null opponent set" )
	
	EndSignal( player, "ChallengeStarted", "OnDisconnected" )
	EndSignal( opponent, "ChallengeStarted", "OnDisconnected" )
	
	OnThreadEnd
	(
		void function() : ( player )
		{
			if( IsValid( player ) )
				ClearNotifications( player )
		}
	)
	
	int iStatusText = 0
	bool waitingForSelfToJoin = false 
	bool HasChalText = false
	
	for( ; ; )
	{
		wait 1
		
		if ( !IsValid( player ) )
			break
		
		if( !HasChalText )
		{
			#if DEVELOPER
				printt( "CREATING 002 for", player )
			#endif
			
			Gamemode1v1_NotifyPlayer( player, eNotify.CHALLENGE, "#FS_CHALLENGE_STARTED" )
			HasChalText = true 
			wait 2
			
			if ( !IsValid( player ) )
				break
				
			iStatusText = 2
		}
	
		if ( !isPlayerInWaitingList( player ) )
		{			
			if( iStatusText != 3 )
			{
				#if DEVELOPER
					printt( "CREATING 003 for", player )
				#endif 
				
				Gamemode1v1_NotifyPlayer( player, eNotify.CHALLENGE, "#FS_JOIN_QUEUE" )
				iStatusText = 3
			}
			
			wait 1
			continue
		}
		
		entity challenged = player.p.entLastChallenger
		if( !IsValid ( challenged ) )
		{
			#if DEVELOPER
				Warning( "Invalid challenger. DEBUG IT" )
			#endif 
			
			continue //do something
		}
		else 
		{			
			if( !isPlayerInWaitingList( challenged ) )
			{			
				wait 1
				
				if( !IsValid( player ) )
					break
				
				if( iStatusText != 4 )
				{
					#if DEVELOPER
						printt( "CREATING 004 for", player )
					#endif 
					
					Gamemode1v1_NotifyPlayer( player, eNotify.CHALLENGE, "#FS_CHALLENGE_WAITING_FOR", challenged.p.name )
					iStatusText = 4
				}
			}
		}
	}
}

void function _CleanupPlayerEntities( entity player )
{
	PROTO_CleanupTrackedProjectiles( player )
	player.Signal( "CleanUpPlayerAbilities" )
}

/*{
"725342087": "Bangalore",
"898565421": "Bloodhound",
"1111853120": "Caustic",
"80232848": "Crypto",
"182221730": "Gibraltar",
"1409694078": "Lifeline",
"2045656322": "Mirage",
"843405508": "Octane",
"1464849662": "Pathfinder",
"187386164": "Wattson",
"827049897": "Wraith",
}*/

/*
		"Bangalore", //0
		"Bloodhound", //1
		"Caustic", //2
		"Gibby", //3
		"Lifeline", //4
		"Mirage", //5
		"Octane", //6
		"Pathfinder", //7
		"Wraith", //8
		"Wattson", //9
		"Crypto", //10
*/

const table<string,int> characterRefMap =
{
	["725342087"] 	= 0,	//"Bangalore",
	["898565421"] 	= 1,	//"Bloodhound",
	["1111853120"] 	= 2,	//"Caustic",
	["182221730"] 	= 3,	//"Gibraltar",
	["1409694078"] 	= 4,	//"Lifeline",
	["2045656322"] 	= 5,	//"Mirage",
	["843405508"] 	= 6,	//"Octane",
	["1464849662"] 	= 7,	//"Pathfinder",
	["827049897"] 	= 8,	//"Wraith",
	["187386164"] 	= 9,	//"Wattson",
	["80232848"] 	= 10 	//"Crypto",
}

int function CharacterGuidRefToIndex( string numRef )
{
	if( numRef in characterRefMap )
		return characterRefMap[ numRef ]
	
	return -1
}

const array<int> LEGEND_GUID_ENABLED_PASSIVES = 
[	
	725342087, //ref character_bangalore	
]

const array<int> LEGEND_GUID_ENABLED_ULTIMATES = 
[	
	898565421, //ref character_bloodhound
	187386164, //ref character_wattson
	2045656322, //ref character_mirage
	843405508, //ref character_octane
	827049897, //ref character_wraith
	1464849662, //ref character_pathfinder
]


void function Init_ValidLegendRange()
{
	int min = -1 //ValidLegendRange checks with greater than expr
	int max = file.characters.len() //ValidLegendRange checks with less than expr
	
	if( max <= 0 )
		max = -1
		
	file.minLegendRange = min
	file.maxLegendRange = max 
}

bool function ValidLegendRange( int i )
{
	return i > file.minLegendRange && i < file.maxLegendRange
}

void function RechargePlayerAbilities( entity player, int index = -1, bool noUltimate = false )
{
	if( !IsValid( player ) )
		return
	
	//printt( "player:", player, "index:", index )
	//mAssert( index > -1 , "RechargePlayerAbilities() was changed to use character index instead of using waitforitemflavor. Comment this assert out if you dont want to change method in scenarios." )
	
	ItemFlavor character
	
	if( ValidLegendRange( index ) )
		character = file.characters[ characterslist[ index ] ]
	else
		character = LoadoutSlot_WaitForItemFlavor( ToEHI( player ), Loadout_CharacterClass() )
	
	//sqprint( format("LEGEND: %s, GUID: %d", ItemFlavor_GetHumanReadableRef( character ), ItemFlavor_GetGUID( character ) ))
	ItemFlavor tacticalAbility = CharacterClass_GetTacticalAbility( character )
	player.GiveOffhandWeapon(CharacterAbility_GetWeaponClassname( tacticalAbility ), OFFHAND_TACTICAL )	

	int charID = ItemFlavor_GetGUID( character )

	if( Playlist() == ePlaylists.fs_scenarios )
	{
		ItemFlavor passive = CharacterClass_GetPassiveAbility( character )
		GivePassive( player, CharacterAbility_GetPassiveIndex( passive ) )
	}
	else if( LEGEND_GUID_ENABLED_PASSIVES.contains( charID ) )
	{
		GivePassive( player, 0 ) //bangalore is only legend current in list
		
		/* //Only needed if passive list expands
		TakeAllPassives( player )
		ItemFlavor passive = CharacterClass_GetPassiveAbility( character )
		GivePassive( player, CharacterAbility_GetPassiveIndex( passive ) )
		*/
	}

	//wait 0.5
	
	if( settings.isScenariosMode || LEGEND_GUID_ENABLED_ULTIMATES.contains( charID ) ) 
	{
		ItemFlavor ultiamteAbility = CharacterClass_GetUltimateAbility( character )
		player.GiveOffhandWeapon( CharacterAbility_GetWeaponClassname( ultiamteAbility ), OFFHAND_ULTIMATE, [] )
	}
	
	entity wep = player.GetOffhandWeapon( OFFHAND_INVENTORY )
	
	if( !noUltimate && IsValid( wep ) )
		wep.SetWeaponPrimaryClipCount( wep.GetWeaponPrimaryClipCountMax() )
	
	ReloadTactical( player )
	player.Server_TurnOffhandWeaponsDisabledOff()
}

void function ReloadTactical( entity player )
{	
	entity weapon = player.GetOffhandWeapon( OFFHAND_LEFT )
	
	if ( IsValid( weapon ) )
	{
		int max = weapon.GetWeaponPrimaryClipCountMax()
		weapon.SetNextAttackAllowedTime( Time() - 1 )

		if ( weapon.IsChargeWeapon() )
			weapon.SetWeaponChargeFractionForced( 0 )
		else if ( max > 0 )
			weapon.SetWeaponPrimaryClipCount( max )
	}
	
	player.SetSuitGrapplePower( 100 )
}

void function HandleGroupIsFinished( entity player ) //, var damageInfo )
{
	if( !IsValid( player ) )
		return

	soloGroupStruct group = returnSoloGroupOfPlayer( player ) 
	if( !isGroupValid( group ) )
	{
		removeGroup( group )
		return
	}
	
	if( !group.IsKeep )
		group.IsFinished = true //tell solo thread this round has finished
}

void function TakeUltimate( entity player )
{
	if( IsValid( player.GetOffhandWeapon( OFFHAND_ULTIMATE ) ) )
		player.TakeOffhandWeapon( OFFHAND_ULTIMATE )
}


void function Init_IBMM( entity player )
{
	#if TRACKER && HAS_TRACKER_DLL
		if( IsBotEnt( player ) ) //Todo(mk): nuke.
			return 
	#endif
			
	thread Thread_CheckInput( player ) //Todo(mk): move to code
	
	AddButtonPressedPlayerInputCallback( player, IN_MOVELEFT, SetInput_IN_MOVELEFT )
	AddButtonPressedPlayerInputCallback( player, IN_MOVERIGHT, SetInput_IN_MOVERIGHT )
	AddButtonPressedPlayerInputCallback( player, IN_BACK, SetInput_IN_BACK )
	AddButtonPressedPlayerInputCallback( player, IN_FORWARD, SetInput_IN_FORWARD )	
	
	if( Playlist() == ePlaylists.fs_scenarios )
		return 
		
	thread NotificationThread( player )
	
	if( player.p.IBMM_grace_period == -1 )
		SetDefaultIBMM( player )
}


void function Thread_CheckInput( entity player )
{
	int timesCheckedForNewInput = 0
	int previousInput = -1
	bool isCheckerRunning

    for( ; ; )
	{
		wait 0.1 //was 0.1
		
		if( !IsValid( player ) )
			break

		int typeOfInput = GetInput( player )
		
		if ( !isCheckerRunning && typeOfInput == 1 )
			player.p.movevalue = 0
		
		if( typeOfInput == 9 )
			continue

		if( isCheckerRunning )
		{
			if( typeOfInput == previousInput )
			{
				if( timesCheckedForNewInput >= 4 )
				{
					isCheckerRunning = false
					timesCheckedForNewInput = 0

					if ( InvalidInput( typeOfInput, player.p.movevalue ) ) 
					{				
                       // HandlePlayer( player ) //not used yet
					   player.p.input = 1					
                    }
					else
					{
                        //sqprint("Player did change input! Old: " + player.p.input.tostring() + " - New: " + typeOfInput.tostring());
                        player.p.input = typeOfInput
						player.p.lastInputChangeTime = Time()
						player.Signal( "InputChanged" ) //registered signal in CPlayer class		
                    }
					continue
				}
				timesCheckedForNewInput++
				//sqprint( "Checking if it's a valid input change..." + typeOfInput.tostring() + previousInput.tostring() + " - Times checked: " + timesCheckedForNewInput.tostring() )
			}
			else
			{
				timesCheckedForNewInput = 0
				isCheckerRunning = false
				//sqprint( "Player did NOT change input. It was a false alarm." )
			}
			
			previousInput = typeOfInput
			continue
		}

		if( player.p.input != typeOfInput && !isCheckerRunning )
		{
			//sqprint( "Input change check triggered. " + player.p.input.tostring() + typeOfInput.tostring() + " - Did player change input?" )
			isCheckerRunning = true
			previousInput = typeOfInput
			continue
		}

		/*
		if( player.p.input == 0 )
				sqprint( player.GetPlayerName() + "is mnk" )
			else // 1
				sqprint( player.GetPlayerName() + "is rolla" )
		*/
    }
}//ty cafe for fixed thread

bool function InvalidInput( int input_type, int movevalue )
{
	if ( movevalue == 0 && input_type == 0 )
		return true
	
	return false	
}

//(mk): not currently used
void function HandlePlayer( entity player )
{
	string id = player.GetPlatformUID()
	int action = GetCurrentPlaylistVarInt( "invalid_input_action", 1 )
	string msg = GetCurrentPlaylistVarString( "invalid_input_msg", "Invalid Input Device" )
	bool log_invalid_input = GetCurrentPlaylistVarBool( "log_invalid_input", false )
	
	switch (action)
	{
	
		case 1:
			printt("Action: keeping as controller")
			player.p.input = 1
			break
		case 2:
			printt("Action: kick")
			//KickPlayerById( id, msg )
			break
		case 3:
			printt("Action: Ban")
			//BanPlayerById( id, msg )
			break
	
	}
}

//Made by @CafeFPS
int function GetInput( entity player )
{	
    float value = player.GetInputAxisRight() == 0 ? player.GetInputAxisForward() : player.GetInputAxisRight() 
	
    if( value == 0 || value == 0.5 )
		return 9
		
	//sqprint( "Right axis value: " + player.GetInputAxisRight().tostring() + " --- Player forward axis: " + player.GetInputAxisForward())
	//sqprint( "Value: " + value.tostring() + " Length:" + value.tostring().len().tostring() )
    
	return value.tostring().len() < 5 ? 0 : 1
}

void function SetInput_IN_MOVELEFT( entity player )
{
	//sqprint( "Setting movevalue for " + player.GetPlayerName() + " to 3" )
	player.p.movevalue = 3
}

void function SetInput_IN_MOVERIGHT( entity player )
{
	//sqprint("Setting movevalue for " + player.GetPlayerName() + " to 4")
	player.p.movevalue = 4
}

void function SetInput_IN_BACK( entity player )
{	
	//sqprint("Setting movevalue for " + player.GetPlayerName() + " to 5")
	player.p.movevalue = 5
}

void function SetInput_IN_FORWARD( entity player )
{	
	//sqprint("Setting movevalue for " + player.GetPlayerName() + " to 6")
	player.p.movevalue = 6
}

bool function GroupIsLockable( soloGroupStruct newGroup )
{	//(mk): This can return "could not lock" message when the enemy has not moved yet for the match. Intended behavior.
	return ( newGroup.player1.p.lastmoved > 2 && newGroup.player2.p.lastmoved > 2 && ( ( Fetch_IBMM_Timeout_For_Player( newGroup.player1 ) == false && Fetch_IBMM_Timeout_For_Player( newGroup.player2 ) == false ) || newGroup.player1.p.input == newGroup.player2.p.input ) )	
}

bool function ClientCommand_mkos_IBMM_wait( entity player, array<string> args )
{
	if ( !CheckRate( player ) ) 
		return true

	string param = ""
	int limit = settings.ibmm_wait_limit
	
	if ( args.len() > 0 )
		param = args[ 0 ]

	if  ( args.len() < 1 )
	{		
		string status = " " //(mk): needs to be a char or var is treated as empty
		if ( player.p.IBMM_grace_period == 0 )
			status = " (disabled)"
		
		LocalVarMsg( player, "#FS_WAIT_TIME_CC", eMsgUI.VAR_SUBTEXT_SLOT, 15, limit.tostring(), player.p.IBMM_grace_period, status )
		return true
	}
				
	if ( args.len() > 0 && !IsStringNumeric( param, 0, limit ) )
	{
		LocalMsg( player, "#FS_FAILED", "#FS_IBMM_Time_Failed", eMsgUI.DEFAULT, 5, "", limit.tostring() )
		return true
	} 		
	
	try
	{	
		float user_value = float( param )
		
		if ( user_value > 0.0 && user_value < 3.0 )
			user_value = 3
		
		player.p.IBMM_grace_period = user_value
		SavePlayerData( player, "wait_time", user_value )
		Remote_CallFunction_ByRef( player, "ForceScoreboardLoseFocus" )
		
		LocalMsg( player, "#FS_SUCCESS", "#FS_IBMM_Time_Changed", eMsgUI.DEFAULT, 3, "", user_value.tostring() )
		return true
	}
	catch ( hiterr )
	{
		return true			
	}				
}

bool function ClientCommand_mkos_lock1v1_setting( entity player, array<string> args )
{
	if ( !CheckRate( player ) ) 
		return false
	
	string param = ""
	
	if ( args.len() > 0 )
		param = args[ 0 ]
	
		if ( args.len() < 1 )
			return true			
		
		if ( param == "" )
			return true 
		
		
		switch( param.tolower() )
		{
		
		case "ON":
		case "on":
		case "1":
		case "true":
		case "enabled":
		
				player.p.lock1v1_setting = true
				Remote_CallFunction_ByRef( player, "ForceScoreboardLoseFocus" )
				SavePlayerData( player, "lock1v1_setting", true )
				LocalMsg( player, "#FS_SUCCESS", "#FS_LOCK1V1_ENABLED", eMsgUI.DEFAULT, 3 )
				return true

		
		case "OFF":
		case "off":
		case "0":
		case "false":
		case "disabled":
		

				player.p.lock1v1_setting = false
				Remote_CallFunction_ByRef( player, "ForceScoreboardLoseFocus" )
				SavePlayerData( player, "lock1v1_setting", false )
				LocalMsg( player, "#FS_SUCCESS", "#FS_LOCK1V1_DISABLED", eMsgUI.DEFAULT, 3 )
				return true
				
		}
		
	return false
					
}

bool function ClientCommand_mkos_start_in_rest_setting( entity player, array<string> args )
{
	if ( !CheckRate( player ) ) 
		return false
	
	string param = ""
	
	if ( args.len() > 0 )
		param = args[ 0 ]
		
		if ( args.len() < 1 )
		{
			LocalMsg( player, "#FS_START_IN_REST_TITLE", "#FS_START_IN_REST_SUBSTR" )
			return true
		}
		
		if ( param == "" )
			return true
		
		switch( param.tolower() )
		{
		
		case "ON":
		case "on":
		case "1":
		case "true":
		case "enabled":
		
				player.p.start_in_rest_setting = true;
				Remote_CallFunction_ByRef( player, "ForceScoreboardLoseFocus" )
				
				SavePlayerData( player, "start_in_rest_setting", true )
				LocalMsg( player, "#FS_SUCCESS", "#FS_START_IN_REST_ENABLED", eMsgUI.DEFAULT, 3 )
				
				return true	
		
		case "OFF":
		case "off":
		case "0":
		case "false":
		case "disabled":
		
				player.p.start_in_rest_setting = false
				Remote_CallFunction_ByRef( player, "ForceScoreboardLoseFocus" )
				
				SavePlayerData( player, "start_in_rest_setting", false )
				LocalMsg( player, "#FS_SUCCESS", "#FS_START_IN_REST_DISABLED" )
				
				return true
				
		}
		
	return false					
}

bool function ClientCommand_enable_input_banner( entity player, array<string> args )
{
	if ( !CheckRate( player ) ) 
		return false
	
	string param = ""	
	if ( args.len() > 0 )
		param = args[ 0 ]
	
		if ( args.len() < 1 )
		{
			LocalMsg( player, "#FS_INPUT_BANNER_DEPRECATED", "#FS_INPUT_BANNER_SUBSTR_DEP" )
			return true
		}				
		
		if ( param == "")
			return true
		
		switch( param.tolower() )
		{	
			case "on":
			case "1":
			case "true":
			case "enabled":
			
						try
						{	
							player.p.enable_input_banner = true
							Remote_CallFunction_ByRef( player, "ForceScoreboardLoseFocus" )
							
							SavePlayerData( player, "enable_input_banner", true )
							LocalMsg( player, "#FS_SUCCESS", "#FS_INPUT_BANNER_ENABLED_DEP", eMsgUI.DEFAULT, 3 )
							
							return true				
						} 
						catch ( rest_setting_err_1 )
						{			
							return true		
						}
			
			case "off":
			case "0":
			case "false":
			case "disabled":
			
						try
						{
							player.p.enable_input_banner = false
							Remote_CallFunction_ByRef( player, "ForceScoreboardLoseFocus" )
							
							SavePlayerData( player, "enable_input_banner", false )
							LocalMsg( player, "#FS_SUCCESS", "#FS_INPUT_BANNER_DISABLED_DEP", eMsgUI.DEFAULT, 3 )
							
							return true
						} 
						catch ( rest_setting_err_2 )
						{
							return true
						}
					
			}
		
	return false
					
}

void function Gamemode1v1_OnPlayerKilled( entity victim, entity attacker, var damageInfo )
{
	victim.SetPlayerNetEnt( "FSDM_1v1_Enemy", null )

	if( IsValid( attacker ) )
		victim.p.lastKiller = attacker

	if( bIsCoachingMode() )
	{
		//(cafe)stops recording
		FS_Coaching_StopRecording( FS_Coaching_GetAvailableMatchIdentifier(), victim, attacker )
	}
	
	if( !isScenariosMode() )
		HandleGroupIsFinished( victim ) //, damageInfo )
		
	if( isPlayerInWaitingList( victim ) )
	{
		if( !IsAlive( victim ) )
		{
			Gamemode1v1_SetPlayerGamestate( victim, e1v1State.SEQUENCE )
			DecideRespawnPlayer( victim, false )
		}
		
		LocPair waitingRoomLocation = getWaitingRoomLocation()
		if ( !IsValid( waitingRoomLocation ) )
		{//(mk): this should never be hit, Maki had it checked. 
			mAssert( 0, "Waiting room location was invalid." )
			return
		}
		
		ClearInvincible( victim )
		maki_tp_player( victim, waitingRoomLocation )
			
		return
	}
		
	ClearInvincible( victim ) //(mk): why? MakeInvincible is never called, however raw entity method SetInvulerable is called in fsdm _HandleRespawn() [1v1 is separate] and StartRound(). Leaving for now
	return
}
LocPairData function Init_DropoffPatchSpawns()
{
	array<LocPair> dropoff_patch = 
	[	
			//removed skyroom
			//NewLocPair( <-1378.05, 559.458, 1026.54 >, < 359.695, 307.314, 0 >),//13
			//NewLocPair( <-1469.03, -117.677, 1026.54 >, < 1.34318, 60.0746, 0 >),
			
			NewLocPair( < -2824.9, 2868.1, -111.969 >, < 0.354577, 31.8209, 0 >), //13
			NewLocPair( < -2541.81, 3919.45, -111.969 >, < 358.65, 315.899, 0 >),
		
			NewLocPair( < -2958.52, 183.899, 190.063 >, < 0.905181, 353.701, 0 >),//14
			NewLocPair( < -1693.05, -663.034, 190.063 >, < 0.514909, 140.627, 0 >),
			
			NewLocPair( <2544.54, 3934.15, -111.969 >, < 3.3168, 218.85, 0>), //15
			NewLocPair( <3196.49, 3010.24, -111.969 >, < 1.33276, 134.094, 0>),
			
			NewLocPair( < 2551.65, 515.938, 193.337 >, < 0.894581, 215.161, 0>), //16
			NewLocPair( <1637.37, -808.877, 193.67 >, < 0.0671947, 36.8544, 0>)	
	]
				
	return SpawnSystem_CreateLocPairObject( dropoff_patch )
}

void function OnMatchStart()
{
	resetChallenges()
}

void function Gamemode1v1_OnSpawned( entity player )
{
	LocPair waitingRoomLocation = getWaitingRoomLocation()
	
	player.SetShieldHealthMax( Equipment_GetDefaultShieldHP() )
	Survival_SetInventoryEnabled( player, false )
	
	maki_tp_player( player, waitingRoomLocation )
	player.UnfreezeControlsOnServer()
}

void function ValidateBlacklistedWeapons( array<string> Weapons ) //(mk): modifies original by ref
{
	int maxIter = Weapons.len() - 1
	
	for( int i = maxIter; i >= 0; i-- )
	{
		int sliceIndex = Weapons[ i ].find( " " )		
		if( sliceIndex > -1 )
		{	
			string weaponName = Weapons[ i ].slice( 0, sliceIndex )
			
			if( GetBlackListedWeapons().contains( weaponName ) )
				Weapons.remove( i )
		}
		else
		{
			if( GetBlackListedWeapons().contains( Weapons[ i ] ) )
				Weapons.remove( i )
		}
	}
}

void function DisablePlayerCollision( entity player )
{
	player.kv.contents = CONTENTS_BULLETCLIP | CONTENTS_MONSTERCLIP | CONTENTS_HITBOX | CONTENTS_BLOCKLOS | CONTENTS_PHYSICSCLIP; //CONTENTS_PLAYERCLIP
}

void function EnablePlayerCollision( entity player )
{
	player.kv.contents = CONTENTS_BULLETCLIP | CONTENTS_MONSTERCLIP | CONTENTS_HITBOX | CONTENTS_BLOCKLOS | CONTENTS_PHYSICSCLIP | CONTENTS_PLAYERCLIP
}

void function DecideToggleCollision_Rest( entity player, bool enable )
{
	if( settings.player_rest_collision_enabled || !settings.player_collision_enabled )
		return
		
	if( enable )
		EnablePlayerCollision( player )
	else 
		DisablePlayerCollision( player )
}

void function SetupPlayerReserveAmmo( entity player, entity weapon )
{
	int ammoType = weapon.GetWeaponAmmoPoolType()
	player.AmmoPool_SetCount( ammoType, 0 ) //(mk):always reset
	
	string ammoRef = AmmoType_GetRefFromIndex( ammoType )
	LootData data = SURVIVAL_Loot_GetLootDataByRef( ammoRef )

	int amount = settings.give_weapon_stack_count_amount * FS_GetWeaponsThatUseThisAmmo( player, ammoRef ).len() //Revisit this
	//(Cafe)todo remove the remaining ammo if player does not have two guns of the same ammo anymore
	
	//Clean up ammo. Cafe
	foreach ( ammo, type in eAmmoPoolType )
	{
		if( !SURVIVAL_Loot_IsRefValid( ammo ) )
			continue
		
		if( !IsAmmoInUse( player, ammo ) )
		{
			int count = SURVIVAL_CountItemsInInventory( player, ammo )
			SURVIVAL_RemoveFromPlayerInventory( player, ammo, count )
			player.AmmoPool_SetCount( type, 0 )
		}
	}

	int amountToGive = amount * data.inventorySlotCount
	int amountToAdd = SURVIVAL_AddToPlayerInventory( player, ammoRef, amountToGive, false ) //(mk): don't actually add it here.
	int ammoInInventory = SURVIVAL_CountItemsInInventory( player, ammoRef )	
	int maxClipSize = weapon.UsesClipsForAmmo() ? weapon.GetWeaponSettingInt( eWeaponVar.ammo_clip_size ) : weapon.GetWeaponPrimaryAmmoCountMax( weapon.GetActiveAmmoSource() )
	
	player.AmmoPool_SetCount( ammoType, ammoInInventory + amountToAdd ) //(mk): add here.
	
	#if DEVELOPER
		//printw( "added", amountToAdd, "for ref", ammoRef, "to player", string( player ) )
	#endif
}

void function Gamemode1v1_SetWeaponAmmoStackAmount( int amount )
{
	settings.give_weapon_stack_count_amount = amount
}

void function HandleOpponentInfo( soloGroupStruct group )
{
	#if ( false ) && DEVELOPER
		printt
		( 
			"Setting Opponents: \n", 
			group.player1, 
			"'s Opponent:", 
			group.player2, 
			"\n ",
			group.player2, 
			"'s Opponent:", 
			group.player1 
		)
	#endif 
	
	group.player1.p.lastOpponent = group.player2
	group.player2.p.lastOpponent = group.player1
}

void function Gamemode1v1_TakeAll( entity player )
{
	if( !IsValid( player ) ) //(mk):this can fire after a player has quit, delayed.
		return
		
	TakeUltimate( player )
	player.TakeOffhandWeapon( OFFHAND_MELEE )
	TakeAllPassives( player )
	TakeAllWeapons( player )
}

void function AssignLegendToGroup( int index, array<entity> players )
{
	foreach( player in players )
	{
		if( !IsValid( player ) )
			continue 
			
		if( index <= 10 )
		{
			ItemFlavor character = file.characters[ characterslist[ index ] ]
			CharacterSelect_AssignCharacter( ToEHI( player ), character )
			player.TakeOffhandWeapon( OFFHAND_TACTICAL )
			TakeUltimate( player )
			TakeAllPassives( player )
		}
		else
		{
			SetPlayerCustomModel( player, index )
		}
	}
}

void function Gamemode1v1_SetAllowLegendSelect( bool setting )
{
	settings.allow_legend_select = setting
}

void function Gamemode1v1_SetAllPlayersLegend( int index )
{
	AssignLegendToGroup( index, GetPlayerArray() )
}