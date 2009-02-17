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

import flash.events.EventDispatcher;
import flash.events.TimerEvent;
import flash.external.ExternalInterface;
import flash.system.Security;
import flash.utils.Timer;

import org.opensocial.client.base.*;
import org.opensocial.client.util.*;

/**
 * Opensocial Actionscript Client SDK - Javascript Wrapper Client.
 * <p>
 * This JSWrapper SDK is used for developers who want to develop flash opensocial apps in 
 * ActionScript 3.0.
 * </p>
 * <p>
 * It's aimed to have no dependency on which container it runs on. It only depents on the 
 * Standard Opensocial Javascript API. It is developed on Shindig based container. So it works best
 * on Shindig. 
 * </p>
 * <p>
 * The main idea for this javascript wrapper client is to setup a interface passing wrapped and 
 * unwrapped opensocial data type between flash and javascript. 
 * </p> 
 * <p>
 * All opensocial data I/O and app control can be handled by this client. An app can simply include 
 * the <code>org.opensocial.client</code> package to the flash project and use this client to make
 * the app social.
 * </p>
 * <p>
 * A typical usage of this client is listing below:
 * </p>
 * @example
 * <listing version="3.0">
 *  
 *   function init():void {
 *     displaySomeStuff();
 * 
 *     // Initialize Client and start
 *     client = new JsWrapperClient();
 *     client.loadFeatures("opensocial", "io");
 *     client.addEventListener(OpensocialEvent.READY, onReady);
 *     client.start();
 *   }
 * 
 *   //...
 *   
 *   function onReady(event:OpensocialEvent):void {
 *     displayOtherStuff();
 * 
 *     // start your logic
 *     client.opensocial.fetchPerson(...);
 * 
 *   }
 * </listing>
 *  
 * @author yiziwu@google.com (Yizi Wu)
 */
public class JsWrapperClient extends EventDispatcher {
  
  /**
   * The Opensocial Actionscript Client SDK namespace on JS-side.
   * @default "opensocial.flash"
   * @private
   */ 
  private var jsNamespace_:String = "opensocial.flash";

  /**
   * The callback manager to buffer all the ongoing request callback handlers.
   * @private
   */ 
  private var callbacks_:CallbackManager;

  /**
   * The logger instance.
   * @private
   */ 
  private var logger_:Logger;
  
  /**
   * Indicating if the API is already started to check the javascript.
   * @default false
   * @private
   */ 
  private var isStarted_:Boolean;


  /**
   * Indicating if the API is already initialized and ready for requests.
   * @default false
   * @private
   */ 
  private var isReady_:Boolean;
  
  
  private var features_:/* String, JsFeature */Object;
  
  
  // ---------------------------------------------------------------------------
  //     Initializing
  // ---------------------------------------------------------------------------
  /**
   * Opensocial Client constructor, initializing some empty collections and values.
   */
  public function JsWrapperClient(jsNamespace:String = null) {
    
    // TODO: The security need to be configured.
    Security.allowDomain("*");
    
    callbacks_ = new CallbackManager();
    isStarted_ = false;
    isReady_ = false;
    
    if (jsNamespace_) {
      jsNamespace_ = jsNamespace;
    }
  }
  

  /**
   * Load the features with default names.
   * <p>
   * Here are the possible values:
   * </p>
   * <listing>
   * 
   *   "opensocial"
   *   "io"
   *   "rpc"
   *   "views"
   *   "windows"
   * </listing>
   * <p>
   * If developers like to load other customized features, extend this class and override this 
   * method.
   * </p>
   * @param featureNames The array of feature names to be loaded. No necessory to load all. 
   *                     By default loads all features in this package.
   */  
  public function loadFeatures(...featureNames):void {
    features_ = {};
    
    if (featureNames == null) {
      featureNames = ["all"];
    }
    try  {
      for each (var name:String in featureNames) {
        switch (name) {
          case "io":
            addFeature("io", GadgetsIo);
            break;
          case 'rpc':
            addFeature("rpc", GadgetsRpc);
            break;
          case 'views':
            addFeature("views", GadgetsViews);
            break;
          case 'window':
            addFeature("window", GadgetsWindow);
            break;
          case 'opensocial':
            addFeature("opensocial", Opensocial);
            break;
          case 'all':
            addFeature("io", GadgetsIo);
            addFeature("rpc", GadgetsRpc);
            addFeature("views", GadgetsViews);
            addFeature("window", GadgetsWindow);
            addFeature("opensocial", Opensocial);
            break;
        }
      }
    } catch (e:Error) {
      logger.error(e);
    }
  }
  
  /**
   * Adds a feature to the client. 
   * @param featureName The name key of the feature.
   * @param featureType The feature type
   */  
  final protected function addFeature(featureName:String, featureType:Class):void {
    if (!features_[featureName]) {
      features_[featureName] = new featureType(this);
    }
  }
  
