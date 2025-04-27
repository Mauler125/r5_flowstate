untyped
// Localized strings framework 																	//mkos

global function INIT_Flowstate_Localization_Strings
global function Flowstate_FetchToken
global function ClientLocalizedTokenExists
global function StringReplaceLimited
global function GetLocalizedStringsCount

#if SERVER
	global function Flowstate_FetchTokenID
	global function LocalMsg //supports 2 tokens, 2 variable data
	global function LocalMsg_TEMP // Use this to call tokens placed in playlists_r5_patch.txt
	global function LocalVarMsg //supports 2 tokens, 251 variable data  ( 255 function call limit minus pre-defined args)
	global function LocalEventMsg //wrapper for LocalMsg ui type 1
	global function LocalEventMsgDelayed
	
	global function IBMM_Notify
	global function LocalizedTokenExists
	global function CreatePanelText_Localized
#endif

#if CLIENT 	
	global function FS_ShowLocalizedMultiVarMessage
	global function FS_BuildLocalizedTokenWithVariableString
	global function FS_DisplayLocalizedToken
	global function FS_BuildLocalizedMultiVarString
	global function FS_CreateTextInfoPanelWithID_Localized
	global function FS_BuildLocalizedVariable_InfoPanel
	global function FS_LocalizationConsistencyCheck_014
#endif

#if DEVELOPER 
	global function DEV_GenerateTable
	global function DEV_Print_eMsgUI
	#if CLIENT || SERVER
		global function DEV_PrintLocalizationTable
	#endif
	#if CLIENT 
		global function DEV_PrintLocalizedTokenByID
	#endif 
#endif

	const ASSERT_LOCALIZATION = false
	const DEBUG_VARMSG = false
	const MAX_CHAR_PER_CALL = 8

global enum eMsgUI
{
	DEFAULT, 			//0
	EVENT, 				//1
	CIRCLE_WARNING, 	//2
	BIG, 				//3
	QUICK, 				//4
	SWEEP, 				//5
	RESULTS, 			//6
	OBJECTIVE, 			//7
	ELITE, 				//8
	WAVE, 				//9
	VAR_TITLE_SLOT, 	//10
	VAR_SUBTEXT_SLOT, 	//11
	VAR_EVENT, 			//12
	VAR_MOTD, 			//13
	IBMM 				//14
}

struct 
{
	table<int, string> FS_LocalizedStrings = {}
	int iConsistencyCheck = -1
	
#if SERVER
	table<string, int> FS_LocalizedStringMap = {}
#endif

#if CLIENT
	string fs_variableString = ""
	string fs_variableSubString = ""
	string fs_variableString_InfoPanel = ""
	string fs_variableSubString_InfoPanel = ""
	
	string motd_text = ""
	string motd_text2 = ""
	
	array<string> variableVars = []
	bool bConsistencyCheckComplete = false
#endif

	//////////////////////////////////////////////////////////////////////////
	//																		//
	//					SERVER-TO-CLIENT TOKEN REGISTRATION					//
	//																		//
	//////////////////////////////////////////////////////////////////////////

	/*
	
		Previously, server-to-client text was streamed one character at a time via 
		rpc from server to client, using the byte ascii of the letter in number form, one call per letter. 
	
		This system aims to reduce calling via a single int -- the index of the token registered 
		on both the server and client in the same order -- in the list below.
		
		1. 
		
			In order for this system to work, the token must exist in localization files, found in:
			\platform\mods\MODNAME\resource   (Flowstate is the basemod)
		
			The mod.vdf file will also define the format of localization files:
			For flowstate:
			
			  "LocalizationFiles"
			  {
				"resource/flowstate_%language%.txt" "1"
			  }
		
			This means when the users client is set to english, it will load tokens from resource/flowstate_english.txt 
			
			Within resource/flowstate_english.txt for example, is where you place your tokens. Optionally you can translate the same token 
			into all other languages.

			////////////////////////////////////////////////
			Left is the token, and on the right is the text:
			
				"TOKEN_NAME" "This is my super long text that will now exist on the client when they download the game."
				
				
			Note that the token name when inside of localization files does not contain a "#"  (hash symbol).
		
		2.
		
			Once the tokens exist, they can be called on CLIENT or UI vm with Localize( "#MY_TOKEN" )
			However, in order for the SERVER to call those tokens on a client, 
			they must be registered HERE, for remote streaming.
			
			Add the tokens you wish to call from the server BELOW (allRegisteredTokens), 
			for usage via LocalMsg() | LocalVarMsg() | LocalEventMsg
			Be sure to prepend '#' before the token on the registration list.
			
			
		Extra.
		
			It is possible to stream tokens to the client when they join via the playlists file, 
			and call those tokens with LocalMsg_TEMP. See inline-documentation above function LocalMsg_TEMP in this file.
			Tokens using this temp method do not need to be registered here. Only in the playlists file. 
	*/



