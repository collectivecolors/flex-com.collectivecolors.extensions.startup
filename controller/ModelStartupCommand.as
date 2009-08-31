package com.collectivecolors.extensions.flex3.startup.controller
{
	//----------------------------------------------------------------------------
	// Imports
	
	import com.collectivecolors.extensions.flex3.startup.StartupFacade;
	import com.collectivecolors.extensions.flex3.startup.model.*;
	
	import mx.core.Application;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	//----------------------------------------------------------------------------

	public class ModelStartupCommand extends SimpleCommand
	{
		//--------------------------------------------------------------------------
		// Overrides
		
		override public function execute( note : INotification ) : void    
    {
      var flashVars : Object =  Application( note.getBody( ) ).parameters;
      
      // Register startup proxies
      sendNotification( StartupFacade.REGISTER_RESOURCES, flashVars );
              	
      // Load startup proxies
      StartupProxy.loadResources( );
    }      
	}
}