  /**
   * Checks and returns if the feature exists. If not, throw an error. 
   * @param featureName The name key of the feature
   * @return The feature object.
   */  
  final protected function checkFeature(featureName:String):JsFeature {
    if (!features_ || !features_[featureName]) {
      throw new OpensocialError("Feature '" + featureName + "' not loaded.");
    }
    return features_[featureName];
  }
  
  
  /**
   * Starts the main process.
   * 
   * <p>
   * The main process will first check the availability of <code>ExternalInterface</code> of the 
   * flash player and the javascript in browser.
   * Customized client can override this method.
   * </p>
   */
  final public function start():void {
    if (isStarted_ || isReady_) return;
    isStarted_ = true;

    if (!ExternalInterface.available) {
      logger.error(new OpensocialError("ExternalInterface is not available."));
    } else {
      // Register external callbacks
      registerExternalCallbacks();
      
      // Check if the javascript is ready in DOM
      checkJavascriptReady();
    }
  }

  /**
   * Checks and waits for the javascript environment ready. 
   * <p>
   * Because the javascript may not be loaded when this flash is loaded so 
   * <code>ExternalInterface</code> may not work correctly. This method will check the 
   * <code><j>opensocial.flash.jsReady()</j></code> function define in Js-side to make sure that 
   * all opensocial/gadgets api javascript codes are loaded.
   * </p>
   * <p>
   * When javascript is ready, an event will be dispatched.
   * </p>
   * @private
   */
  final private function checkJavascriptReady():void {
    var timer:Timer = new Timer(100, 10);
    timer.addEventListener(TimerEvent.TIMER, function(event:TimerEvent):void {
      logger.info("Checking JavaScript status...");
      var jsReady:Boolean = ExternalInterface.call(jsNamespace_ + ".jsReady", 
                                                   ExternalInterface.objectID);
      if (jsReady) {
        logger.info("JavaScript is ready.");
        Timer(event.target).stop();
        
        isReady_ = true;
        
        dispatchEvent(
            new OpensocialEvent(OpensocialEvent.READY, 
                                false, false, event.target.currentCount));
      }
    });
    
    timer.addEventListener(TimerEvent.TIMER_COMPLETE, function(event:TimerEvent):void {
      logger.error(new OpensocialError("Retried " + event.target.currentCount + 
                                       " time(s) and failed."));
    });

    timer.start();
  }
  
  /**
   * Registers the external interface callbacks for all features. 
   * The names are used in the javascript. This method can be overridden by customized client.
   */
  protected function registerExternalCallbacks():void {

    // handle errors from javascript
    ExternalInterface.addCallback("handleError", handleError);

    // allow javascript to call the flash client logger for debugging.
    ExternalInterface.addCallback("trace", logger.log);
    
    // register all features callbacks
    for each (var feature:JsFeature in features_) {
      feature.registerExternalCallbacks();
    }

  }


  // ---------------------------------------------------------------------------
  //  Default RPC Callbacks
  // ---------------------------------------------------------------------------
  /**
   * Handles the javascript error and pop the callback if any.
   * @param reqID Request UID.
   * @param error The error object from javascript.
   */
  protected function handleError(reqID:String, error:Object):void {
    if (error != null) {
      var code:String = "";
      if (error["name"] == "OpensocialError") {
        code = error["code"];
      }
      if (reqID == null) {
        throw new OpensocialError("Error " + error["message"] + 
                                  "from javascript without handler.");
      } else {
        callbacks_.pop(reqID, new ResponseItem(null, code, error["message"]));
      }
    } else {
      if (reqID != null) {
        callbacks_.drop(reqID);
      }
      throw new OpensocialError("Unexpected error callback from javascript.");  
    }
  }

  // ---------------------------------------------------------------------------
  //  Getters and Setters
  // ---------------------------------------------------------------------------

  /**
   * For internal use.
   * @return The callback Manager. 
   * 
   */  
  final internal function get callbacks():CallbackManager {
    return callbacks_;
  }

  /**
   * Gets the logger instance
   * @return The logger.
   */
  final public function get logger():Logger {
    if (logger_ == null) {
      // If the logger is not set, creates a dummy logger which logs nothing.
      logger_ = new Logger();
    }
    return logger_;
  }

  /**
   * Sets the new logger instance for this client.
   * @param newLogger a new logger. 
   */ 
  final public function set logger(newLogger:Logger):void {
    logger_ = newLogger;
  }

  /**
   * Gets the js namespace. 
   * @return The namespace on JS-Side.
   */  
  final public function get jsNamespace():String {
    return jsNamespace_;
  }

  /**
   * Checks if the client is ready for javascript
   * @return True if the client is ready.
   */ 
  final public function get ready():Boolean {
    return isReady_;
  }

  /**
   * Returns the "io" feature 
   * @return The "io" feature.
   */
  public function get io():GadgetsIo {
    return checkFeature("io") as GadgetsIo;
  }

  /**
   * Returns the "rpc" feature 
   * @return The "rpc" feature.
   */
  public function get rpc():GadgetsRpc {
    return checkFeature("rpc") as GadgetsRpc;
  }
  
  /**
   * Returns the "views" feature 
   * @return The "views" feature.
   */
  public function get views():GadgetsViews {
    return checkFeature("views") as GadgetsViews;
  }

  /**
   * Returns the "window" feature 
   * @return The "window" feature.
   */
  public function get window():GadgetsWindow {
    return checkFeature("window") as GadgetsWindow;
  }

  /**
   * Returns the "opensocial" feature 
   * @return The "opensocial" feature.
   */
  public function get opensocial():Opensocial {
    return checkFeature("opensocial") as Opensocial;
  }
}

}

