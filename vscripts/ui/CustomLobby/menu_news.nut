global function InitR5RNews

const MAX_NEWS_ITEMS = 1

struct NewsPage
{
    string title
    string desc
    asset image
}

struct
{
	var menu
    var prevPageButton
    var nextPageButton
    
    int activePageIndex

    array<NewsPage> newspages

    bool navInputCallbacksRegistered = false
    
} file

void function InitR5RNews( var newMenuArg ) //
{
	var menu = GetMenu( "R5RNews" )
	file.menu = menu

	file.prevPageButton = Hud_GetChild( menu, "PrevPageButton" )
	HudElem_SetRuiArg( file.prevPageButton, "flipHorizontal", true )
	Hud_AddEventHandler( file.prevPageButton, UIE_CLICK, Page_NavLeft )

	file.nextPageButton = Hud_GetChild( menu, "NextPageButton" )
	Hud_AddEventHandler( file.nextPageButton, UIE_CLICK, Page_NavRight )

    for(int i = 0; i < MAX_NEWS_ITEMS; i++)
    {
        var button = Hud_GetChild( menu, "NewsItem" + (i + 1) )
	    Hud_AddEventHandler( button, UIE_CLICK, NewsItem_Activated )
    }

	SetGamepadCursorEnabled( menu, false )

	AddMenuEventHandler( menu, eUIEvent.MENU_OPEN, PromoDialog_OnOpen )
	//AddMenuEventHandler( menu, eUIEvent.MENU_CLOSE, PromoDialog_OnClose )
	AddMenuEventHandler( menu, eUIEvent.MENU_NAVIGATE_BACK, PromoDialog_OnNavigateBack )

	AddMenuFooterOption( menu, LEFT, BUTTON_B, true, "#B_BUTTON_CLOSE", "#B_BUTTON_CLOSE" )
}

void function NewsItem_Activated(var button)
{
    int id = Hud_GetScriptID( button ).tointeger()

    file.activePageIndex = id
    UpdatePageRui( file.activePageIndex )

    Hud_SetSelected( button, true )
	Hud_SetFocused( button )
}

void function Page_NavRight(var button)
{
    NavRight(true)
}

void function Page_NavLeft(var button)
{
    NavLeft(true)
}

void function Page_NavRightScrollWheel()
{
    NavRight(false)
}

void function Page_NavLeftScrollWheel()
{
    NavLeft(false)
}

void function NavRight(bool isbutton = false)
{
    file.activePageIndex++
    if ( file.activePageIndex > file.newspages.len() - 1 )
        file.activePageIndex = 0

    UpdatePageRui( file.activePageIndex )

    if(!isbutton)
        EmitUISound("UI_Menu_MOTD_Tab")
}

void function NavLeft(bool isbutton = false)
{
    file.activePageIndex--
    if ( file.activePageIndex < 0 )
        file.activePageIndex = file.newspages.len() - 1

    UpdatePageRui( file.activePageIndex )
    
    if(!isbutton)
        EmitUISound("UI_Menu_MOTD_Tab")
}

void function PromoDialog_OnNavigateBack()
{
    if(file.navInputCallbacksRegistered)
    {
        RemoveCallback_OnMouseWheelUp( Page_NavLeftScrollWheel )
        RemoveCallback_OnMouseWheelDown( Page_NavRightScrollWheel )
        file.navInputCallbacksRegistered = false
    }

	CloseActiveMenu()
}

void function PromoDialog_OnOpen()
{
    if(!file.navInputCallbacksRegistered)
    {
        AddCallback_OnMouseWheelUp( Page_NavLeftScrollWheel )
        AddCallback_OnMouseWheelDown( Page_NavRightScrollWheel )
        file.navInputCallbacksRegistered = true
    }

    //Get the news from the endpoint
    GetR5RNews()

	file.activePageIndex = 0
	UpdatePageRui( file.activePageIndex )
	UpdatePromoButtons()
}

void function GetR5RNews()
{
    //INFO FOR LATER
    //MAX PAGES = 6
    //TEMPOARY NEWS FOR TESTING
    //WILL BE REPLACED WITH A CALL TO THE NEWS ENDPOINT
    file.newspages.clear()

    for(int i = 0; i < 6; i++)  // Loop through 5 pages
    {
        NewsPage page
        if (i == 0)
        {
            page.title = "Patch Notes!"
            page.desc = "Check out the new patch notes from our blogpost!"
            page.image = GetAssetFromString( $"rui/promo/sdk_0".tostring() )
        }
        else if (i == 1)
        {
            page.title = "New Maps!"
            page.desc = "R5Reloaded now supports various new maps from season 4."
            page.image = GetAssetFromString( $"rui/promo/sdk_1".tostring() )
        }
		else if (i == 2)
        {
            page.title = "A fresh new look"
            page.desc = "R5Reloaded now uses season 4 theme, enjoy the new look!"
            page.image = GetAssetFromString( $"rui/promo/sdk_2".tostring() )
        }
		else if (i == 3)
        {
            page.title = "New Weapons"
            page.desc = "Apex added relic EPG? We added more! A lot of new titanfall weapons now available to play."
            page.image = GetAssetFromString( $"rui/promo/sdk_3".tostring() )
        }
		else if (i == 4)
        {
            page.title = "OTHER CHANGES AND BUG FIXES"
            page.desc = "So many new changes! Various bug fixes and more! Check out our blogpage for the full list."
            page.image = GetAssetFromString( $"rui/promo/sdk_4".tostring() )
        }
		else if (i == 5)
        {
            page.title = "MORE TO COME..."
            page.desc = "We are working on a lot more projects and can't wait to share it with you all."
            page.image = GetAssetFromString( $"rui/promo/sdk_5".tostring() )
        }

        file.newspages.append(page)
    }
}

