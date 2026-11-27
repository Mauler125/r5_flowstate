untyped //needed for sqwarning																		//mkos

//player util
global function CheckRate
global function ResetRate
global function GetPlayer
global function GetPlayerEntityByUID
global function GetPlayerEntityByName
global function IsServerAdmin
global function GetAdminList
global function AdminMessage
global function SendResponse
global function SendPM

//string util
global function IsStringNumeric
global function IsStringNumber
global function IsStringBool
global function StringToBool
global function StringRemoveControlCharacters
global function Concatenate
global function LineBreak
global function IsSafeString
global function UnescapeWithRules
global function FindFirstUnescaped
global function SplitUnescapedWithRules
global function ResolveFormattersForPlayerMessage
global function PrepareForJson	

//print util -- moved to _threads
// global function print_string_array
// global function print_var_table
// global function print_var_array

//Tracker print-to-console as native
global function sqprint
global function sqerror
global function sqwarning

//Weapons util:
global function ParseWeapon
global function IsWeaponValid
global function TrackerWepTable
global function GetWeaponSettingIntFromFile
global function ShouldExcludeDamageSourceShipping
global function DEV_PrintTrackerWeapons
global function PrintSupportedAttachpointsForWeapon

//Client commands util
global function __PlayerAdminsInit
global function ClientCommand_mkos_return_data
global function ClientCommand_mkos_admin
global function CheckAdmin_OnConnect
global function IsAuthEnabled

//misc
global function TrackerUtilityInit
global function EnableVoice
global function PlayTimeFromSecondsString
global function Tracker_DetermineNextMap
global function Tracker_GotoNextMap
global function ArrayUniqueInt
global function ArrayUniqueString
global function IsMapPlaylistGamemodeRotationEnabled
global function DecideNextMapPlaylistGamemodeRotation
global function IsValidCharacterGUID
global function TP

//code callbacks
global function CodeCallback_SendMessage

#if DEVELOPER
	global function RegExpUnitTest
	global function RegExpUnitTest2
	global function StringUnitTest
	global function TestRandom
#endif

#if TRACKER && HAS_TRACKER_DLL
	global function PrintMatchIDtoAll
#endif

global struct ParseRules
{
	string escapeChar
	table<string,string> escapeMap
}

struct PlaylistGamemodeRotateData
{
	string map 
	string playlist
	string gamemode
	int minplayers
	int maxplayers
}

struct
{
	table< PlaylistGamemodeRotateData, array< string > > errorRotationData
	array< PlaylistGamemodeRotateData > allRotationData
	table< string, table< string, string > > tbl_adminConfirmations
	table< string, int > tbl_weaponIdentifiers
	array< string > adminsArray
	
	bool bStopUpdateMsg
	bool bAutoRotationEnabled
	bool bAllowLooseNameComp
	
} file

