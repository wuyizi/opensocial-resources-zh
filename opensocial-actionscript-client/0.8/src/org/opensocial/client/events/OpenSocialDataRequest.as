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

import org.opensocial.client.base.*;
import org.opensocial.client.core.*;

/**
 * Event dispatcher for asynchronous OpenSocial and IO data requests.
 * 
 * @author chaowang@google.com (Jacky Wang)
 * @author yiziwu@google.com (Yizi Wu)
 */
public class OpenSocialDataRequest extends AsyncRequest {
  /**
   * Constructor of this request event dispatcher. 
   * @param featureName The feature to be executed. 
   */  
  public function OpenSocialDataRequest(featureName:String) {
    super(featureName);
  }

  /**
   * The handler which wraps a response object into event, and dispatches it.
   * @param rawData The response object, should be in <code>ResponseItem</code> type.
   */
  override protected function handleComplete(responseItem:*):void {
    var event:OpenSocialDataRequestEvent = 
        new OpenSocialDataRequestEvent(AsyncRequestEvent.ASYNC_COMPLETE, responseItem);
    isRunning_ = false;
    dispatchEvent(event);
  }

  /**
   * The quick short-cut for adding a callback function for the request completion. It wraps the 
   * async request from event-driven style to a simple callback style.
   * @param callback The callback function
   * @return The request instance itself.
   */
  override public function addCompleteHandler(callback:Function):AsyncRequest {
    addEventListener(AsyncRequestEvent.ASYNC_COMPLETE, 
                     function(event:OpenSocialDataRequestEvent):void {
                       callback(event.response);
                     }, false, 0, true);
    return this;
  }

  /**
   * Helper function for setting the parameters of the <code>Feature.FETCH_PERSON</code> feature.
   * @param id An <code>IdSpec.PersonId</code> value, can be <code>VIEWER</code> or 
   *           <code>OWNER</code>.
   * @param params A <code>Map.&lt;DataRequest.PeopleRequestField, Object&gt;</code> object.
   * @return The request instance itself.
   * 
   * @see org.opensocial.client.core.OpenSocialHelper#fetchPerson 
   */  
  public function forFetchPerson(id:String, params:Object = null)
      :OpenSocialDataRequest {
    assertFeature(Feature.FETCH_PERSON);
    setParams(id, params);
    return this; 
  }

  /**
   * Helper function for setting the parameters of the <code>Feature.FETCH_PERSON</code> feature.
   * @param idSpec An <code>IdSpec</code> object.
   * @param params A <code>Map.&lt;DataRequest.PeopleRequestField, Object&gt;</code> object.
   * @return The request instance itself. 
   * 
   * @see org.opensocial.client.core.OpenSocialHelper#fetchPeople
   */  
  public function forFetchPeople(idSpec:IdSpec, params:Object = null)
      :OpenSocialDataRequest {
    assertFeature(Feature.FETCH_PEOPLE);
    setParams(idSpec, params);
    return this;
  }

  /**
   * Helper function for setting the parameters of the <code>Feature.FETCH_PERSON</code> feature.
   * Sends request to fetch person app data.
   * @param idSpec An <code>IdSpec</code> object.
   * @param keys Array of key names, '*' to represent all.
   * @param params A <code>Map.&lt;DataRequest.DataRequestField, Object&gt;</code> object.
   * @return The request instance itself.
   * 
   * @see org.opensocial.client.core.OpenSocialHelper#fetchPersonAppData
   */    
  public function forFetchPersonAppData(idSpec:IdSpec, keys:Array, params:Object = null)
      :OpenSocialDataRequest {
    assertFeature(Feature.FETCH_PERSON_APP_DATA);
    setParams(idSpec, keys, params);
    return this;
  }

  /**
   * Helper function for setting the parameters of the <code>Feature.FETCH_PERSON</code> feature.
   * @param id A <code>IdSpec.PersonId</code> value, can only be <code>VIEWER</code>.
   * @param key One key name of the data.
   * @param value The value to be store, must be a json format.
   * @return The request instance itself. 
   * 
   * @see org.opensocial.client.core.OpenSocialHelper#updatePersonAppData
   */    
  public function forUpdatePersonAppData(id:String, key:String, value:Object)
      :OpenSocialDataRequest {
    assertFeature(Feature.UPDATE_PERSON_APP_DATA);
    setParams(id, key, value);
    return this;
  }
  
