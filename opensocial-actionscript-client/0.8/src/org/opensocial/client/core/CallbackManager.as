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

import flash.utils.Dictionary;

/**
 * Manages a callback queue. The dictionary stores <code>&lt;String, Function&gt;</code> pairs.
 * <p> 
 * When comminicating with javascript, the function object cannot pass through 
 * <code>ExternalInterface</code>. The solution is to make a reqID string mapped to a function, 
 * then only pass the reqID to javascript. When receive callback from javascript, get the real
 * actionscript function from the dictionary by this reqID.
 * </p>
 * <p>
 * For other async endpoint request like restful requests, this can also use to exchange function 
 * instances and simple strings to reduce closure or callback recurense.
 * </p>
 * <p>
 * Currenly internally used only. 
 * </p>
 * 
 * @author yiziwu@google.com (Yizi Wu)
 */
internal dynamic class CallbackManager extends Dictionary {
  
  /**
   * A unique incremental number for constructing the callback ID.
   * @private 
   */  
  private var uuid_:uint = 0; 
  
  /**
   * Constructs the manager to store callbacks.
   * @private
   */
  public function CallbackManager() {
  }
  
  /**
   * Returns an unique Id for each callback. Uses as a key to register each callback.
   * @return A unique callback ID.
   * @private
   */
  private function getCallbackID():String {
    // Use timestamp millseconds and a natural number for uuid.
    // NOTE: actionscript is single-threaded. So it is for sure thread-safe.
    ++uuid_;
    return new String(new Date().getTime() + uuid_);
  }
  
  
  /**
   * Pushes a callback to this callback buffer map.
   * @param callback The callback function.
   * @param callbackID If not sets, use a uuid as the ID for the callback.
   * @return The callback ID for this callback.
   */
  public function push(callback:Function = null, callbackID:String = null):String {
    if (!callbackID) {
      callbackID = getCallbackID();
    }
    this[callbackID] = callback;
    return callbackID;
  }

  /**
   * Pops a callback from this buffer map and executes it.
   * @param callbackID The key to access the stored callback function.
   * @param dataObjs Multiple data objects pass to the callback.
   */
  public function pop(callbackID:String, ...dataObjs:Array):void {
    var callback:Function = this[callbackID];
    if (callback is Function) {
      callback.apply(null, dataObjs);
    }
    delete this[callbackID];
  }
  
  /**
   * Simply drops the failed callback from this buffer map.
   * @param callbackID The key to access the stored callback function.
   */
  public function drop(callbackID:String):void {
    delete this[callbackID];
  }
}
}