void function TrackerUtilityInit()
{
	RegisterSignal( "ConfirmAction" )
	
	string autoRotateList 				= GetCurrentPlaylistVarString( "auto_rotate_list", "" )
	bool autoRotateListForcedDisabled 	= Dev_CommandLineParmValue( "autoRotateForceDisable" ) == "true"
	
	if( autoRotateList != "" && !autoRotateListForcedDisabled )
	{
		file.bAutoRotationEnabled = true
		AutoMapPlaylistGamemodeRotationInit( autoRotateList )
		AddCallback_GameStateEnter( eGameState.Postmatch, DecideNextMapPlaylistGamemodeRotation )
	}
	
	file.bAllowLooseNameComp = GetCurrentPlaylistVarBool( "enable_loose_playername_comparison", true )
}
	
	//client command: show
		bool function ClientCommand_mkos_return_data( entity player, array<string> args )
		{
			if ( !CheckRate( player, "verbose_stream", 5.0, true ) ) 
				return false
			
			if ( args.len() < 1 )
			{	
				Message( player, "\n\n\nUsage: ", " showdata argument \n\n\n Arguments:\n map - Shows current map name \n round - Shows current round number \n input - Shows a list of players and their current input", 5 )
				return true	
			}
			
			string requestedData = args[ 0 ]
			string param = ""
			
			if ( args.len() >= 2 )
				param = args[ 1 ]

			switch( requestedData )
			{

				case "map":
					//sqprint( GetMapName() )
					Message( player, "Mapname:", GetMapName(), 5 )
					return true
					
				case "round":
					//sqprint( GetCurrentRound().tostring() )
					Message( player, "Round:", GetCurrentRound().tostring(), 5 )
					return true
					
				case "player":
						
						string stringHandicap
						string handicap
						string p_input
						string data
						string inputmsg
						float kd
						string kd_string
						int kills
						int deaths
						string l_oid
						string l_name
						float l_wait
						
						if ( param == "" )
						{
							Message( player, "Failed", " Command 'player' requires playername/oid as first param. " )
							return true
						}
							
						try
						{			
							if ( param.len() > 16 )
							{
								Message( player, "Failed", "Input exceeds char limit. " )
								return true
							}
							
							entity l_player = GetPlayer( param )
							
							if ( !IsValid( l_player ) )
							{
								Message( player, "Failed", "Player: " + param + " - is invalid. " )
								return true
							}			
							
							if ( Flowstate_IsLGDuels() )
							{
								handicap = l_player.p.p_damage == 2 ? "On" : "Off"
								stringHandicap = "---- Handicap: " + handicap 
							}
							
							p_input = l_player.p.input > 0 ? "Controller" : "MnK" 
							kills = l_player.p.season_kills + player.GetPlayerNetInt( "kills" )
							deaths = l_player.p.season_deaths + player.GetPlayerNetInt( "deaths" )
							l_name = l_player.GetPlayerName()
							l_oid = l_player.GetPlatformUID()
							l_wait = l_player.p.IBMM_grace_period
							inputmsg = "Player: " + l_name + " OID: " + l_oid
							
							if ( deaths > 0 ) 
								kd = getkd( kills, deaths )
							
							data += "Season Kills: " + kills + " ---- Deaths: " + deaths + " ---- KD: " + kd + "\n"
							data += "Input:  " + p_input + stringHandicap + "\n"
							data += "wait time:  " + l_wait.tostring() + "\n" 
							data += GetScore(l_player) + "\n"
							data += "Season playtime: " + PlayTimeFromSecondsString( l_player.p.season_playtime ) + "\n"
							data += "Season games: " + l_player.p.season_gamesplayed + "\n"
							data += "Season score: " + l_player.p.season_score
							
							if( ( inputmsg.len() + data.len() ) > 2800 )
							{
								Message( player, "Failed", "Cannot execute this command currently due to return data resulting in overflow" )
								return true
							}
							
							Message( player, inputmsg, data, 15 )
							
						} 
						catch ( errlookup ) 
						{
							Message(player, "Failed", "Command failed because of: \n\n " + errlookup )
							return false
						}
						
						return true
				
				case "input":
											
						string handicap = ""
						string p_input = ""					
						string data = ""
						string inputmsg = "Current Player Inputs"
						
						try 
						{
							foreach ( active_player in GetPlayerArray() )
							{	
								handicap = active_player.p.p_damage == 2 ? "On" : "Off"
								p_input = active_player.p.input > 0 ? "Controller" : "MnK"
								data += "Player: " + active_player.GetPlayerName() + " is using: " + p_input + " ---- Handicap: " + handicap + "\n"
							}				
							
							if( ( inputmsg.len() + data.len()) > 2800 )
							{
								Message( player, "Failed", "Cannot execute this command currently due to return data resulting in overflow" )
								return true
							}
							
							Message( player, inputmsg, data, 20 )	
						} 
						catch ( show_err ) 
						{
							Message( player, "Failed", "Command failed because of: \n\n " + show_err )
							return false			
						}		
						
						return true
						
				case "inputs":
				
						int controllerCount = 0;
						int mnkCount = 0
						
						foreach ( active_player in GetPlayerArray() )
						{
							if ( active_player.p.input == 0 )
								mnkCount++
							else if ( active_player.p.input == 1 )
								controllerCount++
						}
						
						string cplural = controllerCount > 1 || controllerCount == 0 ? "s" : ""
						string mplural = mnkCount > 1 || mnkCount == 0 ? "s" : "";
						
						string countMsg = format("%d controller player%s \n %d mnk player%s", controllerCount, cplural, mnkCount, mplural );
						Message( player, "There is currently", countMsg, 7 )
						
						return true
						
				case "stats":
						
						string data = ""
						string inputmsg = bGlobalStats() ? "Current Player Global Stats" : "Current Player Round Stats"
						float kd = 0.0
						string kd_string = ""
						int kills = 0
						int deaths = 0
						string global_stats_msg = bGlobalStats() ? " Season Stats:" : " Current Round Stats:"
						
						try 
						{				
							foreach ( active_player in GetPlayerArray() )
							{
								kills = active_player.p.season_kills + player.GetPlayerNetInt( "kills" )
								deaths = active_player.p.season_deaths + player.GetPlayerNetInt( "deaths" )
								
								if (deaths > 0) 
								{
									kd = getkd( kills, deaths )
								}
								
								kd_string = kd != 0.0 ? kd.tostring() : "N/A";

								data += "Player: " + active_player.GetPlayerName() + global_stats_msg + " Kills: " + kills + " ---- Deaths: " + deaths + " ---- KD: " + kd + "\n"; 
							}
							
							
							if( ( inputmsg.len() + data.len()) > 2800 )
							{
								Message( player, "Failed", "Cannot execute this command currently due to return data resulting in overflow" )
								return true
							}
							
							Message( player, inputmsg, data, 20 )	
						} 
						catch ( show_err2 ) 
						{
							Message( player, "Failed", "Command failed because of: \n\n " + show_err2 )
							return false						
						}		
						
						return true
						
				case "aa":
					
						string data = ""
						string inputmsg = "Server AA values:"
						
						try 
						{			
							data += format( "\n Console Aim Assist: %.1f ", GetCurrentPlaylistVarFloat( "aimassist_magnet", 0.0 ) )
							data += format( "\n PC Aim Assist: %.1f", GetCurrentPlaylistVarFloat( "aimassist_magnet_pc", 0.0 ) )
									
							if( ( inputmsg.len() + data.len() ) > 2800 )
							{	
								Message( player, "Failed", "Cannot execute this command currently due to return data resulting in overflow" )
								return true		
							}
							
							Message( player, inputmsg, data, 20 )
						} 
						catch ( show_err3 ) 
						{	
							Message( player, "Failed", "Command failed because of: \n\n " + show_err3 )
							return false					
						}
						
						return true
					
				case "id":
				
				#if TRACKER && HAS_TRACKER_DLL
					
					string data = "";
					string inputmsg = ":::: Match ID ::::";
					
					try 
					{
						
						data += format("\n\n %s ", TrackerMatchID__internal() )
								
						if( ( inputmsg.len() + data.len() ) > 2800 )
						{	
							Message( player, "Failed", "Cannot execute this command currently due to return data resulting in overflow" )
							return true		
						}
						
						Message( player, inputmsg, data, 20 )
					
					}
					catch ( show_err4 ) 
					{
						Message( player, "Failed", "Command failed because of: \n\n " + show_err4 )
						return false						
					}
					
				#endif 
				
					return true

					
				default:
					//sqprint ( "Usage: show argument \n" )
					Message( player, "Failed: ", "Usage: show argument \n", 5 )
					return true
			}
			
			return false
		}
		
		

	void function __PlayerAdminsInit()
	{
		if( !IsAuthEnabled() )
			sqwarning( "WARNING: Client Command Admin is enabled but online auth is disabled" )
	
		file.adminsArray.resize( 0 )
	
		string admins_list
		string pair
		
		#if TRACKER && HAS_TRACKER_DLL
			admins_list = TrackerGetSettingString( "settings.ADMINS" )
		#endif
		
		if( admins_list != "" )
		{
			#if DEVELOPER 
				sqprint( "Admins loaded from r5r_dev.json" )
			#endif
		}
		else 
		{
			admins_list = GetCurrentPlaylistVarString( "admins_list", "" )
		}
		
		if ( empty( admins_list ) )
			return
		
		try
		{
			array<string> list = StringToArray( admins_list )
			
			foreach ( admin_pair in list ) //backwards compat
			{
				pair = admin_pair			
				if( admin_pair.find( "-" ) != -1 ) //todo: problematic backwards compat for usernames containing hyphen.
				{
					array<string> a_format = split( admin_pair, "-" )
					file.adminsArray.append( a_format[ 1 ] )
				}
				else 
					file.adminsArray.append( admin_pair ) //new format only uid
			}
		}
		catch( erradmin )
		{
			sqerror( "Error with adminpair:", pair, "Error:", erradmin )
		}
	}
	
	array<string> function GetAdminList()
	{
		return file.adminsArray
	}

	string function PlayTimeFromSecondsString( int iSeconds ) 
	{	
		float seconds = iSeconds.tofloat()
		float hours =  seconds / 3600
		float minutes = ( seconds % 3600 ) / 60
		float r_seconds = seconds % 60
		
		string playtime = format( "%d hours, %d minutes, %d seconds", hours, minutes, r_seconds )
		return playtime
	}

	//////////////////////////////////////////////////////////////////////////
	//cc commands
	bool function ClientCommand_mkos_admin( entity player, array<string> args )
	{	
		string PlayerUID = player.GetPlatformUID()
		bool bIsAdmin = IsServerAdmin( PlayerUID )
		
		if ( !bIsAdmin ) 
			return false
			
		string command
		string param
		string param2
		string param3
		string param4
		
		if ( args.len() > 0 )
			command = args[ 0 ]
			
		if ( args.len() > 1 )
			param = args[ 1 ]
			
		if ( args.len() > 2 )
			param2 = args[ 2 ]
			
		if ( args.len() > 3 )
			param3 = args[ 3 ]
			
		if ( args.len() > 4 )
			param4 = args[ 4 ]
		
		switch( command.tolower() )
		{
			case "help":
			{
				const array<string> commandHelp = 
				[
					"\n\n\n\n\n\n\n\n\n\n\n\n\n\nA command is entered as:\n\n cc command #param #param2 ...\n\n",
					"cc afk [0|1|true|false]   - disabled or enables afk to rest mode\n",
					"cc kick [name|oid] [-r \"reason\"] [-say]  - Kicks a player by name/oid, optionally add -say to announce\n",
					"cc timeout [name|oid] [true|false] [-r \"reason\"] [timestring] [-say]   - Times out the player. Optionally add -say to announce\n",
					"cc gettimeout [name|oid]    - Returns data about a timeout\n",
					"cc mute/unmute [name|oid] [-r \"[reason]\"] [timestring] [-say]    - Mutes / unmutes\n", 
					"cc msg [name|oid] \"message\"    - Sends a PM to a player. A way to communicate with other admins\n",
					"cc sayto [name|oid] [title] [msg] [dur]    - Sends a titled message to a specific player (duration defaults to ~3s if omitted)\n"
					"cc sayall [#title] [#message] [duration]   - Broadcasts a titled message to all clients with a duration (seconds).\n",
					"cc adminmsg [name|oid] \"message\"    - Sends an admin-branded message to a specific player\n",
					"cc adminmsgall \"message\"    - Sends an admin-branded message to all players.\n",
					"cc ban [name/oid] [-r \"[reason]\"] [-say]   - Bans a player. Optionally add -say to announce\n",
					"cc unban [oid]   - attempts to unban a player by OID\n",
					"cc map [name] [playlist] [gamemode]   - reloads map. partials match i.e. \"cc map comp\" will load mp_rr_arena_composite\n", 
					"cc endround    - forces the round timer to end now\n",
					"cc playerinput [name/oid]   - shows players input\n", 
					"cc playerinfo  - some debug stats",
					"\n\n For more commands, see https://docs.r5r.dev"
				]
				
				try 
				{
					LocalMsg( player, "#FS_NULL", "#FS_NULL", eMsgUI.DEFAULT, 20, "Commands:", commandHelp.join( "" ) )
				}
				catch ( err ) 
				{
					sqerror( string( err ) )
					return true 
				}
		
				return true
			}
			case "addbot":
			{
				if( param == "" )
				{
					Message( player, "Failed", "addbot requires name for 1st param of command" )
					return true
				}
				
				if( param2 == "" )
				{
					Message( player, "Failed", "addbot requires team for 2nd param of command" )
					return true
				}
				
				if( !IsStringNumber( param2 ) )
				{
					Message( player, "Failed", "addbot requires team as number for 2nd param of command" )
					return true
				}
				
				int calc = param2.tointeger()
				if( ( calc > 129 || calc < 0 ) && calc != -1 )
				{
					Message( player, "Invalid team. Must be >= -1 and < 129" )
					return true
				}
				
				__ServerCommand( format( "sv_addbot %s %s", param, param2 ) )
				Message( player, format( "Bot '%s' created on team '%s'", param, param2 ) )
				
				return true
			}
			case "kick":
			{
				if ( args.len() < 2 )
				{
					Message( player, "Failed", "kick requires name/id for 1st param of command" )
					return true
				}

				try 
				{		
					entity kickPlayer
					string kickPlayerUid
					string kickPlayerName
					string reason = Chat_FindReasonInArgs( args )
					
					kickPlayer = GetPlayer( param )
					
					if ( !IsValid( kickPlayer ) )
					{
						Message( player, "Failed", format( "Player: '%s' is invalid. ", param ) )
						return true
					}
					
					if( kickPlayer.IsBot() )
					{
						string botName = kickPlayer.GetPlayerName()
						__ServerCommand( format( "kick %s", botName ) )
						
						Message( player, format( "Bot player %s was kicked", botName ) )
						return true
					}
						
					kickPlayerUid = kickPlayer.GetPlatformUID()	
					kickPlayerName = kickPlayer.GetPlayerName()
					
					if ( IsServerAdmin( kickPlayerUid ) )
					{
						Message( player, "Cannot kick admin")
						return true
					}
				
					KickPlayerById( kickPlayerUid, reason )
					UpdatePlayerCounts()
					
					Message( player, "Kicked player", format( "PUID: '%s'\nName: '%s'", kickPlayerUid, kickPlayerName ) )
					
					if( args.contains( "-say" ) )
					{
						string msgHeader = format( "%s was kicked for: ", kickPlayerName )
						BroadcastResponse( msgHeader + reason, true )
						foreach( s_player in GetPlayerArray() )
							Message( s_player, msgHeader, reason )
					}
					
					return true	
				}
				catch ( erraaarg )
				{
					Message( player, "Error", "Invalid player or argument missing" )
					return true
				}
				
				return true	
			}	
			case "afk":
			{
				if( !IsStringBool( param ) )
				{
					Message( player, "Param 1 of command 'afk' requires bool. [0|1|true|false]" )
					return true
				}
				
				if ( StringToBool( param ) )
				{
					SetAfkToRest( true )
					Message( player, "Command sent", "Afk to rest was ENABLED" )
					return true
				}

				SetAfkToRest( false )
				Message( player, "Command sent", "Afk to rest was disabled" )
			
				return true
			}		
			case "restricted":
			{
				if( !IsStringBool( param ) )
				{
					Message( player, "Param 1 of command 'restricted' requires bool. [0|1|true|false]" )
					return true
				}
				
				if ( StringToBool( param ) )
				{
					Tracker_SetRestrictedServer( true )
					Message( player, "Command sent", "restricted_server was ENABLED" )		
					return true
				}

				Tracker_SetRestrictedServer( false )
				Message( player, "Command sent", "restricted_server was disabled" )

				return true
			}
			case "playonself": 
			{
				if ( args.len() < 2 )
				{
					Message( player, "Failed", "playself requires param of audiofile as string" )
					return true
				} 
					
				try 
				{
					EmitSoundOnEntity( player, args[1] )	
				} 
				catch ( erra )
				{
					Message(player, "Failed", "Command failed because of: \n\n " + erra )
					return true	
				}
				
				return true
			}
			case "playself": 
			{
				if ( args.len() < 2 )
				{
					Message( player, "Failed", "Command 'playself' requires param of audiofile as string" )
					return true
				} 
					
				try 
				{
					EmitSoundOnEntityOnlyToPlayer( player, player, args[1] )	
				} 
				catch ( erra )
				{			
					Message(player, "Failed", "Command failed because of: \n\n " + erra )
					return true	
				}
				
				return true
			}		
			case "playall":
			{						
				foreach ( connected_player in GetPlayerArray() )
				{
					try 
					{
						EmitSoundOnEntityOnlyToPlayer( connected_player, connected_player, args[1] )
						return true		
					} 
					catch ( errb )
					{	
						Message(player, "Failed", "Command failed because of: \n\n " + errb )
						return true	
					}
				}

				return true
			}			
			case "stopplayall":
			{		
				foreach ( connected_player in GetPlayerArray() )
				{					
					try 
					{
						StopSoundOnEntity( connected_player, args[1] )
						return true	
					} 
					catch ( errb )
					{	
						Message(player, "Failed", "Command failed because of: \n\n " + errb )
						return true
					}
				}

				return true
			}				
			case "sayall": 
			{	
				if ( args.len() < 4 )
				{	
					Message( player, "Failed", "Command 'sayall' requires duration for third param of command as float" )
					return true
				} 
				
				foreach ( say_to_player in GetPlayerArray() )
				{
					try	
					{	
						Message( say_to_player, param, param2, param3.tofloat() )	
					} 
					catch ( errc )
					{		
						Message( player, "Failed", "Command failed because of: \n\n " + errc )
						return true
					}
				}
							
				return true
			}		
			case "sayto": 
			{
				if ( param4 == "" || !IsStringNumeric( param4 ) )		
					param4 = "3"		
					
				if( param3 != "" && param2 == "" )
					param2 = " "
					
				try
				{
					entity to_player = GetPlayer(param)	
					
					if( IsValid( to_player ) )
						Message( to_player, param2, param3, param4.tofloat() )
					else 
						Message( player, "INVALID PLAYER")
													
				} 
				catch ( errst )
				{	
					Message( player, "Failed", "Command failed because of: \n\n " + errst )			
				}

				return true
			}
			case "ban":
			{				
				if ( args.len() < 2 )
				{		
					Message( player, "Failed", "Command 'ban' requires name/id for 1st param of command" )
					return true
				}			
				
				try 
				{
					entity banPlayer
					string banPlayerUID
					string banPlayerName
					string banReason = Chat_FindReasonInArgs( args )	
					
					banPlayer = GetPlayer( param )
				
					if ( !IsValid( banPlayer ) )
					{
						Message( player, "Failed", "Player: " + param + " - is invalid. " )
						return true
					}
					
					banPlayerName = banPlayer.GetPlayerName()
					banPlayerUID = banPlayer.GetPlatformUID()			
					
					if ( IsServerAdmin( banPlayerUID ) )
					{
						Message( player, format( "Cannot ban admin %s", banPlayerName ) )
						return true
					}
				
					#if HAS_TRACKER_DLL
						// if( args.contains( "-id" ) )
							// BanPlayerByIdOnly( banPlayerUID, banReason, player.GetPlatformUID() ) //not released yet.
						// else
							BanPlayerById( banPlayerUID, banReason, player.GetPlatformUID() )
					#else
						BanPlayerById( banPlayerUID, banReason )
					#endif
					
					UpdatePlayerCounts()
					
					Message( player, "Success", format( "Player: %s\n\n was banned for: \n\n%s", banPlayerName, banReason ) )
					
					if( args.contains( "-say" ) )
					{
						string msgHeader = format( "%s was BANNED for: ", banPlayerName )
						SendServerMessage( msgHeader + banReason )
						foreach( s_player in GetPlayerArray() )
							Message( s_player, msgHeader, banReason, 10.0 )
					}
					
					return true		
				} 
				catch ( erre )
				{
					Message( player, "Failed", "Command failed because of: \n\n " + erre )
					return true
				}
					
				return true
			}
			case "banid":
			{
				#if HAS_TRACKER_DLL
					if ( args.len() < 2 )
					{
						Message( player, "Failed", "Command 'banid' requires oid for 1st param of command")
						return true
					}	

					try 
					{
						if ( IsServerAdmin( param ) )
						{
							Message( player, "Failed", param + " is an admin. Ban rejected.", 10 )
							return true		
						}
						
						if ( !IsStringNumber( param ) )
						{			
							Message( player, "Failed", param + " is not a valid oid format.", 10 )
							return true	
						}
						
						string reason = Chat_FindReasonInArgs( args )
						entity playerToBan = GetPlayerEntityByUID( param )
						
						if( IsValid( playerToBan ) )
						{
							BanPlayerById( param, reason, player.GetPlatformUID() )
							Message( player, "Success", param + " was added to the banlist and removed from the server.", 10 )
							return true
						}
							
						Message( player, "Attempting banlist edit", format( "For user: [%s] with reason: \"%s\"", param, reason ), 10 )
						AddBanByID( param, reason, player.GetPlatformUID() )
						
						return true				
					}
					catch ( errbanid )
					{
						Message(player, "Failed", "Command failed because of: \n\n " + errbanid )
						return true
					}
				#endif // TRACKER && HAS_TRACKER_DLL
				
				return true
			}
			case "unban":				
			{
				if ( args.len() < 2 )
				{		
					Message( player, "Failed", "Command 'unban' requires id for 1st param of command as string" )
					return true	
				}
				
				try 
				{
					UnbanPlayer( args[1] )					
					Message( player, "Success", "ID: " + args[1] + " was supposedly unbanned" )				
					return true
						
				} 
				catch ( erre )
				{	
					Message(player, "Failed", "Command failed because of: \n\n " + erre )
					return true
				}
				
				return true
			}				
			case "playerinfo":
			{
				try 
				{				
					string nputmsg = "Current Stats:"
					
					string info = Tracker_BuildAllPlayerMetrics( true )
					
					if( ( nputmsg.len() + info.len()) > 2800 )
					{
						Message( player, "Failed", "Cannot execute this command currently due to return data resulting in overflow" )
						return true
					}
					
					Message( player, nputmsg, LineBreak( info ), 20 )
					return true	
				} 
				catch ( errf )
				{	
					Message( player, "Failed", "Command failed because of: \n\n " + errf )
					return true
				}
			}
			//for testing
			case "playerinput":
			{		
				if ( args.len() < 1)
				{	
					Message( player, "Failed", "Param 1 of command 'playerinput' requires player name/oid." )
					return true		
				}
				
				try
				{		
					entity a_player
					string mode
					
					a_player = GetPlayer( param )
					
					if ( !IsValid( a_player ) )
					{	
						Message( player, "Failed", "Player: " + param + " -- is invalid" );
						return true
					}
					
					mode = a_player.p.input == 0 ? "Mouse and keyboard" : "Controller";
					
					Message( player, "Success: ", "Current inputmode: " + mode )
					return true
					
				} 
				catch ( errh ) 
				{		
					Message( player, "Failed", "Command failed because of: \n\n " + errh )
					return true		
				}
			
				return true
			}		
			case "input":	
			{
#if DEVELOPER			
				if ( args.len() < 1)
				{		
					Message( player, "Failed", "Param 1 of command 'input' requires player name/oid.")
					return true		
				}
				
				if ( args.len() < 2)
				{	
					Message( player, "Failed", "Param 2 of command 'input' requires type 0/1.")
					return true		
				}
						
				try 
				{	
					string str = args[2]
					string a_str = str
					
					if ( str == "mnk" ){ a_str = "0" }
					if ( str == "controller" ){ a_str = "1" }
					
					if ( !IsStringBool( a_str ) )
					{	
						Message( player, "Failed", "Incorrect usage, setting input using: " + a_str )
						return true	
					}
					
					bool newInputBool = StringToBool( a_str )
					entity selectPlayer =  GetPlayer( param )
					
					if ( !IsValid( selectPlayer ) )
					{
						Message( player, "Failed", "Player: " + param + " - is invalid. " )
						return true
					}
					
					const array<string> inputs = [ "MnK", "Controller" ]
					int currentInput = selectPlayer.p.input
					int newInput = newInputBool.tointeger()
					string sayInput = newInput > 0 ? inputs[ 1 ] : inputs [ 0 ] 
					
					if( newInput != currentInput )
					{
						selectPlayer.p.input = newInput							
						selectPlayer.Signal( "InputChanged" )						
						Message( player, "Success", "Player " + selectPlayer.GetPlayerName() + "  was changed to input: " + sayInput  )
						return true
					}
					else 
					{
						Message( player, "Failed", "Player is already input type: " + sayInput )
					}		
				} 
				catch( errj ) 
				{		
					Message( player, "Failed", "Command failed because of: \n\n " + errj )
					return true
				}
#endif 
				return true
			}		
			case "listhandles":
			{
				try 
				{
					string statement = "\n "
					
					foreach ( list_player in GetPlayerArray() )
					{
						int handle = list_player.GetEncodedEHandle()
						string p_name = list_player.GetPlayerName()
						
						statement += " Player: " + p_name + "   Handle: " + handle + "\n"
					}
					
					sqprint( statement )
					Message( player, "Handles:", statement, 20 )
					
					return true
				
				} 
				catch ( errk ) 
				{
					Message( player, "Failed", "Command failed because of: \n\n " + errk )
					return true		
				}
				
				return true
			}		
			case "map":
			{
				string map
				
				if( param == "" )
					map = GetMapName()
				else 
					map = FindMap( param )
				
				if( map == "" )
				{
					Message( player, "Map not found:", format( "Could not find map with \"%s\" in it`s name", param ) )
					sqerror( "Map not found:", param )
					return true
				}
				
				string playlist = GetCurrentPlaylistName()
				string errorMsg
				bool bIsPlaylistValid
						
				if( param2 != "" )
				{
					playlist = FindPlaylistName( param2 )
				
					if( playlist == "" )
						errorMsg = format( "Could not find a valid playlist via partial matching for criteria '%s'", param2 )
					else if( !GetPlaylistMaps( playlist ).contains( map ) )
						errorMsg = format( "Map '%s' not in playlist '%s' - rejecting cc map load", map, playlist )

					if( errorMsg != "" )
					{
						Message( player, "ERROR", errorMsg )
						sqerror( errorMsg )
						
						return true
					}
					
					string actionKey = "playlist_max_players"
					int requestedPlaylistMaxPlayers = GetMaxPlayersForPlaylistName( playlist )
					int currentConnectedPlayerCount = GetConnectedPlayerCount()
					
					if( !__AdminHasConfirmedAction( player, actionKey ) && requestedPlaylistMaxPlayers < currentConnectedPlayerCount )
					{
						int lostPlayers = currentConnectedPlayerCount - requestedPlaylistMaxPlayers
						string confirmMessage = format
						( 
							"The requested map change for map: '%s', Playlist: '%s' will lose some players.\nCurrent Player Count: %d\nMax Players for new playlist: %d\n[%d] players will not get in.\n\nIf this is acceptable, enter 'cc confirm' to proceed",
							map,
							playlist,
							currentConnectedPlayerCount,
							requestedPlaylistMaxPlayers,
							lostPlayers,	
							actionKey
						)
						
						string action = args.join( " " )
						AdminNeedsConfirmAction( player, actionKey, action )
						Message( player, "Notice:", confirmMessage )
						
						return true
					}
					
					bIsPlaylistValid = true
				}
				
				string gamemode = GameRules_GetGameMode()
				if( param3 != "" )
				{
					gamemode = FindModeName( param3 )
					if( gamemode == "" )
					{
						errorMsg = format( "Could not match '%s' to a gamemode", param3 )
						Message( player, errorMsg )
						sqerror( errorMsg )
						return true
					}
				}
					
				if( !DoesPlaylistSupportGamemode( playlist, gamemode ) )
				{
					errorMsg = format( "Playlist '%s' does not support gamemode '%s'", playlist, gamemode )
					Message( player, "Error:", errorMsg )
					sqerror( errorMsg )
					
					return true 
				}
				
				if( bIsPlaylistValid )
					Dev_CommandLineAddParm( "playlistOverride", playlist )
				
				printf( "Admin '%s' Changing to map: %s, Gamemode: %s, playlist: %s", player.GetPlatformUID(), map, gamemode, playlist != "" ? playlist : GetCurrentPlaylistName() )
				GameRules_ChangeMap( map, gamemode )
					
				return true
			}
			case "confirm":
			{
				array< string > storedCmdArgs = GetStoredAdminCommand( player )
				
				if( !storedCmdArgs.len() )
				{
					Message( player, "Invalid action", "No action was stored for confirm." )
					return true
				}
				
				Message( player, "Success", format( "Running command: %s", storedCmdArgs.join( " " ) ) )
				
				thread void function() : ( player, storedCmdArgs )
				{
					if( !IsValid( player ) )
						return 
						
					player.Signal( "ConfirmAction" )
					player.EndSignal( "ConfirmAction", "OnDestroy", "OnDisconnected" )
				
					wait 3
					
					ClientCommand_mkos_admin( player, storedCmdArgs )
				}()
						
				return true
			}
			case "playlist":
			{
				string playlistOverride = Dev_CommandLineParmValue( "playlistOverride" )
				
				string playlistConfig = format
				(
					"Active Playlist: %s\nActive Gamemode: %s\nActive Playlist Override:%s",
					GetCurrentPlaylistName(),
					GameRules_GetGameMode(),
					playlistOverride != "" ? playlistOverride : "{none}"
				)
				
				Message( player, "Current playlist config:", playlistConfig )
				return true
			}
			case "score":
			{
				if ( args.len() < 1 )
				{		
					Message( player, "Info", "Param 1 of command 'score' requires player name/oid/*/current/season/difference. \n\n Usage: score player | score * | score current")
					return true			
				}
				
				if ( param == "current" )
				{	
					Message( player, "Success", "'Current KD' server weight setting is:   " + getSbmmSetting( "current_kd_weight" ) )
					return true		
				}
				else if ( param == "season" )
				{	
					Message( player, "Success", "'season KD' server weight setting is:   " + getSbmmSetting( "season_kd_weight" ) )
					return true
				}
				else if ( param == "difference" )
				{	
					Message( player, "Success", "'KD matchmaking difference' server setting is:   " + getSbmmSetting( "SBMM_kd_difference" ) )
					return true
				}
			
				if ( param == "*" )
				{			
					try 
					{
						string putmsg = "Success"
						string s_data
						
						foreach ( score_player in GetPlayerArray() )
						{
							if ( !IsValid( score_player ) ) continue
							
							s_data += GetScore( score_player ) + "\n"
						}
						
						if( ( putmsg.len() + s_data.len() ) > 2800 )
						{
							Message( player, "Failed", "Cannot execute this command currently due to return data resulting in overflow" )
							return true
						}
					
						Message( player, putmsg, s_data, 20 )
					
					}
					catch ( errallscore ) 
					{
						Message( player, "Failed", "Command failed because of: \n\n " + errallscore )
						return true
					}
				}
				else
				{
					entity s_player = GetPlayer( param )
					
					if ( !IsValid( s_player ) )
					{	
						Message( player, "Failed", "Player: " + param + " -- is invalid" )
						return true
					}
					
					try 
					{
						Message( player, "Success", GetScore( s_player ) )	
					} 
					catch ( errscore ) 
					{
						Message( player, "Failed", "Command failed because of: \n\n " + errscore )
						return true			
					}
				
				}
				
				return true
			}
			case "scoreconfig":
			{
				if ( args.len() < 2 )
				{
					Message( player, "Failed", "Param 1 of command 'scoreconfig' requires type: current/season/difference." )
					return true
				}
				
				if ( args.len() < 3 )
				{	
					Message( player, "Failed", "Param 2 of command 'scoreconfig' requires float" )
					return true	
				}
				
				try 
				{			
					if ( !IsStringFloat( param2 ) )
					{
						Message( player, "Failed", "param 3 of command 'scoreconfig' must be numeric type float, \n\n example: 0.8 --            '" + param2 + "' was provided" )
						return true
					}
					
					if ( param == "current" )
					{	
						setSbmmSetting( "current_kd_weight", param2.tofloat() )		
					}
					else if ( param == "season" )
					{		
						setSbmmSetting( "season_kd_weight", param2.tofloat() )				
					}
					else if ( param == "difference" )
					{	
						setSbmmSetting( "SBMM_kd_difference", param2.tofloat() )	
					}
					else
					{
						Message( player, "Failed", "Invalid scoreconfig type: " + param )
						return true
					}	
					
					Message( player, "Success", "Weight for " + param + " KD -- was set to: " + param2 , 5 )
				
				} 
				catch ( errsetweight ) 
				{
					Message( player, "Failed", "Command failed because of: \n\n " + errsetweight )
					return true;			
				}
				
				return true
			}
			case "cleanuplogs":
			{
				#if TRACKER && HAS_TRACKER_DLL	
					TrackerCleanupLogs__internal()
					Message( player, "Success", "Internal logs cleanup process ran" )
					return true
				#endif
						
				return false
			}
			case "reload_config":
			{
				#if TRACKER && HAS_TRACKER_DLL	
					TrackerReloadConfig__internal()
					Message( player, "Success", "r5rdev_config.json was reloaded" )
					return true
				#endif
						
				return false
			}
			case "setting":
			{		
				#if TRACKER && HAS_TRACKER_DLL	
				
					const array<string> PROTECTED_SETTINGS =
					[
						"apikey", /* blocked at engine level */
						"webhooks.PLAYERS_WEBHOOK",
						"webhooks.MATCHES_WEBHOOK"
					]
				
					if ( args.len() < 2)
					{
						Message( player, "Failed", "Param 1 of command 'setting' requires key name" )
						return true
					}			
					
					if( param == "" )
					{
						Message( player, "Failed", "setting name cannot be empty" )
						return true
					}

					if( PROTECTED_SETTINGS.contains( param ) )
					{
						Message( player, "Failed", format( "Setting \"%s\" is a protected setting and cannot be shown.", param ) )
						return true
					}
					
					try 
					{	
						string return_str = ""
						return_str = TrackerGetSettingString( param )	
						
						Message( player, param + ":", return_str )
						return true
					} 
					catch ( errset ) 
					{			
						Message( player, "Failed", "Command failed because of: \n\n " + errset )
						return true		
					}
				
				#endif
						
				break
			}
			case "spamupdate":
			case "spam":
			{
				file.bStopUpdateMsg = false
				thread RunUpdateMsg()
				sqprint( "Update spam messages started" )
				
				break
			}
			case "spamstop":
			case "stopspam":
			{
				file.bStopUpdateMsg = true
				sqprint( "Update spam messages stopped" )
				
				break
			}
			case "msgall":
			{
				if ( args.len() < 2 )
				{
					Message( player, "Failed", "Param 1 of command 'msgall' requires string" )
					return true
				}
				
				try
				{	
					if( !SendServerMessage( param ) )
						Message( player, "Error", "Message was truncated")
					
					return true
				}
				catch ( errservermsg ) 
				{		
					Message( player, "Failed", "Command failed because of: \n\n " + errservermsg )
					return true		
				}
					
				break
			}	
			case "msg":
			{
				if ( args.len() < 2 )
				{
					Message( player, "Failed", "Param 1 of command 'msg' requires playername/uid" )
					return true
				}
				
				if( args.len() < 3 )
				{
					Message( player, "Failed", "Param 2 of command 'msg' requires string" )
					return true
				}
				
				if( param2 == "" )
				{
					Message( player, "Failed", "Cannot send empty message" )
					return true
				}
				
				try
				{	
					entity toPlayer = GetPlayer( param )
					if( !IsValid( player ) )
					{
						Message( player, "Error", format( "Player '%s' is invalud", param ) )
						return true
					}
					
					if( player == toPlayer )
					{
						Message( player, "Error", "Cannot send a message to yourself" )
						return true
					}
				
					if( !SendPM( player, toPlayer, param2 ) )
						Message( player, "Error", "Message was not sent" )
					
					return true
				}
				catch ( errservermsg ) 
				{		
					Message( player, "Failed", "Command failed because of: \n\n " + errservermsg )
					return true		
				}
				
				break
			}
			case "adminmsgall":
			{
				if( args.len() < 2 || param == "" )
				{
					Message( player, "Error", "Param 1 of adminmsgall requires string" )
					return true
				}
				
				foreach( sPlayer in GetPlayerArray() )
					AdminMessage( player, sPlayer, param )
					
				Message( player, "Message sent" )
				break
			}
			case "adminmsg":
			{
				if ( args.len() < 2 )
				{
					Message( player, "Failed", "Param 1 of command 'adminmsg' requires playername/uid" )
					return true
				}
				
				if( args.len() < 3 )
				{
					Message( player, "Failed", "Param 2 of command 'adminmsg' requires string" )
					return true
				}
				
				entity toPlayer = GetPlayer( param )
				if( !IsValid( toPlayer ) )
				{
					Message( player, "Failed", format( "Player '%s' is not valid.", toPlayer ) )
					return true 
				}
				
				if( !AdminMessage( player, toPlayer, param2 ) )
				{
					Message( player, "Failed", "Message was not sent" )
					return true
				}
				
				Message( player, format( "Admin message sent to '%s'", toPlayer.GetPlayerName() ) )
				break
			}
			case "vc":
			{
				if ( args.len() < 2)
				{
					Message( player, "Failed", "Param 1 of command 'vc' requires bool: 1/0 true/false on/off enabled/disabled")
					return true
				}
					
					
				try 
				{	
					switch( param )
					{	
						case "1":
						case "true":
						case "on":
						case "enabled":
							SetConVarBool( "sv_voiceenable", true )
							SetConVarBool( "sv_alltalk", true )
							
							if ( GetConVarBool( "sv_voiceenable" ) || GetConVarBool( "sv_alltalk" ) )
							{
								foreach ( active_player in GetPlayerArray() )
								{	
									Message( active_player, "VOICE CHAT ENABLED" )
								}
							}
							else 
							{
								Message( player, "FAILED" )
							}

							return true
							
						case "0":
						case "false":
						case "off":
						case "disabled":
							SetConVarBool( "sv_voiceenable", false )
							SetConVarBool( "sv_alltalk", false )
							
							if ( !GetConVarBool( "sv_voiceenable" ) || !GetConVarBool( "sv_alltalk" ) )
							{	
								foreach ( active_player in GetPlayerArray() )
								{	
									Message( active_player, "VOICE CHAT DISABLED" )
								}
							}
							else 
							{
								Message( player, "FAILED" )
							}
							
							return true		
					}
					
					Message( player, "INVALID SETTING" )
					return true
				} 
				catch ( errvc ) 
				{		
					Message( player, "Failed", "Command failed because of: \n\n " + errvc)
					return true		
				}
					
				break	
			}	
			case "startbr":
			{
				FlagSet( "MinPlayersReached" )	
				return true
			}	
			case "pos":
			{	
				#if DEVELOPER		
					if ( args.len() < 2 )
					{
						Message( player, "NEED TO NAME THE SPAWN" );
						return true
					}
					
					try 
					{
						POS_CC( player, param )
					}
					catch( pos_error )
					{
						Message( player, "Error", "Failed: " + pos_error )
					}

					return true
				#else
					return false
				#endif
			}
			case "groups":
			{
				Message( player, "\"groupsInProgress\"", Gamemode1v1_GetNumberOfGroupsInProgress().tostring() )
				return true
			}
			case "groupmap":
			{
				Message( player, "\"playerToGroupMap\"", Gamemode1v1_GetNumberOfPlayersInGroupMap().tostring() )
				return true
			}
			case "start_interval_thread":
			{
				#if TRACKER
					if( IsMessageBotIntervalThreadRunning() )
					{
						Message( player, "Interval thread is already running." )
						return true 
					}
					
					Message( player, "INTERVAL THREAD STARTING" )
					DEV_StartIntervalThread()
				#endif
				
				return true 
			}		
			case "kill_interval_thread":
			{		
				#if TRACKER
					svGlobal.levelEnt.Signal( "KillIntervalThread" ) 
					Message( player, "INTERVAL THREAD STOPPING" )
				#endif
				
				return true
			}		
			case "thumbsup":
			{	
				SendServerMessage(chat.effects["THUMBSUP"])		
				return true
			}	
			case "print_chat_effects":
			{
				#if DEVELOPER
					DEV_PrintAllChatEffects()
				#endif 
				
				return true
			}	
			case "msgeffect":
			{		
				SendServerMessage( Chat_FindEffect( param ) )
				return true
			}	
			case "nextmap":
			{
				Tracker_GotoNextMap()
				return true
			}
			case "fetchsetting":
			{
				#if TRACKER
					entity p = GetPlayer( param )
					
					if ( empty(param2) )
					{
						Message( player, "Parameter 2 was empty" )
						return true 
					}
					
					if( IsValid( p ) )
						Message( player, "Data for: " + param, Tracker_FetchPlayerData( p.p.UID, param2 ) )
					else 
						Message( player, "Error", format( "Player: %s was invalid", StringRemoveControlCharacters( param ) ), 7 )
					
					return true
				#endif
				
				return false
			}	
			case "testremote":
			{
				#if DEVELOPER
					Remote_CallFunction_NonReplay( player, "ServerCallback_SetPersistenceSettings", 1, 2, 3, 4)
					return true
				#endif
				
				return false
			}	
			case "acceptchal":
			{
				#if DEVELOPER
					entity p = GetPlayer( param )
					
					if ( !IsValid( p ) )
					{
						printt("Invalid player")
						return true
					}
					
					DEV_acceptchal(p)
					return true
				#endif 
				
				return false
			}	
			case "draw":
			{
				#if DEVELOPER 			
					printt("Drawing...")
					foreach( s_player in GetPlayerArray() )
					{
						Remote_CallFunction_ByRef( s_player, "Minimap_EnableDraw_Internal" )
						//Remote_CallFunction_NonReplay( s_player, "Minimap_EnableDraw_Internal")
					}
					
					return true
				#endif 
				
				return false 
			}	
			case "disabledraw":
			{
				#if DEVELOPER 		
					printt( "DisableDrawing..." )
					foreach( s_player in GetPlayerArray() )
						Remote_CallFunction_ByRef( s_player, "Minimap_DisableDraw_Internal" )
						
					return true 
				#endif 
				
				return false 
			}		
#if DEVELOPER			
			case "stoplog":
			{
				#if TRACKER && HAS_TRACKER_DLL
				
					bool ship = false 
					
					switch( param )
					{
						case "1":
						case "true":
						case "ship":
							ship = true 
							break
						
						default:
							break
					}
				
					DEV_ManualLogKill( ship )
					Message( player, "TRACKER LOG TERMINATED" )
					
				#endif
				
				return true
			}	
			case "startlog":
			{
				#if TRACKER && HAS_TRACKER_DLL
					if( bLog() )
					{
						DEV_ManualLogStart()
						Message( player, "LOG INITIALIZED" )
					}
					else 
					{
						Message( player, "TRACKER IS DISABLED" )
					}
				#endif
				
				return true
				
			}
#endif 
			case "mute":
			case "gag":
			{	
				entity mutePlayer = GetPlayer( param )				
				string reason = Chat_FindReasonInArgs( args )
				
				if( !IsValid( mutePlayer ) )
				{
					if( !IsStringNumber( param ) )
					{
						Message( player, "Error", "Invalid player & non-numeric uid." )
						return true
					}
					else 
					{
						Message( player, "Attempting Save", "Offline player is being saved to muted list: " + param )
					}
				}
				else 
				{
					LocalMsg( mutePlayer, "#FS_MUTED", "", eMsgUI.DEFAULT, 5, "", reason )
				}
					
				#if TRACKER
					Tracker_SetForceUpdatePlayerData() //does nothing if already set.
				#endif
				
				if( !Chat_ToggleMuteForAll( mutePlayer, true, true, args, -1, param, player ) )
					Message( player, "Failed" )
				else
					Message( player, "Muted " + param )
					
				if( args.contains( "-say" ) )
				{
					string muteMessage = format( "%s was muted for %s", mutePlayer.GetPlayerName(), reason )
					foreach( s_player in GetPlayerArray() )
					{
						if( s_player == mutePlayer )
							continue
							
						SendResponse( s_player, muteMessage )
					}
				}
				
				return true
			}
			case "unmute":
			case "ungag":
			{
				entity p = GetPlayer( param )				
				if( !IsValid( p ) )
				{
					if( !IsStringNumber( param ) )
					{
						Message( player, "Error", "Invalid player & non-numeric uid." )
						return true
					}
					else 
					{
						Message( player, "Attempting Save", "Offlie player is being saved unmuted: " + param )
					}
				}
				else 
				{
					if( !Chat_InMutedList( p.p.UID ) )
					{
						Message( player, "Failed", "Player is in server but not muted" )
						return true
					}
				}
					
				#if TRACKER
					Tracker_SetForceUpdatePlayerData() //does nothing if already set.
				#endif 
				
				string uid = IsValid( p ) ? p.p.UID : param
				if( Chat_ToggleMuteForAll( p, false, true, args, 0, "", player ) )
				{
					string reason = Chat_FindReasonInArgs( args )			
					LocalMsg( p, "#FS_UNMUTED", "", eMsgUI.DEFAULT, 5, "", reason )
					Message( player, "Player " + uid, "UNMUTED" )
				}
				else 
				{
					string msg
					if( empty( param2 ) )
						msg = " FAILED to Unmute."
					else if( IsValid( player ) )
						msg = " SET to Unmute."
					else 
						msg = " SAVED to be unmuted."
						
					Message( player, "Player " + uid, msg )
				}
				
				return true
			}	
			case "is_muted":
			case "is_gagged":
			{	
				entity p = GetPlayer( param )				
				if( !IsValid( p ) )
				{
					Message( player, "Invalid Player" )
					return true
				}
				
				//todo muted list fetch for server 
				
				string isMuted
				{
					string info
					isMuted = string( p.p.bTextmute )
					
					if( p.p.bTextmute )
						info += GetPlayerStatBool( p.p.UID, "globally_muted" ) ? " -- Global mute" : " -- Local mute"
						
					Message( player, "MUTED:", isMuted + info )
				}
				
				return true 
			}	
			case "mute_reason":
			case "gag_reason":
			{	
				entity p = GetPlayer( param )
				string uidLookup
				
				if( IsStringNumeric( param ) )
					uidLookup = param
					
				if( IsValid( p ) )
					uidLookup = p.p.UID
					
				string reason = Chat_GetMutedReason( uidLookup, p )	
				if( empty( reason ) && !IsValid( player ) && uidLookup.len() < 7 )
					reason = "Error during lookup: player was invalid. Possible mistake with uid?"
				
				Message( player, "MUTED REASON:", reason )
				return true
			}	
			case "unmute_time":
			case "ungag_time":
			{
				entity p = GetPlayer( param )
				string uidLookup
				
				if( IsStringNumeric( param ) )
					uidLookup = param
					
				if( IsValid( p ) )
					uidLookup = p.p.UID
					
				string unmuteTimestamp 	= Tracker_FetchPlayerData( uidLookup, "unmuteTime" )
				string timestring 		= "0"
				
				if( IsStringNumeric( unmuteTimestamp ) )
					timestring = Chat_ReadableExpiresTime( unmuteTimestamp.tointeger() )
				
				Message( player, "UNMUTE TIME: " + unmuteTimestamp, timestring )
				return true
			}	
			case "killme":
			{
				#if DEVELOPER
					if( IsAlive( player ) )
					{
						player.Die( null, null, { damageSourceId = eDamageSourceId.damagedef_suicide } )
					}
				#endif 	
				
				return true
			}			
			case "dmg":
			{
				#if DEVELOPER
					entity p = GetPlayer( param )
					
					if( IsValid( p ) )
					{
						if( IsStringNumeric( param2 ) )
						{
							int dmg = param2.tointeger()
							entity worldspawn = GetEnt( "worldspawn" )
							p.TakeDamage( dmg, worldspawn, worldspawn, {} )
						}
					}
				#endif 
			
				return true
			}
			case "movement_recorder_playback_rate":
			{
				if( IsStringNumeric( param ) )
				{
					MovementRecorder_SetPlaybackRate( float( param ) )
					Message( player, "Playback rate set to: " + param )
				}
				else 
				{
					Message( player, "Invalid playback rate specified" )
				}
				
				break
			}
			case "kill_banners":
			{
				WorldAssets_KillAllBanners()
				Message( player, "Banners stopped" )		
				break 
			}	
			case "start_banners":
			{
				WorldAssets_Restart()
				Message( player, "Banners restarted" )	
				break
			}	
			case "allow_legend_select":
			{
				if( empty( param ) )
				{
					Message( player, "Command 'allow_legend_select' requires paramater of [true|1] / [false|0]" )
					return true
				}
					
				bool result = false
				switch( param )
				{
					case "1":
					case "true":
						Gamemode1v1_SetAllowLegendSelect( true )
						result = true
						break
						
					case "0":
					case "false":
						Gamemode1v1_SetAllowLegendSelect( true )
						result = false
						break
						
					default:
						Message( player, "Invalid paramater" )
						return true
				}
				
				Message( player, "Legend Select was set to " + ( result ? "ENABLED" : "DISABLED" ) )
				break
			}	
			case "set_legend":
			{
				if( empty( param ) || !IsStringNumeric( param ) )
				{
					Message( player, "Command 'set_legend' requires numeric paramater for legend index" )
					return true
				}
				
				int index = param.tointeger()
				Gamemode1v1_SetAllPlayersLegend( index )
				break
			}
			case "endround":
			{
				EndRound()
				break
			}
				
			case "addmotd":
			{			
				if( empty( param ) )
				{
					Message( player, "Failed", "parameter 1 of 'addmotd' requires playername|uid" )
					return true 
				}
				
				if( empty( param2 ) )
				{
					Message( player, "Failed", "parameter 2 of 'addmotd' requires \"message in quotes\"" )
					return true
				}
				
				entity potentialPlayer = GetPlayer( param )
				if( !IsValid( potentialPlayer ) )
				{
					Message( player, "Player was invalid" )
					return true
				}
				
				Tracker_UpdateMOTDTextForPlayer( potentialPlayer, param2 )
				Message( player, "Success", format( "Message was prepended to player \"%s\" as: \n\n %s", string( potentialPlayer ), param2 ), 15 )
				
				break 
			}			
			case "restart_ws":
			{
				#if TRACKER 
					TrackerRestartWebsocket__internal() //useful if websocket server goes down for some reason and admin wants to manually reset connection from cc		
					Message( player, "Success", "Restarting websocket connection to r5r.dev" )
				#else
					return false
				#endif 
				
				break
			}
			case "timeout":  // criteria, toggle, timeoutAmount + -reason "reason" 
			{
				if( param == "" )
				{
					Message( player, "Error:", "Cmd timeout requires param 1 of playername/uid" )
					return true
				}
				
				entity timeoutPlayer = GetPlayer( param )
				if( !IsValid( timeoutPlayer ) )
				{
					Message( player, "Error:", "Player was invalid" )
					return true
				}
				
				if( param2 == "" )
				{
					Message( player, "Error: Cmd timeout requires param 2 of bool", "Should be replaced after the player name. Example: cc timeout [playername] true/false -r \"Bad boy\" 30 s -say" )
					return true
				}
				
				if( !IsStringBool( param2 ) )
				{
					Message( player, "Error:", "Param 2 was not a valid representation of bool. Example:  [true/false|1/0]" )
					return true
				}
				
				bool toggle = StringToBool( param2 )
				
				int timeoutAmount = ParseTimeString( ReturnParsableTimestringArgsAtIndex( args, 3 ) )			
				
				string reason = Chat_FindReasonInArgs( args )
				Timeout_SetPlayerTimedOut( timeoutPlayer, toggle, player.GetPlayerName(), timeoutAmount, reason )
							
				string readableExpiresTime = Chat_ReadableExpiresTime( Timeout_GetTimeoutExpiresTimestamp( timeoutPlayer ) )	
					
				string timeoutMessage = format( "%s was put in timeout for (%s)\nReason: %s", timeoutPlayer.GetPlayerName(), readableExpiresTime, reason != "" ? reason : "{empty}" )
				Message( player, "Success", timeoutMessage )
				
				if( args.contains( "-say" ) )
				{
					foreach( s_player in GetPlayerArray() )
					{
						if( s_player == timeoutPlayer )
							continue 
							
						SendResponse( s_player, timeoutMessage )
					}
				}
				
				if( args.contains( "-motd" ) )
					AdminCommandOpenMOTD( timeoutPlayer )
				
				break
			}
			case "gettimeout":
			{
				if( param == "" )
				{
					Message( player, "Error:", "Cmd gettimeout requires param 1 as [player/uid]" )
					return true
				}
				
				entity candidate = GetPlayer( param )
				if( !IsValid( player ) )
				{
					Message( player, "Error:", format( "Player '%s' was invalid.", param ) )
					return true
				}
				
				Message( player, "Info:", Timeout_PrintTimeoutData( candidate ), 15.0 )
				
				break
			}
			case "noclip":
			{
				if( !GetCurrentPlaylistVarBool( "enable_admin_noclip", false ) )
				{
					Message( player, "Failed", "Server operator has 'enable_admin_noclip' disabled" )
					return true 
				}
			
				if ( player.IsNoclipping() )
					player.SetPhysics( MOVETYPE_WALK )
				else
					player.SetPhysics( MOVETYPE_NOCLIP )
					
				break
			}
			case "disable_rotate":
			{
				if( param == "" || !IsStringBool( param ) )
				{
					Message( player, "Failed", format( "Param 1 of command \"%s\" requires bool 0|1|false|true", command ) )
					return true
				}
				
				string bSettingValue = StringToBool( param ) ? "true" : "false"
				Dev_CommandLineAddParm( "autoRotateForceDisable", bSettingValue )
				
				Message( player, "Success", format( "Force Auto map rotation was set to \"%s\"", bSettingValue ) )
				break
			}
			case "show_motd":
			{
				entity candidate = GetPlayer( param )
				if( !IsValid( candidate ) )
				{
					Message( player, "Error", "Invalid player " + param )
					break
				}
				
				if( !AdminCommandOpenMOTD( candidate ) )
					Message( player, "Error", "Player disconnected" )
				else
					Message( player, "Sent", "If the player has MOTD enabled they will see it popup,\n else they would need to manually view it from menu button" )
			
				break
			}
			//more...
			
			default:
			{	
				Message( player, "Usage", "cc #command #param1 #param2 #..." )
				return true
			}
		}
			
		return true
	}

