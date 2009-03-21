/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

package org.opensocial.client.core {

/**
 * Features helper for several sub-namespaces in the <code><j>gadgets</j></code> namespace.
 * <p>
 * It contains the most important <code><j>makeRequest</j></code> asynchronous request, which can
 * be applied to both jswrapper and restful client. And some useful views or rpc features, which
 * may be only used in jswrapper client. 
 * </p>
 * 
 * @see http://code.google.com/apis/opensocial/docs/0.8/reference/gadgets/#gadgets.io gadgets.io
 * @see http://code.google.com/apis/opensocial/docs/0.8/reference/gadgets/#gadgets.rpc gadgets.rpc
 * @see http://code.google.com/apis/opensocial/docs/0.8/reference/gadgets/#gadgets.views gadgets.views
 * @see http://code.google.com/apis/opensocial/docs/0.8/reference/gadgets/#gadgets.window gadgets.window
 *  
 * @author yiziwu@google.com (Yizi Wu)
 */
public class GadgetsHelper extends ClientHelper {

  /**
   * Constructor.
   * @param client The opensocial client instance.
   */
  public function GadgetsHelper(client:OpenSocialClient) {
    super(client);
  }

  /**
   * Sends request to a remote site to get or post data.
   * @param url The remote site url.
   * @param callback A fucntion with a parameter of <code>ResponseItem</code>.
   *                 The underlying data in the response item can be 
   *                 <code>String | Object</code> for different content types respectfully.
   * @param params A <code>Map.&lt;GadgetsIo.RequestParameters, Object&gt;</code> object.
   * 
   * @see http://code.google.com/apis/opensocial/docs/0.8/reference/gadgets/#gadgets.io.makeRequest
   *      gadgets.io.makeRequest
   * @see http://code.google.com/apis/opensocial/articles/makerequest-0.8.html 
   *      Introduction to makeRequest
   */
  public function makeRequest(url:String, callback:Function = null, params:Object = null):void {
    client.callAsync(Feature.MAKE_REQUEST, callback, url, params);
  }
  
  
  /**
   * Calls the <code><j>gadgets.views.getCurrentView</j></code> to get the current view
   * name. Null if the 'views' feature is not enabled.
   * @return The view name, defined in <code>GadgetsViews.ViewType</code>.
   * @see http://code.google.com/apis/opensocial/docs/0.8/reference/gadgets/#gadgets.views.getCurrentView
   *      gadgets.views.getCurrentView
   * @see http://code.google.com/apis/opensocial/docs/0.8/reference/gadgets/#gadgets.views.View.getName
   *      gadgets.views.View.getName 
   */ 
  public function getCurrentView():String {
    return client.callSync(Feature.GET_CURRENT_VIEW);
  }

  /**
   * Calls the <code><j>gadgets.views.View.isOnlyVisibleGadget</j></code> to check if 
   * it is the only app on the page. Returns true if the 'views' feature is not enabled. 
   * @return True if it's the only one visible app.
   * @see http://code.google.com/apis/opensocial/docs/0.8/reference/gadgets/#gadgets.views.View.isOnlyVisibleGadget 
   *      gadgets.views.View.isOnlyVisibleGadget
   * 
   */
  public function isViewOnlyVisible():Boolean {
    return client.callSync(Feature.IS_ONLY_VISIBLE);
  }

  /**
   * Calls the <code><j>gadgets.views.getParams</j></code> to get the params from current view.
   * @return The params object.
   * @see http://code.google.com/apis/opensocial/docs/0.8/reference/gadgets/#gadgets.views.getParams
   *      gadgets.views.getParams
   */ 
  public function getViewParams():Object {
    return client.callSync(Feature.GET_VIEW_PARAMS);
  }
  
  /**
   * Sets the app's witdh. This will resize the swf object's width.
   * @param width The new width.
   */ 
  public function setStageWidth(width:Number):void {
    client.callSync(Feature.SET_STAGE_WIDTH, width);
  }


  /**
   * Sets the app's height. 
   * This will resize the swf object's height. It will also adjust the iframe's height 
   * if the 'dynamicHeight' feature is available.
   * @param height The new height.
   * @see http://code.google.com/apis/opensocial/docs/0.8/reference/gadgets/#gadgets.window.adjustHeight
   *      gadgets.window.adjustHeight
   */
  public function setStageHeight(height:Number):void {
    client.callSync(Feature.SET_STAGE_HEIGHT, height);
  }


  /**
   * Sets the app's title if the 'settitle' feature is available.
   * @param title The new title.
   * @see http://code.google.com/apis/opensocial/docs/0.8/reference/gadgets/#gadgets.window.setTitle
   *      gadgets.window.setTitle
   */  
  public function setTitle(title:String):void {
    client.callSync(Feature.SET_TITLE, title);
  }
  
  /**
   * Calls the rpc service on another target. 
   * @param targetId The target app's iframe id, null for the parent.
   * @param serviceName The service name to be called.
   * @param callback The callback function with a return value from the service.
   * @param args Other arguments for the service call.
   * 
   * @see http://code.google.com/apis/opensocial/docs/0.8/reference/gadgets/#gadgets.rpc.call
   *      gadgets.rpc.call
   */
  public function call(targetId:String, serviceName:String, callback:Function, ...args:Array):void {
    client.callAsync(Feature.CALL_RPC,
                     function(result:*):void {
                       callback(result);
                     },
                     targetId, serviceName, args);
  }


  private static const DEFAULT_SERVICE_NAME:String = "__default_rpc__";

  /**
   * Wraps the target handler to the service handler for the rpc registration. The returnning
   * function is the real handler registered on <code><j>gadgets.rpc</j></code> and will get called
   * by other apps. So this function will call the target handler in flash and call the 
   * <code><j>opensocial.flash.rpcReturn</j></code> to pass back the return value to the caller app.
   *   
   * @param handler The target handler in flash to handle the registered rpc service.
   * @return The real function to be registered on javascript side.
   * @private
   */  
  private function makeServiceHandler(handler:Function):Function {
    return (
        function(callID:String, ...args:Array):void {
          var returnValue:* = handler.apply(null, args);
          client.callSync(Feature.RETURN_RPC_SERVICE, callID, returnValue);
        }
    );
  }

  
  /**
   * Registers an rpc service on this app. 
   * @param serviceName The service name.
   * @param handler The target handler function.
   * 
   * @see http://code.google.com/apis/opensocial/docs/0.8/reference/gadgets/#gadgets.rpc.register
   *      gadgets.rpc.register
   */  
  public function register(serviceName:String, handler:Function):void {
    client.registerCallback(serviceName, makeServiceHandler(handler));
    client.callSync(Feature.REGISTER_RPC_SERVICE, serviceName, serviceName);
  }


  /**
   * Registers the default rpc service on this app. 
   * @param handler The target handler function
   * 
   * @see http://code.google.com/apis/opensocial/docs/0.8/reference/gadgets/#gadgets.rpc.registerDefault
   *      gadgets.rpc.registerDefault
   */  
  public function registerDefault(handler:Function):void {
    client.registerCallback(DEFAULT_SERVICE_NAME, makeServiceHandler(handler));
    client.callSync(Feature.REGISTER_RPC_SERVICE, null, DEFAULT_SERVICE_NAME);
  }


  /**
   * Unregisters the rpc service on this app. 
   * @param serviceName The service name to be unregistered.
   * 
   * @see http://code.google.com/apis/opensocial/docs/0.8/reference/gadgets/#gadgets.rpc.unregister
   *      gadgets.rpc.unregister
   */    
  public function unregister(serviceName:String):void {
    client.callSync(Feature.UNREGISTER_RPC_SERVICE, serviceName);
    client.unregisterCallback(serviceName);
  }


  /**
   * Unregisters the default rpc service on this app.
   * 
   * @see http://code.google.com/apis/opensocial/docs/0.8/reference/gadgets/#gadgets.rpc.unregisterDefault
   *      gadgets.rpc.unregisterDefault
   */    
  public function unregisterDefault():void {
    client.callSync(Feature.UNREGISTER_RPC_SERVICE, null);
    client.unregisterCallback(DEFAULT_SERVICE_NAME);
  }
}
}
