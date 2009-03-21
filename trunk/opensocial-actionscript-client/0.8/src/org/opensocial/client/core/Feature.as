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
 * Atomized OpenSocial action item.
 * <p>
 * A feature instance is created and registered by a client's initialization function.  
 * It will hold the name and parsers pairs for a real action. But different clients can register 
 * different parsers and execute the feature differently.
 * </p>
 * 
 * @author yiziwu@google.com (Yizi Wu)
 */
public class Feature {

  // All available features
  
  /** The feature of fetching a person. */  
  public static const FETCH_PERSON:String =             "fetchPerson";
  /** The feature of fetching a group of people. */
  public static const FETCH_PEOPLE:String =             "fetchPeople";
  /** The feature of fetching person app data. */
  public static const FETCH_PERSON_APP_DATA:String =    "fetchPersonAppData";
  /** The feature of updating person app data. */
  public static const UPDATE_PERSON_APP_DATA:String =   "updatePersonAppData";
  /** The feature of removing person app data. */
  public static const REMOVE_PERSON_APP_DATA:String =   "removePersonAppData";
  /** The feature of fetching activities. */
  public static const FETCH_ACTIVITIES:String =         "fetchActivities";
  /** The feature of creating an activity */
  public static const REQUEST_CREATE_ACTIVITY:String =  "requestCreateActivity";
  /** The feature of sending a message. */
  public static const REQUEST_SEND_MESSAGE:String =     "requestSendMessage";
  /** The feature of sharing this app. */
  public static const REQUEST_SHARE_APP:String =        "requestShareApp";
  /** The feature of requesting permission. */
  public static const REQUEST_PERMISSION:String =       "requestPermission";
  /** The feature of checking supported fields. */
  public static const SUPPORTS_FIELD:String =           "supportsField";
  /** The feature of getting the domain defined by the container server. */
  public static const GET_DOMAIN:String =               "getDomain";
  /** The feature of getting the container url domain. */
  public static const GET_CONTAINER_DOMAIN:String =     "getContainerDomain";
  /** The feature of making remote IO request. */
  public static const MAKE_REQUEST:String =             "makeRequest";
  /** The feature of getting current view. */
  public static const GET_CURRENT_VIEW:String =         "getCurrentView";
  /** The feature of checking the gadget is solo. */
  public static const IS_ONLY_VISIBLE:String =          "isOnlyVisible";
  /** The feature of getting view parameters. */
  public static const GET_VIEW_PARAMS:String =          "getViewParams";
  /** The feature of setting the flash stage width. */
  public static const SET_STAGE_WIDTH:String =          "setStageWidth";
  /** The feature of setting the flash stage height. */
  public static const SET_STAGE_HEIGHT:String =         "setStageHeight";
  /** The feature of setting the app title. */
  public static const SET_TITLE:String =                "setTitle";
  /** The feature of calling another app or parent container's rpc service. */
  public static const CALL_RPC:String =                 "callRpc";
  /** The feature of returning service call from another app or parent container. */
  public static const REGISTER_RPC_SERVICE:String =     "registerRpcService";
  /** The feature of registering an rpc service from other apps or parent container. */
  public static const UNREGISTER_RPC_SERVICE:String =   "unregisterRpcService";
  /** The feature of unregistering an rpc service. */
  public static const RETURN_RPC_SERVICE:String =       "returnRpcService";

  private static const DEFAULT_PARSER:Function = function(data:*):* {return data;};

  private var name_:String;
  
  private var isAsync_:Boolean;
  
  private var reqParser_:Function = DEFAULT_PARSER;
  
  private var resParser_:Function = DEFAULT_PARSER;
  
  /**
   * Constructor of a feature object. 
   * @param name The feature name.
   * @param isAsync Is async feature or not.
   * @param reqParser A parser function to parse the request parameters.
   * @param resParser A parser function to parse the response value.
   */  
  public function Feature(name:String,
                          isAsync:Boolean,
                          reqParser:Function = null,
                          resParser:Function = null) {
    name_ = name;
    isAsync_ = isAsync;
    reqParser_ = reqParser == null ? DEFAULT_PARSER : reqParser;
    resParser_ = resParser == null ? DEFAULT_PARSER : resParser;
  }
  
  /**
   * The name of the feature. 
   * @return The name of the feature.
   */  
  public function get name():String {
    return name_;
  }
  
  /**
   * Indicates if this feature is asynchronous or synchronous.  
   * @return True if this feature is asynchronous.
   */  
  public function get isAsync():Boolean {
    return isAsync_;
  }
  
  /**
   * The request parameters parser function. 
   * @return The request parameters parser function.
   */  
  public function get reqParser():Function {
    return reqParser_;
  }

  /**
   * The response value parser function. 
   * @return The response value parser function.
   */  
  public function get resParser():Function {
    return resParser_; 
  }

}
}