void function RunUpdateMsg()
{		
	string update_title = GetCurrentPlaylistVarString( "update_title", "Server about to UPDATE" )
	string update_msg = GetCurrentPlaylistVarString( "update_msg", "Server will go down briefly" )
	
	while( !file.bStopUpdateMsg )
	{		
		foreach( player in GetPlayerArray() )
		{
			if ( !IsValid( player ) )
				continue
			
			Message( player, update_title, update_msg, 3 )
		}
		
		SendServerMessage( update_title )	
		wait 3.6
	}
}

bool function EnableVoice()
{
	if ( !GetConVarBool( "sv_voiceenable" ) || !GetConVarBool( "sv_alltalk" ) )
	{
		SetConVarBool( "sv_voiceenable", true )
		SetConVarBool( "sv_alltalk", true )
		
		if ( GetConVarBool( "sv_voiceenable" ) && GetConVarBool( "sv_alltalk" ) )
		{
			#if DEVELOPER 
				printt("voice enabled")
			#endif 
			
			return true
		}
	}
	
	return false
}



/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
/////////////////////////////					  ///////////////////////////
/////////////////////////////		UTILITY		  ///////////////////////////
/////////////////////////////					  ///////////////////////////
/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////


string function Concatenate( string str1, string str2 )  //cleanup
{	
	int str1_length = str1.len()
	int str2_length = str2.len()
	int dif
	string error
	
    if ( str1 == "" && str2 == "" ) 
	{
        return "";
    }

    if ( str1_length > 1000 ) 
	{
		dif = ( str1_length - 1000 )
		throw ("Error: First string exceeds length limit of 1000 by " + dif.tostring() + " chars")
    }
	
    if ( str2_length > 1000 ) 
	{	
		dif = ( str2_length - 1000 )
        throw ("Error: Second string exceeds length limit of 1000 by " + dif.tostring() + " chars")
    }
	
	if ( str2 != ""  )
	{
		str2 = "," + str2;	
	}
	
    return str1 + str2;
}

