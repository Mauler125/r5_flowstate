untyped
global function CodeCallback_RegisterClass_C_Player
global function ServerCallback_ToggleDisabledWeaponType

var function CodeCallback_RegisterClass_C_Player()
{
	C_Player.ClassName <- "C_Player"

	C_Player.classChanged <- true
	C_Player.cv <- null
	
	C_Player.canUseZipline <- true
	C_Player.disabledWeaponTypes <- 0
	
	function C_Player::SetCanUseZipline( setting ) //todo(mk): move to code 
	{
		entity player = expect entity ( this )
		
		player.canUseZipline = expect bool( setting )
		
		if( player.canUseZipline )
		{
			player.p.ziplineUsages = 0
			player.canUseZipline = true
		}
		else
		{
			player.canUseZipline = false
		}
	}
	
	function C_Player::IsDisabledFor( weaponType ) //Todo(mk): move to code (amos:todo)
	{		
		return ( this.disabledWeaponTypes & expect int( weaponType ) ) != 0
	}
	
	function C_Player::ToggleDisabledWeaponType_internal( weaponType, toggle ) //Todo(mk): move to code (amos:todo)
	{
		if( toggle )
			this.disabledWeaponTypes = this.disabledWeaponTypes | weaponType
		else 
			this.disabledWeaponTypes = this.disabledWeaponTypes & ~weaponType	
	}
	
	function C_Player::GetWeaponDisabledFlags() //Todo(mk): move to code (amos:todo) (note: already exists as GetWeaponDisableFlags -- however is incomplete and does not contain all types uniformly. )
	{
		return this.disabledWeaponTypes
	}
}

void function ServerCallback_ToggleDisabledWeaponType( int weaponType, bool toggle )
{
	GetLocalClientPlayer().ToggleDisabledWeaponType_internal( weaponType, toggle )
}