	//WARNING: do not update this on live servers/client or clients will not be able to connect unless server matches.
	//these must match the same order on client between releases. Always add to tail. 
	//if the token is not registered here, it will not be callable from server with LocalMsg() or variants. (except LocalMsg_TEMP())
	array<string> allRegisteredTokens = 
	[
		"#FS_NULL",
		"#FS_1v1_Banner",
		"#FS_1V1_Tracker",
		"#FS_GameNotPlaying",
		"#FS_Scenarios_Banner",
		"#FS_Challenges_Disabled",
		"#FS_NotInFight",
		"#FS_CantChalSelf",
		"#FS_ChalSent",
		"#FS_InvalidPlayer",
		"#FS_OVERFLOW",
		"#FS_FAILED",
		"#FS_Usage",
		"#FS_Challenge_usage",
		"#FS_Challenges",
		"#FS_Challenge_usage_2",
		"#FS_NEW_REQUEST",
		"#FS_ChalRequest",
		"#FS_PlayerNotInChallenges",
		"#FS_RemovedChallenger",
		"#FS_ChallengersCleared",
		"#FS_ChalRevoked",
		"#FS_RevokedX",
		"#FS_RevokedFromPlayers",
		"#FS_NoChallengesToRemove",
		"#FS_PlayerQuit",
		"#FS_NotInChal",
		"#FS_SpawnCycDisabled",
		"#FS_SpawnCycEnabled",
		"#FS_SpawnSwapDisabled",
		"#FS_SpawnSwapEnabled",
		"#FS_DisabledLegends",
		"#FS_InvalidLegend",
		"#FS_PlayingAs",
		"#FS_OutgoingChal",
		"#FS_NoOutgoingChal",
		"#FS_UnknownCommand",
		"#FS_InChallenge",
		"#FS_InChallenge_SUBSTR",
		"#FS_PlayerInChal",
		"#FS_NoChal",
		"#FS_NoChalFromPlayer",
		"#FS_NoChalFromPlayer_SUBSTR",
		"#FS_ChalQuit",
		"#FS_ChalAccepted",
		"#FS_NoChalToEnd",
		"#FS_ChalEnded",
		"#FS_RESTCOOLDOWN",
		"#FS_MATCHING",
		"#FS_BASE_RestText",
		"#FS_SendingToRestAfter",
		"#FS_TryRestAgainIn",
		"#FS_RestGrace",
		"#FS_YouAreResting",
		"#FS_WaitingForPlayers",
		"#FS_MustBeInRest",
		"#FS_MustBeInRest_SUBSTR",
		"#FS_JumpToStopSpec",
		"#FS_IBMM_Any",
		"#FS_IBMM_SAME",
		"#FS_SettingNotAllowed",
		"#FS_ChalDisabled",
		"#FS_ChalEnabled",
		"#FS_StartInRestDisabled",
		"#FS_StartInRestEnabled",
		"#FS_InputBannerDisabled",
		"#FS_InputBannerEnabled",
		"#FS_OpponentDisconnect",
		"#FS_ChalStarted",
		"#FS_InputLocked",
		"#FS_CouldNotLock",
		"#FS_AnyInput",
		"#FS_INPUT_CHANGED",
		"#FS_INPUT_CHANGED_SUBSTR",
		"#FS_ERROR",
		"#FS_DisabledTDMWeps",
		"#FS_NotAllowedWaiting",
		"#FS_WepNotAllowed",
		"#FS_WepBlacklisted",
		"#FS_AbilityBlacklisted",
		"#FS_TgiveCooldown",
		"#FS_WEAPONSAVED",
		"#FS_FAILEDSAVE",
		"#FS_TEAMSBALANCED",
		"#FS_TEAMSBALANCED_SUBSTR",
		"#FS_HitsoundNumFail",
		"#FS_SUCCESS",
		"#FS_HitsoundChanged",
		"#FS_HandicapTitle",
		"#FS_HandicapSubstr",
		"#FS_HandicapOnSubstr",
		"#FS_HandicapOffSubstr",
		"#FS_IBMM_Time_Failed",
		"#FS_IBMM_Time_Changed",
		"#FS_LOCK1V1_ENABLED",
		"#FS_LOCK1V1_DISABLED",
		"#FS_START_IN_REST_TITLE",
		"#FS_START_IN_REST_SUBSTR",
		"#FS_START_IN_REST_ENABLED",
		"#FS_START_IN_REST_DISABLED",
		"#FS_INPUT_BANNER_DEPRECATED",
		"#FS_INPUT_BANNER_SUBSTR_DEP",
		"#FS_INPUT_BANNER_ENABLED_DEP",
		"#FS_INPUT_BANNER_DISABLED_DEP",
		"#FS_KILL_STREAK",
		"#FS_5_KILL_STREAK_SUBSTR",
		"#FS_EXTRA_KILL_STREAK_TITLE",
		"#FS_EXTRA_KILL_STREAK_SUBSTR",
		"#FS_15_KILL_STREAK_TITLE",
		"#FS_15_KILL_STREAK_SUBSTR",
		"#FS_20_KILL_STREAK_TITLE",
		"#FS_20_KILL_STREAK_SUBSTR",
		"#FS_30_KILL_STREAK_TITLE",
		"#FS_30_KILL_STREAK_SUBSTR",
		"#FS_PRED_SUMPREMACY_TITLE",
		"#FS_35_KILL_STREAK_SUBSTR",
		"#FS_50_KILL_STREAK_TITLE",
		"#FS_50_KILL_STREAK_SUBSTR",
		"#FS_25_PREDATORY_SUPREMACY",
		"#FS_EXTRA_SHIELD_TITLE",
		"#FS_EXTRA_SHIELD_SUBSTR",
		"#FS_Oddball",
		"#FS_STRING_VAR",
		"#FS_OddballReady",
		"#FS_Deathmatch",
		"#FS_ERROR_OCCURED",
		"#FS_ERROR_OCCURED2",
		"#FS_COOLDOWN",
		"#FS_COULD_NOT_SPECTATE",
		"#FS_NO_PLAYERS_TO_SPEC",
		"#FS_WAIT_TIME_CC",
		"#FS_AFK_KICK",
		"#FS_PUSHDOWN",
		"#FS_SPACE",
		"#FS_OVERFLOW_TEST",
		"#FS_CUSTOM_WEAPON_CHAL_ONLY",
		"#FS_CustomWepChalOnly",
		"#FS_IN_QUEUE",
		"#FS_MATCHED",
		"#FS_RESTING",
		"#FS_WEAPONS_RESET",
		"#FS_ALL_WEPS_SAVED",
		"#FS_MUTED",
		"#FS_UNMUTED",
		"#FS_ADMIN_RECORDER_ENDALL",
		"#FS_RECORDER_ENDALL",
		"#FS_MOVEMENT_RECORDER",
		"#FS_PLAYBACK_LIMIT",
		"#FS_PLAYING_ALL_ANIMS",
		"#FS_CANT_SWITCH_LEGEND",
		"#FS_RECORDINGANIM_CUSTOM",
		"#FS_NO_SLOTS",
		"#FS_MOVEMENT_SAVED",
		"#FS_ANIM_NOT_FOUND",
		"#FS_ANIM_REMOVED_SLOT",
		"#FS_WELCOME",
		"#FS_INPUT_VS",
		"#FS_CONTROLLER",
		"#FS_MKB",
		"#FS_Scenarios_Tip",
		"#FS_Scenarios_WaitingForRoundEnd",
		"#FS_Scenarios_30Remaining",
		"#FS_OVER_BUDGET",
		"#FS_PLAYING_ANIM",
		"#FS_REMOVING_ALL_ANIMS",
		"#FS_CMD",
		"#FS_NO_ANIMS",
		"#FS_PLAYING_RANDOM",
		"#FS_PLAYING_RANDOM_DESC",	
		"#SCORE_EVENT_FS_Scenarios_EnemyDowned",
		"#SCORE_EVENT_FS_Scenarios_EnemyKilled",
		"#SCORE_EVENT_FS_Scenarios_SurvivalTime",
		"#SCORE_EVENT_FS_Scenarios_EnemyDoubleDowned",
		"#SCORE_EVENT_FS_Scenarios_EnemyTripleDowned",
		"#SCORE_EVENT_FS_Scenarios_BonusTeamWipe",
		"#SCORE_EVENT_FS_Scenarios_TeamWin",
		"#SCORE_EVENT_FS_Scenarios_SoloWin",
		"#SCORE_EVENT_FS_Scenarios_PenaltyDeath",
		"#SCORE_EVENT_FS_Scenarios_PenaltyRing",
		"#SCORE_EVENT_FS_Scenarios_BecomesSoloPlayer",
		"#SCORE_EVENT_FS_Scenarios_KilledSoloPlayer",
		"#SCORE_EVENT_FS_SND_BombPlanted",
		"#SCORE_EVENT_FS_SND_Player_Killed",
		"#FS_MATCHING_FOR",
		"#FS_CHALLENGE_STARTED",
		"#FS_JOIN_QUEUE",
		"#FS_CHALLENGE_WAITING_FOR",
		"#FS_WAITING_PANEL",
		"#FS_STATS_SHIPPED",
		"#FS_STATS_SHIPPED_MSG",
		"#FS_HALOSLAYER",
		"#FS_AFK_ALERT",
		"#FS_AFK_REST_MSG",
		"#FS_AFK_KICK_MSG",
		"#FS_REST_CONFIRM",
		"#FS_NOT_AVAILABLE",
		"#FS_AUTO_UNMUTED",
		"#FS_WARNING",
		"#FS_SPAM_MUTE",
		"#FS_SPAM_MUTE_DESC",
		"#HUB_INCORRECT_USERNAME",
		"#HUB_YOU_CANT_SPECTATE",
		"#HUB_TIMER_IS_ACTIVE",
		"#HUB_OUT_OF_BOUNDS",
		"#HUB_CLEAN_UP",
		"#HUB_CLEAN_UP_1",
		"#HUB_INVISIBLE",
		"#HUB_VISIBLE",
		"#HUB_ACTION_NOT_ALLOWED",
		"#HUB_INVALID_PARAMETERS",
		"#HUB_VOLUMETRIC_LIGHT",
		"#HUB_VOLUMETRIC_LIGHT_1",
		"#HUB_NOT_FAST_ENOUGH",
		"#HUB_FREE_ROAM",
		"#HUB_MAP_WELCOME",
		"#HUB_MAP_MANTLE_JUMP",
		"#HUB_MAP_IT_HURTS",
		"#HUB_MAP_GYM",
		"#HUB_MAP_FIRST",
		"#HUB_CONGRATULATIONS",
		"#HUB_ABILITY_OCTANE",
		"#HUB_ABILITY_WRAITH",
		"#HUB_ABILITY_PATHFINDER",
		"#HUB_TOP3_WARNING",
		"#HUB_TIMER_START",
		"#HUB_TIMER_STOP",
		"#HUB_YOU_FINISHED",
		"#HUB_FINAL_TIME",
		"#HUB_SERVER_LIFETIME",
		"#HUB_CANT_USE_TIMER_RUNNING",
		"#FS_KIDNAPPED",
		"#FS_REMOVED_PORTAL",
		"#FS_REMOVED_PORTAL_DESC",
		
		/* (mk): Added 4/5/2025 */
		
		"#FS_TEAMHELP",
		"#FS_IN_TEAM",
		"#FS_ERR_CMD_PARAM_LEN",
		"#FS_INVALID_TEAM",
		"#FS_PLAYER_NOT_OWNER",
		"#FS_TEAM_FULL",
		"#FS_JOIN_REQUEST_COOLDOWN",
		"#FS_NOT_IN_TEAM",
		"#FS_PLAYER_LEFT_TEAM",
		"#FS_PLAYER_JOINED_TEAM",
		"#FS_YOU_JOINED_TEAM",
		"#FS_FAILED_JOIN_TEAM",
		"#FS_NEW_JOIN_REQUEST",
		"#FS_JOIN_REQUEST_SENT",
		"#FS_LEFT_TEAM",
		"#FS_FAILED_LEAVE_TEAM",
		"#FS_JOIN_REQ_FAILED",
		"#FS_TEAMNAME_MAXLEN",
		"#FS_TEAM_CREATED",
		"#FS_FAILED_CREATETEAM",
		"#FS_TEAMINFO_ERR",
		"#FS_ALL_TEAMS",
		"#FS_TEAM_INFO",
		"#FS_HELP_INFO",
		"#FS_TEAM_DISMANTLED",
		"#FS_JOIN_REQ",
		"#FS_TEAMS_CMDHLP_01",
		"#FS_TEAMS_FAIL_REQ",
		"#FS_INV_REQ_PLAYER",
		"#FS_REQ_REVOKED",
		"#FS_INV_TEAM_PLAYER",
		"#FS_TEAMKICK_FAIL",
		"#FS_PLAYER_NOT_ON_TEAM",
		"#FS_PLAYER_CAPTAIN_ERR",
		"#FS_ADDED_CAPTAIN",
		"#FS_TEAM_SETTINGS",
		"#FS_NOT_CAPTAIN",
		"#FS_INV_TEAM_SETTING",
		"#FS_SAME_SETT_VALUE",
		"#FS_INV_SETT_VALUE",
		"#FS_SETTING_SET",
		"#FS_TEAMCMD_ERR_01",
		"#FS_TEAMS_DISABLED",
		"#FS_NOT_ON_A_TEAM",
		"#INVALID_BADGE",
		"#INVALID_BADGE_REQ",
		"#DEV_ONLY",
		"#BADGE_SAVED",
		
		/* 4/8/2025 */
		
		"#FS_STATS_NOT_READY"
	]
	
} file

