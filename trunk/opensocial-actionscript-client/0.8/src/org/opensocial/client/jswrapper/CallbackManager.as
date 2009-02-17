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

import flash.utils.Dictionary;

/**
 * Manager for the callback queue. The dictionary stores <String, Function> pairs.
 * <p> 
 * When comminicating with javascript, the function object cannot pass through 
 * <code>ExternalInterface</code>. The solution is to make a reqID string mapped to a function, 
 * then only pass the reqID to javascript. When receive callback from javascript, get the real
 * actionscript function from the dictionary by this reqID.
 * </p>
 * 
 * <p>
 * TODO: Consider moving it ro util package.
 * </p> 
 *  
 * @author yiziwu@google.com (Yizi Wu)
 */
internal dynamic class CallbackManager extends Dictionary {
  
  private var uuid_:uint = 0; 
  
  /**
   * Constructs the request manager to store callbacks.
   * @internal
   */
  public function CallbackManager() {
     
  }
  
  /**
   * Returns an unique Id for each callback. Uses as a key to register each callback.
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
   * @param callbackKey If not sets, use a uuid as the key for the callback.
   * @return the key for this callback.
   * @internal
   */
  internal function push(callback:Function = null, callbackKey:String = null):String {
    if (!callbackKey) {
      callbackKey = getCallbackID();
    }
    this[callbackKey] = callback;
    return callbackKey;
  }

  /**
   * Pops a callback from this buffer map and excutes it.
   * @param callbackKey The key to access the stored callback function.
   * @param dataObjs Multiple data objects pass to the callback.
   * @internal
   */
  internal function pop(callbackKey:String, ...dataObjs:*):void {
    var callback:Function = this[callbackKey];
    if (callback is Function) {
      callback.apply(null, dataObjs);
    }
    delete this[callbackKey];
  }
  
  /**
   * Simply drops the failed callback from this buffer map.
   * @param callbackKey The key to access the stored callback function.
   * @internal
   */
  internal function drop(callbackKey:String):void {
    delete this[callbackKey];
  }
  
}

}