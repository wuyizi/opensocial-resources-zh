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

import flash.events.TimerEvent;
import flash.external.ExternalInterface;
import flash.system.Security;
import flash.utils.Timer;

import org.opensocial.client.base.*;
import org.opensocial.client.core.*;
import org.opensocial.client.events.OpenSocialClientEvent;
import org.opensocial.client.util.*;

/**
 * OpenSocial Actionscript Client SDK - Javascript Wrapper Client.
 * <p>
 * This javascript wrapper client is to setup a interface passing wrapped and unwrapped 
 * opensocial data type between flash and javascript. To achieve this, there is a javascript file
 * to run together with the OpenSocial Standard Javascript API. This javascript plays a role as 
 * a bridge. In this package, the codes in javascript are called 'JS-Side', correspodingly codes in 
 * this client is called 'AS-Side'. 
 * </p> 
 * <p>
 * A typical usage of this javascript wrapper client is listing below:
 * </p>
 * @example
 * <listing version="3.0">
 *  
 *   var client:JsWrapperClient;
 *   var opensocial:OpenSocialHelper;
 * 
 *   function init():void {
 *     displaySomeStuff();
 * 
 *     // Initialize the client and start.
 *     client = new JsWrapperClient();
 *     client.addEventListener(OpenSocialClientEvent.READY, onReady);
 *     client.start();
 * 
 *     // Initialize the helper objects.
 *     opensocial = new OpenSocialHelper(client);
 *   }
 * 
 *   //...
 *   
 *   function onReady(event:OpenSocialEvent):void {
 *     displayOtherStuff();
 * 
 *     // start your logic using callbacks
 *     opensocial.fetchPerson(..., callback);
 * 
 *     // Or start your logic using events
 *     var req:OpenSocialDataRequest = new OpenSocialDataRequest(...);
 *     req.setParams(...);
 *     req.addEventListener(..., handler);
 *     req.send(client);
 *   }
 * </listing>
 *  
 * @author yiziwu@google.com (Yizi Wu)
 * @author chaowang@google.com (Jacky Wang)
 */
public class JsWrapperClient extends OpenSocialClient {
  
  /**
   * The logger for this class.  
   * @private 
   */  
  private static var logger:Logger = new Logger(JsWrapperClient);
  
  /**
   * The OpenSocial Actionscript Client SDK namespace on JS-side.
   * @default "opensocial.flash"
   * @private
   */ 
  private var jsNamespace_:String = "opensocial.flash";


  /**
   * Indicates if the API is already started to check the javascript.
   * @default false
   * @private
   */ 
  private var isStarted_:Boolean;


  /**
   * Indicates if the API is already initialized and ready for requests.
   * @default false
   * @private
   */ 
  private var isReady_:Boolean;
  

  /**
   * Javascrip Wrapper Client constructor, initializing some empty collections and values.
   * @param jsNamespace The javascript namespace used in the Js-Side, null to use the default value.
   */
  public function JsWrapperClient(jsNamespace:String = null) {
    super();
    
     // TODO: The security need to be configured.
    Security.allowDomain("*");
    
    isStarted_ = false;
    isReady_ = false;
    
    if (jsNamespace_) {
      jsNamespace_ = jsNamespace;
    }
  }
  
  // ---------------------------------------------------------------------------
  //     Initializing Javascript
  // ---------------------------------------------------------------------------
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

