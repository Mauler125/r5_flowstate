"scripts/resource/ui/menus/panels/armory.res"
{
    PanelFrame
    {
		ControlName				Label
		xpos					0
		ypos					0
		wide					%100
		tall					%100
		labelText				""
		visible				    0
        bgcolor_override        "0 0 0 0"
        paintbackground         1
    }

    WeaponCategoryButton0
    {
        ControlName				RuiButton
        InheritProperties		WeaponCategoryButton
        classname               WeaponCategoryButtonClass
        scriptID				0
        xpos                    125
        xpos_nx_handheld        -58			[$NX || $NX_UI_PC]
        ypos                    189
        tabPosition             1
        cursorVelocityModifier  0.7

        navDown                 WeaponCategoryButton4
        navRight                WeaponCategoryButton1
    }
    WeaponCategoryButton1
    {
        ControlName				RuiButton
        InheritProperties		WeaponCategoryButton
        classname               WeaponCategoryButtonClass
        scriptID				1
        xpos                    -84
        cursorVelocityModifier  0.7

        navDown                 WeaponCategoryButton4
        navLeft                 WeaponCategoryButton0
        navRight                WeaponCategoryButton2

        pin_to_sibling			WeaponCategoryButton0
        pin_corner_to_sibling	TOP_LEFT
        pin_to_sibling_corner	TOP_RIGHT
    }
    WeaponCategoryButton2
    {
        ControlName				RuiButton
        InheritProperties		WeaponCategoryButton
        classname               WeaponCategoryButtonClass
        scriptID				2
        xpos                    -84
        cursorVelocityModifier  0.7

        navDown                 WeaponCategoryButton5
        navLeft                 WeaponCategoryButton1
        navRight                WeaponCategoryButton3

        pin_to_sibling			WeaponCategoryButton1
        pin_corner_to_sibling	TOP_LEFT
        pin_to_sibling_corner	TOP_RIGHT
    }
    WeaponCategoryButton3
    {
        ControlName				RuiButton
        InheritProperties		WeaponCategoryButton
        classname               WeaponCategoryButtonClass
        scriptID				3
        xpos                    -84
        cursorVelocityModifier  0.7

        navDown                 WeaponCategoryButton6
        navLeft                 WeaponCategoryButton2

        pin_to_sibling			WeaponCategoryButton2
        pin_corner_to_sibling	TOP_LEFT
        pin_to_sibling_corner	TOP_RIGHT
    }
    WeaponCategoryButton4
    {
        ControlName				RuiButton
        InheritProperties		WeaponCategoryButton
        classname               WeaponCategoryButtonClass
        scriptID				4
        ypos                    20
        xpos                    30
        cursorVelocityModifier  0.7
        ruiArgs
        {
            isNameAtTop         1
        }

        navUp                   WeaponCategoryButton1
        navRight                WeaponCategoryButton5
        navDown                 MiscCustomizeButton

        pin_to_sibling			WeaponCategoryButton0
                pin_corner_to_sibling	TOP_LEFT
                pin_to_sibling_corner	BOTTOM_LEFT
    }
    WeaponCategoryButton5
    {
        ControlName				RuiButton
        InheritProperties		WeaponCategoryButton
        classname               WeaponCategoryButtonClass
        scriptID				5
        xpos                    -84
        cursorVelocityModifier  0.7
        ruiArgs
        {
            isNameAtTop         1
        }

        navUp                   WeaponCategoryButton2
        navLeft                 WeaponCategoryButton4
        navRight                WeaponCategoryButton6
        navDown                 MiscCustomizeButton

        pin_to_sibling			WeaponCategoryButton4
        pin_corner_to_sibling	TOP_LEFT
        pin_to_sibling_corner	TOP_RIGHT
    }
    WeaponCategoryButton6
    {
        ControlName				RuiButton
        InheritProperties		WeaponCategoryButton
        classname               WeaponCategoryButtonClass
        scriptID				6
        xpos                    -84
        cursorVelocityModifier  0.7
        ruiArgs
        {
            isNameAtTop         1
        }

        navUp                   WeaponCategoryButton3
        navLeft                 WeaponCategoryButton5
        navDown                 MiscCustomizeButton

        pin_to_sibling			WeaponCategoryButton5
        pin_corner_to_sibling	TOP_LEFT
        pin_to_sibling_corner	TOP_RIGHT
    }
	WeaponCategoryButton7
    {
        ControlName				RuiButton
        InheritProperties		WeaponCategoryButton
        classname               WeaponCategoryButtonClass
        scriptID				7
        xpos                    -84
        cursorVelocityModifier  0.7
        ruiArgs
        {
            isNameAtTop         1
        }

        navUp                   WeaponCategoryButton3
        navLeft                 WeaponCategoryButton6
        navDown                 MiscCustomizeButton

        pin_to_sibling			WeaponCategoryButton6
        pin_corner_to_sibling	TOP_LEFT
        pin_to_sibling_corner	TOP_RIGHT
    }
    MiscCustomizeButton
    {
        ControlName				RuiButton
        InheritProperties		MiscCustomizeButton
        classname               MiscCustomizeButtonClass
        scriptID				6
        ypos                    110
		xpos                    -170
        ypos_nx_handheld        22		[$NX || $NX_UI_PC]
        visible                 0
        cursorVelocityModifier  0.7

        navUp                   WeaponCategoryButton5

        pin_to_sibling			WeaponCategoryButton6
        pin_corner_to_sibling	TOP
        pin_to_sibling_corner	BOTTOM
    }
}