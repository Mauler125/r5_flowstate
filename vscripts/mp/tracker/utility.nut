untyped //needed for sqwarning																		//mkos

//player util
global function CheckRate
global function ResetRate
global function GetPlayer
global function GetPlayerEntityByUID
global function GetPlayerEntityByName
global function IsServerAdmin
global function GetAdminList
global function IsAuthEnabled	

//string util
global function IsStringNumeric
global function IsStringNumber
global function IsStringBool
global function StringRemoveControlCharacters
global function Concatenate
global function LineBreak
global function IsSafeString

//print util
global function print_string_array
global function print_var_table
global function print_var_array

//Tracker print-to console as native
global function sqprint
global function sqerror
global function sqwarning

//Weapons util:
global function ParseWeapon
global function IsWeaponValid
global function TrackerWepTable
global function ShouldExcludeDamageSourceShipping
global function DEV_PrintTrackerWeapons

//Client commands util
global function __PlayerAdminsInit
global function ClientCommand_mkos_return_data
global function ClientCommand_mkos_admin

//ibmm util ( Todo: rework how this is done )
global function GetDefaultIBMM
global function SetDefaultIBMM
global function ValidateIBMMWaitTime

//misc
global function TP
global function EnableVoice
global function PlayTimeFromSecondsString
global function Tracker_DetermineNextMap
global function Tracker_GotoNextMap
global function PrepareForJson
global function ArrayUniqueInt

#if DEVELOPER
	global function RegExpUnitTest
	global function RegExpUnitTest2
	global function StringUnitTest
#endif

#if TRACKER && HAS_TRACKER_DLL
	global function PrintMatchIDtoAll
#endif