const MAX_CHARS = 2990

//########################################################
//							init						//
//########################################################


void function INIT_Flowstate_Localization_Strings()
{	
	#if DEVELOPER
		printt( "Initializing all localization tokens" )
	#endif
	
	int iTokensCount = file.allRegisteredTokens.len()
	file.iConsistencyCheck = iTokensCount
	
	Localization_ConsistencyCheck()
	
	if( iTokensCount <= 0 )
		return
	
	for ( int i = 0; i <= iTokensCount - 1; i++ )
	{
		file.FS_LocalizedStrings[ i ] <- file.allRegisteredTokens[ i ]
		
		#if SERVER
			file.FS_LocalizedStringMap[ file.allRegisteredTokens[ i ] ] <- i
		#endif
	}
	
	file.allRegisteredTokens.clear()
	
	#if DEVELOPER && ASSERT_LOCALIZATION
		Warning( "ASSERTS ENABLED for script: " + FILE_NAME() )
	#endif
}


//########################################################
//					 UTILITY FUNCTIONS					//
//########################################################

//SHARED
string function Flowstate_FetchToken( int tokenID )
{
	if( tokenID in file.FS_LocalizedStrings )
		return file.FS_LocalizedStrings[ tokenID ]
	
	//possibly developer define out and return blank	
	return "Token not found"
}

