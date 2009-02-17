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

package org.opensocial.client.jswrapper {

import flash.external.ExternalInterface;

/**
 * Wrapper of <code><j>gadgets.io</j></code> namespace in javascript.
 * 
 * @see http://code.google.com/apis/opensocial/docs/0.8/reference/gadgets/#gadgets.io gadgets.io
 * @author yiziwu@google.com (Yizi Wu)
 */
public class GadgetsRpc extends JsFeature {
  
  private const DEFAULT_SERVICE_NAME:String = "__default_rpc__"; 
  
  /**
   * Default constructor.
   * <p>
   * NOTE: This constructor is internally used. Do not call this constructor directly outside 
   * this package.
   * </p>
   * @param client The jswrapper client.
   * @private
   */
  public function GadgetsRpc(client:JsWrapperClient) {
    super(client);
  }
  
  
  /**
   * Registers the external interface callbacks for this feature. 
   */
  override public function registerExternalCallbacks():void {
    ExternalInterface.addCallback("handleRpcCall", handleRpcCall);
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
  public function call(targetId:String,
                       serviceName:String,
                       callback:Function,
                       ...args):void {
    assertReady();
    var reqID:String = pushCallback(callback);
    ExternalInterface.call(getJsFuncName("rpcCall"), reqID, targetId, serviceName, args);
  }
  
  /**
   * Callback of rpc service call.
   * @param reqID Request UID.
   * @param returnValue Any value returns from the service.
   */
  protected function handleRpcCall(reqID:String, returnValue:*):void {
    popCallback(reqID, returnValue);
  }
  
  
  /**
   * Registers an rpc service on this app. 
   * @param serviceName The service name.
   * @param handler The handler function.
   * 
   * @see http://code.google.com/apis/opensocial/docs/0.8/reference/gadgets/#gadgets.rpc.register
   *      gadgets.rpc.register
   */  
  public function register(serviceName:String,
                           handler:Function):void {
    assertReady();
    pushCallback(handler, serviceName);
    ExternalInterface.addCallback(serviceName, handler);
    ExternalInterface.call(getJsFuncName("rpcRegister"), serviceName, serviceName);
  }
  
  /**
   * Registers the default rpc service on this app. 
   * @param handler The handler function
   * 
   * @see http://code.google.com/apis/opensocial/docs/0.8/reference/gadgets/#gadgets.rpc.registerDefault
   *      gadgets.rpc.registerDefault
   */  
  public function registerDefault(handler:Function):void {
    assertReady();
    pushCallback(handler, DEFAULT_SERVICE_NAME);
    ExternalInterface.addCallback(DEFAULT_SERVICE_NAME, handler);
    ExternalInterface.call(getJsFuncName("rpcRegister"), null, DEFAULT_SERVICE_NAME);
  }

  /**
   * Unregisters the rpc service on this app. 
   * @param serviceName The service name to be unregistered.
   * 
   * @see http://code.google.com/apis/opensocial/docs/0.8/reference/gadgets/#gadgets.rpc.unregister
   *      gadgets.rpc.unregister
   */    
  public function unregister(serviceName:String):void {
    assertReady();
    dropCallback(serviceName);
    // TODO how to remove callbacks from ExternalInterface?
    ExternalInterface.call(getJsFuncName("rpcUnregister"), serviceName);
  }

  /**
   * Unregisters the default rpc service on this app.
   * 
   * @see http://code.google.com/apis/opensocial/docs/0.8/reference/gadgets/#gadgets.rpc.unregisterDefault
   *      gadgets.rpc.unregisterDefault
   */    
  public function unregisterDefault():void {
    assertReady();
    dropCallback(DEFAULT_SERVICE_NAME);
    // TODO how to remove callbacks from ExternalInterface?
    ExternalInterface.call(getJsFuncName("rpcUnregister"), null);
  }

  
}
}
