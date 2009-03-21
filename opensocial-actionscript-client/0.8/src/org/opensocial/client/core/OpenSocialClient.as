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

import flash.events.EventDispatcher;
import flash.utils.Dictionary;
import org.opensocial.client.base.OpenSocialError;


/**
 * The core abstract class of the OpenSocial Actionscript Client SDK.
 * <p>
 * This Client SDK is for those developers who want to develop flash opensocial apps in 
 * ActionScript 3.0.
 * </p>
 * <p>
 * It's aimed to have no dependency on which container it runs on. It only depents on the 
 * Standard OpenSocial Javascript API and Restful protocol. It is developed on Shindig based 
 * container. 
 * </p>
 * <p>
 * All opensocial data I/O and app control can be handled by this client. An app can simply include 
 * the <code>org.opensocial.client</code> package to the flash project and use this client to make
 * the app social.
 * </p>
 * <p>
 * This <code>OpenSocialClient</code> is just an abstract class. It has two sub classes: 
 * the <code>JsWrapperClient</code> and <code>RestfulClient</code>, which is the real working 
 * client. They share many interfaces for developers to reduce the learning and migration effort.
 * </p>
 * 
 * @see org.opensocial.client.jswrapper.JsWrapperClient JsWrapperClient
 * @see org.opensocial.client.restful.RestfulClient RestfulClient
 * 
 * @author yiziwu@google.com (Yizi Wu)
 * @author chaowang@google.com (Jacky Wang)
 */
public class OpenSocialClient extends EventDispatcher {
  
  /**
   * The feature book holds all available features on the client.
   * @private 
   */  
  protected var featureBook_:Dictionary;

  /**
   * The callback manager to buffer all the ongoing request callback handlers.
   * @private
   */ 
  protected var callbacks_:CallbackManager;

  /**
   * Constructor of the client. 
   * Initializes the feature book and callback manager. 
   */  
  public function OpenSocialClient() {
    initFeatureBook();
    initCallbackManager();
  }

  /**
   * Gets and checks the feature by its name.
   * @param featureName The feature name to lookup.
   * @throws OpenSocialError 
   * @return The feature instance.
   */
  public function checkFeature(featureName:String):Feature {
    var feature:Feature = featureBook_[featureName] as Feature;
    if (feature == null) {
      throw new OpenSocialError("'" + featureName + "' is not supported in this client.");
    }
    return feature;
  }
  
  /**
   * Adds new feature to this client. 
   * @param name The feature name.
   * @param isAsync Is async feature or not.
   * @param reqParser A parser function to parse the request parameters.
   * @param resParser A parser function to parse the response value.
   */  
  public function addFeature(featureName:String,
                             isAsync:Boolean,
                             reqParser:Function = null,
                             resParser:Function = null):void {
    var feature:Feature = new Feature(featureName, isAsync, reqParser, resParser);
    featureBook_[feature.name] = feature;
  }
  
  /**
   * Initializes the feature book. This method should be overriden for customizing features. 
   */
  protected function initFeatureBook():void {
    featureBook_ = new Dictionary();
  }
  
  /**
   * Initializes the feature book. This method can be overriden by special initialization. 
   */
  protected function initCallbackManager():void {
    callbacks_ = new CallbackManager();
  }
  
  /**
   * Executes the feature synchronously. 
   * @param featureName The name of the sync feature.
   * @param params The request parameters
   * @return The response value.
   */  
  public function callSync(featureName:String, ...params:Array):* {
    // Must be overriden
    throw new OpenSocialError("This method in this abstract class must be overriden.");
  }
  
  /**
   * Executes the feature asynchronously.
   * @param featureName The name of the async feature.
   * @param callback The callback to handle the response.
   * @param params The request parameters.
   * 
   */  
  public function callAsync(featureName:String, callback:Function, ...params:Array):void {
    // Must be overriden
    throw new OpenSocialError("This method in this abstract class must be overriden.");
  }
  
  /**
   * Registers a callback handler on this client.
   * @param callbackName The name or id of the callback.
   * @param callback The callback function.
   * 
   */  
  public function registerCallback(callbackName:String, callback:Function):void {
    // Must be overriden
    throw new OpenSocialError("This method in this abstract class must be overriden.");
  }
  
  /**
   * Unregisters a callback handler from this client.
   * @param callbackName The name or id of the callback.
   */  
  public function unregisterCallback(callbackName:String):void {
    // Must be overriden
    throw new OpenSocialError("This method in this abstract class must be overriden.");
  }
}
}