void function UpdatePageRui( int pageIndex )
{
    int nextpage = pageIndex + 1
    if ( nextpage > file.newspages.len() - 1 )
        nextpage = 0

    int lastpage = pageIndex - 1
    if ( lastpage < 0 )
        lastpage = file.newspages.len() - 1

    RuiSetImage(Hud_GetRui( Hud_GetChild( file.menu, "CenterNewsImage" ) ), "loadscreenImage", file.newspages[pageIndex].image )
    Hud_SetText(Hud_GetChild( file.menu, "TitleText" ), file.newspages[pageIndex].title )
    Hud_SetText(Hud_GetChild( file.menu, "DescText" ), file.newspages[pageIndex].desc )

    Hud_SetPinSibling( Hud_GetChild( file.menu, "NewsItemSelected" ), Hud_GetHudName( Hud_GetChild( file.menu, "NewsItem" + (pageIndex + 1) ) ) )

    Hud_Hide(Hud_GetChild( file.menu, "RightNewsImage" ))
    Hud_Hide(Hud_GetChild( file.menu, "LeftNewsImage" ))

    if(file.newspages.len() > 1)
    {
        Hud_Show(Hud_GetChild( file.menu, "RightNewsImage" ))
        Hud_Show(Hud_GetChild( file.menu, "LeftNewsImage" ))
        RuiSetImage(Hud_GetRui( Hud_GetChild( file.menu, "RightNewsImage" ) ), "loadscreenImage", file.newspages[nextpage].image )
        RuiSetImage(Hud_GetRui( Hud_GetChild( file.menu, "LeftNewsImage" ) ), "loadscreenImage", file.newspages[lastpage].image )
    }

    SetSmallPreviewItems( pageIndex )
}

void function SetSmallPreviewItems( int pageIndex )
{
    int totalPages = file.newspages.len()

    // Hide all items first
    for(int j = 0; j < 5; j++)
    {
        Hud_Hide( Hud_GetChild( file.menu, "NewsItem" + (j + 1) ) )
    }

    // Calculate offset for page positioning
    int offset = 0

    // Show only the items we need (up to 6 items)
    for(int j = 0; j < totalPages && j < 6; j++)  // Show up to 6 items, depending on the total number of pages
    {
        Hud_Show( Hud_GetChild( file.menu, "NewsItem" + (j + 1) ) )

        if(j != 0)
            offset -= (Hud_GetWidth(Hud_GetChild( file.menu, "NewsItem1" )) / 2) + 6
    }

    // Adjust positioning of the first item (set to 0 for centering)
    Hud_SetX( Hud_GetChild( file.menu, "NewsItem1" ), 0 )

    // Only apply offset if there are more than 1 page
    if( totalPages > 1 )
        Hud_SetX( Hud_GetChild( file.menu, "NewsItem1" ), offset )

    // Update the content for each news item up to the number of available pages (or 6)
    int i = 1
    foreach( NewsPage page in file.newspages )
    {
        // Update the title, description, and image for each item
        if(i <= 6)  // Ensure we don't try to access more than 6 items
        {
            RuiSetString( Hud_GetRui( Hud_GetChild( file.menu, "NewsItem" + i ) ), "modeNameText", page.title )
            RuiSetString( Hud_GetRui( Hud_GetChild( file.menu, "NewsItem" + i ) ), "modeDescText", "" )
            RuiSetBool( Hud_GetRui( Hud_GetChild( file.menu, "NewsItem" + i )), "alwaysShowDesc", false )
            RuiSetImage( Hud_GetRui( Hud_GetChild( file.menu, "NewsItem" + i ) ), "modeImage", page.image )
        }

        i++

        // Stop if we've set content for the maximum number of news items
        if(i > 6)
            break
    }
}


void function UpdatePromoButtons()
{
	Hud_Hide( file.prevPageButton )
    Hud_Hide( file.nextPageButton )

	if ( file.newspages.len() > 1 )
    {
		Hud_Show( file.prevPageButton )
        Hud_Show( file.nextPageButton )
    }
    
	Hud_SetWidth( Hud_GetChild( file.menu, "FooterButtons" ), ContentScaledXAsInt( 200 ) )
}