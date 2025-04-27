global function InitGamemodeSelectDialogV4
global function SetFreeRoamMap

const int MAX_DISPLAYED_SERVERS = 3

//RUI Element breaks after 21 pages so im limiting it
const int MAX_SERVER_PAGES = 21

global bool FreeRoamMapSelectionOpen = false

struct {
	var menu

	int currentServerPage = 0
	int lastServerNameLineHeight = 0

	ServerListing selectedServer

	string freeRoamSelectedMap = "mp_rr_canyonlands_64k_x_64k"

	table <var, int> buttonVideoChannels
} file

void function InitGamemodeSelectDialogV4( var newMenuArg )
{
	var menu = GetMenu( "GamemodeSelectV4Dialog" )
	file.menu = menu

	AddMenuEventHandler( menu, eUIEvent.MENU_OPEN, OnOpenModeSelectDialog )
	AddMenuEventHandler( menu, eUIEvent.MENU_CLOSE, OnCloseModeSelectDialog )

	AddMenuEventHandler( menu, eUIEvent.MENU_NAVIGATE_BACK, OnModeSelectMenu_NavigateBack )

	Hud_AddEventHandler( Hud_GetChild(file.menu, "ServersPrevButton"), UIE_CLICK, Servers_PageBackward )
	Hud_AddEventHandler( Hud_GetChild(file.menu, "ServersNextButton"), UIE_CLICK, Servers_PageForward )

	AddMenuFooterOption( menu, LEFT, BUTTON_B, true, "#B_BUTTON_CLOSE", "#CLOSE" )
	AddMenuFooterOption( menu, LEFT, BUTTON_A, true, "#A_BUTTON_SELECT" )

	Hud_AddEventHandler( Hud_GetChild(file.menu, "FreeRoamChangeMapButton"), UIE_CLICK, FreeRoamChangeMapButton )
	Hud_AddEventHandler( Hud_GetChild(file.menu, "TrainingChangeMapButton"), UIE_CLICK, SelectTraining )
	Hud_AddEventHandler( Hud_GetChild(file.menu, "FiringRangeButton"), UIE_CLICK, SelectFiringRange )
	Hud_AddEventHandler( Hud_GetChild(file.menu, "AimtrainerButton"), UIE_CLICK, SelectAimTrainer )

	for(int i = 0; i < MAX_DISPLAYED_SERVERS; i++)
	{
		Hud_SetVisible( Hud_GetChild(file.menu, "ServerText" + i), false )
		Hud_SetVisible( Hud_GetChild(file.menu, "ServerMapName" + i), false )
		Hud_SetVisible( Hud_GetChild(file.menu, "ServerPlaylist" + i), false )
		Hud_SetVisible( Hud_GetChild(file.menu, "ServerButton" + i), false )
		Hud_SetVisible( Hud_GetChild(file.menu, "ServerPlayerCount" + i), false )

		Hud_AddEventHandler( Hud_GetChild(file.menu, "ServerButton" + i), UIE_CLICK, SelectServer )
	}

	SetFreeRoamMap("mp_rr_canyonlands_64k_x_64k")
}

void function OnModeSelectMenu_NavigateBack()
{
	if(FreeRoamMapSelectionOpen)
	{
		FreeRoamMapSelectionOpen = false
		HidePanel( Hud_GetChild(file.menu, "MapSelectPanel" ) )
		return
	}

	CloseActiveMenu()
}

void function FreeRoamChangeMapButton( var button )
{
	FreeRoamMapSelectionOpen = true
	ShowPanel( Hud_GetChild(file.menu, "MapSelectPanel" ) )
}

void function SelectTraining( var button )
{
	string map = "mp_rr_canyonlands_staging"
	string playlist = "survival_training"

	R5RPlay_SetSelectedPlaylist(map, GetUIMapAsset(map, true), playlist, "Training")
	CloseActiveMenu()
}

void function Servers_PageBackward( var button )
{
	if(FreeRoamMapSelectionOpen)
	{
		Maps_PageBackwards(button)
		return
	}
	
	if(GetMaxPages() == 0)
		return

	int newPage = file.currentServerPage - 1

	if( newPage - 1 < -1)
		newPage = GetMaxPages() - 1

	LoadServers(newPage)
}