bool function IsStringNumber( string str ) 
{
	if ( str.len() == 0 )
		return false
	
    int start = ( str[0] == '-' && str.len() > 1 ) ? 1 : 0    
	bool dot = false
	
	for ( int i = start; i < str.len(); i++ ) 
	{
		if (str[i] == '.')
		{
			if( dot )
				return false
			else 
				dot = true
		} 
		else if ( str[i] < '0' || str[i] > '9' )
			return false
    }
	
    return true
}

bool function IsStringNumber2( string str )
{
	return DoesMatchRegexp( str, "^-?(\\d+\\.\\d+|\\d+)$" ) 
}

array<float> s_unitTestArr1
void function RegExpUnitTest( string str )
{
	mAssert( IsThreadTop(), "Thread this function" )
	
	int iter = 0	
	bool test
	
	TimerStart()
	while( iter < 100000 )
	{
		test = IsStringNumber2( str )
		iter++
	}
	
	float finish = TimerEnd()
	s_unitTestArr1.append( finish )
	
	printt( "Unit test1; regexp; 100000 iterations: ms:", finish, ";Criteria:", str )
	
	if( s_unitTestArr1.len() > 5 )
	{
		float total
		foreach( float entry in s_unitTestArr1 )
		{
			printt( "entry =", entry )
			total += entry
		}
			
		float avg = total / 6
		printt( "Unit test 1 avg = ms", avg )
		
		s_unitTestArr1.clear()
	}
}


