scripts/resource/ui/menus/panels/serverbrowser.res
{
	"DarkenBackground"
	{
		"ControlName"			"Label"
		"xpos"					"0"
		"ypos"					"0"
		"wide"					"%100"
		"tall"					"%100"
		"labelText"				""
		"bgcolor_override"		"0 0 0 0"
		"visible"				"1"
		"paintbackground"		"1"
	}

	"ServerBrowserBG"
	{
		"ControlName"			"ImagePanel"
		"xpos"					"-225"
		"ypos"					"-70"
		"tall"					"50"
		"wide" 					"1395"
		fillColor		"50 50 50 255"
        drawColor		"50 50 50 255"
		"wrap"					"1"
		"visible"				"1"
		"zpos"					"3"

		"pin_to_sibling"		"DarkenBackground"
		"pin_corner_to_sibling"	"TOP"
		"pin_to_sibling_corner"	"TOP"
	}

	"ServersBG"
	{
		ControlName				RuiPanel
		rui                     "ui/basic_image.rpak"
		"xpos"					"0"
		"ypos"					"-22"
		"tall"					"656"
		"wide" 					"1395"
		"fillColor"				"30 30 30 120"
        "drawColor"				"30 30 30 120"
		"wrap"					"1"
		"visible"				"1"
		"zpos"					"0"
		scaleImage              1

        ruiArgs
        {
            // basicImage "rui/menu/character_skills/background"
			basicImage "rui/menu/lobby/tabs_background"
        }
         

		"pin_to_sibling"		"ServerBrowserBG"
		"pin_corner_to_sibling"	"TOP_LEFT"
		"pin_to_sibling_corner"	"BOTTOM_LEFT"
	}


	"DirectConnectServerBrowserBGBottom"
	{
		ControlName				RuiPanel
		rui                     "ui/basic_image.rpak"
		"xpos"					"0"
		"ypos"					"15"
		"tall"					"60"
		"wide" 					"1395"
		fillColor		"50 50 50 255"
        drawColor		"50 50 50 255"
		"wrap"					"1"
		"visible"				"1"
		"zpos"					"0"
        ruiArgs
        {
			basicImage "rui/menu/lobby/tabs_background"
        }

		"pin_to_sibling"		"ServersBG"
		"pin_corner_to_sibling"	"TOP"
		"pin_to_sibling_corner"	"BOTTOM"
	}

	"DirectConnectIPLabel"
	{
		"ControlName"			"Label"
		"labelText"				"IP Address"
		"xpos"					"-23"
		"ypos"					"-16"
		"auto_wide_tocontents"	"1"
		"zpos" 					"10"
		"fontHeight"			"30"

		ruiArgs
		{
			buttonText "IP Address"
		}

		pin_to_sibling 			DirectConnectServerBrowserBGBottom
		pin_corner_to_sibling	TOP_LEFT
		pin_to_sibling_corner	TOP_LEFT
	}

	DirectConnectIPTextEntry
	{
		ControlName				TextEntry
		zpos 100 // This works around input weirdness when the control is constructed by code instead of VGUI blackbox.
		xpos 10
		ypos 0
		wide 180
		tall 40
		zpos					70
		allowRightClickMenu		0
		allowSpecialCharacters	0
		unicode					1

		visible					1
		enabled					1
		textHidden				0
		editable				1
		maxchars				100
		textAlignment			"center"
		ruiFont                 TitleRegularFont
		ruiFontHeight           22
		ruiMinFontHeight        16
		bgcolor_override		"30 30 30 200"

		pin_to_sibling 			DirectConnectIPLabel
		pin_corner_to_sibling LEFT
		pin_to_sibling_corner RIGHT
	}

	"DirectConnectNetKeyLabel"
	{
		"ControlName"			"Label"
		"labelText"				"NetKey"
		"xpos"					"15"
		"ypos"					"0"
		"auto_wide_tocontents"	"1"
		"zpos" 					"10"
		"fontHeight"			"30"

		ruiArgs
		{
			buttonText "NetKey"
		}

		pin_to_sibling 			DirectConnectIPTextEntry
		pin_corner_to_sibling	LEFT
		pin_to_sibling_corner	RIGHT
	}

	DirectConnectNetKeyTextEntry
	{
		ControlName				TextEntry
		zpos 100 // This works around input weirdness when the control is constructed by code instead of VGUI blackbox.
		xpos 10
		ypos 0
		wide 300
		tall 40
		zpos					70
		allowRightClickMenu		0
		allowSpecialCharacters	0
		unicode					1

		visible					1
		enabled					1
		textHidden				0
		editable				1
		maxchars				100
		textAlignment			"center"
		ruiFont                 TitleRegularFont
		ruiFontHeight           22
		ruiMinFontHeight        16
		bgcolor_override		"30 30 30 200"

		pin_to_sibling 			DirectConnectNetKeyLabel
		pin_corner_to_sibling LEFT
		pin_to_sibling_corner RIGHT
	}

	"DirectConnectTokenLabel"
	{
		"ControlName"			"Label"
		"labelText"				"Token"
		"xpos"					"15"
		"ypos"					"0"
		"auto_wide_tocontents"	"1"
		"zpos" 					"10"
		"fontHeight"			"30"

		ruiArgs
		{
			buttonText "Token"
		}

		pin_to_sibling 			DirectConnectNetKeyTextEntry
		pin_corner_to_sibling	LEFT
		pin_to_sibling_corner	RIGHT
	}

	DirectConnectTokenTextEntry
	{
		ControlName				TextEntry
		zpos 100 // This works around input weirdness when the control is constructed by code instead of VGUI blackbox.
		xpos 10
		ypos 0
		wide 300
		tall 40
		zpos					70
		allowRightClickMenu		0
		allowSpecialCharacters	0
		unicode					1

		visible					1
		enabled					1
		textHidden				0
		editable				1
		maxchars				100
		textAlignment			"center"
		ruiFont                 TitleRegularFont
		ruiFontHeight           22
		ruiMinFontHeight        16
		bgcolor_override		"30 30 30 200"

		pin_to_sibling 			DirectConnectTokenLabel
		pin_corner_to_sibling LEFT
		pin_to_sibling_corner RIGHT
	}

	"DirectConnectButton"
	{
		ControlName				RuiButton
		wide					260
        tall					40
        //rui                     "ui/generic_ready_button.rpak"
        //rui                     "ui/tab_button.rpak"
        rui                     "ui/footer_button.rpak"
		xpos 20
		ypos 0
		zpos 6

		ruiArgs
		{
			buttonText "DIRECT CONNECT"
		}

        sound_focus             "UI_Menu_Focus_Large"

		"pin_to_sibling"		"DirectConnectTokenTextEntry"
		"pin_corner_to_sibling"	"LEFT"
		"pin_to_sibling_corner"	"RIGHT"
	}


	"ServerBrowserBGBottom"
	{
		"ControlName"			"ImagePanel"
		"xpos"					"0"
		"ypos"					"15"
		"tall"					"115"
		"wide" 					"1395"
		fillColor		"50 50 50 255"
        drawColor		"50 50 50 255"
		"wrap"					"1"
		"visible"				"1"
		"zpos"					"0"

		"pin_to_sibling"		"DirectConnectServerBrowserBGBottom"
		"pin_corner_to_sibling"	"TOP"
		"pin_to_sibling_corner"	"BOTTOM"
	}

	"BtnSearchLabel"
	{
		"ControlName"			"Label"
		"labelText"				""
		"xpos"					"-20"
		"ypos"					"-27"
		"auto_wide_tocontents"	"1"
		"zpos" 					"10"
		"fontHeight"			"30"

		ruiArgs
		{
			buttonText ""
		}

		pin_to_sibling 			ServerBrowserBGBottom
		pin_corner_to_sibling	TOP_LEFT
		pin_to_sibling_corner	TOP_LEFT
	}

	BtnServerSearch
	{
		ControlName				TextEntry
		zpos 100 // This works around input weirdness when the control is constructed by code instead of VGUI blackbox.
		xpos 10
		ypos 0
		wide 210
		tall 50
		zpos					70
		allowRightClickMenu		0
		allowSpecialCharacters	0
		unicode					1

		visible					1
		enabled					1
		textHidden				0
		editable				1
		maxchars				100
		textAlignment			"center"
		ruiFont                 TitleRegularFont
		ruiFontHeight           22
		ruiMinFontHeight        16
		bgcolor_override		"30 30 30 200"

		pin_to_sibling 			BtnSearchLabel
		pin_corner_to_sibling LEFT
		pin_to_sibling_corner RIGHT
	}

	SwtBtnSelectGamemode
	{
		ControlName RuiButton
		InheritProperties SwitchButton
		style                   DialogListButton
		ConVar "serverbrowser_gameModeFilter"
		wide 365
		xpos 15
		ypos 0

		ruiArgs
		{
			buttonText ""
		}

		pin_to_sibling BtnServerSearch
		pin_corner_to_sibling LEFT
		pin_to_sibling_corner RIGHT

		childGroupAlways        MultiChoiceButtonAlways
	}

	SwtBtnSelectMap
	{
		ControlName RuiButton
		InheritProperties SwitchButton
		style                   DialogListButton
		ConVar "serverbrowser_mapFilter"
		wide 365
		ypos 0
		xpos 15

		ruiArgs
		{
			buttonText ""
		}

		pin_to_sibling SwtBtnSelectGamemode
		pin_corner_to_sibling LEFT
		pin_to_sibling_corner RIGHT

		childGroupAlways        MultiChoiceButtonAlways
	}

	SwtBtnHideEmpty
	{
		ControlName RuiButton
		InheritProperties SwitchButton
		style                   DialogListButton
		ConVar "serverbrowser_hideEmptyServers"
		classname FilterPanelChild
		wide 365
		xpos 15
		ypos 0

		ruiArgs
		{
			buttonText ""
		}

		list
		{
			"Show empty" 0
			"Hide empty" 1
		}

		pin_to_sibling SwtBtnSelectMap
		pin_corner_to_sibling LEFT
		pin_to_sibling_corner RIGHT

		childGroupAlways        MultiChoiceButtonAlways
	}


	"NoServersLbl"
	{
		"ControlName"			"Label"
		"labelText"				"#FS_NO_SERVERS_FOUND"
		"xpos"					"0"
		"ypos"					"-10"
		"auto_wide_tocontents"	"1"
		"zpos" 					"10"
		"fontHeight"			"40"

		"pin_to_sibling"		"ServersBG"
		"pin_corner_to_sibling"	"CENTER"
		"pin_to_sibling_corner"	"CENTER"
	}

	"RefreshServers"
	{
		"ControlName"				"RuiButton"
		"style"						"RuiButton"
		"wide"						"200"
		"tall"						"35"
		"xpos"						"-5"
		"ypos"						"-5"
		"visible"					"1"
		"enabled"					"1"
		"zpos" 						"10"
        "rui"						"ui/tab_button.rpak"
		"cursorVelocityModifier"  	"0.7"

		ruiArgs
		{
			buttonText ""
		}

		"pin_to_sibling"			"ServerBrowserBGBottom"
		"pin_corner_to_sibling"		"BOTTOM_LEFT"
		"pin_to_sibling_corner"		"BOTTOM_LEFT"
	}

	"RefreshServersText"
	{
		"ControlName"			"Label"
		"labelText"				"#FS_REFRESH_SERVERS"
		"font"					"DefaultBold_41"
		"allcaps"				"1"
		"auto_wide_tocontents"	"1"
		"zpos" 					"0"
		"fontHeight"			"25"
		"xpos"					"0"
		"ypos"					"0"
		"zpos" 					"9"
		"fgcolor_override"		"255 255 255 255"

		"pin_to_sibling"		"RefreshServers"
		"pin_corner_to_sibling"	"CENTER"
		"pin_to_sibling_corner"	"CENTER"
	}

	"ClearFliters"
	{
		"ControlName"				"RuiButton"
		"style"						"RuiButton"
		"wide"						"200"
		"tall"						"35"
		"xpos"						"5"
		"ypos"						"0"
		"visible"					"1"
		"enabled"					"1"
		"zpos" 						"10"
        "rui"						"ui/tab_button.rpak"
		"cursorVelocityModifier"  	"0.7"

		ruiArgs
		{
			buttonText ""
		}

		"pin_to_sibling"			"RefreshServers"
		"pin_corner_to_sibling"		"BOTTOM_LEFT"
		"pin_to_sibling_corner"		"BOTTOM_RIGHT"
	}

	"ClearFlitersText"
	{
		"ControlName"			"Label"
		"labelText"				"#FS_CLEAR_FILTERS"
		"font"					"DefaultBold_41"
		"allcaps"				"1"
		"auto_wide_tocontents"	"1"
		"zpos" 					"0"
		"fontHeight"			"25"
		"xpos"					"0"
		"ypos"					"0"
		"zpos" 					"9"
		"fgcolor_override"		"255 255 255 255"

		"pin_to_sibling"		"ClearFliters"
		"pin_corner_to_sibling"	"CENTER"
		"pin_to_sibling_corner"	"CENTER"
	}

	"ListSliderBG"
	{
		"ControlName"			"ImagePanel"
		wide 24
		tall 687
		xpos 6
		ypos 30
		zpos 0
        "fillColor"				"195 29 38 255"
		scaleImage				1
		"visible"				"0"

		pin_to_sibling ServersBG
		pin_corner_to_sibling TOP_LEFT
		pin_to_sibling_corner TOP_RIGHT
	}

	BtnServerListSlider
	{
		ControlName RuiButton
		InheritProperties RuiSmallButton
		//labelText "V"
		wide 22
		tall 687
		xpos -10
		ypos 30
		zpos 0

		image "vgui/hud/white"
		drawColor "255 255 255 255"

		pin_to_sibling ListSliderBG
		pin_corner_to_sibling TOP_LEFT
		pin_to_sibling_corner TOP_LEFT
	}

	BtnServerListSliderPanel
	{
		ControlName RuiPanel
		wide 22
		tall 687
		xpos -10
		ypos 30
		zpos 100

		rui "ui/control_options_description.rpak"

		visible 1
		zpos -1

		pin_to_sibling ListSliderBG
		pin_corner_to_sibling TOP_LEFT
		pin_to_sibling_corner TOP_LEFT
	}

	// sh_menu_models.gnut has a global function which gets called when
	// left mouse button gets called while hovering and has mouse
	// deltaX; deltaY which we can yoink for ourselfes
	MouseMovementCapture
	{
		ControlName CMouseMovementCapturePanel
		wide 22
		tall 550
		xpos 10
		ypos 1
		zpos 100

		pin_to_sibling ServersBG
		pin_corner_to_sibling TOP_LEFT
		pin_to_sibling_corner TOP_RIGHT
	}

	BtnServerListUpArrow
	{
		ControlName RuiButton
		InheritProperties RuiSmallButton
		//labelText "A"
		wide 22
		tall 45
		xpos -4
		ypos 0
		zpos 5

		image "vgui/hud/white"
		drawColor "255 255 255 128"

		pin_to_sibling ListSliderBG
		pin_corner_to_sibling TOP
		pin_to_sibling_corner TOP
	}

	BtnServerListUpArrowPanel
	{
		ControlName RuiPanel
		wide 22
		tall 45
		xpos -4
		ypos 0

		rui "ui/control_options_description.rpak"

		visible 1
		zpos 4

		pin_to_sibling ListSliderBG
		pin_corner_to_sibling TOP
		pin_to_sibling_corner TOP
	}

	BtnServerListDownArrow
	{
		ControlName RuiButton
		InheritProperties RuiSmallButton
		//labelText "A"
		wide 22
		tall 45
		xpos -4
		ypos 0
		zpos 5

		image "vgui/hud/white"
		drawColor "255 255 255 128"

		pin_to_sibling ListSliderBG
		pin_corner_to_sibling BOTTOM
		pin_to_sibling_corner BOTTOM
	}

	BtnServerListDownArrowPanel
	{
		ControlName RuiPanel
		wide 22
		tall 45
		xpos -4
		ypos 0

		rui "ui/control_options_description.rpak"

		visible 1
		zpos 4

		pin_to_sibling ListSliderBG
		pin_corner_to_sibling BOTTOM
		pin_to_sibling_corner BOTTOM
	}

	"ServersCount"
	{
		"ControlName"			"Label"
		"labelText"				"Servers: 0"
		"font"					"DefaultBold_41"
		"allcaps"				"1"
		"auto_wide_tocontents"	"1"
		"zpos" 					"7"
		"fontHeight"			"25"
		"xpos"					"-25"
		"ypos"					"-10"
		"fgcolor_override"		"255 255 255 255"

		"pin_to_sibling"		"ServerBrowserBGBottom"
		"pin_corner_to_sibling"	"BOTTOM_RIGHT"
		"pin_to_sibling_corner"	"BOTTOM_RIGHT"
	}
	
	"PlayersCount"
	{
		"ControlName"			"Label"
		"labelText"				"Players: 0"
		"font"					"DefaultBold_41"
		"allcaps"				"1"
		"auto_wide_tocontents"	"1"
		"zpos" 					"7"
		"visible"				"1"
		"fontHeight"			"25"
		"xpos"					"30"
		"ypos"					"0"
		"fgcolor_override"		"255 255 255 255"

		"pin_to_sibling"		"ServersCount"
		"pin_corner_to_sibling"	"RIGHT"
		"pin_to_sibling_corner"	"LEFT"
	}

	"ServerNameLbl"
	{
		"ControlName"			"Label"
		"labelText"				"#FS_SERVER_NAME"
		"xpos"					"-15"
		"ypos"					"0"
		"zpos"					"6"
		"textalignment"			"center"
		"wide"					"150"
		"zpos" 					"4"
		"fontHeight"			"35"
		"tall"					"35"

		"pin_to_sibling"		"ServerBrowserBG"
		"pin_corner_to_sibling"	"LEFT"
		"pin_to_sibling_corner"	"LEFT"
	}

	"PlayerCountLbl"
	{
		"ControlName"			"Label"
		"labelText"				"#FS_PLAYERS"
		"xpos"					"-670"
		"ypos"					"0"
		"zpos"					"6"
		"textalignment"			"center"
		"wide"					"110"
		"zpos" 					"4"
		"fontHeight"			"35"
		"tall"					"35"

		"pin_to_sibling"		"ServerBrowserBG"
		"pin_corner_to_sibling"	"LEFT"
		"pin_to_sibling_corner"	"LEFT"
	}

	"PlaylistLbl"
	{
		"ControlName"			"Label"
		"labelText"				"#FS_PLAYLIST"
		"xpos"					"-800"
		"ypos"					"0"
		"zpos"					"6"
		"textalignment"			"center"
		"wide"					"230"
		"fontHeight"			"35"
		"tall"					"35"

		"pin_to_sibling"		"ServerBrowserBG"
		"pin_corner_to_sibling"	"LEFT"
		"pin_to_sibling_corner"	"LEFT"
	}

	"MapLbl"
	{
		"ControlName"			"Label"
		"labelText"				"#FS_MAP"
		"xpos"					"-1050"
		"ypos"					"0"
		"zpos"					"6"
		"textalignment"			"center"
		"wide"					"330"
		"fontHeight"			"35"
		"tall"					"35"

		"pin_to_sibling"		"ServerBrowserBG"
		"pin_corner_to_sibling"	"LEFT"
		"pin_to_sibling_corner"	"LEFT"
	}

	"ServerNameLine"
	{
		"ControlName"			"ImagePanel"
		"xpos"					"0"
		"ypos"					"0"
		"tall"					"634"
		"wide" 					"2"
		"fillColor"				"155 155 155 200"
        "drawColor"				"155 155 155 200"
		"wrap"					"1"
		"visible"				"1"
		"zpos"					"3"

		"pin_to_sibling"		"ServerBrowserBG"
		"pin_corner_to_sibling"	"TOP_LEFT"
		"pin_to_sibling_corner"	"BOTTOM_LEFT"
	}

	"PlayerCountLine"
	{
		"ControlName"			"ImagePanel"
		"xpos"					"-660"
		"ypos"					"0"
		"tall"					"634"
		"wide" 					"2"
		"fillColor"				"155 155 155 200"
        "drawColor"				"155 155 155 200"
		"wrap"					"1"
		"visible"				"1"
		"zpos"					"3"

		"pin_to_sibling"		"ServerBrowserBG"
		"pin_corner_to_sibling"	"TOP_LEFT"
		"pin_to_sibling_corner"	"BOTTOM_LEFT"
	}

	"PlaylistLine"
	{
		"ControlName"			"ImagePanel"
		"xpos"					"-790"
		"ypos"					"0"
		"tall"					"634"
		"wide" 					"2"
		"fillColor"				"155 155 155 200"
        "drawColor"				"155 155 155 200"
		"wrap"					"1"
		"visible"				"1"
		"zpos"					"3"

		"pin_to_sibling"		"ServerBrowserBG"
		"pin_corner_to_sibling"	"TOP_LEFT"
		"pin_to_sibling_corner"	"BOTTOM_LEFT"
	}

	"MapLine"
	{
		"ControlName"			"ImagePanel"
		"xpos"					"-1040"
		"ypos"					"0"
		"tall"					"634"
		"wide" 					"2"
		"fillColor"				"155 155 155 200"
        "drawColor"				"155 155 155 200"
		"wrap"					"1"
		"visible"				"1"
		"zpos"					"3"

		"pin_to_sibling"		"ServerBrowserBG"
		"pin_corner_to_sibling"	"TOP_LEFT"
		"pin_to_sibling_corner"	"BOTTOM_LEFT"
	}

	"RightLine"
	{
		"ControlName"			"ImagePanel"
		"xpos"					"0"
		"ypos"					"0"
		"tall"					"634"
		"wide" 					"2"
		"fillColor"				"155 155 155 200"
        "drawColor"				"155 155 155 200"
		"wrap"					"1"
		"visible"				"1"
		"zpos"					"3"

		"pin_to_sibling"		"ServerBrowserBG"
		"pin_corner_to_sibling"	"TOP_RIGHT"
		"pin_to_sibling_corner"	"BOTTOM_RIGHT"
	}

	"ServerMapImg"
	{
		"ControlName"			"RuiPanel"
		"wide"					"430"
		"tall"            		"250"
		"visible"				"1"
		rui                     "ui/gamemode_select_v2_button.rpak"
		"xpos"					"31"
		"zpos" 					"4"
		polyShape               "5.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0"

        ruiArgs
        {
            lockIconEnabled 0
            modeNameText ""
            modeDescText ""
            alwaysShowDesc 0
        }

		"pin_to_sibling"		"ServerBrowserBG"
		"pin_corner_to_sibling"	"TOP_LEFT"
		"pin_to_sibling_corner"	"TOP_RIGHT"
		
	}

	"ServerInfoBG"
	{
		ControlName				RuiPanel
		rui                     "ui/basic_image.rpak"
		ypos					15
        "tall"					"495"
		"wide" 					"430"
		visible					1
		scaleImage              1

        ruiArgs
        {
            basicImage "rui/menu/lobby/tabs_background"
        }

        "pin_to_sibling"		"ServerMapImg"
		"pin_corner_to_sibling"	"TOP_LEFT"
		"pin_to_sibling_corner"	"BOTTOM_LEFT"
	}

	"ServerNameInfoEdit"
	{
		"ControlName"			"Label"
		"labelText"				""
		"font"					"Default_27_Outline"
		"allcaps"				"1"
		"wide"					"420"
		"tall"					"60"
		"wrap"					"1"
		"zpos" 					"7"
		"fontHeight"			"32"
		"xpos"					"10"
		"ypos"					"-15"
		"textAlignment"			"center"
		fgcolor_override		"240 240 240 255"
		"bgcolor_override"		"0 0 0 255"

		"pin_to_sibling"		"ServerInfoBG"
		"pin_corner_to_sibling"	"TOP"
		"pin_to_sibling_corner"	"TOP"
	}

	"ServerCurrentMap"
	{
		"ControlName"			"Label"
		"labelText"				""
		"font"					"Default_27_Outline"
		"allcaps"				"1"
		"wide"					"100"
		"zpos" 					"7"
		"fontHeight"			"20"
		"xpos"					"-15"
		"ypos"					"-75"
		"textAlignment"			"left"
		fgcolor_override		"240 240 240 255"
		"bgcolor_override"		"0 0 0 255"

		"pin_to_sibling"		"ServerInfoBG"
		"pin_corner_to_sibling"	"TOP_LEFT"
		"pin_to_sibling_corner"	"TOP_LEFT"
	}

	"ServerCurrentMapEdit"
	{
		"ControlName"			"Label"
		"textAlignment"			"east"
		"labelText"				""
		"font"					"Default_27_Outline"
		"allcaps"				"1"
		"wide"					"270"
		"zpos" 					"7"
		"fontHeight"			"20"
		"xpos"					"-15"
		"ypos"					"-75"
		fgcolor_override		"240 240 240 255"
		"bgcolor_override"		"0 0 0 255"

		"pin_to_sibling"		"ServerInfoBG"
		"pin_corner_to_sibling"	"TOP_RIGHT"
		"pin_to_sibling_corner"	"TOP_RIGHT"
	}

	"ServerCurrentPlaylist"
	{
		"ControlName"			"Label"
		"labelText"				""
		"font"					"Default_27_Outline"
		"allcaps"				"1"
		"wide"					"130"
		"zpos" 					"7"
		"fontHeight"			"20"
		"xpos"					"-15"
		"ypos"					"-105"
		"textAlignment"			"left"
		fgcolor_override		"240 240 240 255"
		"bgcolor_override"		"0 0 0 255"

		"pin_to_sibling"		"ServerInfoBG"
		"pin_corner_to_sibling"	"TOP_LEFT"
		"pin_to_sibling_corner"	"TOP_LEFT"
	}

	"PlaylistInfoEdit"
	{
		"ControlName"			"Label"
		"labelText"				""
		"font"					"Default_27_Outline"
		"allcaps"				"1"
		"wide"					"270"
		"zpos" 					"7"
		"fontHeight"			"20"
		"xpos"					"-15"
		"ypos"					"-105"
		"textAlignment"			"east"
		"fgcolor_override"		"240 240 240 255"
		"bgcolor_override"		"0 0 0 255"

		"pin_to_sibling"		"ServerInfoBG"
		"pin_corner_to_sibling"	"TOP_RIGHT"
		"pin_to_sibling_corner"	"TOP_RIGHT"
	}

	"ServerDesc"
	{
		"ControlName"			"Label"
		"labelText"				""
		"wide"					"390"
		"tall"					"330"
		"wrap"					"1"
		"zpos" 					"7"
		"fontHeight"			"25"
		"xpos"					"-15"
		"ypos"					"-145"
		"textAlignment"			"north-west"
		"fgcolor_override"		"255 255 255 255"

		"pin_to_sibling"		"ServerInfoBG"
		"pin_corner_to_sibling"	"TOP_LEFT"
		"pin_to_sibling_corner"	"TOP_LEFT"
	}

	"ConnectButton"
	{
		ControlName				RuiButton
		wide					430
        tall					112
        rui                     "ui/generic_ready_button.rpak"
		xpos 0
		ypos 15
		zpos 6

		ruiArgs
		{
			buttonText "CONNECT"
		}


		"pin_to_sibling"		"ServerInfoBG"
		"pin_corner_to_sibling"	"TOP"
		"pin_to_sibling_corner"	"BOTTOM"
	}

	"ServerButton0"
	{
		"ControlName"				"RuiButton"
		"classname"					"ServBtn"
		"wide"						"1395"
		"tall"						"45"
		"doubleClickEvents"       	"1"
		"visible"					"1"
		"enabled"					"1"
		"style"						"RuiButton"
        "rui"						"ui/tab_button.rpak"
		"labelText"					""
		"cursorVelocityModifier"  	"0.7"
		"zpos"						"1"
		"scriptID"					"0"
		

		"pin_to_sibling"			"ServerBrowserBG"
		"pin_corner_to_sibling"		"TOP_LEFT"
		"pin_to_sibling_corner"		"BOTTOM_LEFT"
	}

	"ServerButton1"
	{
		"ControlName"				"RuiButton"
		"classname"					"ServBtn"
		"wide"						"1395"
		"tall"						"45"
		"doubleClickEvents"       	"1"
		"visible"					"1"
		"enabled"					"1"
		"style"						"RuiButton"
        "rui"						"ui/tab_button.rpak"
		"labelText"					""
		"cursorVelocityModifier"  	"0.7"
		"zpos"						"1"
		"scriptID"					"1"

		"pin_to_sibling"			"ServerButton0"
		"pin_corner_to_sibling"		"TOP_LEFT"
		"pin_to_sibling_corner"		"BOTTOM_LEFT"
	}

	"ServerButton2"
	{
		"ControlName"				"RuiButton"
		"classname"					"ServBtn"
		"wide"						"1395"
		"tall"						"45"
		"doubleClickEvents"       	"1"
		"visible"					"1"
		"enabled"					"1"
		"style"						"RuiButton"
        "rui"						"ui/tab_button.rpak"
		"labelText"					""
		"cursorVelocityModifier"  	"0.7"
		"zpos"						"1"
		"scriptID"					"2"

		"pin_to_sibling"			"ServerButton1"
		"pin_corner_to_sibling"		"TOP_LEFT"
		"pin_to_sibling_corner"		"BOTTOM_LEFT"
	}

	"ServerButton3"
	{
		"ControlName"				"RuiButton"
		"classname"					"ServBtn"
		"wide"						"1395"
		"tall"						"45"
		"doubleClickEvents"       	"1"
		"visible"					"1"
		"enabled"					"1"
		"style"						"RuiButton"
        "rui"						"ui/tab_button.rpak"
		"labelText"					""
		"cursorVelocityModifier"  	"0.7"
		"zpos"						"1"
		"scriptID"					"3"

		"pin_to_sibling"			"ServerButton2"
		"pin_corner_to_sibling"		"TOP_LEFT"
		"pin_to_sibling_corner"		"BOTTOM_LEFT"
	}

	"ServerButton4"
	{
		"ControlName"				"RuiButton"
		"classname"					"ServBtn"
		"wide"						"1395"
		"tall"						"45"
		"doubleClickEvents"       	"1"
		"visible"					"1"
		"enabled"					"1"
		"style"						"RuiButton"
        "rui"						"ui/tab_button.rpak"
		"labelText"					""
		"cursorVelocityModifier"  	"0.7"
		"zpos"						"1"
		"scriptID"					"4"

		"pin_to_sibling"			"ServerButton3"
		"pin_corner_to_sibling"		"TOP_LEFT"
		"pin_to_sibling_corner"		"BOTTOM_LEFT"
	}

	"ServerButton5"
	{
		"ControlName"				"RuiButton"
		"classname"					"ServBtn"
		"wide"						"1395"
		"tall"						"45"
		"doubleClickEvents"       	"1"
		"visible"					"1"
		"enabled"					"1"
		"style"						"RuiButton"
        "rui"						"ui/tab_button.rpak"
		"labelText"					""
		"cursorVelocityModifier"  	"0.7"
		"zpos"						"1"
		"scriptID"					"5"

		"pin_to_sibling"			"ServerButton4"
		"pin_corner_to_sibling"		"TOP_LEFT"
		"pin_to_sibling_corner"		"BOTTOM_LEFT"
	}

	"ServerButton6"
	{
		"ControlName"				"RuiButton"
		"classname"					"ServBtn"
		"wide"						"1395"
		"tall"						"45"
		"doubleClickEvents"       	"1"
		"visible"					"1"
		"enabled"					"1"
		"style"						"RuiButton"
        "rui"						"ui/tab_button.rpak"
		"labelText"					""
		"cursorVelocityModifier"  	"0.7"
		"zpos"						"1"
		"scriptID"					"6"

		"pin_to_sibling"			"ServerButton5"
		"pin_corner_to_sibling"		"TOP_LEFT"
		"pin_to_sibling_corner"		"BOTTOM_LEFT"
	}

	"ServerButton7"
	{
		"ControlName"				"RuiButton"
		"classname"					"ServBtn"
		"wide"						"1395"
		"tall"						"45"
		"doubleClickEvents"       	"1"
		"visible"					"1"
		"enabled"					"1"
		"style"						"RuiButton"
        "rui"						"ui/tab_button.rpak"
		"labelText"					""
		"cursorVelocityModifier"  	"0.7"
		"zpos"						"1"
		"scriptID"					"7"

		"pin_to_sibling"			"ServerButton6"
		"pin_corner_to_sibling"		"TOP_LEFT"
		"pin_to_sibling_corner"		"BOTTOM_LEFT"
	}

	"ServerButton8"
	{
		"ControlName"				"RuiButton"
		"classname"					"ServBtn"
		"wide"						"1395"
		"tall"						"45"
		"doubleClickEvents"       	"1"
		"visible"					"1"
		"enabled"					"1"
		"style"						"RuiButton"
        "rui"						"ui/tab_button.rpak"
		"labelText"					""
		"cursorVelocityModifier"  	"0.7"
		"zpos"						"1"
		"scriptID"					"8"

		"pin_to_sibling"			"ServerButton7"
		"pin_corner_to_sibling"		"TOP_LEFT"
		"pin_to_sibling_corner"		"BOTTOM_LEFT"
	}

	"ServerButton9"
	{
		"ControlName"				"RuiButton"
		"classname"					"ServBtn"
		"wide"						"1395"
		"tall"						"45"
		"doubleClickEvents"       	"1"
		"visible"					"1"
		"enabled"					"1"
		"style"						"RuiButton"
        "rui"						"ui/tab_button.rpak"
		"labelText"					""
		"cursorVelocityModifier"  	"0.7"
		"zpos"						"1"
		"scriptID"					"9"

		"pin_to_sibling"			"ServerButton8"
		"pin_corner_to_sibling"		"TOP_LEFT"
		"pin_to_sibling_corner"		"BOTTOM_LEFT"
	}

	"ServerButton10"
	{
		"ControlName"				"RuiButton"
		"classname"					"ServBtn"
		"wide"						"1395"
		"tall"						"45"
		"doubleClickEvents"       	"1"
		"visible"					"1"
		"enabled"					"1"
		"style"						"RuiButton"
        "rui"						"ui/tab_button.rpak"
		"labelText"					""
		"cursorVelocityModifier"  	"0.7"
		"zpos"						"1"
		"scriptID"					"10"

		"pin_to_sibling"			"ServerButton9"
		"pin_corner_to_sibling"		"TOP_LEFT"
		"pin_to_sibling_corner"		"BOTTOM_LEFT"
	}

	"ServerButton11"
	{
		"ControlName"				"RuiButton"
		"classname"					"ServBtn"
		"wide"						"1395"
		"tall"						"45"
		"doubleClickEvents"       	"1"
		"visible"					"1"
		"enabled"					"1"
		"style"						"RuiButton"
        "rui"						"ui/tab_button.rpak"
		"labelText"					""
		"cursorVelocityModifier"  	"0.7"
		"zpos"						"1"
		"scriptID"					"11"

		"pin_to_sibling"			"ServerButton10"
		"pin_corner_to_sibling"		"TOP_LEFT"
		"pin_to_sibling_corner"		"BOTTOM_LEFT"
	}

	"ServerButton12"
	{
		"ControlName"				"RuiButton"
		"classname"					"ServBtn"
		"wide"						"1395"
		"tall"						"45"
		"doubleClickEvents"       	"1"
		"visible"					"1"
		"enabled"					"1"
		"style"						"RuiButton"
        "rui"						"ui/tab_button.rpak"
		"labelText"					""
		"cursorVelocityModifier"  	"0.7"
		"zpos"						"1"
		"scriptID"					"12"

		"pin_to_sibling"			"ServerButton11"
		"pin_corner_to_sibling"		"TOP_LEFT"
		"pin_to_sibling_corner"		"BOTTOM_LEFT"
	}

	"ServerButton13"
	{
		"ControlName"				"RuiButton"
		"classname"					"ServBtn"
		"wide"						"1395"
		"tall"						"45"
		"doubleClickEvents"       	"1"
		"visible"					"1"
		"enabled"					"1"
		"style"						"RuiButton"
        "rui"						"ui/tab_button.rpak"
		"labelText"					""
		"cursorVelocityModifier"  	"0.7"
		"zpos"						"1"
		"scriptID"					"13"

		"pin_to_sibling"			"ServerButton12"
		"pin_corner_to_sibling"		"TOP_LEFT"
		"pin_to_sibling_corner"		"BOTTOM_LEFT"
	}

	// "ServerButton14"
	// {
	// 	"ControlName"				"RuiButton"
	// 	"classname"					"ServBtn"
	// 	"wide"						"1395"
	// 	"tall"						"45"
	// 	"doubleClickEvents"       	"1"
	// 	"visible"					"1"
	// 	"enabled"					"1"
	// 	"style"						"RuiButton"
    //     "rui"						"ui/tab_button.rpak"
	// 	"labelText"					""
	// 	"cursorVelocityModifier"  	"0.7"
	// 	"zpos"						"1"
	// 	"scriptID"					"14"

	// 	"pin_to_sibling"			"ServerButton13"
	// 	"pin_corner_to_sibling"		"TOP_LEFT"
	// 	"pin_to_sibling_corner"		"BOTTOM_LEFT"
	// }

	"ServerName0"
	{
		"ControlName"				"Label"
		"labelText"					""
		"xpos"						"-15"
		"ypos"						"0"
		"zpos"						"0"
		"wide"						"630"
		"zpos" 						"4"
		"fontHeight"				"35"
		"tall"						"48"
		"classname"					"ServerLabels"

		"pin_to_sibling"			"ServerButton0"
		"pin_corner_to_sibling"		"LEFT"
		"pin_to_sibling_corner"		"LEFT"
	}

	"ServerName1"
	{
		"ControlName"				"Label"
		"labelText"					""
		"xpos"						"-15"
		"ypos"						"0"
		"zpos"						"0"
		"wide"						"630"
		"zpos" 						"4"
		"fontHeight"				"35"
		"tall"						"48"
		"classname"					"ServerLabels"

		"pin_to_sibling"			"ServerButton1"
		"pin_corner_to_sibling"		"LEFT"
		"pin_to_sibling_corner"		"LEFT"
	}

	"ServerName2"
	{
		"ControlName"				"Label"
		"labelText"					""
		"xpos"						"-15"
		"ypos"						"0"
		"zpos"						"0"
		"wide"						"630"
		"zpos" 						"4"
		"fontHeight"				"35"
		"tall"						"48"
		"classname"					"ServerLabels"

		"pin_to_sibling"			"ServerButton2"
		"pin_corner_to_sibling"		"LEFT"
		"pin_to_sibling_corner"		"LEFT"
	}

	"ServerName3"
	{
		"ControlName"				"Label"
		"labelText"					""
		"xpos"						"-15"
		"ypos"						"0"
		"zpos"						"0"
		"wide"						"630"
		"zpos" 						"4"
		"fontHeight"				"35"
		"tall"						"48"
		"classname"					"ServerLabels"

		"pin_to_sibling"			"ServerButton3"
		"pin_corner_to_sibling"		"LEFT"
		"pin_to_sibling_corner"		"LEFT"
	}

	"ServerName4"
	{
		"ControlName"				"Label"
		"labelText"					""
		"xpos"						"-15"
		"ypos"						"0"
		"zpos"						"0"
		"wide"						"630"
		"zpos" 						"4"
		"fontHeight"				"35"
		"tall"						"48"
		"classname"					"ServerLabels"

		"pin_to_sibling"			"ServerButton4"
		"pin_corner_to_sibling"		"LEFT"
		"pin_to_sibling_corner"		"LEFT"
	}

	"ServerName5"
	{
		"ControlName"				"Label"
		"labelText"					""
		"xpos"						"-15"
		"ypos"						"0"
		"zpos"						"0"
		"wide"						"630"
		"zpos" 						"4"
		"fontHeight"				"35"
		"tall"						"48"
		"classname"					"ServerLabels"

		"pin_to_sibling"			"ServerButton5"
		"pin_corner_to_sibling"		"LEFT"
		"pin_to_sibling_corner"		"LEFT"
	}

	"ServerName6"
	{
		"ControlName"				"Label"
		"labelText"					""
		"xpos"						"-15"
		"ypos"						"0"
		"zpos"						"0"
		"wide"						"630"
		"zpos" 						"4"
		"fontHeight"				"35"
		"tall"						"48"
		"classname"					"ServerLabels"

		"pin_to_sibling"			"ServerButton6"
		"pin_corner_to_sibling"		"LEFT"
		"pin_to_sibling_corner"		"LEFT"
	}

	"ServerName7"
	{
		"ControlName"				"Label"
		"labelText"					""
		"xpos"						"-15"
		"ypos"						"0"
		"zpos"						"0"
		"wide"						"630"
		"zpos" 						"4"
		"fontHeight"				"35"
		"tall"						"48"
		"classname"					"ServerLabels"

		"pin_to_sibling"			"ServerButton7"
		"pin_corner_to_sibling"		"LEFT"
		"pin_to_sibling_corner"		"LEFT"
	}

	"ServerName8"
	{
		"ControlName"				"Label"
		"labelText"					""
		"xpos"						"-15"
		"ypos"						"0"
		"zpos"						"0"
		"wide"						"630"
		"zpos" 						"4"
		"fontHeight"				"35"
		"tall"						"48"
		"classname"					"ServerLabels"

		"pin_to_sibling"			"ServerButton8"
		"pin_corner_to_sibling"		"LEFT"
		"pin_to_sibling_corner"		"LEFT"
	}

	"ServerName9"
	{
		"ControlName"				"Label"
		"labelText"					""
		"xpos"						"-15"
		"ypos"						"0"
		"zpos"						"0"
		"wide"						"630"
		"zpos" 						"4"
		"fontHeight"				"35"
		"tall"						"48"
		"classname"					"ServerLabels"

		"pin_to_sibling"			"ServerButton9"
		"pin_corner_to_sibling"		"LEFT"
		"pin_to_sibling_corner"		"LEFT"
	}

	"ServerName10"
	{
		"ControlName"				"Label"
		"labelText"					""
		"xpos"						"-15"
		"ypos"						"0"
		"zpos"						"0"
		"wide"						"630"
		"zpos" 						"4"
		"fontHeight"				"35"
		"tall"						"48"
		"classname"					"ServerLabels"

		"pin_to_sibling"			"ServerButton10"
		"pin_corner_to_sibling"		"LEFT"
		"pin_to_sibling_corner"		"LEFT"
	}

	"ServerName11"
	{
		"ControlName"				"Label"
		"labelText"					""
		"xpos"						"-15"
		"ypos"						"0"
		"zpos"						"0"
		"wide"						"630"
		"zpos" 						"4"
		"fontHeight"				"35"
		"tall"						"48"
		"classname"					"ServerLabels"

		"pin_to_sibling"			"ServerButton11"
		"pin_corner_to_sibling"		"LEFT"
		"pin_to_sibling_corner"		"LEFT"
	}

	"ServerName12"
	{
		"ControlName"				"Label"
		"labelText"					""
		"xpos"						"-15"
		"ypos"						"0"
		"zpos"						"0"
		"wide"						"630"
		"zpos" 						"4"
		"fontHeight"				"35"
		"tall"						"48"
		"classname"					"ServerLabels"

		"pin_to_sibling"			"ServerButton12"
		"pin_corner_to_sibling"		"LEFT"
		"pin_to_sibling_corner"		"LEFT"
	}

	"ServerName13"
	{
		"ControlName"				"Label"
		"labelText"					""
		"xpos"						"-15"
		"ypos"						"0"
		"zpos"						"0"
		"wide"						"630"
		"zpos" 						"4"
		"fontHeight"				"35"
		"tall"						"48"
		"classname"					"ServerLabels"

		"pin_to_sibling"			"ServerButton13"
		"pin_corner_to_sibling"		"LEFT"
		"pin_to_sibling_corner"		"LEFT"
	}

	// "ServerName14"
	// {
	// 	"ControlName"				"Label"
	// 	"labelText"					""
	// 	"xpos"						"-15"
	// 	"ypos"						"0"
	// 	"zpos"						"0"
	// 	"wide"						"630"
	// 	"zpos" 						"4"
	// 	"fontHeight"				"35"
	// 	"tall"						"48"
	// 	"classname"					"ServerLabels"

	// 	"pin_to_sibling"			"ServerButton14"
	// 	"pin_corner_to_sibling"		"LEFT"
	// 	"pin_to_sibling_corner"		"LEFT"
	// }

	"Playlist0"
	{
		"ControlName"				"Label"
		"labelText"					""
		"xpos"						"-800"
		"ypos"						"0"
		"zpos"						"0"
		"textAlignment"				"center"
		"wide"						"230"
		"zpos" 						"4"
		"fontHeight"				"35"
		"tall"						"48"
		"classname"					"ServerLabels"

		"pin_to_sibling"			"ServerButton0"
		"pin_corner_to_sibling"		"LEFT"
		"pin_to_sibling_corner"		"LEFT"
	}

	"Playlist1"
	{
		"ControlName"				"Label"
		"labelText"					""
		"xpos"						"-800"
		"ypos"						"0"
		"zpos"						"0"
		"textalignment"				"center"
		"wide"						"230"
		"zpos" 						"4"
		"fontHeight"				"35"
		"tall"						"48"
		"classname"					"ServerLabels"

		"pin_to_sibling"			"ServerButton1"
		"pin_corner_to_sibling"		"LEFT"
		"pin_to_sibling_corner"		"LEFT"
	}

	"Playlist2"
	{
		"ControlName"				"Label"
		"labelText"					""
		"xpos"						"-800"
		"ypos"						"0"
		"zpos"						"0"
		"textalignment"				"center"
		"wide"						"230"
		"zpos" 						"4"
		"fontHeight"				"35"
		"tall"						"48"
		"classname"					"ServerLabels"

		"pin_to_sibling"			"ServerButton2"
		"pin_corner_to_sibling"		"LEFT"
		"pin_to_sibling_corner"		"LEFT"
	}

	"Playlist3"
	{
		"ControlName"				"Label"
		"labelText"					""
		"xpos"						"-800"
		"ypos"						"0"
		"zpos"						"0"
		"textalignment"				"center"
		"wide"						"230"
		"zpos" 						"4"
		"fontHeight"				"35"
		"tall"						"48"
		"classname"					"ServerLabels"

		"pin_to_sibling"			"ServerButton3"
		"pin_corner_to_sibling"		"LEFT"
		"pin_to_sibling_corner"		"LEFT"
	}

	"Playlist4"
	{
		"ControlName"				"Label"
		"labelText"					""
		"xpos"						"-800"
		"ypos"						"0"
		"zpos"						"0"
		"textalignment"				"center"
		"wide"						"230"
		"zpos" 						"4"
		"fontHeight"				"35"
		"tall"						"48"
		"classname"					"ServerLabels"

		"pin_to_sibling"			"ServerButton4"
		"pin_corner_to_sibling"		"LEFT"
		"pin_to_sibling_corner"		"LEFT"
	}

	"Playlist5"
	{
		"ControlName"				"Label"
		"labelText"					""
		"xpos"						"-800"
		"ypos"						"0"
		"zpos"						"0"
		"textalignment"				"center"
		"wide"						"230"
		"zpos" 						"4"
		"fontHeight"				"35"
		"tall"						"48"
		"classname"					"ServerLabels"

		"pin_to_sibling"			"ServerButton5"
		"pin_corner_to_sibling"		"LEFT"
		"pin_to_sibling_corner"		"LEFT"
	}

	"Playlist6"
	{
		"ControlName"				"Label"
		"labelText"					""
		"xpos"						"-800"
		"ypos"						"0"
		"zpos"						"0"
		"textalignment"				"center"
		"wide"						"230"
		"zpos" 						"4"
		"fontHeight"				"35"
		"tall"						"48"
		"classname"					"ServerLabels"

		"pin_to_sibling"			"ServerButton6"
		"pin_corner_to_sibling"		"LEFT"
		"pin_to_sibling_corner"		"LEFT"
	}

	"Playlist7"
	{
		"ControlName"				"Label"
		"labelText"					""
		"xpos"						"-800"
		"ypos"						"0"
		"zpos"						"0"
		"textalignment"				"center"
		"wide"						"230"
		"zpos" 						"4"
		"fontHeight"				"35"
		"tall"						"48"
		"classname"					"ServerLabels"

		"pin_to_sibling"			"ServerButton7"
		"pin_corner_to_sibling"		"LEFT"
		"pin_to_sibling_corner"		"LEFT"
	}

	"Playlist8"
	{
		"ControlName"				"Label"
		"labelText"					""
		"xpos"						"-800"
		"ypos"						"0"
		"zpos"						"0"
		"textalignment"				"center"
		"wide"						"230"
		"zpos" 						"4"
		"fontHeight"				"35"
		"tall"						"48"
		"classname"					"ServerLabels"

		"pin_to_sibling"			"ServerButton8"
		"pin_corner_to_sibling"		"LEFT"
		"pin_to_sibling_corner"		"LEFT"
	}

	"Playlist9"
	{
		"ControlName"				"Label"
		"labelText"					""
		"xpos"						"-800"
		"ypos"						"0"
		"zpos"						"0"
		"textalignment"				"center"
		"wide"						"230"
		"zpos" 						"4"
		"fontHeight"				"35"
		"tall"						"48"
		"classname"					"ServerLabels"

		"pin_to_sibling"			"ServerButton9"
		"pin_corner_to_sibling"		"LEFT"
		"pin_to_sibling_corner"		"LEFT"
	}

	"Playlist10"
	{
		"ControlName"				"Label"
		"labelText"					""
		"xpos"						"-800"
		"ypos"						"0"
		"zpos"						"0"
		"textalignment"				"center"
		"wide"						"230"
		"zpos" 						"4"
		"fontHeight"				"35"
		"tall"						"48"
		"classname"					"ServerLabels"

		"pin_to_sibling"			"ServerButton10"
		"pin_corner_to_sibling"		"LEFT"
		"pin_to_sibling_corner"		"LEFT"
	}

	"Playlist11"
	{
		"ControlName"				"Label"
		"labelText"					""
		"xpos"						"-800"
		"ypos"						"0"
		"zpos"						"0"
		"textalignment"				"center"
		"wide"						"230"
		"zpos" 						"4"
		"fontHeight"				"35"
		"tall"						"48"
		"classname"					"ServerLabels"

		"pin_to_sibling"			"ServerButton11"
		"pin_corner_to_sibling"		"LEFT"
		"pin_to_sibling_corner"		"LEFT"
	}

	"Playlist12"
	{
		"ControlName"				"Label"
		"labelText"					""
		"xpos"						"-800"
		"ypos"						"0"
		"zpos"						"0"
		"textalignment"				"center"
		"wide"						"230"
		"zpos" 						"4"
		"fontHeight"				"35"
		"tall"						"48"
		"classname"					"ServerLabels"

		"pin_to_sibling"			"ServerButton12"
		"pin_corner_to_sibling"		"LEFT"
		"pin_to_sibling_corner"		"LEFT"
	}

	"Playlist13"
	{
		"ControlName"				"Label"
		"labelText"					""
		"xpos"						"-800"
		"ypos"						"0"
		"zpos"						"0"
		"textalignment"				"center"
		"wide"						"230"
		"zpos" 						"4"
		"fontHeight"				"35"
		"tall"						"48"
		"classname"					"ServerLabels"

		"pin_to_sibling"			"ServerButton13"
		"pin_corner_to_sibling"		"LEFT"
		"pin_to_sibling_corner"		"LEFT"
	}

	// "Playlist14"
	// {
	// 	"ControlName"				"Label"
	// 	"labelText"					""
	// 	"xpos"						"-800"
	// 	"ypos"						"0"
	// 	"zpos"						"0"
	// 	"textalignment"				"center"
	// 	"wide"						"230"
	// 	"zpos" 						"4"
	// 	"fontHeight"				"35"
	// 	"tall"						"48"
	// 	"classname"					"ServerLabels"

	// 	"pin_to_sibling"			"ServerButton14"
	// 	"pin_corner_to_sibling"		"LEFT"
	// 	"pin_to_sibling_corner"		"LEFT"
	// }

	"PlayerCount0"
	{
		"ControlName"				"Label"
		"labelText"					""
		"xpos"						"-670"
		"ypos"						"0"
		"zpos"						"0"
		"textAlignment"				"center"
		"wide"						"110"
		"zpos" 						"4"
		"fontHeight"				"35"
		"tall"						"48"
		"classname"					"ServerLabels"

		"pin_to_sibling"			"ServerButton0"
		"pin_corner_to_sibling"		"LEFT"
		"pin_to_sibling_corner"		"LEFT"
	}

	"PlayerCount1"
	{
		"ControlName"				"Label"
		"labelText"					""
		"xpos"						"-670"
		"ypos"						"0"
		"zpos"						"0"
		"textalignment"				"center"
		"wide"						"110"
		"zpos" 						"4"
		"fontHeight"				"35"
		"tall"						"48"
		"classname"					"ServerLabels"

		"pin_to_sibling"			"ServerButton1"
		"pin_corner_to_sibling"		"LEFT"
		"pin_to_sibling_corner"		"LEFT"
	}

	"PlayerCount2"
	{
		"ControlName"				"Label"
		"labelText"					""
		"xpos"						"-670"
		"ypos"						"0"
		"zpos"						"0"
		"textalignment"				"center"
		"wide"						"110"
		"zpos" 						"4"
		"fontHeight"				"35"
		"tall"						"48"
		"classname"					"ServerLabels"

		"pin_to_sibling"			"ServerButton2"
		"pin_corner_to_sibling"		"LEFT"
		"pin_to_sibling_corner"		"LEFT"
	}

	"PlayerCount3"
	{
		"ControlName"				"Label"
		"labelText"					""
		"xpos"						"-670"
		"ypos"						"0"
		"zpos"						"0"
		"textalignment"				"center"
		"wide"						"110"
		"zpos" 						"4"
		"fontHeight"				"35"
		"tall"						"48"
		"classname"					"ServerLabels"

		"pin_to_sibling"			"ServerButton3"
		"pin_corner_to_sibling"		"LEFT"
		"pin_to_sibling_corner"		"LEFT"
	}

	"PlayerCount4"
	{
		"ControlName"				"Label"
		"labelText"					""
		"xpos"						"-670"
		"ypos"						"0"
		"zpos"						"0"
		"textalignment"				"center"
		"wide"						"110"
		"zpos" 						"4"
		"fontHeight"				"35"
		"tall"						"48"
		"classname"					"ServerLabels"

		"pin_to_sibling"			"ServerButton4"
		"pin_corner_to_sibling"		"LEFT"
		"pin_to_sibling_corner"		"LEFT"
	}

	"PlayerCount5"
	{
		"ControlName"				"Label"
		"labelText"					""
		"xpos"						"-670"
		"ypos"						"0"
		"zpos"						"0"
		"textalignment"				"center"
		"wide"						"110"
		"zpos" 						"4"
		"fontHeight"				"35"
		"tall"						"48"
		"classname"					"ServerLabels"

		"pin_to_sibling"			"ServerButton5"
		"pin_corner_to_sibling"		"LEFT"
		"pin_to_sibling_corner"		"LEFT"
	}

	"PlayerCount6"
	{
		"ControlName"				"Label"
		"labelText"					""
		"xpos"						"-670"
		"ypos"						"0"
		"zpos"						"0"
		"textalignment"				"center"
		"wide"						"110"
		"zpos" 						"4"
		"fontHeight"				"35"
		"tall"						"48"
		"classname"					"ServerLabels"

		"pin_to_sibling"			"ServerButton6"
		"pin_corner_to_sibling"		"LEFT"
		"pin_to_sibling_corner"		"LEFT"
	}

	"PlayerCount7"
	{
		"ControlName"				"Label"
		"labelText"					""
		"xpos"						"-670"
		"ypos"						"0"
		"zpos"						"0"
		"textalignment"				"center"
		"wide"						"110"
		"zpos" 						"4"
		"fontHeight"				"35"
		"tall"						"48"
		"classname"					"ServerLabels"

		"pin_to_sibling"			"ServerButton7"
		"pin_corner_to_sibling"		"LEFT"
		"pin_to_sibling_corner"		"LEFT"
	}

	"PlayerCount8"
	{
		"ControlName"				"Label"
		"labelText"					""
		"xpos"						"-670"
		"ypos"						"0"
		"zpos"						"0"
		"textalignment"				"center"
		"wide"						"110"
		"zpos" 						"4"
		"fontHeight"				"35"
		"tall"						"48"
		"classname"					"ServerLabels"

		"pin_to_sibling"			"ServerButton8"
		"pin_corner_to_sibling"		"LEFT"
		"pin_to_sibling_corner"		"LEFT"
	}

	"PlayerCount9"
	{
		"ControlName"				"Label"
		"labelText"					""
		"xpos"						"-670"
		"ypos"						"0"
		"zpos"						"0"
		"textalignment"				"center"
		"wide"						"110"
		"zpos" 						"4"
		"fontHeight"				"35"
		"tall"						"48"
		"classname"					"ServerLabels"

		"pin_to_sibling"			"ServerButton9"
		"pin_corner_to_sibling"		"LEFT"
		"pin_to_sibling_corner"		"LEFT"
	}

	"PlayerCount10"
	{
		"ControlName"				"Label"
		"labelText"					""
		"xpos"						"-670"
		"ypos"						"0"
		"zpos"						"0"
		"textalignment"				"center"
		"wide"						"110"
		"zpos" 						"4"
		"fontHeight"				"35"
		"tall"						"48"
		"classname"					"ServerLabels"

		"pin_to_sibling"			"ServerButton10"
		"pin_corner_to_sibling"		"LEFT"
		"pin_to_sibling_corner"		"LEFT"
	}

	"PlayerCount11"
	{
		"ControlName"				"Label"
		"labelText"					""
		"xpos"						"-670"
		"ypos"						"0"
		"zpos"						"0"
		"textalignment"				"center"
		"wide"						"110"
		"zpos" 						"4"
		"fontHeight"				"35"
		"tall"						"48"
		"classname"					"ServerLabels"

		"pin_to_sibling"			"ServerButton11"
		"pin_corner_to_sibling"		"LEFT"
		"pin_to_sibling_corner"		"LEFT"
	}

	"PlayerCount12"
	{
		"ControlName"				"Label"
		"labelText"					""
		"xpos"						"-670"
		"ypos"						"0"
		"zpos"						"0"
		"textalignment"				"center"
		"wide"						"110"
		"zpos" 						"4"
		"fontHeight"				"35"
		"tall"						"48"
		"classname"					"ServerLabels"

		"pin_to_sibling"			"ServerButton12"
		"pin_corner_to_sibling"		"LEFT"
		"pin_to_sibling_corner"		"LEFT"
	}

	"PlayerCount13"
	{
		"ControlName"				"Label"
		"labelText"					""
		"xpos"						"-670"
		"ypos"						"0"
		"zpos"						"0"
		"textalignment"				"center"
		"wide"						"110"
		"zpos" 						"4"
		"fontHeight"				"35"
		"tall"						"48"
		"classname"					"ServerLabels"

		"pin_to_sibling"			"ServerButton13"
		"pin_corner_to_sibling"		"LEFT"
		"pin_to_sibling_corner"		"LEFT"
	}

	// "PlayerCount14"
	// {
	// 	"ControlName"				"Label"
	// 	"labelText"					""
	// 	"xpos"						"-670"
	// 	"ypos"						"0"
	// 	"zpos"						"0"
	// 	"textalignment"				"center"
	// 	"wide"						"110"
	// 	"zpos" 						"4"
	// 	"fontHeight"				"35"
	// 	"tall"						"48"
	// 	"classname"					"ServerLabels"

	// 	"pin_to_sibling"			"ServerButton14"
	// 	"pin_corner_to_sibling"		"LEFT"
	// 	"pin_to_sibling_corner"		"LEFT"
	// }

	"Map0"
	{
		"ControlName"				"Label"
		"labelText"					""
		"xpos"						"-1050"
		"ypos"						"0"
		"zpos"						"0"
		"textalignment"				"center"
		"wide"						"330"
		"zpos" 						"4"
		"fontHeight"				"35"
		"tall"						"50"
		"classname"					"ServerLabels"

		"pin_to_sibling"			"ServerButton0"
		"pin_corner_to_sibling"		"LEFT"
		"pin_to_sibling_corner"		"LEFT"
	}

	"Map1"
	{
		"ControlName"				"Label"
		"labelText"					""
		"xpos"						"-1050"
		"ypos"						"0"
		"zpos"						"0"
		"textalignment"				"center"
		"wide"						"330"
		"zpos" 						"4"
		"fontHeight"				"35"
		"tall"						"50"
		"classname"					"ServerLabels"

		"pin_to_sibling"			"ServerButton1"
		"pin_corner_to_sibling"		"LEFT"
		"pin_to_sibling_corner"		"LEFT"
	}

	"Map2"
	{
		"ControlName"				"Label"
		"labelText"					""
		"xpos"						"-1050"
		"ypos"						"0"
		"zpos"						"0"
		"textalignment"				"center"
		"wide"						"330"
		"zpos" 						"4"
		"fontHeight"				"35"
		"tall"						"50"
		"classname"					"ServerLabels"

		"pin_to_sibling"			"ServerButton2"
		"pin_corner_to_sibling"		"LEFT"
		"pin_to_sibling_corner"		"LEFT"
	}

	"Map3"
	{
		"ControlName"				"Label"
		"labelText"					""
		"xpos"						"-1050"
		"ypos"						"0"
		"zpos"						"0"
		"textalignment"				"center"
		"wide"						"330"
		"zpos" 						"4"
		"fontHeight"				"35"
		"classname"					"ServerLabels"

		"pin_to_sibling"			"ServerButton3"
		"pin_corner_to_sibling"		"LEFT"
		"pin_to_sibling_corner"		"LEFT"
	}

	"Map4"
	{
		"ControlName"				"Label"
		"labelText"					""
		"xpos"						"-1050"
		"ypos"						"0"
		"zpos"						"0"
		"textalignment"				"center"
		"wide"						"330"
		"zpos" 						"4"
		"fontHeight"				"35"
		"tall"						"50"
		"classname"					"ServerLabels"

		"pin_to_sibling"			"ServerButton4"
		"pin_corner_to_sibling"		"LEFT"
		"pin_to_sibling_corner"		"LEFT"
	}

	"Map5"
	{
		"ControlName"				"Label"
		"labelText"					""
		"xpos"						"-1050"
		"ypos"						"0"
		"zpos"						"0"
		"textalignment"				"center"
		"wide"						"330"
		"zpos" 						"4"
		"fontHeight"				"35"
		"tall"						"50"
		"classname"					"ServerLabels"

		"pin_to_sibling"			"ServerButton5"
		"pin_corner_to_sibling"		"LEFT"
		"pin_to_sibling_corner"		"LEFT"
	}

	"Map6"
	{
		"ControlName"				"Label"
		"labelText"					""
		"xpos"						"-1050"
		"ypos"						"0"
		"zpos"						"0"
		"textalignment"				"center"
		"wide"						"330"
		"zpos" 						"4"
		"fontHeight"				"35"
		"tall"						"50"
		"classname"					"ServerLabels"

		"pin_to_sibling"			"ServerButton6"
		"pin_corner_to_sibling"		"LEFT"
		"pin_to_sibling_corner"		"LEFT"
	}

	"Map7"
	{
		"ControlName"				"Label"
		"labelText"					""
		"xpos"						"-1050"
		"ypos"						"0"
		"zpos"						"0"
		"textalignment"				"center"
		"wide"						"330"
		"zpos" 						"4"
		"fontHeight"				"35"
		"tall"						"50"
		"classname"					"ServerLabels"

		"pin_to_sibling"			"ServerButton7"
		"pin_corner_to_sibling"		"LEFT"
		"pin_to_sibling_corner"		"LEFT"
	}

	"Map8"
	{
		"ControlName"				"Label"
		"labelText"					""
		"xpos"						"-1050"
		"ypos"						"0"
		"zpos"						"0"
		"textalignment"				"center"
		"wide"						"330"
		"zpos" 						"4"
		"fontHeight"				"35"
		"tall"						"50"
		"classname"					"ServerLabels"

		"pin_to_sibling"			"ServerButton8"
		"pin_corner_to_sibling"		"LEFT"
		"pin_to_sibling_corner"		"LEFT"
	}

	"Map9"
	{
		"ControlName"				"Label"
		"labelText"					""
		"xpos"						"-1050"
		"ypos"						"0"
		"zpos"						"0"
		"textalignment"				"center"
		"wide"						"330"
		"zpos" 						"4"
		"fontHeight"				"35"
		"tall"						"50"
		"classname"					"ServerLabels"

		"pin_to_sibling"			"ServerButton9"
		"pin_corner_to_sibling"		"LEFT"
		"pin_to_sibling_corner"		"LEFT"
	}

	"Map10"
	{
		"ControlName"				"Label"
		"labelText"					""
		"xpos"						"-1050"
		"ypos"						"0"
		"zpos"						"0"
		"textalignment"				"center"
		"wide"						"330"
		"zpos" 						"4"
		"fontHeight"				"35"
		"tall"						"50"
		"classname"					"ServerLabels"

		"pin_to_sibling"			"ServerButton10"
		"pin_corner_to_sibling"		"LEFT"
		"pin_to_sibling_corner"		"LEFT"
	}

	"Map11"
	{
		"ControlName"				"Label"
		"labelText"					""
		"xpos"						"-1050"
		"ypos"						"0"
		"zpos"						"0"
		"textalignment"				"center"
		"wide"						"330"
		"zpos" 						"4"
		"fontHeight"				"35"
		"tall"						"50"
		"classname"					"ServerLabels"

		"pin_to_sibling"			"ServerButton11"
		"pin_corner_to_sibling"		"LEFT"
		"pin_to_sibling_corner"		"LEFT"
	}

	"Map12"
	{
		"ControlName"				"Label"
		"labelText"					""
		"xpos"						"-1050"
		"ypos"						"0"
		"zpos"						"0"
		"textalignment"				"center"
		"wide"						"330"
		"zpos" 						"4"
		"fontHeight"				"35"
		"tall"						"50"
		"classname"					"ServerLabels"

		"pin_to_sibling"			"ServerButton12"
		"pin_corner_to_sibling"		"LEFT"
		"pin_to_sibling_corner"		"LEFT"
	}

	"Map13"
	{
		"ControlName"				"Label"
		"labelText"					""
		"xpos"						"-1050"
		"ypos"						"0"
		"zpos"						"0"
		"textalignment"				"center"
		"wide"						"330"
		"zpos" 						"4"
		"fontHeight"				"35"
		"tall"						"50"
		"classname"					"ServerLabels"

		"pin_to_sibling"			"ServerButton13"
		"pin_corner_to_sibling"		"LEFT"
		"pin_to_sibling_corner"		"LEFT"
	}

	// "Map14"
	// {
	// 	"ControlName"				"Label"
	// 	"labelText"					""
	// 	"xpos"						"-1050"
	// 	"ypos"						"0"
	// 	"zpos"						"0"
	// 	"textalignment"				"center"
	// 	"wide"						"330"
	// 	"zpos" 						"4"
	// 	"fontHeight"				"35"
	// 	"tall"						"50"
	// 	"classname"					"ServerLabels"

	// 	"pin_to_sibling"			"ServerButton14"
	// 	"pin_corner_to_sibling"		"LEFT"
	// 	"pin_to_sibling_corner"		"LEFT"
	// }
}