void function Servers_PageForward( var button )
{
	if(FreeRoamMapSelectionOpen)
	{
		Maps_PageForward(button)
		return
	}

	if(GetMaxPages() == 0)
		return

	int newPage = file.currentServerPage + 1

	if( newPage + 1 > GetMaxPages())
		newPage = 0

	LoadServers(newPage)
}

void function SetFreeRoamMap(string map)
{
	FreeRoamMapSelectionOpen = false
	file.freeRoamSelectedMap = map
	RuiSetImage( Hud_GetRui( Hud_GetChild(file.menu, "FreeRoamBackground") ), "modeImage", GetUIMapAsset( map, true ) )
	Hud_SetText( Hud_GetChild(file.menu, "FreeRoamTextMapName"), GetUIMapName(map) )
}

void function SelectFiringRange( var button )
{
	string map = "mp_rr_canyonlands_staging"
	string playlist = "survival_firingrange"

	R5RPlay_SetSelectedPlaylist(map, GetUIMapAsset(map, true), playlist, "Firing Range")
	CloseActiveMenu()
}

void function SelectAimTrainer( var button )
{
	string map = "mp_rr_desertlands_64k_x_64k"
	string playlist = "fs_aimtrainer"

	R5RPlay_SetSelectedPlaylist(map, $"rui/menu/maps/aim_trainer", playlist, "Aim Trainer")
	CloseActiveMenu()
}

void function SelectServer( var button )
{
	int id = Hud_GetScriptID( button ).tointeger() + file.currentServerPage

	file.selectedServer.svServerID = global_m_vServerList[id].svServerID
	file.selectedServer.svServerName = global_m_vServerList[id].svServerName
	file.selectedServer.svMapName = global_m_vServerList[id].svMapName
	file.selectedServer.svPlaylist = global_m_vServerList[id].svPlaylist
	file.selectedServer.svDescription = global_m_vServerList[id].svDescription
	file.selectedServer.svMaxPlayers = global_m_vServerList[id].svMaxPlayers
	file.selectedServer.svCurrentPlayers = global_m_vServerList[id].svCurrentPlayers

	R5RPlay_SetSelectedServer(file.selectedServer)
	CloseActiveMenu()
}

int function GetMaxPages()
{
	int maxPages = (global_m_vServerList.len() + 2 / 3 )

	if(maxPages > MAX_SERVER_PAGES)
		maxPages = MAX_SERVER_PAGES

	return maxPages
}

void function OnOpenModeSelectDialog()
{
	RegisterButtonPressedCallback( MOUSE_WHEEL_DOWN, Servers_PageForward )
	RegisterButtonPressedCallback( MOUSE_WHEEL_UP, Servers_PageBackward )
	
	thread SetupGameSelectV4()

	PlayVideoOnGamemodeButton(Hud_GetChild(file.menu, "TrainingChangeMapButton"), $"media/gamemodes/training.bik")
	PlayVideoOnGamemodeButton(Hud_GetChild(file.menu, "FreeRoamChangeMapButton"), $"media/gamemodes/freerom_sdk.bik")
	PlayVideoOnGamemodeButton(Hud_GetChild(file.menu, "AimtrainerButton"), $"media/gamemodes/training_flowstate.bik")
	PlayVideoOnGamemodeButton(Hud_GetChild(file.menu, "FiringRangeButton"), $"media/gamemodes/firingrange_sdk.bik")
}

void function SetupGameSelectV4()
{
	waitthread Servers_GetCurrentServerListing()
	thread LoadServers(0)
}

void function PlayVideoOnGamemodeButton(var button, asset videoAsset)
{
	if(button in file.buttonVideoChannels)
	{
		StartVideoOnChannel( file.buttonVideoChannels[button], videoAsset, true, 0.0 )
		return
	}

	int channel = ReserveVideoChannel()
	file.buttonVideoChannels[button] <- channel

	StartVideoOnChannel( channel, videoAsset, true, 0.0 )

	RuiSetBool( Hud_GetRui( button ), "hasVideo", true )
	RuiSetInt( Hud_GetRui( button ), "channel", channel )
}

void function ReleaseAllVideoChannels()
{
	foreach( button, channel in file.buttonVideoChannels )
	{
		ReleaseVideoChannel( channel )
		RuiSetBool( Hud_GetRui( button ), "hasVideo", false )
		RuiSetInt( Hud_GetRui( button ), "channel", -1 )
	}

	file.buttonVideoChannels.clear()
}

