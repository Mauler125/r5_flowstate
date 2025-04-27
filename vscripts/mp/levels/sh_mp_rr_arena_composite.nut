global function ShInit_ArenaComposite
#if SERVER
global function CodeCallback_MapInit

void function CodeCallback_MapInit()
{
	ConveyorInit($"mdl/vehicles_r5/land_med/msc_freight_tortus_mod/veh_land_msc_freight_tortus_mod_cargo_holder_v2_static.rmdl", "", 6, 80)
	thread InitARBarriers()
}
#endif

void function ShInit_ArenaComposite()
{
	SetVictorySequencePlatformModel( $"mdl/dev/empty_model.rmdl", < 0, 0, -10 >, < 0, 0, 0 > )
	#if CLIENT
		SetVictorySequenceLocation(<1374, -4060, 418>, <0, 201.828598, 0> )
	#endif
}

#if SERVER
void function InitARBarriers()
{
	AddSpawnCallback( "func_brush", void function ( entity brush )
	{
		brush.Destroy()//TODO: Recover this function once we get correct shaders and arenas -LorryLeKral
	} )
}
#endif