string function StringReplaceLimited( string baseString, string searchString, string replaceString, int limit )
{
	#if ASSERT_LOCALIZATION
		mAssert( searchString.len() > 0, "cannot use StringReplaceLimited with an empty searchString" )
	#endif
	
	string newString = ""

	int searchIndex = 0
	int iReplaced = 0
	
	while( searchIndex < (baseString.len() - searchString.len() + 1) && iReplaced < limit )
	{
		var occurenceIndexOrNull = baseString.find_olduntyped( searchString, searchIndex )

		if ( occurenceIndexOrNull == null )
			break

		int occurenceIndex = expect int( occurenceIndexOrNull )

		newString += baseString.slice( searchIndex, occurenceIndex )
		newString += replaceString

		searchIndex = occurenceIndex + searchString.len()
		iReplaced++;
	}

	newString += baseString.slice( searchIndex )

	return newString
}

bool function ClientLocalizedTokenExists( int tokenRef )
{
	return ( tokenRef in file.FS_LocalizedStrings )
}

void function Localization_ConsistencyCheck()
{
	#if SERVER
		AddClientCommandCallback( "localizationIntegrityCheck", ClientCommand_CheckLocalizationConsistency )
		AddCallback_OnClientConnected
		( 
			void function( entity player )
			{
				if( IsValid( player ) )
					Remote_CallFunction_NonReplay( player, "FS_LocalizationConsistencyCheck_014" )
			}
		)
	#endif
}
// end SHARED

#if SERVER

	bool function LocalizedTokenExists( string token )
	{
		return ( token in file.FS_LocalizedStringMap )
	}
	
	int function Flowstate_FetchTokenID( string ref )
	{
		if ( ref in file.FS_LocalizedStringMap )
			return file.FS_LocalizedStringMap[ref]
		
		return 0
	}
	
#endif

//########################################################
//					 SERVER FUNCTIONS					//
//########################################################

#if SERVER

bool function ClientCommand_CheckLocalizationConsistency( entity player, array<string> args )
{
	if( args.len() < 1 )
		return true
		
	string param = args[ 0 ]
	
	if( !IsStringNumeric( param ) )
	{
		KickPlayerById( player.GetPlatformUID(), "Invalid localization check data" )
		return true
	}
		
	int clientCount = int( param )
	
	if ( clientCount != file.iConsistencyCheck )
	{
		string info = format( "Your Flowstate localization files do not match the server localization registry. Please update your scripts. Server count: %d, Local count: %d", file.iConsistencyCheck, clientCount )
		KickPlayerById( player.GetPlatformUID(), info )
	}

	return true
}

/*
	Purpose:
		In-between release, a server may set tokens in their playlist file.  
		This function can call those tokens directly. This is best used 
		with very short tokens under 5 chars in length.	

		Example:		 LocalMsg_TEMP( player, "#TMP_1" )
		
		in playlists_r5_patch.txt:
		
		"LocalizedStrings"
		{
		  "lang"
			{
				"Language" "english"
				"Tokens"
				{
					"TMP_1" "Some super long string that will get shipped in the playlist to the client when they join the server once and then can be called with LocalMsg_TEMP"
				}
			}
		}
*/
void function LocalMsg_TEMP( entity player, string token, string token2 = "", int uiType = eMsgUI.DEFAULT, float duration = 5.0 )
{
	mAssert( token.find( "#" ) == 0, "Should use a token with LocalMsg_TEMP()" )
	mAssert( token.len() <= 10, "Lag can be incurred with tokens over 10 in length." )
	
	LocalMsg( player, "#FS_NULL", "#FS_NULL", uiType, duration, token, token2 )
}