void function SetServerHeaderVis(bool show)
{
	Hud_SetVisible( Hud_GetChild(file.menu, "ServersFooter"), show )
	Hud_SetVisible( Hud_GetChild(file.menu, "ServersLine"), show )
	Hud_SetVisible( Hud_GetChild(file.menu, "HeaderModes2Text"), show )
	Hud_SetVisible( Hud_GetChild(file.menu, "ServersPrevButton"), show )
	Hud_SetVisible( Hud_GetChild(file.menu, "ServersNextButton"), show )

	Hud_SetVisible( Hud_GetChild(file.menu, "NoServersText"), !show )
}

void function OnCloseModeSelectDialog()
{
	DeregisterButtonPressedCallback( MOUSE_WHEEL_DOWN, Servers_PageForward )
	DeregisterButtonPressedCallback( MOUSE_WHEEL_UP, Servers_PageBackward )
	
	Lobby_OnGamemodeSelectV2Close()
	ReleaseAllVideoChannels()
}

void function LoadServers(int page)
{
	EmitUISound( "UI_Menu_BattlePass_LevelTab" )

	file.currentServerPage = page

	SetServerHeaderVis(GetMaxPages() > 1)

	HudElem_SetRuiArg( Hud_GetChild(file.menu, "ServersFooter"), "currentPage", file.currentServerPage )
	HudElem_SetRuiArg( Hud_GetChild(file.menu, "ServersFooter"), "numPages", GetMaxPages() )

	string serversHeaderText = GetMaxPages() > 1 ? "SERVERS: " + (file.currentServerPage + 1) + "/" + GetMaxPages() : "SERVERS"

	if(global_m_vServerList.len() < 1)
		serversHeaderText = ""

	Hud_SetText( Hud_GetChild(file.menu, "HeaderModes2Text"), serversHeaderText)

	for(int i = 0; i < MAX_DISPLAYED_SERVERS; i++)
	{
		int adjustedPageIndex = i + file.currentServerPage

		bool invalidIndex = adjustedPageIndex >= global_m_vServerList.len()

		Hud_SetVisible( Hud_GetChild(file.menu, "ServerText" + i), !invalidIndex )
		Hud_SetVisible( Hud_GetChild(file.menu, "ServerMapName" + i), !invalidIndex )
		Hud_SetVisible( Hud_GetChild(file.menu, "ServerPlaylist" + i), !invalidIndex )
		Hud_SetVisible( Hud_GetChild(file.menu, "ServerButton" + i), !invalidIndex )
		Hud_SetVisible( Hud_GetChild(file.menu, "ServerPlayerCount" + i), !invalidIndex )

		if(!invalidIndex)
		{
			Hud_SetText( Hud_GetChild(file.menu, "ServerText" + i), WrapText(global_m_vServerList[adjustedPageIndex].svServerName, 30) )
			Hud_SetText( Hud_GetChild(file.menu, "ServerMapName" + i), GetUIMapName(global_m_vServerList[adjustedPageIndex].svMapName) )
			Hud_SetText( Hud_GetChild(file.menu, "ServerPlaylist" + i), GetUIPlaylistName(global_m_vServerList[adjustedPageIndex].svPlaylist) )
			Hud_SetText( Hud_GetChild(file.menu, "ServerPlayerCount" + i), global_m_vServerList[adjustedPageIndex].svCurrentPlayers + "/" + global_m_vServerList[adjustedPageIndex].svMaxPlayers + " PLAYERS" )
			RuiSetImage( Hud_GetRui( Hud_GetChild(file.menu, "ServerButton" + i) ), "modeImage", GetUIMapAsset(global_m_vServerList[adjustedPageIndex].svMapName, true ) )

			//This has to be below ServerText, as it requires WrapText to be called first
			Hud_SetHeight( Hud_GetChild(file.menu, "ServerText" + i), file.lastServerNameLineHeight * 25 + 8)
		}
	}
}

string function WrapText(string text, int maxLineWidth)
{
	array<string> textArray = split(text, " ")
	array<string> lines
	string currentLine = "";
	foreach (string word in textArray)
    {
		if (currentLine.len() == 0)
            currentLine = word;
		else if (currentLine.len() + 1 + word.len() <= maxLineWidth)
			currentLine = currentLine + " " + word;
		else
		{
            lines.append(currentLine);
            currentLine = word;
        }
	}

	if (currentLine != "")
        lines.append(currentLine);

	file.lastServerNameLineHeight = lines.len()

	return lines.join("\n");
}