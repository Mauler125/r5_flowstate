"resource/ui/menus/panels/credits.res"
{
    PanelFrame
    {
		ControlName				Label
		xpos					0
		ypos					0
		wide					%100
		tall					%100
		labelText				""
		visible				    1
        bgcolor_override        "0 0 0 0"
        paintbackground         1

        proportionalToParent    1
    }

    //ActionButton
    //{
    //    ControlName				RuiButton
    //    classname               "MenuButton"
    //    wide					280
    //    tall					80
    //    xpos                    -28
    //    ypos                    -25
    //    rui                     "ui/generic_loot_button.rpak"
    //    labelText               ""
    //    visible					0
    //    cursorVelocityModifier  0.7

    //    pin_to_sibling			PanelFrame
    //    pin_corner_to_sibling	BOTTOM_LEFT
    //    pin_to_sibling_corner	BOTTOM_LEFT
    //}

    ActionLabel
    {
        ControlName				Label
        auto_wide_tocontents 	1
        auto_tall_tocontents 	1
        visible					0
        labelText				"This is a Label"
        fgcolor_override		"220 220 220 255"
        fontHeight              36
        ypos                    420
        xpos                    -178

        pin_to_sibling			CreditsInfo
        pin_corner_to_sibling	TOP_LEFT
        pin_to_sibling_corner	BOTTOM_LEFT
    }

    CreditsInfo
    {
        ControlName		        RuiPanel
        xpos                    -150
        ypos                    -120
        wide                    740
        tall                    153
        visible			        1
        rui                     "ui/character_select_info.rpak"

        pin_to_sibling			PanelFrame
        pin_corner_to_sibling	TOP_LEFT
        pin_to_sibling_corner	TOP_LEFT
    }

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    Anchor
    {
        ControlName             Label

        labelText               ""
        xpos                    428 //500
        ypos                    300
        wide					50
        tall                    50
        //bgcolor_override		"0 255 0 100"
        //paintbackground			1
    }
}

