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
 * Event used for asynchronous rpc requests and services.
 * It stores the return value.
 * 
 * @author chaowang@google.com (Jacky Wang)
 * @author yiziwu@google.com (Yizi Wu)
 */
public class RpcRequestEvent extends AsyncRequestEvent {
  
  /**
   * Constructor of the event. 
   * @param type The event type of <code>OpenSocialEvent.ASYNC_COMPLETE</code>.
   * @param result The result value returned from the rpc service on the target.
   */
  public function RpcRequestEvent(type:String, result:*) {
    super(type, result);
  }

  /**
   * Gets the result value.
   * @return The result value.
   */  
  public function get result():* {
    return rawData_;
  }

  /**
   * Clones the event to a new one.
   * @return A new <code>RpcRequestEvent</code> object. 
   */
  override public function clone():Event {
    return new RpcRequestEvent(type, result);
  }
}

}