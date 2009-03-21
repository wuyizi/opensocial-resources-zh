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

package {
  
import flash.display.Loader;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.net.URLRequest;
import flash.text.TextField;
import flash.text.TextFormat;

import org.opensocial.client.base.*;
import org.opensocial.client.core.*;
import org.opensocial.client.events.*;
import org.opensocial.client.jswrapper.*;
import org.opensocial.client.util.*;

/**
 * Sample Application using the OpenSocial(0.8) Actionscript Client SDK in Adobe Flash IDE.
 * <p>
 * Usage:<br>
 * 1. Create a JsWrapperClient instance.
 * <br> 
 * 2. Add a eventhandler for READY event and call the start() method.
 * <br>
 * 3. When the client is ready, use the feature helper or events to interact with OpenSocial API.
 * </p>
 * 
 * @author yiziwu@google.com (Yizi Wu)
 * @author chaowang@google.com (Jacky Wang)
 */
public class SampleApp extends MovieClip {

  private var logger:Logger = new Logger(SampleApp);
  private var client:JsWrapperClient;
  private var opensocial:OpenSocialHelper;
  private var gadgets:GadgetsHelper;

  public function SampleApp() {
    prepareBtns();
    
    // Create the output box for information displaying
    var printer:TextFieldPrinter = new TextFieldPrinter(2, 100, 500, 350);
    addChild(printer);
    Logger.initialize(printer);
    
    // Initialize Client and start
    client = new JsWrapperClient("opensocial.flash");
    client.addEventListener(OpenSocialClientEvent.CLIENT_READY, onReady);
    client.start();
    logger.log(new Date());
    
    opensocial = new OpenSocialHelper(client);
    gadgets = new GadgetsHelper(client);
  }

  private function onReady(event:OpenSocialClientEvent):void {
    logger.info("Domain: " + opensocial.getDomain());
    logger.info("ContainerDomain: " + opensocial.getContainerDomain());
    logger.info("CurrentView: " + gadgets.getCurrentView());
    logger.info("Client Ready.");
  }
  
  // -------------------------------------------------------------
  //  Demo Actions
  // -------------------------------------------------------------
  private function fetchMe():void {
    opensocial.fetchPerson(IdSpec.PersonId.VIEWER, function(r:ResponseItem):void {
      var p:Person = r.getData();
      logger.info(p.getDisplayName());
      drawPerson(p, 0);
    });
  }
  
  private function fetchFriends(start:int = 0):void {
    var idSpec:IdSpec = IdSpec.newInstance(IdSpec.PersonId.VIEWER, IdSpec.GroupId.FRIENDS);
    var params:Object = DataRequest.newPeopleRequestParams(start, 5);
    opensocial.fetchPeople(idSpec, function(r:ResponseItem):void {
      var c:Collection = r.getData();
      logger.info(c.toDebugString());
      
      var arr:Array = c.getArray();
      for (var i:int = 0; i < arr.length; i++) {
        var p:Person = arr[i];
        logger.info(p.getDisplayName());
        drawPerson(p, i + 1);
      }
      if (c.getRemainingSize() > 0) {
        fetchFriends(c.getNextOffset());
      }
    }, params);
  }

  private function sendMessage():void {
    var message:Message = Message.newInstance("Hello World...", "My new message.");
    logger.log(message.toRawObject());
    opensocial.requestSendMessage(['VIEWER'], message, function(r:ResponseItem):void {
      if (r.hadError()) {
        logger.info("msg sending failed: " + r.getErrorCode());
      } else {
        logger.info("msg sent.");
      }
    });
  }

  private function createActivity():void {
    var activity:Activity = Activity.newInstance("My new activity!", "Hello World...");
    logger.log(activity.toRawObject());
    opensocial.requestCreateActivity(activity, null, function(r:ResponseItem):void {
      if (r.hadError()) {
        logger.info("activity creation failed: " + r.getErrorCode());
      } else {
        logger.info("activity created");
      }
    });
  }

  private function makeRequest():void {
    var params:Object = GadgetsIo.newGetRequestParams(GadgetsIo.ContentType.TEXT);
    gadgets.makeRequest("http://www.google.com/crossdomain.xml", 
      function(r:ResponseItem):void {
        if (r.hadError()) {
          logger.info("make request failed: " + r.getErrorCode());
        } else {
          var data:String = r.getData();  
          logger.info(data);
        }
      }, params);
  }

  private function callRpc():void {
    // To use this, you need to first register the rpc service with name "srv-parent" on 
    // container side. If you are using firefox+firebug and looking on a shindig container,
    // before clicking the "Call Rpc" button in the flash to call this method, copy+paste the 
    // following codes to the console window:
    // 
    // <code>
    // gadgets.rpc.register("srv-parent",function(){console.log(arguments);return "'srv-parent' returned."});
    // </code>
    gadgets.call(null, "srv-parent", function(returnValue:Object) {
      logger.info("--- returned from 'srv-parent' ---");
      logger.log(returnValue);
    }, "abc", 123, {'xyz':456});
  }

  private function registerSrv():void {
    // To use this, you need to make a rpc call to "srv-app" from container side. If you are 
    // using firefox+firebug and shindig container, click the "Register Srv" button in the 
    // flash to call this method, then copy+paste the following codes to the console window
    // to test the rpc. 
    // ("remote_iframe_0" assumes this flash app is the first app on the page)
    // 
    // <code>
    // gadgets.rpc.call("remote_iframe_0","srv-app",function(r){console.log(r);},"abc", 123, {'xyz':456});
    // </code>
    gadgets.register("srv-app", function(...args):Object {
      logger.info("---get called by 'srv-app'---");
      logger.log(args);
      return "'srv-app' returned.";
    });
  }
  
  // -------------------------------------------------------------
  //  Helper functions for action and display
  // -------------------------------------------------------------
  private function prepareBtns():void {
  
    if (this['fetchMeBtn']) {
      var btn1:TextField = this['fetchMeBtn'] as TextField;
      btn1.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void {
        fetchMe();
      });
    }
    
    if (this['fetchFriendsBtn']) {
      var btn2:TextField = this['fetchFriendsBtn'] as TextField;
      btn2.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void {
        fetchFriends();
      });
    }
    
    if (this['sendMessageBtn']) {
      var btn3:TextField = this['sendMessageBtn'] as TextField;
      btn3.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void {
        sendMessage();
      });
    }
    
    if (this['createActivityBtn']) {
      var btn4:TextField = this['createActivityBtn'] as TextField;
      btn4.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void {
        createActivity();
      });
    }
    
    if (this['makeRequestBtn']) {
      var btn5:TextField = this['makeRequestBtn'] as TextField;
      btn5.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void {
        makeRequest();
      });
    }

    if (this['callRpcBtn']) {
      var btn6:TextField = this['callRpcBtn'] as TextField;
      btn6.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void {
        callRpc();
      });
    }

    if (this['registerSrvBtn']) {
      var btn7:TextField = this['registerSrvBtn'] as TextField;
      btn7.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void {
        registerSrv();
      });
    }
  }

  private function drawPerson(person:Person, index:int):void {
    var txtfmt:TextFormat = new TextFormat();
    txtfmt.size = 11;
    txtfmt.font = "arial";
    txtfmt.color = 0xFFFFFF;

    var name:TextField = new TextField();
    name.x = 2;
    name.y = 2;
    name.defaultTextFormat = txtfmt;
    name.text = person.getDisplayName();

    var box:Sprite = new Sprite();
    box.x = 2 + (index % 3) * 180;
    box.y = (Math.floor(index / 3)) * 70 + 2;
    box.addChild(name);

    addChild(box);

    try {
      var url:String = person.getThumbnailUrl();
      //logger.info(url);
      if (url != null) {
        var request:URLRequest = new URLRequest(url);
        var thumb:Loader = new Loader();
        box.addChild(thumb);
        thumb.x = 2;
        thumb.y = 20 + 2;
        thumb.load(request);
        
        thumb.contentLoaderInfo.addEventListener(Event.COMPLETE, 
            function(event:Event):void {
              thumb.width = 32;
              thumb.height = 32;
            }, false, 0, true);
      }
    } catch (e:Error) {
      logger.error(e);
    }
  }
  
}
}
