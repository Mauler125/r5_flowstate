untyped

//////////////////////////////////////////
// placing this here temp (mkos Assert) //
//////////////////////////////////////////
global function mAssert

void function mAssert( var condition, string errorMsg = "error", ... )
{
	if ( !condition )
	{	
		array vars = [ this, errorMsg ] 
		for( int i = 0; i < vargc; i++ )
			vars.append( vargv[ i ] )
		
		errorMsg = expect string ( format.acall( vars ) )	
		string appenderr = format( "\n\n%s\n%s", DBG_INFO( 3 ), DBG_INFO( 4 ) )

		PrintLocals( 3 )

		#if UI || CLIENT
			ScriptError( errorMsg + appenderr )
		#elseif SERVER
			ErrorServer( errorMsg + appenderr ) //This allows running servers to send mAssert errors to all clients.
		#endif
	}
}

#if SERVER
	void function ErrorServer( string errorMsg )
	{
		foreach( player in GetPlayerArray() )
			KickPlayerById( player.GetPlatformUID(), errorMsg )
		
		ScriptError( errorMsg )
	}
#endif 
///