    try {
      if (!ExternalInterface.available) {
        logger.error(new OpenSocialError("ExternalInterface is not available."));
      } else {
        // Register external callbacks
        registerSystemCallbacks();
        
        // Check if the javascript is ready in DOM
        checkJavascriptReady();
      }
    } catch (e:SecurityError) {
      logger.error(
          new OpenSocialError("Scripting Security Error: 'allowScriptAccess' value not correct."));
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
        
        dispatchEvent(new OpenSocialClientEvent(
            OpenSocialClientEvent.CLIENT_READY, false, false, event.target.currentCount));
      }
    });
    
    timer.addEventListener(TimerEvent.TIMER_COMPLETE, function(event:TimerEvent):void {
      logger.error(new OpenSocialError("Retried " + event.target.currentCount + 
                                       " time(s) and failed."));
    });

    timer.start();
  }
  
  // ---------------------------------------------------------------------------
  //  Interface for javascript functionality
  // ---------------------------------------------------------------------------

  /**
   * Checks if the client is ready for javascript
   * @return True if the client is ready.
   */ 
  final public function get ready():Boolean {
    return isReady_;
  }
  
  /**
   * Asserts the client.ready property. Throws error if not ready.
   */
  final internal function assertReady():void {
    if (!isReady_) throw new OpenSocialError("The OpenSocial JsWrapper Client is not ready.");
  }  

  /**
   * Registers the external interface callbacks for all features. 
   * The names are used in the javascript. This method can be overridden by customized client.
   * @private
   */
  protected function registerSystemCallbacks():void {
    // handle errors from javascript
    ExternalInterface.addCallback("handleError", handleError);
    // handle async request callback from javascript
    ExternalInterface.addCallback("handleAsync", handleAsync);
    // allow javascript to call the flash client logger for debugging.
    ExternalInterface.addCallback("trace", logger.info);
  }

  /**
   * Handles the javascript successfully async callback if any. 
   * @param reqID Request UID in callback manager.
   * @param args Some arguments from javascript, .
   * @private
   */  
  protected function handleAsync(reqID:String, data:* = null):void {
    callbacks_.pop(reqID, data);
  }

  /**
   * Handles the javascript error and pop the callback if any.
   * @param reqID Request UID in callback manager.
   * @param error The error object from javascript.
   * @private
   */
  protected function handleError(reqID:String, error:Object):void {
    if (error != null) {
      var code:String = "";
      if (error["name"] == "OpenSocialError") {
        code = error["code"];
      }
      if (reqID != null) {
        callbacks_.pop(reqID, new OpenSocialError(error["message"], code));
      } else {
        throw new OpenSocialError("Error " + error["message"] + 
                                  "from javascript without handler.");
      }
    } else {
      if (reqID != null) {
        callbacks_.drop(reqID);
      }
      throw new OpenSocialError("Unexpected error callback from javascript.");  
    }
  }

  // ---------------------------------------------------------------------------
  //  Implementation the client interfaces.
  // ---------------------------------------------------------------------------

  override public function registerCallback(callbackName:String, callback:Function):void {
    assertReady();
    callbacks_.push(callback, callbackName);
    ExternalInterface.addCallback(callbackName, callback);
  }


  override public function unregisterCallback(callbackName:String):void {
    assertReady();
    callbacks_.drop(callbackName);
    // TODO how to remove callbacks from ExternalInterface?
 
  }


  override public function callSync(featureName:String, ...params:Array):* {
    assertReady();
    var feature:Feature = checkFeature(featureName);
    var parsedParams:Array = feature.reqParser(params);
    parsedParams.unshift(jsNamespace_ + "." + featureName);
    var rawData:* = ExternalInterface.call.apply(null, parsedParams);
    return feature.resParser(rawData);
  }


  override public function callAsync(featureName:String, handler:Function, ...params:Array):void {
    assertReady();
    var feature:Feature = checkFeature(featureName);
    var callback:Function = function(rawData:*):void {
      var data:* = feature.resParser(rawData);
      handler(data);
    };
    var reqID:String = callbacks_.push(callback);
    var parsedParams:Array = feature.reqParser(params);
    parsedParams.unshift(jsNamespace_ + "." + featureName, reqID);
    ExternalInterface.call.apply(null, parsedParams);
  }


  /**
   * @inheritDoc
   * @private
   */  
  override protected function initFeatureBook():void {
    super.initFeatureBook();
    
    var features:Array = [ 
        [Feature.FETCH_PERSON,            true, "parseParams", "parsePerson"],
        [Feature.FETCH_PEOPLE,            true, "parseParams", "parsePeopleCollection"],
        [Feature.FETCH_PERSON_APP_DATA,   true, "parseParams", "parseRawData"],
        [Feature.UPDATE_PERSON_APP_DATA,  true, "parseParams", "parseEmpty"],
        [Feature.REMOVE_PERSON_APP_DATA,  true, "parseParams", "parseEmpty"],
        [Feature.FETCH_ACTIVITIES,        true, "parseParams", "parseActivitiesCollection"],
        [Feature.REQUEST_CREATE_ACTIVITY, true, "parseParams", "parseEmpty"],
        [Feature.REQUEST_SEND_MESSAGE,    true, "parseParams", "parseEmpty"],
        [Feature.REQUEST_SHARE_APP,       true, "parseParams", "parseEmpty"],
        [Feature.REQUEST_PERMISSION,      true, "parseParams", "parseEmpty"],
        [Feature.GET_CONTAINER_DOMAIN,    false],
        [Feature.GET_DOMAIN,              false],
        [Feature.SUPPORTS_FIELD,          false],
        
        [Feature.MAKE_REQUEST,            true, "parseParams", "parseRawData"],
        
        [Feature.CALL_RPC,                true],
        [Feature.RETURN_RPC_SERVICE,      false],
        [Feature.REGISTER_RPC_SERVICE,    false],
        [Feature.UNREGISTER_RPC_SERVICE,  false],
        
        [Feature.GET_CURRENT_VIEW,        false],
        [Feature.IS_ONLY_VISIBLE,         false],
        [Feature.GET_VIEW_PARAMS,         false],

        [Feature.SET_STAGE_HEIGHT,        false],
        [Feature.SET_STAGE_WIDTH,         false],
        [Feature.SET_TITLE,               false]
    ];  
    
    
    for each(var item:Array in features) {
      var args:Array = [item[0], item[1]];
      if (item[2]) {
        args.push(JsWrapperParsers[item[2]]);
      }
      if (item[3]) {
        args.push(JsWrapperParsers[item[3]]);
      }
      addFeature.apply(this, args);
    }
    
  }
}

}