struct
{
	table< string,int > WeaponIdentifiers
	array< string > ADMINS
	bool bStopUpdateMsg = false
	
} file

	
	//client command: show
		bool function ClientCommand_mkos_return_data( entity player, array<string> args )
		{
			if ( !CheckRate( player, "verbose_stream", 5.0, true ) ) 
				return false
			
			if ( args.len() < 1)
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
							{
								mnkCount++
							}
							else if ( active_player.p.input == 1 )
							{
								controllerCount++
							}
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
							
							data += format("\n Console Aim Assist: %.1f ", GetCurrentPlaylistVarFloat( "aimassist_magnet", 0.0 ) )
							data += format("\n PC Aim Assist: %.1f", GetCurrentPlaylistVarFloat("aimassist_magnet_pc", 0.0 ) )
									
							if( (inputmsg.len() + data.len()) > 2800 )
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
	
		string admins_list
		string pair
		
		#if TRACKER && HAS_TRACKER_DLL
			admins_list = TrackerGetSetting__internal( "settings.ADMINS" )
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
				if( admin_pair.find( "-" ) != -1 )
				{
					array<string> a_format = split( admin_pair, "-" )
					file.ADMINS.append( a_format[ 1 ] )
				}
				else 
					file.ADMINS.append( admin_pair ) //new format only uid
			}
		}
		catch( erradmin )
		{
			sqerror( "Error with adminpair:", pair, "Error:", erradmin )
		}
		
		AddCallback_OnClientConnected( CheckAdmin_OnConnect )
	}
	
	array<string> function GetAdminList()
	{
		return file.ADMINS
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
		if ( !CheckRate( player ) ) 
			return false
		
		string PlayerName = player.GetPlayerName()
		string PlayerUID = player.GetPlatformUID()

		if( !IsServerAdmin( PlayerUID ) )
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
						try 
						{
							Message( player, "Commands:", "A command is entered as: \n\n cc command #param #param2.  \n\n cc kick #name/oid   - Kicks a player by name/oid \n cc afk #0/1   - disabled or enables afk to rest mode \n cc playself #audiofile   - Plays audiofile to self \n cc playall #audiofile    - Plays audiofile to all player \n cc sayall '#title' '#message' #duration   - says to all \n cc ban #name/oid #reason    - Bans a player \n cc unban #oid   - attempts to unban a player by OID \n cc map #name #mode   - reloads map \n cc playerinput #name/oid   - shows players input \n cc playerinfo  - some stats", 20 )
						}
						catch ( err ) 
						{
							return false 
						}
				
						return true
				
				
			case "kick":	
						if ( args.len() < 2 )
						{
							Message( player, "Failed", "kick requires name/id for 1st param of command" )
							return false
						}
		
						try 
						{		
							entity k_player
							string k_playeroid
							string k_playername
							string reason = param2
							
							k_player = GetPlayer( param )
							
							if ( !IsValid( k_player ) )
							{
								Message( player, "Failed", "Player: " + param + " - is invalid. " )
								return true
							}
								
							k_playeroid = k_player.GetPlatformUID()	
							k_playername = k_player.GetPlayerName()
							
							if ( IsServerAdmin( k_playeroid ) )
							{
								Message( player, "Cannot kick admin")
								return true
							}
						
							KickPlayerById( k_playeroid, reason )
							UpdatePlayerCounts()
							
							Message( player, "Kicked player", "PUID: " + k_playeroid + "\nName: " + k_playername )
							return true	
						}
						catch ( erraaarg )
						{
							Message( player, "Error", "Invalid player or argument missing" )
							return true
						}
						
						return true	
						
			case "afk":
					
						try 
						{					
							if ( args[1] == "1" )
							{
								SetAfkToRest( true )
								Message( player, "Command sent", "Afk to rest was ENABLED" )
								return true
							} 
							else if ( args[1] == "0" )
							{
								SetAfkToRest( false )
								Message( player, "Command sent", "Afk to rest was disabled" )
								return true
							} 
						} 
						catch( erroreo )
						{		
							Message( player, "Error", "argument missing" )
							return false
						}
						
						return true
							
			case "restricted":
			
							try 
							{

								if ( args[1] == "1" )
								{
									Tracker_SetRestrictedServer( true )
									Message( player, "Command sent", "restricted_server was ENABLED" )
									return true
								} 
								else if ( args[1] == "0" )
								{
									Tracker_SetRestrictedServer( false )
									Message( player, "Command sent", "restricted_server was disabled" )
									return true
								} 
							} 
							catch( errorres )
							{
								Message( player, "Error", "argument missing" )
								return false
							}

							return true
							
			case "playonself": 
			
								
							if ( args.len() < 2 )
							{
								Message( player, "Failed", "playself requires param of audiofile as string" )
								return false
							} 
								
							try 
							{
								EmitSoundOnEntity( player, args[1] )	
							} 
							catch ( erra )
							{
								Message(player, "Failed", "Command failed because of: \n\n " + erra )
								return false	
							}
							
							return true
				
				
			case "playself": 
			
								
							if ( args.len() < 2 )
							{
								Message( player, "Failed", "Command 'playself' requires param of audiofile as string" )
								return false
							} 
								
							try 
							{
								EmitSoundOnEntityOnlyToPlayer( player, player, args[1] )	
							} 
							catch ( erra )
							{			
								Message(player, "Failed", "Command failed because of: \n\n " + erra )
								return false	
							}
							
							return true
							
							
			case "playall":
												
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
									return false	
								}
							
							}

							return true
								
							
			case "stopplayall":
						
							
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
									return false
								}
							}

							return true
										
			case "sayall": 
					
							if ( args.len() < 4 )
							{	
								Message( player, "Failed", "Command 'sayall' requires duration for third param of command as float" )
								return false
							} 
							
							foreach ( say_to_player in GetPlayerArray())
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
							
			case "sayto": 
		
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
			case "ban":
									
							if ( args.len() < 2 )
							{		
								Message( player, "Failed", "Command 'ban' requires name/id for 1st param of command" )
								return false
							}			
							
							try 
							{
								entity b_player
								string b_playeroid
								string b_reason = param2	
								
								b_player = GetPlayer( param )
							
								if ( !IsValid( b_player ) )
								{
									Message( player, "Failed", "Player: " + param + " - is invalid. " )
									return true
								}
								
								b_playeroid = b_player.GetPlatformUID()	
									
								
								if ( IsServerAdmin( b_playeroid ) )
								{
									Message( player, "Cannot ban admin" )
									return true
								}
							
								BanPlayerById( b_playeroid, b_reason )
								UpdatePlayerCounts()
								
								Message( player, "Success", "Player: " + param + "\n\n was banned for: \n\n" + b_reason )
								return true		
							} 
							catch ( erre )
							{
								Message(player, "Failed", "Command failed because of: \n\n " + erre )
								return false
							}
							
						return true;
			
			case "bansay":
			
						if ( args.len() < 2 )
						{
							Message( player, "Failed", "Command 'bansay' requires player for 1st param of command" )
							return false
						}
						
						args[0] = "ban"	
						ResetRate( player )
						entity target = GetPlayer( param )
						
						if( IsValid( target ) )
						{
							string targetName = target.GetPlayerName()
							bool result = ClientCommand_mkos_admin( player, args )

							if( result )
							{
								string msgHeader = format( "%s was BANNED for: ", targetName )
								SendServerMessage( msgHeader + param2 )
								foreach( s_player in GetPlayerArray() )
									Message( s_player, msgHeader, param2, 10.0 )
							}
						}
						else 
						{
							Message( player, "Invalid player: " + param )
						}
				break
				
			case "kicksay":
			
						if ( args.len() < 2 )
						{
							Message( player, "Failed", "Command 'kicksay' requires player for 1st param of command" )
							return false
						}
						
						args[ 0 ] = "kick"
						ResetRate( player )
						entity target = GetPlayer( param )
						
						if( IsValid( target ) )
						{
							string targetName = target.GetPlayerName()
							bool result = ClientCommand_mkos_admin( player, args )

							if( result )
							{
								string msgHeader = format( "%s was kicked for: ", targetName )
								SendServerMessage( msgHeader + param2 )
								foreach( s_player in GetPlayerArray() )
									Message( s_player, msgHeader, param2 )
							}
						}
						else 
						{
							Message( player, "Invalid player: " + param )
						}
				break
			
			case "banid":
			
				#if TRACKER && HAS_TRACKER_DLL
				
						if ( args.len() < 2 )
						{
							Message( player, "Failed", "Command 'banid' requires oid for 1st param of command")
							return false
						}	

							try 
							{
								if ( IsServerAdmin( param ) )
								{
									Message( player, "Failed", param + " is an admin. Ban rejected.", 10 )
									return false		
								}
								
								if ( !IsStringNumber( param ) )
								{			
									Message( player, "Failed", param + " is not a valid oid format.", 10 )
									return false	
								}
								
								if ( param2 == "" )
								{		
									param2 = "0";							
								}
								
								entity playerToBan = GetPlayerEntityByUID( param )
								
								if( IsValid( playerToBan ) )
								{
									BanPlayerById( param, param3 )
									Message( player, "Success", param + " was added to the banlist and removed from the server.", 10 )
									
									return true
								}
								
								if ( AddBanByID( param2, param ) )
								{					
									Message( player, "Success", param + " was added to the banlist.", 10 )
									return true	
								}
								else 
								{	
									Message( player, "Failed", "Failed to add player oid: " + param + " to the banlist.", 10 )
									return true		
								}
								
							} 
							catch ( errbanid )
							{
								Message(player, "Failed", "Command failed because of: \n\n " + errbanid )
								return false
							}
							
					#endif 
						return true
					
			case "unban":				
					
						if ( args.len() < 2 )
						{		
							Message( player, "Failed", "Command 'unban' requires id for 1st param of command as string" )
							return false	
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
							return false
						}
						
						return true;
								
			case "playerinfo":
			
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
							return false
						}
						
			//for testing
			case "playerinput":
						
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
		
						
			case "input":	

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
								return false	
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
							return false
						}