array<float> s_unitTestArr2
void function RegExpUnitTest2( string str )
{
	mAssert( IsThreadTop(), "Thread this function" )
	
	int iter = 0	
	bool test
	
	TimerStart()
	while( iter < 100000 )
	{
		test = IsStringNumber( str )
		iter++
	}
	
	float finish = TimerEnd()
	s_unitTestArr2.append( finish )
	
	printt( "Unit test1; custom; 100000 iterations: ms:", finish, ";Criteria:", str )
	
	if( s_unitTestArr2.len() > 5 )
	{
		float total
		foreach( float entry in s_unitTestArr2 )
		{
			printt( "entry =", entry )
			total += entry
		}
			
		float avg = total / 6
		printt( "Unit test 2 avg ms =", avg )
		
		s_unitTestArr2.clear()
	}
}

array<float> s_unitTestArr3
void function StringUnitTest( string str )
{
	mAssert( IsThreadTop(), "Thread this function" )
	
	int iter = 0	
	bool test
	
	TimerStart()
	while( iter < 100000 )
	{
		test = IsSafeString( str )
		iter++
	}
	
	float finish = TimerEnd()
	s_unitTestArr3.append( finish )
	
	printt( "Unit test3; regexp IsSafeString; 100000 iterations: ms:", finish, ";Criteria:", str )
	
	if( s_unitTestArr3.len() > 5 )
	{
		float total
		foreach( float entry in s_unitTestArr3 )
		{
			printt( "entry =", entry )
			total += entry
		}
			
		float avg = total / 6
		printt( "Unit test 3 avg ms =", avg )
		
		s_unitTestArr3.clear()
	}
}

