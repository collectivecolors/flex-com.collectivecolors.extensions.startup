package com.collectivecolors.extensions.flex3.startup.model
{
	//----------------------------------------------------------------------------
	// Imports
	
	import com.collectivecolors.extensions.flex3.startup.StartupFacade;
	import com.collectivecolors.extensions.flex3.startup.model.data.ResourceList;
	
	import flash.errors.IllegalOperationError;
	
	import org.puremvc.as3.patterns.proxy.Proxy;
	import org.puremvc.as3.utilities.startupmanager.controller.StartupResourceFailedCommand;
	import org.puremvc.as3.utilities.startupmanager.controller.StartupResourceLoadedCommand;
	import org.puremvc.as3.utilities.startupmanager.interfaces.IStartupProxy;
	import org.puremvc.as3.utilities.startupmanager.model.RetryParameters;
	import org.puremvc.as3.utilities.startupmanager.model.RetryPolicy;
	import org.puremvc.as3.utilities.startupmanager.model.StartupMonitorProxy;
	import org.puremvc.as3.utilities.startupmanager.model.StartupResourceProxy;
	
	//----------------------------------------------------------------------------
	
	public class StartupProxy extends Proxy implements IStartupProxy
	{
		//--------------------------------------------------------------------------
		// Constants
		
		private static const DEFAULT_RETRIES : int        = 0;
		private static const DEFAULT_RETRY_INTERVAL : int = 0;
		private static const DEFAULT_TIMEOUT : int        = 30;
		
		private static const LOADED_SUFFIX : String = "Loaded";
		private static const FAILED_SUFFIX : String = "Failed";
		
		//--------------------------------------------------------------------------
		// Properties
		
		private static var startupMonitor : StartupMonitorProxy;
		
		private var name : String;
		
		private var _startupProxy : StartupResourceProxy;
		
		protected var requireMap : Object;
		
		//--------------------------------------------------------------------------
		// Constructor
		
		public function StartupProxy( name : String )
		{
			super( name );
			
			this.name     = name;
			this.proxyMap = new Object( );
						
			// Initialize startup monitor ( only one instance for application )
			if ( startupMonitor == null )
			{
				startupMonitor = new StartupMonitorProxy( new ResourceList( ) );
        	
        startupMonitor.defaultRetryPolicy 
          = new RetryPolicy( new RetryParameters( DEFAULT_RETRIES, 
        													                DEFAULT_RETRY_INTERVAL,
        													                DEFAULT_TIMEOUT ) );        	
        facade.registerProxy( startupMonitor );
			}
			
			// Initialize startup resource proxy
			_startupProxy = new StartupResourceProxy( name, this );
					
			// Register startup resource proxy with startup monitor
			startupMonitor.addResource( _startupProxy );
						
			// Register startup manager commands for this proxy
			facade.registerCommand( failedNoteName, StartupResourceFailedCommand );
			facade.registerCommand( loadedNoteName, StartupResourceLoadedCommand );			
		}
		
		//--------------------------------------------------------------------------
		// Accessors / Modifiers
		
		/**
		 * Get the startup proxy associated with the proxy that extends this class.
		 * 
		 * This is useful for setting properties such as required startup proxies.
		 */
		final public function get startupProxy( ) : StartupResourceProxy
		{
			return _startupProxy;
		}
		
		/**
		 * Get the name of the notification sent if the loading of the startup 
		 * resource for this proxy fails.
		 * 
		 * Note that you if you want to listen for this notification, you will
		 * probably want to override this in your sub class so that you can specify
		 * a constant value for this name.  By default, it generates a dynamic name
		 * based upon the name of this proxy.
		 */
		protected function get failedNoteName( ) : String
		{
			return name + FAILED_SUFFIX;
		}
		
		/**
		 * Get the name of the notification sent if the loading of the startup 
		 * resource for this proxy is successful.
		 * 
		 * Note that you if you want to listen for this notification, you will
		 * probably want to override this in your sub class so that you can specify
		 * a constant value for this name.  By default, it generates a dynamic name
		 * based upon the name of this proxy.
		 */
		protected function get loadedNoteName( ) : String
		{
			return name + LOADED_SUFFIX;
		}
		
		//--------------------------------------------------------------------------
		// Extensions
		
		/**
		 * This static method is called after all of the proxies that extend this 
		 * class have been constructed and registered with the facade during 
		 * application initialization.
		 * 
		 * @see ManagerModelStartupCommand
		 */ 
		public static function loadResources( ) : void
		{
			if ( startupMonitor != null )
			{
				startupMonitor.loadResources( );
			}
		}
		
		/**
		 * This method is called automatically by the startup manager for each
		 * extending proxy and handles the initial loading of resources for this
		 * proxy.
		 * 
		 * This method MUST be overridden in all subclasses because the actual 
		 * loading of the resources depends entirely upon what types of resources
		 * are being loaded and the delivery methods used.  Don't worry, this method
		 * will remind you if you forget.
		 */
		public function load( ) : void
		{
			// Override me!!!!  Yee Haw!!!
			throw new IllegalOperationError( 
			  "StartupProxy load method must be overriden in sub class" 
			);
		}
		
		/**
		 * Send a notification that the loading of startup resources failed.
		 * 
		 * This uses the failedNoteName method above for the name of the 
		 * notification sent, so if you want to listen for this notification then
		 * override the failedNoteName method in your sub class.
		 * 
		 * NOTE : Call this method in your faultHandler method instead of the usual
		 * sendNotification() method!
		 */
		final protected function sendFailedNotification( ) : void
		{
			sendStartupNotification( failedNoteName );
			sendNotification( StartupFacade.RESOURCE_FAILED, failedNoteName ); 
		}
		
		/**
		 * Send a notification that the loading of startup resources was successful.
		 * 
		 * This uses the loadedNoteName method above for the name of the 
		 * notification sent, so if you want to listen for this notification then
		 * override the loadedNoteName method in your sub class.
		 * 
		 * NOTE : Call this method in your resultHandler method instead of the usual
		 * sendNotification() method!
		 */
		final protected function sendLoadedNotification( ) : void
		{
			sendStartupNotification( loadedNoteName );
			sendNotification( StartupFacade.RESOURCE_LOADED, loadedNoteName );	
		}
		
		/**
		 * Add a required proxy for this proxy with the startup monitor.
		 * 
		 * Call this method in your constructor in order to ensure that certain 
		 * proxies are loaded before yours.  Note that the proxy given must be 
		 * an extension of the StartupProxy class.
		 */
		protected function addRequiredProxy( proxy : StartupProxy ) : void
		{
		  if ( ! proxyMap.hasOwnProperty( proxy.name ) )
		  {
		    requireMap[ proxy.name ] = proxy;
		    
		    startupProxy.requires.push( proxy.startupProxy );
		  }
		}
		
		/**
		 * Add multiple required proxies for this proxy with the startup monitor.
		 * 
		 * Call this method in your constructor in order to ensure that certain 
		 * proxies are loaded before yours.  Note that the proxy given must be 
		 * an extension of the StartupProxy class.
		 */
		protected function addRequiredProxies( proxies : Array ) : void
		{
		  for each ( var proxy : StartupProxy in proxies )
		  {
		    addRequiredProxy( proxy );
		  }
		} 
		
		//--------------------------------------------------------------------------
		// Private helper functions
		
		/**
		 * This method checks to see if the startup manager has timed out before
		 * sending a loaded or failed notification.
		 * 
		 * This is used in the sendFailedNotification and the sendLoadedNotification
		 * methods defined above.
		 */
		private function sendStartupNotification( noteName : String ) : void
		{
			if ( ! startupProxy.isTimedOut( ) )
			{
				sendNotification( noteName, name );
			}	
		}
	}
}