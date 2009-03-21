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

import org.opensocial.client.base.*;

/**
 * Features helper for <code><j>opensocial</j></code> namespaces. This is the core namespace for 
 * the Opensocial API.
 * <p>
 * It contains the those remote data asynchronous requests to people, activities and data services
 * which can be applied to both jswrapper and restful client. And some environment related features
 * which may be only used in jswrapper client.
 * </p>
 * 
 * @see http://code.google.com/apis/opensocial/docs/0.8/reference/#opensocial opensocial
 * 
 * @author yiziwu@google.com (Yizi Wu)
 * @author chaowang@google.com (Jacky Wang)
 */
public class OpenSocialHelper extends ClientHelper {

  /**
   * Constructor.
   * @param client The opensocial client instance.
   */
  public function OpenSocialHelper(client:OpenSocialClient) {
    super(client);
  }


  /**
   * Sends request to fetch a person.
   * @param id An <code>IdSpec.PersonId</code> value, can be <code>VIEWER</code> or 
   *           <code>OWNER</code>.
   * @param callback A fucntion with a parameter of <code>ResponseItem</code>.
   *                 The underlying data in the response item is <code>Person</code>.
   * @param params A <code>Map.&lt;DataRequest.PeopleRequestField, Object&gt;</code> object.
   * 
   * @see http://code.google.com/apis/opensocial/docs/0.8/reference/#opensocial.DataRequest.newFetchPersonRequest 
   *      opensocial.DataRequest.newFetchPersonRequest
   */
  public function fetchPerson(id:String, callback:Function = null, params:Object = null):void {
    client.callAsync(Feature.FETCH_PERSON, callback, id, params);
  }


  /**
   * Sends request to fetch friends.
   * @param idSpec An <code>IdSpec</code> object.
   * @param callback A fucntion with a parameter of <code>ResponseItem</code>.
   *                 The underlying data in the response item is <code>Collection</code>.
   * @param params A <code>Map.&lt;DataRequest.PeopleRequestField, Object&gt;</code> object.
   * 
   * @see http://code.google.com/apis/opensocial/docs/0.8/reference/#opensocial.DataRequest.newFetchPeopleRequest 
   *      opensocial.DataRequest.newFetchPeopleRequest
   */
  public function fetchPeople(idSpec:IdSpec, callback:Function = null, params:Object = null):void {
    client.callAsync(Feature.FETCH_PEOPLE, callback, idSpec, params);
  }


  /**
   * Sends request to fetch person app data.
   * @param idSpec An <code>IdSpec</code> object.
   * @param keys Array of key names, '*' to represent all.
   * @param callback A fucntion with a parameter of <code>ResponseItem</code>.
   *                 The underlying data in the response item is 
   *                 <code>Map.&lt;String, Map.&lt;String, Object&gt;&gt;</code>.
   * @param params A <code>Map.&lt;DataRequest.DataRequestField, Object&gt;</code> object.
   * 
   * @see http://code.google.com/apis/opensocial/docs/0.8/reference/#opensocial.DataRequest.newFetchPersonAppDataRequest 
   *      opensocial.DataRequest.newFetchPersonAppDataRequest
   */
  public function fetchPersonAppData(idSpec:IdSpec, keys:Array, callback:Function = null, 
                                     params:Object = null):void {
    client.callAsync(Feature.FETCH_PERSON_APP_DATA, callback, idSpec, keys, params);
  }


  /**
   * Sends request to update the person app data.
   * @param id A <code>IdSpec.PersonId</code> value, can only be <code>VIEWER</code>.
   * @param key One key name of the data.
   * @param value The value to be store, must be a json format.
   * @param callback A fucntion with a parameter of <code>ResponseItem</code>.
   *                 The underlying data in the response item is null.
   * 
   * @see http://code.google.com/apis/opensocial/docs/0.8/reference/#opensocial.DataRequest.newUpdatePersonAppDataRequest 
   *      opensocial.DataRequest.newUpdatePersonAppDataRequest
   */
  public function updatePersonAppData(id:String, key:String, value:Object, 
                                      callback:Function = null):void {
    client.callAsync(Feature.UPDATE_PERSON_APP_DATA, callback, id, key, value);
  }


  /**
   * Sends request to remove the person app data.
   * @param id A <code>IdSpec.PersonId</code> value, can only be <code>VIEWER</code>.
   * @param keys Array of key names, '*' to represent all.
   * @param callback A fucntion with a parameter of <code>ResponseItem</code>.
   *                 The underlying data in the response item is null.
   * 
   * @see http://code.google.com/apis/opensocial/docs/0.8/reference/#opensocial.DataRequest.newRemovePersonAppDataRequest 
   *      opensocial.DataRequest.newRemovePersonAppDataRequest
   */
  public function removePersonAppData(id:String, keys:Array, callback:Function = null):void {
    client.callAsync(Feature.REMOVE_PERSON_APP_DATA, callback, id, keys);
  }