int function stringcmp( string a, string b ) 
{
    if ( a.len() != b.len() )
		return a.len() < b.len() ? -1 : 1
	
    for ( int i = 0; i < a.len(); ++i ) 
	{
		if ( a[i] != b[i] )
			return a[i] < b[i] ? -1 : 1
	}

    return 0
}

bool function IsStringNumeric( string str, int ornull min = null, int ornull max = null )
{
	string minStr = min == null ? "-2147483647" : expect int ( min ).tostring()
	string maxStr = max == null ? "2147483647" : expect int ( max ).tostring()
	
	if ( !IsStringNumber( str ) ) 
        return false
    
    if ( str[0] == '-' ) 
	{
        if ( stringcmp( str.slice( 1 ), minStr.slice( 1 ) ) > 0 ) 
            return false
    }
	else 
	{
        if ( stringcmp( str, maxStr ) > 0 ) 
            return false
    }

    //sqprint( format( "%s", str ) )
    return true
}


bool function IsStringFloat( string str, float min = INT_MAX, float limit = INT_MIN )  //cleanup
{
	if ( str.len() == 0 ) 
		return false
	
	for ( int i = 0; i < str.len(); i++ ) 
	{
		var c = str[i]
		if ( !( ( c >= '0' && c <= '9' ) || ( c == '.' && i != 0 ) || ( c == '-' && i == 0 ) ) ) 
			return false
	}
	
	float num = 0.0
	try { num = str.tofloat() } catch ( outofrange ){ return false }	
	return ( num >= min && num <= limit )
}

string function LineBreak( string str, int interval = 80 )
{
	string output = ""
	
	for ( int i = 0; i < str.len(); ) 
	{
		int end = i + interval
		
		if ( end >= str.len() ) 
		{
			output += str.slice( i ) + "\n"
			break
		}
		
		bool located_space = false
		
		for ( int j = end; j > i; --j ) 
		{
			if ( str.slice( j-1, j ) == " " ) 
			{
				end = j
				located_space = true
				break
			}
		}
		
		if ( !located_space ) 
			end = i + interval

		output += str.slice( i, end ) + "\n"
		i = end
	}
	
	return output
}

bool function IsStringBool( string str )
{
	switch( str )
	{
		case "0":
		case "1":
		case "true":
		case "false":		
			return true 
		
		default:
			return false 
	}
	
	unreachable
}

bool function StringToBool( string str )
{	
	switch( str )
	{
		case "0":
		case "false":
			return false 
			
		case "1":
		case "true":
			return true 
			
		default:
			mAssert( IsStringBool( str ), "Tried to convert \"%s\" to bool. Should have used IsStringBool() on criteria before calling", str )
	}
	
	return false
}

entity function GetPlayerEntityByName( string name ) //deprecate use universal lookup for both name/uid
{	
	entity p	
	name = name.tolower()
	
	foreach ( player in GetPlayerArray() )
	{
		if ( player.GetPlayerName().tolower() == name )	
			return player
	}
	
	if( file.bAllowLooseNameComp )
		p = GetPlayerEntityByName_Loose( name )	
		
	return p
}

entity function GetPlayerEntityByName_Loose( string name )
{
	string candidate
	foreach( player in GetPlayerArray() )
	{
		candidate = player.GetPlayerName().tolower()
		if( candidate.find( name ) != -1 )
			return player
	}
	
	entity invalid 
	return invalid
}

void function CheckAdmin_OnConnect( entity player )
{
	if( !IsValid( player ) ) 
		return
	
	if( IsServerAdmin( player.GetPlatformUID() ) ) //use new oid list
	{
		player.SetPlayerNetBool( "IsAdmin", true )
		Remote_CallFunction_UI( player, "UICallback_AdminStatus", true )
		
		//printw( "CheckAdmin_OnConnect ADMIN DETECTED", player.GetPlayerName(), "IsAdmin netvar = TRUE, and UI VM var set" )
	} else
		Remote_CallFunction_UI( player, "UICallback_AdminStatus", false ) //refresh
}

bool function IsAuthEnabled()
{
	return GetConVarInt( "sv_onlineAuthEnable" ) == 1
}

//Todo: Lookup fromthe table of oid -> playerdata, include .entity (this gets created when a player joins once. )

entity function GetPlayerEntityByUID( string str )
{
	entity candidate
	
	#if TRACKER //Todo: direct global hook in client connected and lookups for name/uid to struct of name,uid,entity,etc
		// #if DEVELOPER
			// if( empty( str ) )
			// {
				// mAssert( false, "Empty uid passed to " + FUNC_NAME() + "()" + ( Flowstate_IsTrackerSupportedMode() ? "" : " -- Try ading mode to TrackerSupportedMode list if adding new stats and testing." ) )
				// return null
			// }
		// #endif

		if( !empty( str ) && Tracker_IsPlayerMetricsInitialized( str ) )	
			return Tracker_StatsMetricsByUID( str ).ent
	#else
		
		if ( !IsStringNumber( str ) )
			return candidate
		
		foreach ( player in GetPlayerArray() )
		{
			if ( !IsValid( player ) )
				continue

			if ( player.GetPlatformUID() == str )
				return player	
		}

	#endif
	
	return candidate
}

entity function GetPlayer( string str ) //todo:deprecate
{
	entity candidate = GetPlayerEntityByUID( str )
	
	if( IsValid( candidate ) )
		return candidate
		
	return GetPlayerEntityByName( str )	
}

string function FindMap( string query )
{
	foreach( mapname in AllMapsArray() )
	{
		if( mapname.find( query ) != -1 )
			return mapname
	}
	
	return ""
}

string function FindPlaylistName( string str )
{
	array<string> registeredPlaylists = AllPlaylistsArray() //includes custom
	
	foreach( string playlist in registeredPlaylists )
	{
		if( playlist.find( str ) != -1 )
			return playlist
	}
	
	return ""
}

string function FindModeName( string str )
{
	array<string> registeredModes = AllGamemodesArray()
	
	foreach( string gamemode in registeredModes )
	{
		if( gamemode.find( str ) != -1 )
			return gamemode
	}
	
	return ""
}

bool function IsControlCharacter( string c ) 
{
	var byte = c[ 0 ]
	return ( byte >= 0 && byte <= 31) || byte == 127	
}

string function StringRemoveControlCharacters( string str )
{
	string sanitized = ""

	for ( int i = 0; i < str.len(); i++ ) 
	{
		string c = str.slice( i, i + 1 )

		if ( IsControlCharacter(c) ) 
			continue	
		else 
			sanitized += c
	}

	return sanitized
}

//Returns false on limited. 
bool function CheckRate( entity player, string key = DEFAULT_RATE_KEY, float rate = COMMAND_RATE_LIMIT, bool notify = NOTIFY_RATELIMIT_FAILED )
{	
	if ( !IsValid( player ) ) 
		return false 
			
	if( !( key in player.p.rateLimitTable ) )
		player.p.rateLimitTable[ key ] <- 0
			
	if ( Time() - player.p.rateLimitTable[ key ] <= rate )
	{
		if( notify )
			LocalEventMsg( player, "#FS_CMD", "", 2 )
			
		return false
	}
	
	player.p.rateLimitTable[ key ] = Time()	
	return true
}

void function ResetRate( entity player, string key = DEFAULT_RATE_KEY )
{
	if( !( key in player.p.rateLimitTable ) )
		player.p.rateLimitTable[ key ] <- 0.0
	else		
		player.p.rateLimitTable[ key ] = 0.0
}

#if SERVER	
bool function IsServerAdmin( string uid )
{	
	return file.adminsArray.contains( uid )
}
#endif //SERVER

int function WeaponToIdentifier( string weaponName )
{
	if( !IsWeaponValid( weaponName ) ) 
	{
		string err = format( "#^ Unknown weaponName !DEBUG IT! -- weapon: %s", weaponName )
		
		#if TRACKER && HAS_TRACKER_DLL
			if( bLog() && TrackerIsLogging__internal() )
				TrackerLogEvent__internal( err, bEnc() )
		#endif
		
		sqerror(err)	
		return 2
	}
	
	return file.tbl_weaponIdentifiers[ weaponName ]
}

bool function IsWeaponValid( string weaponref )
{
	return ( weaponref in file.tbl_weaponIdentifiers )
}

void function DEV_PrintTrackerWeapons()
{
	string prnt = "\n\n ---------- TRACKER WEAPON IDENTIFIERS --------- \n\n";
	
	foreach( weapon, id in file.tbl_weaponIdentifiers )
	{
		prnt += format( "[\"%s\"] = %d, \n", weapon, id )
	}
	
	printt( prnt )
}

table<string, int> function TrackerWepTable() 
{
    return file.tbl_weaponIdentifiers
}

bool function ShouldExcludeDamageSourceShipping( int weaponSource )
{
	return !DamageSourceIDHasString( weaponSource )
}

string function ParseWeapon( string weaponString )
{
	array<string> mods = split( strip( weaponString ), " " )
	
	if( !mods.len() )
		return ""
	
	if( !IsWeaponValid( mods[ 0 ] ) || !( SURVIVAL_Loot_IsRefValid( mods[ 0 ] ) ) )
		return ""
	
	bool removed = false
	for ( int i = mods.len() - 1 ; i >= 1; i-- )
	{
		if ( !SURVIVAL_Loot_IsRefValid( mods[ i ] ) )
		{
			removed = true
			sqprint( "removed invalid ref:", mods[ i ] )		
			mods.remove( i )
		}
		else if( !IsModValidForWeapon( mods[ 0 ], mods[ i ] ) )
		{
			removed = true
			sqprint( format( "removed invalid mod \"%s\" for weapon \"%s\" )", mods[ i ], mods[ 0 ] ) )	
			mods.remove( i )
		}
		else if( SURVIVAL_Loot_IsRefDisabled( mods[ i ] ) )
		{
			removed = true
			sqprint( format( "removed disabled ref \"%s\"", mods[ i ] ) )		
			mods.remove( i )
		}
	}
	
	
	if ( removed )
		PrintSupportedAttachpointsForWeapon( mods[ 0 ] )
	
	return mods.join( " " )
}