#endif 
				return true
						
			case "listhandles":
						
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
						
			case "map":
					
						string map
						
						if( param == "" )
							map = GetMapName()
						else 
							map = GetMap( param )
						
						if( map == "" )
						{
							Message( player, "Map not found:", format( "Could not find map with \"%s\" in it`s name", param ) )
							sqerror( "Map not found:", param )
							return true
						}
						
						if( !GetPlaylistMaps( GetCurrentPlaylistName() ).contains( map ) )
						{
							Message( player, "MAP NOT IN PLAYLIST" )
							sqerror( "Map not in playlist - rejecting load" )
							return true
						}
						
						GameRules_ChangeMap( map, GetMode( param2 ) )
						
					return true
					
			case "score":
			
						if ( args.len() < 1)
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
							entity s_player;
									
							s_player = GetPlayer( param )
							
							if ( !IsValid( s_player ) )
							{	
								Message( player, "Failed", "Player: " + param + " -- is invalid" );
								return true
							}
							
							try 
							{
								Message( player, "Success", GetScore( s_player ) );		
							} 
							catch (errscore) 
							{
								Message( player, "Failed", "Command failed because of: \n\n " + errscore )
								return true;			
							}
						
						}
						
					return true
					
			case "scoreconfig":
			
						if ( args.len() < 2)
						{
							Message( player, "Failed", "Param 1 of command 'scoreconfig' requires type: current/season/difference.")
							return true
						}
						
						if ( args.len() < 3)
						{	
							Message( player, "Failed", "Param 2 of command 'scoreconfig' requires float")
							return true	
						}
						
						
						
						try 
						{			
							if ( !IsFloat( param2 ) )
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
							
							Message( player, "Success", "Weight for " + param + " KD -- was set to: " + param2 , 5 );
						
						} 
						catch (errsetweight) 
						{
							Message( player, "Failed", "Command failed because of: \n\n " + errsetweight )
							return true;			
						}
						
					return true
					
			case "cleanuplogs":
				
					#if TRACKER && HAS_TRACKER_DLL	
						TrackerCleanupLogs__internal()
					#endif
							
						return true
			
			case "reload_config":
			
					#if TRACKER && HAS_TRACKER_DLL	
						TrackerReloadConfig__internal()
					#endif
						
						return true
						
			case "setting":
						
					#if TRACKER && HAS_TRACKER_DLL	
					
						if ( args.len() < 2)
						{
							Message( player, "Failed", "Param 1 of command 'setting' requires key name")
							return true
						}
						
						
						try 
						{	
							string return_str = ""
							return_str = TrackerGetSetting__internal( param )	
							
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
					
			case "spamupdate":
			case "spam":
					
					file.bStopUpdateMsg = false
					thread RunUpdateMsg()
					sqprint( "Update spam messages started" )
				
				break
			
			case "spamstop":
			case "stopspam":
			
					file.bStopUpdateMsg = true
					sqprint( "Update spam messages stopped" )
				
				break
				
			case "msg":
			
					if ( args.len() < 2)
					{
						Message( player, "Failed", "Param 1 of command 'serversay' requires string")
						return true
					}
					
					
					try 
					{	
						if( !SendServerMessage( param ) )
						{
							Message( player, "Error", "Message was truncated")
						}
						
						return true
					} 
					catch ( errservermsg ) 
					{		
						Message( player, "Failed", "Command failed because of: \n\n " + errservermsg )
						return true		
					}
					
				break
						
			case "vc":
				
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
				
			case "startbr":
			
					FlagSet( "MinPlayersReached" )	
					return true
					
			case "pos":
				
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
					#endif
				return false
			
			case "groups":
			
					Message( player, "\"groupsInProgress\"", getGroupsInProgress().len().tostring() )
					return true
					
			case "groupmap":
			
					Message( player, "\"playerToGroupMap\"", getPlayerToGroupMap().len().tostring() )
					return true
					
			case "start_interval_thread":

					#if TRACKER
						if( isIntervalThreadRunning() )
						{
							Message( player, "Interval thread is already running." )
							return true 
						}
						
						Message( player, "INTERVAL THREAD STARTING" )
						DEV_StartIntervalThread()
					#endif
					
						return true 
					
			case "kill_interval_thread":
					
					#if TRACKER
						svGlobal.levelEnt.Signal( "KillIntervalThread" ) 
						Message( player, "INTERVAL THREAD STOPPING" )
					#endif
					
					return true
					
			//case "testsend":
			
					//SQ_MsgToClient( param.tointeger(), param2 )
					
					//return true
			case "thumbsup":
				
				SendServerMessage(chat.effects["THUMBSUP"])		
				return true
				
			case "print_chat_effects":
			
				#if DEVELOPER
					DEV_PrintAllChatEffects()
				#endif 
				
				return true
				
			case "msgeffect":
					
				SendServerMessage( Chat_FindEffect( param ) )
				return true
				
			case "nextmap":
			
				Tracker_GotoNextMap()
				return true
			
			case "fetchsetting":
			
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
				
			#endif
				return true
				
			case "testremote":
			
				#if DEVELOPER
					Remote_CallFunction_NonReplay( player, "ServerCallback_SetPersistenceSettings", 1, 2, 3, 4)
				#endif
				return true
				
			case "acceptchal":
			
				#if DEVELOPER
					entity p = GetPlayer( param )
					
					if ( !IsValid( p ) )
					{
						printt("Invalid player")
						return true
					}
					
					DEV_acceptchal(p)
				#else 
					printt("Dev mode only")
				#endif 
				
				return true
				
			case "draw":
			
				#if DEVELOPER 
				
					printt("Drawing...")
					foreach( s_player in GetPlayerArray() )
					{
						Remote_CallFunction_ByRef( s_player, "Minimap_EnableDraw_Internal" )
						//Remote_CallFunction_NonReplay( s_player, "Minimap_EnableDraw_Internal")
					}
					
				#endif 
				
				return true 
				
			case "disabledraw":
			
				#if DEVELOPER 
				
					printt("DisableDrawing...")
					foreach( s_player in GetPlayerArray() )
					{
						Remote_CallFunction_ByRef( s_player, "Minimap_DisableDraw_Internal" )
						//Remote_CallFunction_NonReplay( s_player, "Minimap_DisableDraw_Internal")
					}
					
				#endif 
				
				return true 
			
#if DEVELOPER			
			case "stoplog":
			
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
				
			case "startlog":
			
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
#endif 

			case "mute":
			case "gag":
				
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
						Message( player, "Attempting Save", "Saving uid: " + param )
					}
				}
				else 
				{
					string reason = Chat_FindMuteReasonInArgs( args )
					LocalMsg( p, "#FS_MUTED", "", eMsgUI.DEFAULT, 5, "", reason )
				}
					
				#if TRACKER
					Tracker_SetForceUpdatePlayerData() //does nothing if already set.
				#endif 
				
				if( !Chat_ToggleMuteForAll( p, true, true, args, -1, param ) )
					Message( player, "Failed" )
				else
					Message( player, "Muted " + param )
				
				return true
			
			case "unmute":
			case "ungag":
			
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
						Message( player, "Attempting Save", "Saving uid unmuted: " + param )
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
				if( Chat_ToggleMuteForAll( p, false, true, args ) )
				{
					string reason = Chat_FindMuteReasonInArgs( args )			
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
				
			case "is_muted":
			case "is_gagged":
				
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
				
			case "mute_reason":
			case "gag_reason":
				
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
				
			case "unmute_time":
			case "ungag_time":
			
				entity p = GetPlayer( param )
				string uidLookup
				
				if( IsStringNumeric( param ) )
					uidLookup = param
					
				if( IsValid( p ) )
					uidLookup = p.p.UID
					
				string unmuteTimestamp 	= Tracker_FetchPlayerData( uidLookup, "unmuteTime" )
				string timestring 		= "0"
				
				if( IsStringNumeric( unmuteTimestamp ) )
					timestring = Chat_ReadableUnmuteTime( unmuteTimestamp.tointeger() )
				
				Message( player, "UNMUTE TIME: " + unmuteTimestamp, timestring )
				return true
				
			case "killme":
			
			#if DEVELOPER
				if( IsAlive( player ) )
				{
					player.Die( null, null, { damageSourceId = eDamageSourceId.damagedef_suicide } )
				}
			#endif 	
				return true
						
			case "dmg":
			
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
				
			case "gamerules":
			
				//TODO: mini framework for parsing valid map/playlist combos
				// needs server function capable of swapping playlist & map
				//CreateServer("","","mp_rr_desertlands_64k_x_64k","survival_solos", 0)
				break
				
			case "movement_recorder_playback_rate":
			
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
				
			case "kill_banners":
			
				BannerAssets_KillAllBanners()
				break 
				
			case "start_banners":
			
				BannerAssets_Restart()
				break
				
			case "allow_legend_select":
			
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
				
			case "set_legend":
			
				if( empty( param ) || !IsStringNumeric( param ) )
				{
					Message( player, "Command 'set_legend' requires numeric paramater for legend index" )
					return true
				}
				
				int index = param.tointeger()
				Gamemode1v1_SetAllPlayersLegend( index )
				break
				
			case "endround":
				EndRound()
				break
				
			case "addmotd":
				
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
			
			default:	
					Message( player, "Usage", "cc #command #param1 #param2 #..." )
					return true
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

float function GetDefaultIBMM()
{
	float f_wait = GetCurrentPlaylistVarFloat( "default_ibmm_wait", 0 )
	return ValidateIBMMWaitTime( f_wait )
}

float function ValidateIBMMWaitTime( float f_wait )
{
	return f_wait > 0.0 && f_wait < 3.0 ? 3.0 : f_wait
}

void function SetDefaultIBMM( entity player )
{	
	float f_wait = GetCurrentPlaylistVarFloat("default_ibmm_wait", 0)
	player.p.IBMM_grace_period = f_wait > 0.0 && f_wait < 3.0 ? 3.0 : f_wait
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


bool function IsFloat( string str, float min = INT_MAX, float limit = INT_MIN )  //cleanup
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
	mAssert( IsStringBool( str ), "Tried to convert \"%s\" to bool", str )
	
	switch( str )
	{
		case "0":
		case "false":
			return false 
			
		case "1":
		case "true":
			return true 
	}
	
	unreachable
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
	
	return p
}

void function CheckAdmin_OnConnect( entity player )
{
	if( !IsValid( player ) ) 
		return
	
	if( IsServerAdmin( player.GetPlatformUID() ) ) //use new oid list
		player.SetPlayerNetBool( "IsAdmin", true )
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

string function GetMap( string query )
{
	foreach( mapname in AllMapsArray() )
	{
		if( mapname.find( query ) != -1 )
			return mapname
	}
	
	return ""
}

string function GetMode( string str )
{
	//Todo: scan / find match modes when playlist is able to swap
	return GameRules_GetGameMode()
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

void function print_string_array( array<string> args )
{
	string test = "\n\n------ PRINT STRING ARRAY ------\n\n"
	
	foreach( arg in args )
		test += format( "	\"%s\", \n", arg )
	
	sqprint( test )
}

void function print_var_table( table<string,var> tbl )
{
	string prnt = "\n\n------ PRINT TABLE ------\n\n"
	foreach( string k, var v in tbl )
		prnt += format( "	[%s] = %s\n", k, string( v ) )
	
	sqprint( prnt )
}

void function print_var_array( array<var> arr )
{
	string prnt = "\n\n------ PRINT ARRAY ------\n\n"
	foreach( i, v in arr )
		prnt += format( "	[%d] = %s\n", i, string( v ) )
	
	sqprint( prnt )
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
	return file.ADMINS.contains( uid )
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
	
	return file.WeaponIdentifiers[ weaponName ]
}

bool function IsWeaponValid( string weaponref )
{
	return ( weaponref in file.WeaponIdentifiers )
}

void function DEV_PrintTrackerWeapons()
{
	string prnt = "\n\n ---------- TRACKER WEAPON IDENTIFIERS --------- \n\n";
	
	foreach( weapon, id in file.WeaponIdentifiers )
	{
		prnt += format( "[\"%s\"] = %d, \n", weapon, id )
	}
	
	printt( prnt )
}

table<string, int> function TrackerWepTable() 
{
    return file.WeaponIdentifiers
}

bool function ShouldExcludeDamageSourceShipping( int weaponSource )
{
	return !DamageSourceIDHasString( weaponSource )
}

string function ParseWeapon( string weaponString )
{
	array<string> mods = split( strip( weaponString ), " " )
	
	if( mods.len() < 1 )
		return ""
	
	if( !IsWeaponValid( mods[ 0 ] ) || !( SURVIVAL_Loot_IsRefValid( mods[ 0 ] ) ) )
		return ""
	
	bool removed = false
	for ( int i = mods.len() - 1 ; i >= 1; i-- )
	{
		if ( !SURVIVAL_Loot_IsRefValid( mods[ i ] ) 
		|| !IsModValidForWeapon( mods[ 0 ], mods[ i ] ) )
		{
			removed = true
			sqprint( "removed:", mods[ i ] )		
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

void function sqwarning( ... ) //changed to work like Warning() with format for consistency.
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