void function LocalMsg( entity player, string ref, string subref = "", int uiType = eMsgUI.DEFAULT, float duration = 5.0, string varString = "", string varSubstring = "", string sound = "" )
{
	#if DEVELOPER && ASSERT_LOCALIZATION
		if( !empty(ref) )
		{
			mAssert( ref.find("#") != -1, "Reference missing # symbol  ref: [ " + ref + " ] in calling func: " + FUNC_NAME( 3 ) + "()" )
			mAssert( LocalizedTokenExists( ref ), "Localized Token Reference does not exist for [ " + ref + " ] \n in calling func: " + FUNC_NAME( 3 ) + "()" )
		}
	#endif

	if ( !IsValid( player ) ) 
		return
		
	if ( !player.IsPlayer() ) 
		return
		
	if ( !player.p.isConnected ) 
		return
	
	int dataLen = varString.len() + varSubstring.len()
	int varStringLen = varString.len()
	int varSubStringLen = varSubstring.len()
	
	string appendSubstring
	string appendString
	string sendMessage
	bool isMotd
	
	if( uiType == eMsgUI.VAR_MOTD )
		isMotd = true
	
	if( dataLen > MAX_CHARS )
		mAssert( 0, "Too many chars for LocalMsg()" )
	
	if ( dataLen > 0 )
	{
		for ( int textType = 0; textType < 2; textType++ ) // cycles both slots
		{
			sendMessage = textType == 0 ? varString : varSubstring
			int msgLen = sendMessage.len()
			
			if ( msgLen > MAX_CHAR_PER_CALL )//potentially thread to avoid blocking during large transmission ( amount of calls is msgLen / MAX_CHAR_PER_CALL -- needs unit tested to find optimal switch to thread point )
			{
				int remainingChars = msgLen
				int processedChars = 0

				while ( remainingChars > 0 ) 
				{
					int chunkSize = minint( MAX_CHAR_PER_CALL, remainingChars )
					string chunk = sendMessage.slice( processedChars, processedChars + chunkSize )

					array transmit = [ this, player, "FS_BuildLocalizedTokenWithVariableString", textType, isMotd ]
					for ( int k = 0; k < chunk.len(); k++ )
						transmit.append( chunk[ k ] )

					Remote_CallFunction_NonReplay.acall( transmit )

					processedChars += chunkSize
					remainingChars -= chunkSize
				}
			}
			else
			{
				array transmit = [ this, player, "FS_BuildLocalizedTokenWithVariableString", textType, isMotd ]
				for ( int k = 0; k < msgLen; k++ )
					transmit.append( sendMessage[ k ] )

				Remote_CallFunction_NonReplay.acall( transmit )
			}
		}
	}
	
	int tokenID = Flowstate_FetchTokenID( ref )
	int subTokenID = 0
	
	if( subref != "" )
		subTokenID = Flowstate_FetchTokenID( subref )
	
	Remote_CallFunction_NonReplay( player, "FS_DisplayLocalizedToken", tokenID, subTokenID, uiType, duration )
	
	if ( sound != "" )
		thread EmitSoundOnEntityOnlyToPlayer( player, player, sound )
}

void function LocalVarMsg( entity player, string ref, int uiType = 2, float duration = 5, ... )
{
	if ( !IsValid( player ) ) return
	if ( !player.IsPlayer() ) return
	if ( !player.p.isConnected ) return
	
	int tokenID = Flowstate_FetchTokenID( ref )
	
	int vargCount = expect int( vargc )
	
	for ( int i = 0; i <= vargCount - 1; i++ )
	{
		if ( !ValidateType( vargv[i] ) ) 
			return
		
		string send = ""

		if( typeof( vargv[ i ] ) != "string" )
			send = string( vargv[ i ] )
		else
			send = expect string( vargv[ i ] )

		for ( int k = 0; k <= send.len() - 1; k++ )
			Remote_CallFunction_NonReplay( player, "FS_BuildLocalizedMultiVarString", i, send[ k ] )
	}
	
	Remote_CallFunction_NonReplay( player, "FS_ShowLocalizedMultiVarMessage", tokenID, uiType, duration )	
}

bool function ValidateType( ... )
{
	if( vargc <= 0 )
		return false
	
	string type = typeof( vargv[ 0 ] )
	
	switch( type )
	{	
		case "string":
		case "int":
		case "float":
		case "bool":
		
		return true
	}
	
	return false
}

void function LocalEventMsg( entity player, string ref, string varString = "", float duration = 5 )
{
	LocalMsg( player, ref, "", eMsgUI.EVENT, duration, varString )
}

void function LocalEventMsgDelayed( float eventdelay, entity player, string ref, string varString = "", float duration = 5 )
{
	thread
	( 
		void function() : ( eventdelay, player, ref, varString, duration )
		{
			wait eventdelay
			LocalEventMsg( player, ref, varString, duration )
		}
	)()
}

void function IBMM_Notify( entity player, string ibmmLockTypeToken, int enemyPlayerInputType, float duration = 5.0 )
{
	string inputTypeToken = "";
	
	switch( enemyPlayerInputType )
	{
		case 0: inputTypeToken = "#FS_MKB"; break;
		case 1: inputTypeToken = "#FS_CONTROLLER"; break;
	}
	
	LocalMsg( player, ibmmLockTypeToken, inputTypeToken, eMsgUI.IBMM, duration )
}

void function CreatePanelText_Localized( entity player, string ref, string subRef, string varString, string varSubstring, vector origin, vector angles, float textScale, int panelID = 0 )
{
	#if DEVELOPER && ASSERT_LOCALIZATION
		if( !empty( ref ) )
		{
			mAssert( ref.find( "#" ) != -1, "Reference missing # symbol  ref: [ " + ref + " ] in calling func: " + FUNC_NAME( 3 ) + "()" )
			mAssert( LocalizedTokenExists( ref ), "Localized Token Reference does not exist for [ " + ref + " ] \n in calling func: " + FUNC_NAME( 3 ) + "()" )
		}
		
		if( !empty( subRef ) )
		{
			mAssert( subRef.find( "#" ) != -1, "Reference missing # symbol  ref: [ " + subRef + " ] in calling func: " + FUNC_NAME( 3 ) + "()" )
			mAssert( LocalizedTokenExists( subRef ), "Localized Token Reference does not exist for [ " + subRef + " ] \n in calling func: " + FUNC_NAME( 3 ) + "()" )
		}
	#endif
	
	if ( !IsValid( player ) ) 
		return
		
	if ( !player.IsPlayer() ) 
		return
		
	if ( !player.p.isConnected ) 
		return
	
	int datalen = varString.len() + varSubstring.len()
	
	string appendSubstring
	string appendString
	string sendMessage
	
	mAssert( datalen < 599, "Cannot create localized text panel with more than 599 chars" )
	
	if ( datalen > 0 )
	{
		for ( int textType = 0 ; textType < 2 ; textType++ )
		{
			sendMessage = textType == 0 ? varString : varSubstring

			for ( int i = 0; i < sendMessage.len(); i++ )
				Remote_CallFunction_NonReplay( player, "FS_BuildLocalizedVariable_InfoPanel", textType, sendMessage[i] )
		}
	}
	
	int tokenID = 0
	int subTokenID = 0
	
	if( ref != "" )
		tokenID = Flowstate_FetchTokenID( ref )
	
	if( subRef != "" )
		subTokenID = Flowstate_FetchTokenID( subRef )
	
	Remote_CallFunction_NonReplay( player, "FS_CreateTextInfoPanelWithID_Localized", tokenID, subTokenID, origin, angles, textScale, panelID )
}


