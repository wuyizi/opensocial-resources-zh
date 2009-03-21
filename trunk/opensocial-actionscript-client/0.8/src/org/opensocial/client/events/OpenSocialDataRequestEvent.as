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

import org.opensocial.client.base.ResponseItem;

/**
 * Event used for asynchronous OpenSocial and IO data requests.
 * It stores parsed data in data field, which is a <code>ResponseItem</code> instance.
 * 
 * @author chaowang@google.com (Jacky Wang)
 * @author yiziwu@google.com (Yizi Wu)
 */
public class OpenSocialDataRequestEvent extends AsyncRequestEvent {

  /**
   * Constructor of the event. 
   * @param type The event type of <code>OpenSocialEvent.ASYNC_COMPLETE</code>.
   * @param data The response data, which is in <code>ResponseItem</code> type, for this event.
   */  
  public function OpenSocialDataRequestEvent(type:String, data:ResponseItem) {
    super(type, data);
  }

  /**
   * Gets the parsed response data of this event. 
   * @return The parsed data object.
   */  
  final public function get response():ResponseItem {
    return rawData_ as ResponseItem;
  }

  /**
   * Clones the event to a new one.
   * @return A new <code>OpenSocialDataEvent</code> object. 
   */
  override public function clone():Event {
    return new OpenSocialDataRequestEvent(type, response);
  }
}

}