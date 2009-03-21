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

import flash.events.Event;

/**
 * Event used for asynchronous rpc services.
 * It stores parameters and the callback function.
 * 
 * @author yiziwu@google.com (Yizi Wu)
 */
public class RpcServiceEvent extends Event {
  
  /**
   * For the 'rpcService' event dispatched when the opensocial rpc service get called.
   * @eventType rpcService
   */
  public static const RPC_SERVICE:String = "rpcService";
  
  
  /**
   * The array of parameters which are passed via the calling source.
   * @private 
   */  
  protected var params_:Array = null;
  
  /**
   * The function to send the return value back.
   * @private
   */  
  protected var callback_:Function = null;
  
  /**
   * Constructor of the event. 
   * @param type The event type of <code>OpenSocialEvent.RPC_SERVICE</code>.
   * @param params The array of parameters which are passed via the calling source.
   * @param callback The function to send the return value back. 
   */  
  public function RpcServiceEvent(type:String, params:Array, callback:Function) {
    super(type, false, true);
    params_ = new Array().concat(params);
    callback_ = callback;
  }

  /**
   * Gets the parameters array which are passed via the calling source. 
   * @return The parameters array.
   */  
  public function get params():Array {
    return params_;
  }
  
  /**
   * Gets the return callback function. 
   * @return The return callback function.
   */  
  public function get callback():Function {
    return callback_;
  }
  
  /**
   * Clones the event to a new one.
   * @return A new <code>RpcServiceEvent</code> object. 
   */
  override public function clone():Event {
    return new RpcServiceEvent(type, params_, callback_);
  }
}

}