#endif //SERVER

//########################################################
//					 CLIENT FUNCTIONS					//
//########################################################

#if CLIENT
void function FS_LocalizationConsistencyCheck_014()
{
	if( !file.bConsistencyCheckComplete )
	{
		entity player = GetLocalClientPlayer()
		
		if( IsValid( player ) )
		{
			player.ClientCommand( "localizationIntegrityCheck " + string( file.iConsistencyCheck ) )
			file.bConsistencyCheckComplete = true
		}
	}
}

void function FS_BuildLocalizedTokenWithVariableString( int Type, bool isMotd, ... )
{
	int charCount = expect int( vargc )
	array chars = [ this, RepeatString( "%c", charCount ) ]
		
	for( int i = 0; i < vargc; i++ )
		chars.append( vargv[ i ] )
		
	string appendStr = expect string( format.acall( chars ) )
	
	if ( Type == 0 )
	{
		if( isMotd )
			file.motd_text += appendStr
		else
			file.fs_variableString += appendStr
	}
	else
	{
		if( isMotd )
			file.motd_text2 += appendStr
		else
			file.fs_variableSubString += appendStr
	}
}


void function FS_BuildLocalizedVariable_InfoPanel( int Type, ... )
{
	if ( Type == 0 )
	{
		for ( int i = 0; i < vargc; i++ )
			file.fs_variableString_InfoPanel += format( "%c", vargv[ i ] )
	}
	else 
	{
		for ( int i = 0; i < vargc; i++ )
			file.fs_variableSubString_InfoPanel += format( "%c", vargv[ i ] )
	}
}

int function CountStringArgs( string str )
{
	int found = RegexpFindAll( str, "%s" ).len()
	
	#if DEVELOPER && DEBUG_VARMSG
		printt( "REGEX FOUND %s count:", found )
	#endif
	
	return found
}

void function FS_DisplayLocalizedToken( int token, int subtoken, int uiType, float duration )
{
	string S 
	string SubS 
	
	if( uiType != eMsgUI.VAR_MOTD )
	{
		S = file.fs_variableString
		SubS = file.fs_variableSubString
		
		if( S.len() > 2 )
		{
			string checkForToken = S.slice( 0, 2 ) //don't search the entire string for #
			
			if( checkForToken.find( "#" ) != -1 )
				S = Localize( S )
		}
		
		if( SubS.len() > 2 )
		{
			string checkForToken2 = SubS.slice( 0, 2 )
			
			if( checkForToken2.find( "#" ) != -1 )
				SubS = Localize( SubS )
		}
	}
	else 
	{	//I really hate this.
		S = file.motd_text
		SubS = file.motd_text2 
	}
	
	string localToken = Flowstate_FetchToken( token )
	string localSubToken = Flowstate_FetchToken( subtoken )

	string Msg = " ";
	string SubMsg = " ";

	string add_placeholder_to_msg = CountStringArgs( Localize( localToken ) ) == 0 ? "%s" : "";
	string add_placeholder_to_submsg = CountStringArgs( Localize( localSubToken ) ) == 0 ? "%s" : "";
	
	#if DEVELOPER && DEBUG_VARMSG
		printt("msg placeholder: ", add_placeholder_to_msg, " ; submsg placeholder: ", add_placeholder_to_submsg )
		printt("S: ", S, " SubS: ", SubS )
	#endif
	
	try 
	{
		Msg = format( ( Localize( localToken ) + add_placeholder_to_msg ) , " " + S )
	}
	catch( e )
	{
		printt("Error ", e ," ; Function: ", FUNC_NAME(), " ;Invalid format qualifiers in message ID: ", token )
		Msg = Localize( strip( localToken ) ) + " " + S
		
		#if DEVELOPER && DEBUG_VARMSG 
			printt("New msg:", Msg )
		#endif
	}
	
	try
	{
		SubMsg = format( ( Localize( localSubToken ) + add_placeholder_to_submsg ) , SubS )
	}
	catch( e2 )
	{
		printt( "Error ", e2 ," ; Function: ", FUNC_NAME(), " ;Invalid format qualifiers in message ID: ", subtoken )
	}
	
	#if DEVELOPER && DEBUG_VARMSG
		printt( "msg: ", StringReplaceLimited( Msg, "\n", "\\n", 999 ), " ;SubMsg: ", StringReplaceLimited( SubMsg, "\n", "\\n", 999 ) )
	#endif
	

	switch( uiType )
	{
		case eMsgUI.DEFAULT: DisplayMessage( Msg, SubMsg, duration ); break
		case eMsgUI.EVENT: Flowstate_AddCustomScoreEventMessage(  Msg, duration ); break
		// > 2 is handled by enum: eMsgUI and DisplayMessage()
		
		default:
			DisplayMessage( Msg, SubMsg, duration, uiType ); break
	}
	
	if( uiType == eMsgUI.VAR_MOTD )
	{
		file.motd_text = ""
		file.motd_text2 = ""
	}
	else
	{
		file.fs_variableString = ""
		file.fs_variableSubString = ""
	}
}

