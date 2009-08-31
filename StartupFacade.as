package com.collectivecolors.extensions.flex3.startup
{
  //----------------------------------------------------------------------------
  // Imports
  
  import com.collectivecolors.emvc.patterns.extension.Extension;
  import com.collectivecolors.emvc.patterns.facade.ExtensibleFacade;
  import com.collectivecolors.extensions.flex3.startup.controller.ModelStartupCommand;
  
  import org.puremvc.as3.utilities.startupmanager.StartupManager;

  //----------------------------------------------------------------------------

  public class StartupFacade extends Extension
  {
    //--------------------------------------------------------------------------
    // Constants
    
    public static const NAME : String = "startupFacade";
    
    // Notifications
    
    /**
     * Signal to register all startup resource proxies
     */ 
    public static const REGISTER_RESOURCES : String = "startupFacadeRegisterNotification";
    
    public static const RESOURCE_LOADED : String = "startupFacadeLoadedNotification";
    public static const RESOURCE_FAILED : String = "startupFacadeFailedNotification";
    
    /**
     *  StartupManager core: Notifications to Client App
     */
    public static const LOADING_PROGRESS : String            = StartupManager.LOADING_PROGRESS;
		public static const LOADING_COMPLETE : String            = StartupManager.LOADING_COMPLETE;
		public static const LOADING_FINISHED_INCOMPLETE : String = StartupManager.LOADING_FINISHED_INCOMPLETE;
		public static const RETRYING_LOAD_RESOURCE : String      = StartupManager.RETRYING_LOAD_RESOURCE;
		public static const LOAD_RESOURCE_TIMED_OUT : String     = StartupManager.LOAD_RESOURCE_TIMED_OUT;
		public static const CALL_OUT_OF_SYNC_IGNORED : String    = StartupManager.CALL_OUT_OF_SYNC_IGNORED;
		public static const WAITING_FOR_MORE_RESOURCES : String  = StartupManager.WAITING_FOR_MORE_RESOURCES;    
    
    //--------------------------------------------------------------------------
    // Constructor
    
    public function StartupFacade( )
    {
      super( NAME );
    }
    
    //--------------------------------------------------------------------------
    // eMVC hooks
    
    public function initializeController( ) : void
    {
      core.registerCommand( ExtensibleFacade.STARTUP, ModelStartupCommand );   
    }    
  }
}