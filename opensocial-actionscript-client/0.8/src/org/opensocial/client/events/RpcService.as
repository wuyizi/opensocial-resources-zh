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

package org.opensocial.client.events {

import flash.events.EventDispatcher;

import org.opensocial.client.core.*;

/**
 * Event dispatcher for asynchronous RPC service.
 * 
 * @author yiziwu@google.com (Yizi Wu)
 */
public class RpcService extends EventDispatcher {
  /**
   * The registered service name.
   * @private 
   */
  private var serviceName_:String;
  
  /**
   * Indicates that this service is ready to serve.
   * @private 
   */  
  private var isListening_:Boolean;
  
  /**
   * Constructor of this request event dispatcher. 
   * @param serviceName The service name to be registered.
   */
  public function RpcService(serviceName:String) {
    serviceName_ = serviceName;
  }
  
  /**
   * Gets the registered service name. 
   * @return The service name;
   * 
   */  
  public function get serviceName():String {
    return serviceName_;
  }
  
  /**
   * Indicates that this service is ready to serve.
   * @return True if it has handler and ready to serve.
   */  
  public function get isListening():Boolean {
    return isListening_;
  }

  /**
   * Registers this service to the client.
   * @param client The client.
   * @return The service instance itself. 
   * 
   */  
  public function register(client:OpenSocialClient):RpcService {
    var serviceHandler:Function = function (callID:String, ...params:Array):void {
      var callback:Function = function(result:*):void {
        client.callSync(Feature.RETURN_RPC_SERVICE, callID, result);
      };
      var event:RpcServiceEvent = 
          new RpcServiceEvent(RpcServiceEvent.RPC_SERVICE, params, callback);
      dispatchEvent(event);
    };
    client.registerCallback(serviceName_, serviceHandler);
    client.callSync(Feature.REGISTER_RPC_SERVICE, serviceName_, serviceName_);
    isListening_ = true;
    return this;
  }

  /**
   * Unregisters this service from the client.
   * @param client
   * @return The service instance itself. 
   */  
  public function unregister(client:OpenSocialClient):RpcService {
    client.callSync(Feature.UNREGISTER_RPC_SERVICE, serviceName_);
    client.unregisterCallback(serviceName_);
    isListening_ = false;
    return this;
  }
  
  /**
   * The quick short-cut for adding a callback function for the service. It wraps the async 
   * request from event-driven style to a simple callback style.
   * @param callback The callback function
   * @return The service instance itself.
   */
  public function addServiceHandler(callback:Function):RpcService {
    addEventListener(RpcServiceEvent.RPC_SERVICE, 
                     function(event:RpcServiceEvent):void {
                       var returnValue:* = callback(event.params);
                       event.callback(returnValue);
                     }, false, 0, true);
    return this;
  }

}
}