void function DisplayMessage( string str1, string str2, float duration, int uiType = 0 )
{
	//printt( str1, str2 )
	
	entity player = GetLocalClientPlayer()
	AnnouncementData announcement = Announcement_Create( str1 )
	Announcement_SetSubText( announcement, str2 )
	Announcement_SetHideOnDeath( announcement, false )
	Announcement_SetDuration( announcement, duration )
	Announcement_SetPurge( announcement, true )
	//Announcement_SetSoundAlias( announcement, "" )
	//Announcement_SetLeftText( announcement, ["test","test","test"] )
	//Announcement_SetRightText( announcement, ["test","test","test"] )
	
	//set default 
	Announcement_SetStyle(announcement, ANNOUNCEMENT_STYLE_CIRCLE_WARNING)

	int mode = Gamemode()
	
	if( uiType < 2 ) //old Message() style
	{
		int playlist = Playlist()
		
		switch( mode )
		{
			case eGamemodes.fs_dm:
			case eGamemodes.fs_prophunt:
			case eGamemodes.fs_duckhunt:
			case eGamemodes.fs_snd:
			
				Announcement_SetStyle(announcement, ANNOUNCEMENT_STYLE_CIRCLE_WARNING)
				Announcement_SetTitleColor( announcement, Vector(0,0,0) )	
		
			break;
			
			default: break;
		}
		
		switch( playlist )
		{
			case ePlaylists.fs_movementgym:
			case ePlaylists.fs_scenarios:
			case ePlaylists.fs_1v1:
			case ePlaylists.survival_solos:
			case ePlaylists.fs_lgduels_1v1:
			case ePlaylists.fs_snd:
			
			Announcement_SetStyle(announcement, ANNOUNCEMENT_STYLE_SWEEP)
			Announcement_SetTitleColor( announcement, Vector( 0, 0, 1 ) )
			
			if( duration == 8.420 )
			{
				Announcement_SetDuration( announcement, 5 )
				Announcement_SetStyle(announcement, ANNOUNCEMENT_STYLE_CIRCLE_WARNING)
				Announcement_SetTitleColor( announcement, Vector( 0, 0, 0 ) )
			}
			
			break;
			
			default: break;
		}
	}
	else 
	{
		int iCustomUI = ANNOUNCEMENT_STYLE_CIRCLE_WARNING
		
		switch( uiType )
		{
			case eMsgUI.CIRCLE_WARNING: break;
			case eMsgUI.BIG: iCustomUI = ANNOUNCEMENT_STYLE_BIG; break;
			case eMsgUI.QUICK: iCustomUI = ANNOUNCEMENT_STYLE_QUICK; break;
			case eMsgUI.SWEEP: iCustomUI = ANNOUNCEMENT_STYLE_SWEEP; break;
			case eMsgUI.RESULTS: iCustomUI = ANNOUNCEMENT_STYLE_RESULTS; break;
			case eMsgUI.OBJECTIVE: iCustomUI = ANNOUNCEMENT_STYLE_OBJECTIVE; break;
			case eMsgUI.ELITE: 
				iCustomUI = ANNOUNCEMENT_STYLE_ELITE; 
				//Announcement_SetOptionalTextArgsArray( announcement, [ player.GetPlayerNetInt("SeasonScore").tostring() ] )
				break;	
			case eMsgUI.WAVE:	iCustomUI = ANNOUNCEMENT_STYLE_WAVE; break;
			case eMsgUI.VAR_MOTD:
				RunUIScript( "SetMotdText", str1 + str2 )
				return
			
			case eMsgUI.IBMM:
				thread FS_IBMM_Msg( str1, str2, duration )
				return
				
			default:
				#if DEVELOPER
					Warning( format( "Server tried to call ui that doesn't exist: uiType: %d, function: %s()", uiType, FUNC_NAME()  ) )
				#endif
				break
		}
		
		#if DEVELOPER && DEBUG_VARMSG
			printt("\n\n --- LocalMsg() ---\n", "str1:", StringReplaceLimited( str1, "\n", "\\n", 999 ), "\n str2:", StringReplaceLimited( str2, "\n", "\\n", 999 ), "\n duration:", duration, "\n uiType:", uiType, "\n iCustomUI:", iCustomUI )
		#endif 
		
		Announcement_SetStyle( announcement, iCustomUI )
		Announcement_SetDuration( announcement, duration )
		Announcement_SetTitleColor( announcement, Vector( 0, 0, 0 ) )
	}
	
	AnnouncementFromClass( player, announcement )
}

void function FS_CreateTextInfoPanelWithID_Localized( int token, int subToken, vector origin, vector angles, float textScale, int panelID )
{
	string Msg = "";
	string SubMsg = "";
	
	if( token != 0 )
	{
		string S = file.fs_variableString_InfoPanel
		string localToken = Flowstate_FetchToken( token )
		string add_placeholder_to_msg = CountStringArgs( Localize( localToken ) ) == 0 ? "%s " : "";
		
		#if DEVELOPER && DEBUG_VARMSG
			printt( "S: [", S + "]", "msg placeholder:[", add_placeholder_to_msg + "]" )
		#endif 
		
		try 
		{
			Msg = format( ( Localize( localToken ) + add_placeholder_to_msg ), S )
		}
		catch( e )
		{
			printt("Error ", e ," ; Function: ", FUNC_NAME(), " ;Invalid format qualifiers in message ID: ", token )
			Msg = Localize( strip( localToken ) ) + " " + S
			
			#if DEVELOPER && DEBUG_VARMSG 
				printt("New msg:", Msg )
			#endif
		}
	}
	
	if( subToken != 0 )
	{
		string SubS = file.fs_variableSubString_InfoPanel
		string localSubToken = Flowstate_FetchToken( subToken )
		string add_placeholder_to_submsg = CountStringArgs( Localize( localSubToken ) ) == 0 ? "%s " : "";
		
		#if DEVELOPER && DEBUG_VARMSG
			printt( "SubS: [", SubS + "]", "; submsg placeholder:[", add_placeholder_to_submsg + "]" )
		#endif
	
		try
		{
			SubMsg = format( ( Localize( localSubToken ) + add_placeholder_to_submsg ), SubS )
		}
		catch( e2 )
		{
			printt("Error ", e2 ," ; Function: ", FUNC_NAME(), " ;Invalid format qualifiers in message ID: ", subToken )
		
			#if DEVELOPER && DEBUG_VARMSG 
				printt("New msg:", SubMsg )
			#endif
		}
	}
	
	#if DEVELOPER && DEBUG_VARMSG
		printt("msg: ", StringReplaceLimited( Msg, "\n", "\\n", 999 ), " ;SubMsg: ", StringReplaceLimited( SubMsg, "\n", "\\n", 999 ) )
	#endif
		
	CreateTextPanel_Localized
	( 
		origin.x,
		origin.y,
		origin.z,
		angles.x,
		angles.y,
		angles.z,
		false,
		textScale, 
		panelID, 
		Msg,
		SubMsg
	)
	
	file.fs_variableString_InfoPanel = ""
	file.fs_variableSubString_InfoPanel = ""
}