  /**
   * Sends request to fetch activities for people. 
   * Js-side.
   * @param idSpec An <code>IdSpec</code> object.
   * @param callback A fucntion with a parameter of <code>ResponseItem</code>.
   *                 The underlying data in the response item is <code>Collection</code>.
   * @param params A <code>Map.&lt;DataRequest.ActivityRequestFields, Object&gt;</code> object.
   * 
   * @see http://code.google.com/apis/opensocial/docs/0.8/reference/#opensocial.DataRequest.newFetchActivitiesRequest 
   *      opensocial.DataRequest.newFetchActivitiesRequest
   */
  public function fetchActivities(idSpec:IdSpec, callback:Function = null, 
                                  params:Object = null):void {
    client.callAsync(Feature.FETCH_ACTIVITIES, callback, idSpec, params);
  }


  /**
   * Sends request to create an activity.
   * @param activity An <code>Activity</code> object.
   * @param priority A value of <code>Globals.CreateActivityPriority</code>.
   * @param callback A fucntion with a parameter of <code>ResponseItem</code>.
   *                 The underlying data in the response item is null.
   * 
   * @see http://code.google.com/apis/opensocial/docs/0.8/reference/#opensocial.requestCreateActivity
   *      opensocial.requestCreateActivity
   */
  public function requestCreateActivity(activity:Activity, priority:String, 
                                        callback:Function = null):void {
    client.callAsync(Feature.REQUEST_CREATE_ACTIVITY, callback, activity, priority);    
  }


  /**
   * Sends request to send a message.
   * @param recipients An array of ids, such as OWNER, VIEWER, or person ids in reachable groups.
   * @param message An <code>Message</code> object.
   * @param callback A fucntion with a parameter of <code>ResponseItem</code>.
   *                 The underlying data in the response item is null.
   * 
   * @see http://code.google.com/apis/opensocial/docs/0.8/reference/#opensocial.requestSendMessage 
   *      opensocial.requestSendMessage
   */
  public function requestSendMessage(recipients:Array, message:Message,
                                     callback:Function = null):void {
    client.callAsync(Feature.REQUEST_SEND_MESSAGE, callback, recipients, message);      
  }


  /**
   * Sends request to share this app.
   * @param recipients An array of ids, such as OWNER, VIEWER, or person ids in reachable groups.
   * @param reason An <code>Message</code> object.
   * @param callback A fucntion with a parameter of <code>ResponseItem</code>.
   *                 The underlying data in the response item is null.
   * 
   * @see http://code.google.com/apis/opensocial/docs/0.8/reference/#opensocial.requestShareApp
   *      opensocial.requestShareApp
   */
  public function requestShareApp(recipients:Array, reason:Message, 
                                  callback:Function = null):void {
    client.callAsync(Feature.REQUEST_SHARE_APP, callback, recipients, reason);
  }


  /**
   * Sends request to share this app.
   * @param permissions An array of <code>Globals.Permission</code> values.
   * @param reasonText A string of reason text.
   * @param callback A fucntion with a parameter of <code>ResponseItem</code>.
   *                 The underlying data in the response item is null.
   * 
   * @see http://code.google.com/apis/opensocial/docs/0.8/reference/#opensocial.requestPermission
   *      opensocial.requestPermission
   */
  public function requestPermission(permissions:Array, reasonText:String, 
                                    callback:Function = null):void {
    client.callAsync(Feature.REQUEST_PERMISSION, callback, permissions, reasonText);
  }


  /**
   * Calls the <code><j>opensocial.Environment.supportsField</j></code> to check if the field
   * in the type is supported for this container.
   * @return True if supported.
   * @see http://code.google.com/apis/opensocial/docs/0.8/reference/#opensocial.Environment.supportsField
   *      opensocial.Environment.supportsField
   */ 
  public function supportsField(objectType:String, field:String):Boolean {
    return client.callSync(Feature.SUPPORTS_FIELD, objectType, field);
  }


  /**
   * Calls the <code><j>opensocial.Environment.getDomain</j></code> to get the domain of the 
   * running conatiner.
   * @return The domain of the container, e.g. orkut.com, 51.com
   * @see http://code.google.com/apis/opensocial/docs/0.8/reference/#opensocial.Environment.getDomain
   *      opensocial.Environment.getDomain
   */ 
  public function getDomain():String {
    return client.callSync(Feature.GET_DOMAIN);
  }

 
  /**
   * Extract the container domain from the document.referer field. It maybe different from the
   * <code>getDomain</code> method.
   * @return The domain of the container url.
   */ 
  public function getContainerDomain():String {
    return client.callSync(Feature.GET_CONTAINER_DOMAIN);
  }
}
}