bool function IsModValidForWeapon( string weaponref, string mod )
{	
	array<string> attachPoint = GetAttachPointsForAttachment( mod )
	LootData wData = SURVIVAL_Loot_GetLootDataByRef( weaponref )	
	
	return ( wData.supportedAttachments.contains( attachPoint[ 0 ] ) 
	&& !wData.disabledAttachments.contains( attachPoint[ 0 ] ) )
}

void function PrintSupportedAttachpointsForWeapon( string weaponref )
{
	LootData wData = SURVIVAL_Loot_GetLootDataByRef( weaponref )	
	string debug = format( "\n --- Attachment List for %s --- \n", weaponref )
	
	int i = 1	
	foreach( supported in wData.supportedAttachments )
	{
		debug += format( "%d. %s \n", i, supported )
		i++
	}
	
	sqprint( debug )
}

#if TRACKER && HAS_TRACKER_DLL
	void function PrintMatchIDtoAll()
	{
		string matchID = format( "\n\n Server stats enabled @ www.r5r.dev, \n round: %d - MatchID: %s \n ", GetCurrentRound(), TrackerMatchID__internal() )
		thread
		(
			void function() : ( matchID )
			{
				wait 1 //idk
				CenterPrintAll( matchID )
			}
		)()
	}	
#endif

//Defaults: space and:  A-Z  a-z  0-9  _    [  ]  (  )  :  ;  -  *  &  ^  %  $  #  @  ! + = ? . |
bool function IsSafeString( string str, int strlen = -1, string pattern = "" ) 
{
	if( empty( str ) )
		return true
		
	if( strlen != -1 && str.len() > strlen )
		return false
	
	if( pattern == "" )
		pattern = "^[A-Za-z0-9_ \\[\\]\\(\\):;\\-*&^%$#@!+=?.|]*$"
	
	return ( RegexpFindAll( str, pattern ).len() != 0 )
}

//original by maki
void function TP( entity player, LocPair data )
{
	if( !IsValid( player ) ) 
		return
		
	player.SetVelocity( Vector( 0,0,0 ) )
	player.SetAngles( data.angles )
	player.SetOrigin( data.origin )
}

string function Tracker_DetermineNextMap()
{
	string to_map = GetMapName()
	int countmaps = GetCurrentPlaylistMapsCount()

	for ( int i = 0; i < countmaps; i++ )
	{
		string foundMap = GetCurrentPlaylistGamemodeByIndexMapByIndex( 0, i )
		
		if ( to_map == foundMap ) 
		{
			int index = (i + 1) % countmaps
			to_map = GetCurrentPlaylistGamemodeByIndexMapByIndex( 0, index )
			break
		}
	}
	
	return to_map
}

void function Tracker_GotoNextMap()
{
	if( IsMapPlaylistGamemodeRotationEnabled() )
	{
		DecideNextMapPlaylistGamemodeRotation()
		return
	}

	string to_map = Tracker_DetermineNextMap()
	sqprint( "Changing map to: " + to_map + " - Mode: " + GameRules_GetGameMode() )
	GameRules_ChangeMap( to_map, GameRules_GetGameMode() )	
}

string function PrepareForJson( string data ) 
{
	if( !empty( data ) )
	{
		data = StringReplace( data, "\"", "\\\"" )
		data = StringReplace( data, "'", "\\'" )
		data = StringReplace( data, "\n", "\\n" ) 
		data = StringReplace( data, "\r", "\\r" ) 
		data = StringReplace( data, "\t", "\\t" )
	}
	
    return data
}

array<int> function ArrayUniqueInt( array<int> arr )
{
	array<int> newArr
	
	foreach( item in arr )
	{
		if( !newArr.contains( item ) )
			newArr.append( item )
		#if DEVELOPER && ( false )
		else
			printw( "ArrayUniqueInt: item", item, "was a duplicate and omitted" )
		#endif			
	}
	
	return newArr
}

array<string> function ArrayUniqueString( array<string> arr )
{
	array<string> newArr
	
	foreach( item in arr )
	{
		if( !newArr.contains( item ) )
			newArr.append( item )	
	}
	
	return newArr
}

void function sqprint( ... )
{
	if ( vargc <= 0 )
		return

	string msg
	for ( int i = 0; i < vargc; i++ )
		msg += format( " %s", string( vargv[ i ] ) )

	#if HAS_TRACKER_DLL
		sqprint__internal( msg )
	#else 
		printl( msg )
	#endif
}

void function sqerror( ... )
{
	if ( vargc <= 0 )
		return

	string msg
	for ( int i = 0; i < vargc; i++ )
		msg += format( " %s", string( vargv[ i ] ) )

	#if HAS_TRACKER_DLL
		sqerror__internal( msg )
	#else 
		printl( msg )
	#endif
}

void function sqwarning( ... ) //changed to work as format 
{
	if ( vargc <= 0 )
		return

	string errorMsg = expect string ( vargv[0] )
	
	array vars = [ this, errorMsg ] 
	for( int i = 1; i < vargc; i++ )
		vars.append( vargv[ i ] )
	
	errorMsg = expect string ( format.acall( vars ) )	

	#if HAS_TRACKER_DLL
		sqwarning__internal( errorMsg )
	#else
		Warning( errorMsg )
	#endif
}

int function GetWeaponSettingIntFromFile( string weaponRef, string setting )
{
	var data = GetWeaponInfoFileKeyField_Global( weaponRef, setting ) 

	if( data != null )
		return expect int( data )
	
	#if DEVELOPER
		printw( "Invalid weapons settings for", weaponRef, setting )
	#endif 
	
	return 0
}

string function ConvertVarStatValuetoString( var stat )
{
	string statType = typeof stat
	switch( statType )
	{
		case "string":
			return expect string( stat )
		case "int":
			return expect int( stat ).tostring()
		case "bool":
			return expect bool( stat ).tostring()
		case "float":
			return expect float( stat ).tostring()
		case "null":
			return "INVALID_STAT"
		
		default:
			mAssert( 0, "Stat type %s cannot be implicitely converted to string", statType )
	}
	
	return "~error~"
}

const int STAT_PREFIX_POS = 6
const int SETTING_PREFIX_POS = 9
string function GetFormatterValueForPlayer( entity player, string formatter )
{	
	if( !IsValid( player ) )
		return "INVALID_PLAYER"

	switch( formatter )
	{
		case "#player":
			return player.GetPlayerName()
			
		case "#uid":
			return player.GetPlatformUID()
			
		case "#ping":
			return ( player.GetLatency() * 1000 ).tostring()
			
		default: 
			if( formatter.find( "#stat_" ) == 0 )
			{
				string statKey = formatter.slice( STAT_PREFIX_POS, formatter.len() )
				if( statKey == "" )
					mAssert( 0, "Stat key formatter '%s' was incomplete", formatter )
					
				return ConvertVarStatValuetoString( Stats__RawGetStat( player.p.UID, statKey ) )
			}
			
			if( formatter.find( "#setting_" ) == 0 )
			{
				string settingKey = formatter.slice( SETTING_PREFIX_POS, formatter.len() )
				if( settingKey == "" )
					mAssert( 0, "Setting key formatter '%s' was incomplete", formatter )
					
				return Tracker_FetchPlayerData( player.p.UID, settingKey )
			}
	}
	
	return formatter
}

string function ResolveFormattersForPlayerMessage( entity player, string message )
{
	return RegexpReplaceFuncPlayer
	( 
		message, 
		"#[A-Za-z0-9_]+", 
		
		string function( array<string> captures, entity player = null )
		{
			return GetFormatterValueForPlayer( player, captures[ 0 ] )
		},
		player
	)
}

const SYSTEM_RESPONSE = "System"
bool function SendResponse( entity player, string msg, bool bAdmin = false )
{
	if( !IsValid( player ) )
		return false
		
	player.SendServerTextMessage( SYSTEM_RESPONSE, msg, bAdmin )
	
	return true
}

void function BroadcastResponse( string msg, bool bAdmin = false )
{
	BroadcastServerTextMessage( SYSTEM_RESPONSE, msg, bAdmin )
}

bool function SendPM( entity fromPlayer, entity toPlayer, string msg )
{
	if( !IsValid( fromPlayer ) || ( !IsValid( toPlayer ) ) )
		return false
		
	if( fromPlayer == toPlayer )
		return false
		
	string fromName = format( "PM From: %s", fromPlayer.GetPlayerName() )
	toPlayer.SendServerTextMessage( fromName, ResolveFormattersForPlayerMessage( toPlayer, msg ), false )
	
	string toMessage = format( "Message sent to %s", toPlayer.GetPlayerName() )	
	SendResponse( fromPlayer, toMessage )
	
	return true
}

bool function AdminMessage( entity fromAdmin, entity toPlayer, string msg )
{
	if( !IsValid( toPlayer ) )
		return false
		
	string formattedName = format( "ADMIN: %s", fromAdmin.GetPlayerName() )
	toPlayer.SendServerTextMessage( formattedName, ResolveFormattersForPlayerMessage( toPlayer, msg ), true )
	
	return true
}

void function CodeCallback_SendMessage( string criteria, string fromWebPanelUser, string message, bool bToAll )
{
	string formattedName = format( "ADMIN: %s", fromWebPanelUser )
	
	if( bToAll )
	{
		BroadcastServerTextMessage( formattedName, message, true )
		return
	}
	
	entity candidate = GetPlayer( criteria )
	if( !IsValid( candidate ) )
		return 
		
	candidate.SendServerTextMessage( formattedName, message, true )
}

array<string> function ReturnParsableTimestringArgsAtIndex( array<string> args, int index )
{	
	array<string> returnArgs
	if( index <= 0 || args.len() <= index )
		return returnArgs
	
	int argLen = args.len()
	for( int i = index; i < argLen; i++ )
		returnArgs.append( args[ i ] )
		
	return returnArgs
}

string function UnescapeWithRules( string s, ParseRules rules )
{
	string out = ""
	int i = 0

	while ( i < s.len() )
	{
		if ( i + 1 < s.len() && s.slice( i, i + 1 ) == rules.escapeChar )
		{
			string next = s.slice( i + 1, i + 2 )

			if ( next in rules.escapeMap )
			{
				out += rules.escapeMap[ next ]
				i += 2
				continue
			}
		}

		out += s.slice( i, i + 1 )
		i++
	}

	return out
}

array<string> function SplitUnescapedWithRules( string s, string delimiter, ParseRules rules )
{
	mAssert( delimiter.len() == 1 )

	array<string> parts
	string current = ""

	int i = 0
	while ( i < s.len() )
	{
		if ( i + 1 < s.len() && s.slice( i, i + 1 ) == rules.escapeChar )
		{
			current += s.slice( i, i + 2 )
			i += 2
			continue
		}

		if ( s.slice( i, i + 1 ) == delimiter )
		{
			parts.append( current )
			current = ""
			i++
			continue
		}

		current += s.slice( i, i + 1 )
		i++
	}

	parts.append( current )
	return parts
}

int function FindFirstUnescaped( string s, string delimiter, ParseRules rules )
{
	mAssert( delimiter.len() == 1 )

	int i = 0
	while ( i < s.len() )
	{
		if ( i + 1 < s.len() && s.slice( i, i + 1 ) == rules.escapeChar )
		{
			i += 2
			continue
		}

		if ( s.slice( i, i + 1 ) == delimiter )
			return i

		i++
	}

	return -1
}

void function AdminNeedsConfirmAction( entity player, string actionKey, string action )
{
	string uid = __EnsureAdminConfirmTable( player, actionKey )
	file.tbl_adminConfirmations[ uid ][ actionKey ] = action
}

bool function __AdminHasConfirmedAction( entity player, string actionKey )
{
	string uid = __EnsureAdminConfirmTable( player, actionKey )
	return file.tbl_adminConfirmations[ uid ][ actionKey ] != ""
}

