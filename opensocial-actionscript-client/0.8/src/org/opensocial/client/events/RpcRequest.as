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

import org.opensocial.client.core.*;

/**
 * Event dispatcher for asynchronous RPC requests.
 * 
 * @author chaowang@google.com (Jacky Wang)
 * @author yiziwu@google.com (Yizi Wu)
 */
public class RpcRequest extends AsyncRequest {
  /**
   * Constructor of this request event dispatcher. 
   * <code>Feature.CALL_RPC</code> is the only available feature for this request type.
   */  
  public function RpcRequest() {
    super(Feature.CALL_RPC);
  }

  /**
   * The function for the async callback which is registered on the client callback manager.
   * It takes in the async response raw data to create a corresponding event then dispatches it.
   * This function will be override by derieved classes.
   * @param returnValue The return value object.
   */
  override protected function handleComplete(returnValue:*):void {
    var event:RpcRequestEvent = new RpcRequestEvent(AsyncRequestEvent.ASYNC_COMPLETE, returnValue);
    isRunning_ = false;
    dispatchEvent(event);
  }

  /**
   * The quick short-cut for adding a callback function when request succeed. It wraps the async 
   * request from event-driven style to a simple callback style.
   * @param callback The callback function
   * @return The request instance itself.
   */
  override public function addCompleteHandler(callback:Function):AsyncRequest {
    addEventListener(AsyncRequestEvent.ASYNC_COMPLETE, 
                     function(event:RpcRequestEvent):void {
                       callback(event.result);
                     }, false, 0, true);
    return this;
  }

  /**
   * Helper function for setting the parameters of the <code>Feature.CALL_RPC</code> feature. 
   * @param targetId The target app's iframe id, null for the parent.
   * @param serviceName The service name to be called.
   * @param args Other arguments for the service call.
   * @return The request instance itself. 
   */  
  public function forRpcCall(targetId:String, serviceName:String, ...args:Array):RpcRequest {
    assertFeature(Feature.CALL_RPC);
    setParams(targetId, serviceName, args);
    return this;
  }

}
}
