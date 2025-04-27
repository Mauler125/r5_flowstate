global function InitCreditPanel

struct CreditsItem
{
	asset imageAsset
	string name
	string description
	string description2
	string description_short
	string github
	string twitter
	int rarityLevel
}

struct
{
	var panel
	var listPanel

	bool hasLoaded = false
	int selectedIndex

	array<CreditsItem> creditItems
	table<var, int> buttonIndexTable
} file

void function InitCreditPanel( var panel )
{
	file.panel = panel

	SetPanelTabTitle( panel, "CREDITS" )

	AddPanelEventHandler( panel, eUIEvent.PANEL_SHOW, CreditsPanel_OnShow )

	AddPanelFooterOption( panel, LEFT, BUTTON_B, true, "#B_BUTTON_BACK", "#B_BUTTON_BACK" )

	file.listPanel = Hud_GetChild(panel, "CreditsList")
}

void function CreditsPanel_OnShow( var panel )
{
	UI_SetPresentationType( ePresentationType.CREDITS )

	if(IsLobby() && !file.hasLoaded)
	{
		LoadCredits()
		file.hasLoaded = true
	}
}

void function LoadCredits()
{
	file.creditItems.clear()

	file.selectedIndex = 0

	var dataTable = GetDataTable( $"datatable/custom/sdk_contributors.rpak" )
	int numRows = GetDatatableRowCount( dataTable )

	Hud_InitGridButtons( file.listPanel, numRows )

	var scrollPanel = Hud_GetChild( file.listPanel, "ScrollPanel" )

	for(int i = 0; i < numRows; i++)
	{
		CreditsItem newitem
		newitem.imageAsset = GetDataTableAsset( dataTable, i, GetDataTableColumnByName( dataTable, "imageAsset" ) )
		newitem.name = GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "name" ) )
		newitem.description = GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "description" ) )
		newitem.description2 = GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "description2" ) )
		newitem.description_short = GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "description_short" ) )
		newitem.github = GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "github" ) )
		newitem.twitter = GetDataTableString( dataTable, i, GetDataTableColumnByName( dataTable, "twitter" ) )
		newitem.rarityLevel = GetDataTableInt( dataTable, i, GetDataTableColumnByName( dataTable, "rarity" ) )

		file.creditItems.append(newitem)

		var button = Hud_GetChild( scrollPanel, "GridButton" + i )

		file.buttonIndexTable[button] <- i

		var rui = Hud_GetRui( button )
		RuiSetString( rui, "buttonText", newitem.name )
		RuiSetImage( rui, "buttonImage", newitem.imageAsset )
		RuiSetInt( rui, "quality", newitem.rarityLevel )
		Hud_SetEnabled( button, true )

		AddButtonEventHandler( button, UIE_CLICK, SelectCredits )
		AddButtonEventHandler( button, UIE_GET_FOCUS, OnCreditsHover )
		AddButtonEventHandler( button, UIE_LOSE_FOCUS, OnCreditsUnHover )
	}

	SelectCreditsItem(0, true)
}

void function SelectCredits ( var button )
{
	int index = file.buttonIndexTable[button]
	SelectCreditsItem(index, false)
}

void function OnCreditsHover ( var button )
{
	int index = file.buttonIndexTable[button]
	SelectCreditsItem(index, true)
}

void function OnCreditsUnHover ( var button )
{
	SelectCreditsItem(file.selectedIndex, true)
}

void function SelectCreditsItem(int index, bool preview)
{
	if(!preview)
	{
		file.selectedIndex = index
		EmitUISound( "UI_Menu_BattlePass_LevelTab" )
	}

	RuiSetImage( Hud_GetRui( Hud_GetChild(file.panel, "ProfilePicture") ), "basicImage", file.creditItems[index].imageAsset )
	Hud_SetText(Hud_GetChild(file.panel, "Name"), file.creditItems[index].name)
	Hud_SetText(Hud_GetChild(file.panel, "Github"), Localize(file.creditItems[index].github))
	Hud_SetText(Hud_GetChild(file.panel, "Twitter"), Localize(file.creditItems[index].twitter))
	Hud_SetText(Hud_GetChild(file.panel, "DescriptionShort"), Localize(file.creditItems[index].description_short))
	Hud_SetText(Hud_GetChild( file.panel, "Description" ), Localize(file.creditItems[index].description) + Localize(file.creditItems[index].description2))
}