array< string > function GetStoredAdminCommand( entity player )
{
	array< string > args
	string uid = player.GetPlatformUID()
	if( !( uid in file.tbl_adminConfirmations ) )
		return args
	
	string actionKey = file.tbl_adminConfirmations[ uid ][ "last_action_key" ]	
	if( actionKey == "" )
		return args
		
	if( !__AdminHasConfirmedAction( player, actionKey ) )
		return args
		
	string command = file.tbl_adminConfirmations[ uid ][ actionKey ]
	return split( command, " " )
}

string function __EnsureAdminConfirmTable( entity player, string actionKey )
{
	string uid = player.GetPlatformUID()
	
	if( !( uid in file.tbl_adminConfirmations ) )
	{
		table< string, string > confirmations
		file.tbl_adminConfirmations[ uid ] <- confirmations
	}
	
	if( !( "last_action_key" in file.tbl_adminConfirmations[ uid ] ) )
		file.tbl_adminConfirmations[ uid ][ "last_action_key" ] <- actionKey
	else 
		file.tbl_adminConfirmations[ uid ][ "last_action_key" ] = actionKey
	
	if( !( actionKey in file.tbl_adminConfirmations[ uid ] ) )
		file.tbl_adminConfirmations[ uid ][ actionKey ] <- ""
		
	return uid
}

array<string> function GetGamemodesForPlaylist( PlaylistName playlist )
{
	array< string > modesArray

	int numModes = GetPlaylistGamemodesCount( playlist )
	for ( int modeIndex = 0; modeIndex < numModes; modeIndex++ )
		modesArray.append( GetPlaylistGamemodeByIndex( playlist, modeIndex ) )

	return modesArray
}

bool function DoesPlaylistSupportGamemode( PlaylistName playlist, string gamemode )
{
	return GetGamemodesForPlaylist( playlist ).contains( gamemode )	
}

const string ERROR_STR = "{error}"
void function AutoMapPlaylistGamemodeRotationInit( string autoRotateList )
{
	array< string > rotationList = split( autoRotateList, "," )
	if( !rotationList.len() )
		return
		
	int entryIdx = 0
	foreach( string entry in rotationList )
	{
		++entryIdx
		
		entry = strip( entry )
		array< string > args = split( entry, " " ) // [ "map", "playlist", "gamemode", "5" ]
		
		PlaylistGamemodeRotateData thisRotationData
		int rotationParamsLen = args.len()
		
		if( rotationParamsLen == 0 )
		{
			string errorMsg = format
			(
				"Rotation data #[%d] was empty",
				entryIdx
			)
		
			__AppendRotationErrorDataMessage( thisRotationData, errorMsg )
			continue
		}
		
		for( int i = 0; i < rotationParamsLen; i++ )
		{	
			string rotateParam = strip( args[ i ] )
			switch( i )
			{
				case 0:	
				{
					string map = FindMap( rotateParam )
					if( map == "" )
					{
						__CouldNotMatchMessage( thisRotationData, entryIdx, "map", rotateParam, i, entry )
						thisRotationData.map = ERROR_STR
						break 
					}
					
					thisRotationData.map = map
					break
				}
				case 1:
				{
					string playlist = FindPlaylistName( rotateParam )
					if( playlist == "" )
					{
						__CouldNotMatchMessage( thisRotationData, entryIdx, "playlist", rotateParam, i, entry )
						thisRotationData.playlist = ERROR_STR
						break
					}
				
					thisRotationData.playlist = playlist
					break
				}	
				case 2: 
				{
					string gamemode = FindModeName( rotateParam )
					if( gamemode == "" )
					{
						__CouldNotMatchMessage( thisRotationData, entryIdx, "gamemode", rotateParam, i, entry )
						thisRotationData.gamemode = ERROR_STR
						break
					}
					
					thisRotationData.gamemode = gamemode
					break
				}
				case 3: 
				{
					if( !IsStringNumber( rotateParam ) )
					{
						string errorMsg = format
						(
							"Rotation data #[%d] expected an integer(number) for minplayers param 4 -- Got: '%s'. For Entry: '%s'",
							entryIdx,
							rotateParam,
							entry
						)
					
						__AppendRotationErrorDataMessage( thisRotationData, errorMsg )
						break
					}
					
					thisRotationData.minplayers = rotateParam.tointeger()
					break
				}
				case 4: 
				{
					if( !IsStringNumber( rotateParam ) )
					{
						string errorMsg = format
						(
							"Rotation data #[%d] expected an integer(number) for maxplayers param 5 -- Got: '%s'. For Entry: '%s'",
							entryIdx,
							rotateParam,
							entry
						)
					
						__AppendRotationErrorDataMessage( thisRotationData, errorMsg )
						break
					}
					
					thisRotationData.maxplayers = rotateParam.tointeger()
					break
				}
				default:
				{
					string errorMsg = format
					(
						"Rotation data #[%d] contained an extra argument: '%s'. For Entry: '%s'",
						entryIdx,
						rotateParam,
						entry
					)
					
					__AppendRotationErrorDataMessage( thisRotationData, errorMsg )	
					break
				}
			} //switch		
		} // rotation params for loop
		
		if( thisRotationData.playlist == "" )
			thisRotationData.playlist = GetCurrentPlaylistName()
			
		if( thisRotationData.map == "" )
			thisRotationData.map = GetMapName()
			
		if( thisRotationData.gamemode == "" )
			thisRotationData.gamemode = GameRules_GetGameMode()
			
		int maxPlaylistPlayers = GetPlaylistVarInt( thisRotationData.playlist, "max_players", 129 )
		if( thisRotationData.maxplayers <= 0 )
			thisRotationData.maxplayers = maxPlaylistPlayers >= 0 ? maxPlaylistPlayers : 129
			
		int minPlaylistPlayers = GetPlaylistVarInt( thisRotationData.playlist, "min_players", 0 )
		if( thisRotationData.minplayers <= 0 )
			thisRotationData.minplayers = minPlaylistPlayers >= 0 ? minPlaylistPlayers : 0
			
		if( thisRotationData.playlist != ERROR_STR && thisRotationData.map != ERROR_STR )
		{
			if( !GetPlaylistMaps( thisRotationData.playlist ).contains( thisRotationData.map ) )
			{
				string errorMsg = format
				( 
					"Error in rotation data #[%d]: Map '%s' is not in playlist '%s'. For Entry: '%s'",
					entryIdx,
					thisRotationData.map,
					thisRotationData.playlist, 
					entry
				)
				
				__AppendRotationErrorDataMessage( thisRotationData, errorMsg )	
			}
		
			if( !DoesPlaylistSupportGamemode( thisRotationData.playlist, thisRotationData.gamemode ) )
			{
				string errorMsg = format
				( 
					"Error in rotation data #[%d]: Playlist '%s' does not support gamemode '%s'. For Entry: '%s'",
					entryIdx,
					thisRotationData.playlist,
					thisRotationData.gamemode,
					entry
				)
				
				__AppendRotationErrorDataMessage( thisRotationData, errorMsg )	
			}
		}
		
		file.allRotationData.append( thisRotationData )
	} // combination foreach 
	
	__ValidateAllRotationData()
}

void function __ValidateAllRotationData()
{
	if( !file.errorRotationData.len() )
		return 
		
	int iErrorCount	
	int iRepeatAsterisk	= 120
		
	string errorAlert = format( "\n%s*\n*\n*\n*\n*\n*\n==== The following rotation data errors occurred ==== \n\n", RepeatString( "*", iRepeatAsterisk ) )
	foreach( PlaylistGamemodeRotateData errorRotationData, array< string > errorStrings in file.errorRotationData )
	{
		iErrorCount += errorStrings.len()
		foreach( string message in errorStrings )
			errorAlert += format( "%s\n", message )
	}
	
	errorAlert += format( "\n*\n*\n*\n*\n*\n*\n%s", RepeatString( "*", iRepeatAsterisk ) )
	
	thread
	(		
		void function() : ( errorAlert, iErrorCount )
		{
			Dev_CommandLineAddParm( "playlistOverride", "" )
			wait 3
					
			sqerror( errorAlert )
			mAssert( 0, "AutoRotation via playlist setting 'auto_rotate_list' encountered [%d] errors\nSee console or logs for information.", iErrorCount )
		}
	)()
}

void function __AppendRotationErrorDataMessage( PlaylistGamemodeRotateData data, string msg )
{
	array< string > emptyMessages
	if( !( data in file.errorRotationData ) )
		file.errorRotationData[ data ] <- emptyMessages
	
	file.errorRotationData[ data ].append( msg )
}

void function __CouldNotMatchMessage( PlaylistGamemodeRotateData rotateData, int entryIdx, string matchFor, string criteria, int iParam, string thisEntry  )
{
	string errorMsg = format
	(
		"Rotation data #[%d] could not match a *%s* with criteria '%s' @param#:[%d] For Entry: '%s'",
		entryIdx,
		matchFor,
		criteria,
		iParam + 1,
		thisEntry
	)
	
	__AppendRotationErrorDataMessage( rotateData, errorMsg )
}

int function FindCurrentRotationIndex()
{
	array< PlaylistGamemodeRotateData > rotationData = file.allRotationData
	
	string map = GetMapName()
	string playlist = GetCurrentPlaylistName()
	string gamemode = GameRules_GetGameMode()
	
	int i = 0
	foreach( PlaylistGamemodeRotateData data in rotationData )
	{
		if
		( 
			data.map 		== map 			&&
			data.playlist 	== playlist		&&
			data.gamemode	== gamemode
		)
		{
			return i
		}
		
		i++
	}
	
	return -1
}

array< PlaylistGamemodeRotateData > function GetCurrentRotationSet()
{
	return file.allRotationData
}

void function DecideNextMapPlaylistGamemodeRotation()
{
	if( !file.bAutoRotationEnabled )
		return

	array< PlaylistGamemodeRotateData > allRotationData = file.allRotationData 
	int rotationMaxIndex = allRotationData.len()
	int currentRotationIndex = FindCurrentRotationIndex()
	int rotationIndexToLoad = -1
	
	mAssert( rotationMaxIndex != 0, "Rotation is enabled, but there is no valid rotation data." )
	
	PlaylistGamemodeRotateData rotationDataToLoad
	int playerCount = GetConnectedPlayerCount()
	
	for( int i = 0; i < rotationMaxIndex; i++ )
	{
		rotationIndexToLoad = ( currentRotationIndex + 1 + i ) % rotationMaxIndex		
		rotationDataToLoad = file.allRotationData[ rotationIndexToLoad ]
		
		if( playerCount >= rotationDataToLoad.minplayers && ( rotationDataToLoad.maxplayers <= 0 || playerCount <= rotationDataToLoad.maxplayers ) )
			break
	}
	
	Dev_CommandLineAddParm( "playlistOverride", rotationDataToLoad.playlist )
	GameRules_ChangeMap( rotationDataToLoad.map, rotationDataToLoad.gamemode )
}

bool function IsMapPlaylistGamemodeRotationEnabled()
{
	return file.bAutoRotationEnabled
}

#if DEVELOPER
	void function TestRandom()
	{
		thread
		(
			void function()
			{
				const int RUN_COUNT = 100000
				array<string> randomStuff
				for( int i = 0; i < 5; i++ )
					randomStuff.append( "rand" + i )
					
				string randSelection
				int idxZeroSelections
				
				for( int j = 0; j < RUN_COUNT; j++ )
				{
					randSelection = randomStuff.getrandom()
					if( randSelection == "rand0" )
						idxZeroSelections++
				}
				
				printf
				(
					"Ran %d times, selected idxZero %d times.",
					RUN_COUNT,
					idxZeroSelections
				)
			}
		)()
	}
#endif

bool function IsValidCharacterGUID( int characterGUID, entity player )
{
	ItemFlavor ornull characterOrNull = GetItemFlavorOrNullByGUID( characterGUID )
	if( characterOrNull == null )
		return false
	
	expect ItemFlavor ( characterOrNull )
	if( ItemFlavor_GetType( characterOrNull ) != eItemType.character )
		return false
		
	if( !ItemFlavor_ShouldBeVisible( characterOrNull, player ) )
		return false
		
	if( !ItemFlavor_IsAvailableInPlaylist( characterOrNull ) )
		return false
		
	return true
}