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

import flash.external.ExternalInterface;

import org.opensocial.client.base.*;

/**
 * Wrapper of <code><j>opensocial</j></code> namespace in javascript. This is the core namespace
 * for the Opensocial API.
 * 
 * @see http://code.google.com/apis/opensocial/docs/0.8/reference/#opensocial opensocial
 * 
 * @author yiziwu@google.com (Yizi Wu)
 */
public class Opensocial extends JsFeature {

  /**
   * Default constructor.
   * <p>
   * NOTE: This constructor is internally used. Do not call this constructor directly outside 
   * this package.
   * </p>
   * @param client The jswrapper client.
   * @private
   */
  public function Opensocial(client:JsWrapperClient) {
    super(client);
  }

  /**
   * Registers the external interface callbacks for this feature. 
   */
  override public function registerExternalCallbacks():void {
    // opensocial.request* callbacks 
    ExternalInterface.addCallback("handleRequestCreateActivity", handleRequestCreateActivity);
    ExternalInterface.addCallback("handleRequestSendMessage", handleRequestSendMessage);
    ExternalInterface.addCallback("handleRequestShareApp", handleRequestShareApp);
    ExternalInterface.addCallback("handleRequestPermission", handleRequestPermission);
  
    // opensocial.newDataRequest callbacks    
    ExternalInterface.addCallback("handleFetchPerson", handleFetchPerson);
    ExternalInterface.addCallback("handleFetchPeople", handleFetchPeople);
    ExternalInterface.addCallback("handleFetchPersonAppData", handleFetchPersonAppData);
    ExternalInterface.addCallback("handleUpdatePersonAppData", handleUpdatePersonAppData);
    ExternalInterface.addCallback("handleRemovePersonAppData", handleRemovePersonAppData);
    ExternalInterface.addCallback("handleFetchActivities", handleFetchActivities);
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
  public function fetchPerson(
      id:String,
      callback:Function = null,
      params:/* Map.<DataRequest.PeopleRequestField, Object> */Object = null):void {
    assertReady();
    var reqID:String = pushCallback(callback);
    ExternalInterface.call(getJsFuncName("fetchPerson"),
                           reqID, id, params);
  }

  /**
   * Callback of fetch person response.
   * @param reqID Request UID.
   * @param rawPerson A wrapped <code><j>opensocial.Person</j></code> object from Js-side.
   */
  protected function handleFetchPerson(reqID:String, rawPerson:Object):void {
    var person:Person = new Person(rawPerson);
    popCallback(reqID, new ResponseItem(person));
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
  public function fetchPeople(
      idSpec:IdSpec,
      callback:Function = null,
      params:/* Map.<DataRequest.PeopleRequestField, Object> */Object = null):void {
    assertReady();
    var reqID:String = pushCallback(callback);
    ExternalInterface.call(getJsFuncName("fetchPeople"),
                           reqID, idSpec.toRawObject(), params);
  }

  /**
   * Callback of fetch people response.
   * @param reqID request UID.
   * @param rawPeople A wrapped <code><j>opensocial.Collection.&lt;opensocial.Person&gt;</j></code>
   *                  object from Js-side.
   */
  protected function handleFetchPeople(reqID:String, rawPeople:Object):void {
    var people:Collection = new Collection(rawPeople, Person);
    popCallback(reqID, new ResponseItem(people));
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
  public function fetchPersonAppData(
      idSpec:IdSpec,
      keys:/* String */Array,
      callback:Function = null,
      params:/* Map.<DataRequest.DataRequestField, Object> */Object = null):void {
    assertReady();
    var reqID:String = pushCallback(callback);
    ExternalInterface.call(getJsFuncName("fetchPersonAppData"), 
                           reqID, idSpec.toRawObject(), keys, params);
  }

  /**
   * Callback of fetch person app data response.
   * @param reqID Request UID.
   * @param rawDataSet <code>Map.&lt;String, Map.&lt;String, Object&gt;&gt;</code> object 
   *                   from Js-side.
   */
  protected function handleFetchPersonAppData(reqID:String, rawDataSet:Object):void {
    popCallback(reqID, new ResponseItem(rawDataSet));
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
  public function updatePersonAppData(
      id:String,
      key:String,
      value:Object,
      callback:Function = null):void {
    assertReady();
    var reqID:String = pushCallback(callback);
    ExternalInterface.call(getJsFuncName("updatePersonAppData"),
                           reqID, id, key, value);
  }

  /**
   * Callback of update person app data response.
   * @param reqID Request UID.
   */
  protected function handleUpdatePersonAppData(reqID:String):void {
    popCallback(reqID, ResponseItem.SIMPLE_SUCCESS);
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
  public function removePersonAppData(
      id:String,
      keys:/* String */Array,
      callback:Function = null):void {
    assertReady();
    var reqID:String = pushCallback(callback);
    ExternalInterface.call(getJsFuncName("removePersonAppData"),
                           reqID, id, keys);
  }

  /**
   * Callback of update person app data response.
   * @param reqID Request UID.
   */
  protected function handleRemovePersonAppData(reqID:String):void {
    popCallback(reqID, ResponseItem.SIMPLE_SUCCESS);
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
  public function fetchActivities(
      idSpec:IdSpec,
      callback:Function = null,
      params:/* Map.<DataRequest.ActivityRequestField, Object> */Object = null):void {
    assertReady();
    var reqID:String = pushCallback(callback);
    ExternalInterface.call(getJsFuncName("fetchActivities"),
                           reqID, idSpec.toRawObject, params);
  }

  /**
   * Callback of fetch person activities.
   * @param reqID Request UID.
   * @param rawActivities A wrapped 
   *               <code><j>opensocial.Collection.&lt;opensocial.Activity&gt;</j></code> 
   *               object from Js-side.
   */
  protected function handleFetchActivities(reqID:String, rawActivities:Object):void {
    var activities:Collection = new Collection(rawActivities, Activity);
    popCallback(reqID, new ResponseItem(activities));
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
  public function requestCreateActivity(
      activity:Activity,
      priority:String,
      callback:Function = null):void {
    assertReady();
    var reqID:String = pushCallback(callback);
    ExternalInterface.call(getJsFuncName("requestCreateActivity"),
                           reqID, activity.toRawObject(), priority);
  }

  /**
   * Callback of create activities request.
   * @param reqID Request UID.
   */
  protected function handleRequestCreateActivity(reqID:String):void {
    popCallback(reqID, ResponseItem.SIMPLE_SUCCESS);
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
  public function requestSendMessage(
      recipients:/* String */Array,
      message:Message,
      callback:Function = null):void {
    assertReady();
    var reqID:String = pushCallback(callback);
    ExternalInterface.call(getJsFuncName("requestSendMessage"),
                           reqID, recipients, message.toRawObject());
  }

  /**
   * Callback of send message request.
   * @param reqID Request UID.
   */
  protected function handleRequestSendMessage(reqID:String):void {
    popCallback(reqID, ResponseItem.SIMPLE_SUCCESS);
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
  public function requestShareApp(
      recipients:/* String */Array,
      reason:Message,
      callback:Function = null):void {
    assertReady();
    var reqID:String = pushCallback(callback);
    ExternalInterface.call(getJsFuncName("requestShareApp"),
                           reqID, recipients, reason.toRawObject());
  }

  /**
   * Callback of share app request.
   * @param reqID Request UID.
   */
  protected function handleRequestShareApp(reqID:String):void {
    popCallback(reqID, ResponseItem.SIMPLE_SUCCESS);
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
  public function requestPermission(
      permissions:/* String */Array,
      reasonText:String,
      callback:Function = null):void {
    assertReady();
    var reqID:String = pushCallback(callback);
    ExternalInterface.call(getJsFuncName("requestPermission"),
                           reqID, permissions, reasonText);
  }

  /**
   * Callback of permission request.
   * @param reqID Request UID.
   */
  protected function handleRequestPermission(reqID:String):void {
    popCallback(reqID, ResponseItem.SIMPLE_SUCCESS);
  }

  /**
   * Calls the <code><j>opensocial.Environment.getDomain</j></code> to get the domain of the 
   * running conatiner.
   * @return The domain of the container, e.g. orkut.com, 51.com
   * @see http://code.google.com/apis/opensocial/docs/0.8/reference/#opensocial.Environment.getDomain
   *      opensocial.Environment.getDomain
   */ 
  public function getDomain():String {
    assertReady();
    return ExternalInterface.call("opensocial.getEnvironment().getDomain");
  }

  /**
   * Calls the <code><j>opensocial.Environment.supportsField</j></code> to check if the field
   * in the type is supported for this container.
   * @return True if supported.
   * @see http://code.google.com/apis/opensocial/docs/0.8/reference/#opensocial.Environment.supportsField
   *      opensocial.Environment.supportsField
   */ 
  public function supportsField(objectType:String, field:String):Boolean {
    assertReady();
    return ExternalInterface.call("opensocial.getEnvironment().supportsField", objectType, field);
  }  
}
}