void function FS_BuildLocalizedMultiVarString( int varNum, ... )
{	
	for ( int i = 0; i < vargc; i++ )
	{ 
		if( file.variableVars.len() <= varNum )
			file.variableVars.append( format( "%c", vargv[ i ] ) )
		else 
			file.variableVars[ varNum ] += format( "%c", vargv[ i ] )
	}
}


void function FS_ShowLocalizedMultiVarMessage( int token, int uiType, float duration )
{
	string localToken = Flowstate_FetchToken( token )
	string localTokenString = Localize( localToken )
	
	int varCount = file.variableVars.len()
	int tokenPlaceholdersCount = CountStringArgs( localTokenString )
	
	#if DEVELOPER && ASSERT_LOCALIZATION //assert here, because we should not have to correct tokens below.
		mAssert( file.variableVars.len() == tokenPlaceholdersCount, "Variable vars(%d) do not match token placeholders(%d)", file.variableVars.len(), tokenPlaceholdersCount )
	#endif
	
	if( tokenPlaceholdersCount > varCount )
	{
		int placeholdersToRemove = tokenPlaceholdersCount - varCount;	
		localTokenString = StringReplaceLimited( localTokenString, "%s", "", placeholdersToRemove )
	}
	else if( varCount > tokenPlaceholdersCount )
	{
		int placeholdersToAdd = varCount - tokenPlaceholdersCount 
		localTokenString += RepeatString( " %s", placeholdersToAdd )
	}
	
	string Msg = ""	
	
	try 
	{
		array vars = [ this, localTokenString ] 	
		vars.extend( file.variableVars )
		Msg = expect string( format.acall( vars ) )
	}
	catch ( e )
	{
		Warning( "Error " + e + " ;Invalid format qualifiers in message ID: %d , Text: %s", token, Localize( Flowstate_FetchToken( token ) ) )
	}
	
	#if DEVELOPER && DEBUG_VARMSG
		int count = 0
		foreach( vVar in file.variableVars )
		{
			count++
			printt( "var:", count, vVar )
		}
		
		printt( "Message:", Msg )
		printt( "uiType:", uiType )
		printt( "Var count was:" + varCount + ", place holder count was:", tokenPlaceholdersCount )
	#endif 
	
	switch( uiType )
	{
		case eMsgUI.VAR_TITLE_SLOT: DisplayMessage( Msg, " ", duration ); break;
		case eMsgUI.VAR_SUBTEXT_SLOT: DisplayMessage( " ", Msg, duration ); break;
		case eMsgUI.VAR_EVENT: Flowstate_AddCustomScoreEventMessage(  Msg, duration ); break;

		default:
			#if DEVELOPER
				Warning( "Server tried to call ui that doesn't exist: uiType: %d, function: %s()", uiType, FUNC_NAME() )
			#endif
			break
	}
	
	file.variableVars.clear()
}
#endif //CLIENT


#if SERVER || CLIENT 

	int function GetLocalizedStringsCount()
	{
		return file.iConsistencyCheck
	}

#endif //SERVER || CLIENT 

//########################################################
//					DEV FUNCTIONS						//
//########################################################

#if DEVELOPER
void function DEV_GenerateTable()
{
	//ParseFSTokens("mods/Flowstate.Localization/resource/flowstate_english.txt")
	//Todo: logic to dump data
}

void function ParseFSTokens( string path )
{
/*
	if( !DevDoesFileExist( path ) )
	{
		printt("file not found.")
		return
	}
	
    string fileData = DevReadFile( path )
    string fpattern = "\"(FS_[^\"]+)\"";

    array<string> found = RegexpFindAll( fileData, fpattern);
	//file.allRegisteredTokens.extend(found)
	
	string buildPrint = ""
	
	foreach( match in found )
		buildPrint += format( "\"#" + match + "\", \n")
	
	printt( buildPrint )
	printt("FS_Tokens Count: ", found.len() )
*/
}

#if CLIENT || SERVER
void function DEV_PrintLocalizationTable()
{
	
	#if CLIENT 
		string kvFormat = "";
	#endif //CLIENT
	
	foreach ( key, value in file.FS_LocalizedStrings )
	{		
#endif
		#if CLIENT 
			string vFormat = StringReplaceLimited( Localize(value), "\n", "\\n", 100 )
			string kFormat = StringReplaceLimited( value, "#", "", 1 )
			int kOffset = 30 - kFormat.len()
			kvFormat += "\"" + kFormat + "\"" + TableIndent( kOffset ) + "\"" + vFormat + "\"\n"				
		#endif //CLIENT
			
		#if SERVER 
			printt( key, value )
		#endif 
#if CLIENT || SERVER
	}
	
	#if CLIENT 
		printt( "\n\n --- LOCALIZATION TOKENS --- \n\n" + kvFormat + "\n" )
		printt( "Token count:", file.FS_LocalizedStrings.len(), "\n\n" )
	#endif //CLIENT
}
#endif //CLIENT || SERVER

	#if CLIENT 
		void function DEV_PrintLocalizedTokenByID( int id )
		{
			printt( Localize( Flowstate_FetchToken( id ) ) )
		}
	#endif //CLIENT
	
	//SHARED
	void function DEV_Print_eMsgUI()
	{	
		string tableText = "\n\nglobal enum eMsgUI\n{\n"
		
		foreach( enumName, index in eMsgUI )
		{
			int offset = 25 - enumName.len()
			tableText += TableIndent( 5 ) + enumName + TableIndent( offset ) + " = " + string( index ) + "\n"
		}
		
		tableText += "}\n\n"
		printt( tableText )
	}
	//end SHARED 
	
#endif //DEVELOPER


/////////////////////////////////////////
// reload command: reload_localization //