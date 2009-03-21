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

import org.opensocial.client.base.OpenSocialError;
import org.opensocial.client.core.OpenSocialClient;

/**
 * Event dispatcher for asynchronous requests.
 * 
 * @author chaowang@google.com (Jacky Wang)
 * @author yiziwu@google.com (Yizi Wu)
 */
public class AsyncRequest extends EventDispatcher {
  
  /**
   * The feature to be executed.
   * @private
   */ 
  protected var featureName_:String;
  
  /**
   * Indicates this request instance is waiting for response or not.
   * @private 
   */  
  protected var isRunning_:Boolean;
  
  /**
   * The array stores parameters for the async request.
   * @private
   */ 
  protected var params_:Array = null;

  
  /**
   * Constructor of this request event dispatcher. 
   * @param featureName The feature to be executed. 
   */  
  public function AsyncRequest(featureName:String) {
    featureName_ = featureName;
    isRunning_ = false;
  }
  
  /**
   * Checks the feature name. If the feature name of this request object is not expected then 
   * throws error. 
   * @param featureName
   * @throws OpenSocialError Throw error if assertion fails.
   */  
  public function assertFeature(featureName:String):void {
    if (featureName_ != featureName) {
      throw new OpenSocialError("Cannot reassign this request object to another feature.");
    }
  }

  /**
   * Indicates this request instance is waiting for response or not.
   * @return True if it's waiting.
   */  
  public function get isRunning():Boolean {
    return isRunning_;
  }

  /**
   * Returns the request parameters array. 
   * @return The parameters array.
   */  
  public function get params():Array {
    return params_;
  }

  /**
   * Sets the parameters of this request.
   * @param params An array stores parameters for the async request.
   * @return The request instance itself.
   */
  public function setParams(...params:Array):AsyncRequest {
    params_ = params;
    return this;
  }

  /**
   * The function for the async callback which is registered on the client callback manager.
   * It takes in the async response raw data to create a corresponding event then dispatches it.
   * This function will be override by derieved classes.
   * @param rawData The raw response object.
   */
  protected function handleComplete(rawData:*):void {
    var event:AsyncRequestEvent = new AsyncRequestEvent(AsyncRequestEvent.ASYNC_COMPLETE, rawData);
    isRunning_ = false;
    dispatchEvent(event);
  }

  /**
   * Sends out the request using client's async call api. If this request instance is running, then
   * this method will do nothing.
   * <p>
   * The underlying client has no knowledge on the event-driven system.
   * </p>
   * @param client The client, could be JsWrapperClient or RestfulClient.
   */
  public function send(client:OpenSocialClient):void {
    if (isRunning_) {
      return;
    }
    var args:Array = [featureName_, handleComplete];
    if (params_ != null) {
      args = args.concat(params_);
    }
    client.callAsync.apply(client, args);
    isRunning_ = true;
  }

  /**
   * The quick short-cut for adding a callback function for the request completion. It wraps the 
   * async request from event-driven style to a simple callback style.
   * @param callback The callback function.
   * @return The request instance itself.
   */
  public function addCompleteHandler(callback:Function):AsyncRequest {
    addEventListener(AsyncRequestEvent.ASYNC_COMPLETE,
                     function (event:AsyncRequestEvent):void {
                       callback(event.rawData);
                     }, false, 0, true);
    return this;
  }

}
}