  /**
   * Helper function for setting the parameters of the <code>Feature.FETCH_PERSON</code> feature.
   * @param id A <code>IdSpec.PersonId</code> value, can only be <code>VIEWER</code>.
   * @param keys Array of key names, '*' to represent all.
   * @return The request instance itself. 
   * 
   * @see org.opensocial.client.core.OpenSocialHelper#removePersonAppData
   */  
  public function forRemovePersonAppData(id:String, keys:Array)
      :OpenSocialDataRequest {
    assertFeature(Feature.REMOVE_PERSON_APP_DATA);
    setParams(id, keys);
    return this;
  }
  
  /**
   * Helper function for setting the parameters of the <code>Feature.FETCH_PERSON</code> feature.
   * @param idSpec An <code>IdSpec</code> object.
   * @param params A <code>Map.&lt;DataRequest.ActivityRequestFields, Object&gt;</code> object.
   * @return The request instance itself. 
   * 
   * @see org.opensocial.client.core.OpenSocialHelper#fetchActivities
   */  
  public function forFetchActivities(idSpec:IdSpec, params:Object = null)
      :OpenSocialDataRequest {
    assertFeature(Feature.FETCH_ACTIVITIES);
    setParams(idSpec, params);
    return this;
  }
  
  /**
   * Helper function for setting the parameters of the <code>Feature.FETCH_PERSON</code> feature.
   * @param activity An <code>Activity</code> object.
   * @param priority A value of <code>Globals.CreateActivityPriority</code>.
   * @return The request instance itself. 
   * 
   * @see org.opensocial.client.core.OpenSocialHelper#requestCreateActivity
   */  
  public function forRequestCreateActivity(activity:Activity, priority:String = null)
      :OpenSocialDataRequest {
    assertFeature(Feature.REQUEST_CREATE_ACTIVITY);
    setParams(activity, priority);
    return this;
  }

  /**
   * Helper function for setting the parameters of the <code>Feature.FETCH_PERSON</code> feature.
   * @param recipients An array of ids, such as OWNER, VIEWER, or person ids in reachable groups.
   * @param message An <code>Message</code> object.
   * @return The request instance itself. 
   * 
   * @see org.opensocial.client.core.OpenSocialHelper#requestSendMessage
   */  
  public function forRequestSendMessage(recipients:Array, message:Message)
      :OpenSocialDataRequest {
    assertFeature(Feature.REQUEST_SEND_MESSAGE);
    setParams(recipients, message);
    return this;
  }

  /**
   * Helper function for setting the parameters of the <code>Feature.FETCH_PERSON</code> feature.
   * @param recipients An array of ids, such as OWNER, VIEWER, or person ids in reachable groups.
   * @param reason An <code>Message</code> object.
   * @return The request instance itself. 
   * 
   * @see org.opensocial.client.core.OpenSocialHelper#requestShareApp
   */    
  public function forRequestShareApp(recipients:Array, reason:Message)
      :OpenSocialDataRequest {
    assertFeature(Feature.REQUEST_SHARE_APP);
    setParams(recipients, reason);
    return this;
  }

  /**
   * Helper function for setting the parameters of the <code>Feature.FETCH_PERSON</code> feature.
   * @param permissions An array of <code>Globals.Permission</code> values.
   * @param reasonText A string of reason text.
   * @return The request instance itself.
   * 
   * @see org.opensocial.client.core.OpenSocialHelper#requestPermission
   */    
  public function forRequestPermission(permissions:Array, reasonText:String)
      :OpenSocialDataRequest {
    assertFeature(Feature.REQUEST_PERMISSION);
    setParams(permissions, reasonText);
    return this;
  }
  
  /**
   * Helper function for setting the parameters of the <code>Feature.FETCH_PERSON</code> feature.
   * @param url The remote site url.
   * @param params A <code>Map.&lt;GadgetsIo.RequestParameters, Object&gt;</code> object.
   * @return The request instance itself.
   * 
   * @see org.opensocial.client.core.OpenSocialHelper#makeRequest
   */  
  public function forMakeRequest(url:String, params:Object = null)
      :OpenSocialDataRequest {
    assertFeature(Feature.MAKE_REQUEST);
    setParams(url, params);
    return this;
  }

}
}
