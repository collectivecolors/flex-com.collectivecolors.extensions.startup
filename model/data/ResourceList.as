package com.collectivecolors.extensions.flex3.startup.model.data
{
  //----------------------------------------------------------------------------
  // Imports
  
  import org.puremvc.as3.utilities.startupmanager.model.ResourceList;
  import org.puremvc.as3.utilities.startupmanager.model.StartupResourceProxy;

  //----------------------------------------------------------------------------

  public class ResourceList extends ResourceList
  {
    //--------------------------------------------------------------------------
    // Constants
    
    // I wish these were public or protected in the super class.
    protected static const OPEN :int   = 1;
    protected static const CLOSED :int = 2;
    
    //--------------------------------------------------------------------------
    // Properties
    
    protected var resourceMap : Object = { };
    protected var overrides : Boolean  = false;
        
    //--------------------------------------------------------------------------
    // Overrides
    
    /**
     * Add a new startup resource proxy to the resource list.
     * 
     * If a startup proxy exists that points to the same resource proxy then
     * we override the one that already exists with the new one.
     */
    override public function addResource( resource : Object ) : void
    {
      if ( _status == OPEN )
      {
        var startupProxy : StartupResourceProxy 
          = resource as StartupResourceProxy;
          
        var proxyName : String = startupProxy.appResourceProxyName( );
        
        if ( resourceMap.hasOwnProperty( proxyName ) )
        {
          // Rebuild existing startup proxies.
          resourceMap[ proxyName ].startupProxy = startupProxy;
          
          _resources = rebuildResources( );
          overrides  = true;
        }
        else
        {
          // Or add a new startup proxy.
          resourceMap[ proxyName ] = new ProxyData( startupProxy );
          
          _resources.push( startupProxy );
        }        
      } 
    }
    
    /**
     * Add new startup resource proxies to the resource list.
     * 
     * If a startup proxy exists that points to the same resource proxy then
     * we override the one that already exists with the new one.
     */
    override public function addResources( resources : Array ) : void
    {
      if ( _status == OPEN )
      {
        for each ( var resource : Object in resources )
        {
          addResource( resource );
        }
      }  
    }
    
    /**
     * Refresh startup proxy requirement references.
     * 
     * This is called right before the resources are loaded so it gives us a 
     * chance to refresh the requirements.  Since we allow overriding of the
     * startup proxy extension classes, and the startup manager framework
     * assigns references instead of names for the requirements, we need to
     * update pointers to startup manager classes that have been overridden.
     */ 
    override public function close( ) : void
    {
      super.close( );
      
      if ( overrides )
      {
        // Rebuild requirement references.
        for ( var proxyName : String in resourceMap )
        {
          var proxyData : ProxyData = resourceMap[ proxyName ] as ProxyData;
          var requirements : Array  = [ ];
          
          // Get requirement references from names.        
          for each ( var reqName :String in proxyData.requires )
          {
            var reqData : ProxyData = resourceMap[ reqName ] as ProxyData;
          
            requirements.push( reqData.startupProxy );  
          }
        
          // Assign new reference values to current startup proxy requirements.
          proxyData.startupProxy.requires = requirements; 
        }
      }  
    }
    
    //--------------------------------------------------------------------------
    // Internal utilities
    
    /**
     * Build a resource array from the available startup resource proxies.
     */ 
    private function rebuildResources( ) : Array
    {
      var resources : Array = [ ];
          
      for ( var proxyName : String in resourceMap )
      {
        resources.push( resourceMap[ proxyName ].startupProxy );
      }
      
      return resources;     
    }    
  }
}

//******************************************************************************
//******************************************************************************
// ** INTERNAL CLASS **
//******************************************************************************
//******************************************************************************

//------------------------------------------------------------------------------
// Imports

import org.puremvc.as3.utilities.startupmanager.model.StartupResourceProxy;

//------------------------------------------------------------------------------

class ProxyData
{
  //----------------------------------------------------------------------------
  // Properties
  
  private var _startupProxy : StartupResourceProxy;
  private var _requires : Array;
  
  //----------------------------------------------------------------------------
  // Constructor
  
  public function ProxyData( startupProxy : StartupResourceProxy )
  {
    this.startupProxy = startupProxy;   
  }
  
  //----------------------------------------------------------------------------
  // Accessor / Modifiers
  
  //----------------
  // Startup Proxy
  
  /**
   * Get the startup resource proxy object.
   */ 
  public function get startupProxy( ) : StartupResourceProxy
  {
    return _startupProxy;
  }
  
  /**
   * Set the startup resource proxy object.
   * 
   * Note that this also updates the requirement names array.
   */ 
  public function set startupProxy( value : StartupResourceProxy ) : void
  {
    _startupProxy = value;
    
    setRequires( value.requires );
  }
  
  //-----------
  // Requires
  
  /**
   * Get startup resource proxy's requirement names.
   * 
   * These are tightly associated with the startup resource proxy so they are 
   * read only.
   */ 
  public function get requires( ) : Array
  {
    return _requires;
  }
  
  //----------------------------------------------------------------------------
  // Internal Utilities
  
  /**
   * Convert requirement references into names and set requires property.
   */
  private function setRequires( values : Array ) : void
  {
    var requireMap : Object = { };
    
    _requires  = [ ];
    
    for each ( var proxy : StartupResourceProxy in values )
    {
      var proxyName : String = proxy.appResourceProxyName( );
      
      // Avoid storing duplicates.
      if ( ! requireMap.hasOwnProperty( proxyName ) )
      {
        _requires.push( proxyName );
                
        requireMap[ proxyName ] = true; 
      }        
    }
  }
}