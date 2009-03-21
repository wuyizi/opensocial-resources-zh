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

import org.opensocial.client.base.OpensocialError;
  
/**
 * Base class for all features wrapped from Javascript. Core and abstract functionalities are 
 * defined in this class, and other feature related codes are in sub classes.
 * The client will load several instances of JsFeature to support the whole API.
 * 
 * @author yiziwu@google.com (Yizi Wu)
 */
public class JsFeature {

  private var client_:JsWrapperClient;
  
  /**
   * Initializes the feature instance.
   * @param client The wrapper client.
   */  
  public function JsFeature(client:JsWrapperClient) {
    client_ = client;
  }
  
  /**
   * Returns the client.ready property.
   * @return The client.ready property.
   * @see JsWrapperClient#ready
   */  
  protected function get ready():Boolean {
    return client_.ready;
  }
  
  /**
   * Asserts the client.ready property. Throws error if not ready.
   */
  protected function assertReady():void {
    if (!ready) throw new OpensocialError("The Opensocial Client is not ready.");
  }
  
  /**
   * Generates the javascript function name with the <code>jsNamespace</code> value.
   * @return The javascript function name for <code>ExternalInterface</code> to call.
   * @see JsWrapperClient#jsNamespace
   */
  protected function getJsFuncName(funcName:String):String {
    return client_.jsNamespace + "." + funcName;
  }
  
  /**
   * Helper method to register all external callbacks used in this feature.
   * Subclasses may override this method.
   */  
  public function registerExternalCallbacks():void {
    // no default callbacks
  }
  
  /**
   * Returns the push function of the <code>CallbackManager</code> instance in the client.
   * @return The handler function for pushing callback.
   * @see CallbackManager#push
   */  
  protected function get pushCallback():Function {
    return client_.callbacks.push;
  }
  
  /**
   * Returns the pop function of the <code>CallbackManager</code> instance in the client.
   * @return The handler function for popping callback.
   * @see CallbackManager#pop
   */  
  protected function get popCallback():Function {
    return client_.callbacks.pop;
  }
  
  /**
   * Returns the drop function of the <code>CallbackManager</code> instance in the client.
   * @return The handler function for dropping callback.
   * @see CallbackManager#drop
   */  
  protected function get dropCallback():Function {
    return client_.callbacks.drop;
  }
}
}