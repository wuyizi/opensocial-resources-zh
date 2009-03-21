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
 * Event for clients.
 * 
 * @author yiziwu@google.com (Yizi Wu)
 */
public class OpenSocialClientEvent extends Event {

  /**
   * For the 'clientReady' event dispatched when the opensocial environment is ready.
   * @eventType clientReady
   */
  public static const CLIENT_READY:String = "clientReady";


  
  private var message_:String = "";

  /**
   * Constructor of the event. 
   * @param type The event type.
   * @param bubbles 
   * @param cancelable 
   * @param msg The string to deliver message if any. 
   */  
  public function OpenSocialClientEvent(type:String, 
                                  bubbles:Boolean = false,
                                  cancelable:Boolean = false,
                                  msg:String = "") {
    super(type, false, false);
    message_ = msg;
  }

  /**
   * Gets the message property of this event.
   * @return The message value.
   */  
  public function get message():String {
    return message_;
  }

}
}
