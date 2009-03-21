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

package org.opensocial.client.util {

import flash.utils.getQualifiedClassName;

/**
 * A reference logger funtionality class. Its style is from java.util.logging.Logger.
 * Developers can extend this class to do more customize and use different pinrters.
 * 
 * @author yiziwu@google.com (Yizi Wu)
 */
public class Logger {

  /**
   * A printer instance for info output.
   * If it's not set, by default do nothing.
   * @private
   */ 
  private static var printer_:IPrinter = null;

  
  private static var global_:Logger = null;
  
  private static var verbose_:int = 0;
  
  /**
   * Static initializer for the Logger.
   * @param printer The printer instance for the Logger in the app.
   * @param verbose The verbose param, set to 1 to log the warnings.
   */ 
  public static function initialize(printer:IPrinter = null, verbose:int = 0):void {
    printer_ = printer;
    verbose_ = verbose;
    global_ = new Logger();
  }

  
  public static function get global():Logger {
    if (global_ == null) {
      global_ = new Logger();
    }
    return global_;
  }

  private var class_:Class; 
  /**
   * Constructor for the logger.
   * @param theClass The class of the logger locates and is logging.
   */ 
  public function Logger(theClass:Class = null) {
    class_ = theClass;
  }

  private function print(text:String):void {
    if (printer_ != null) {
      printer_.print(text);
    }
  }

  /**
   * Output the content as text.
   * @param obj The object to be output.
   */
  public function info(obj:Object):void {
    print(inspect(obj != null ? obj.toString() : null, "I"));
  }
  
  /**
   * Log as WARNNING for the message 
   * @param obj The object to be output.
   * 
   */  
  public function warning(obj:Object):void {
    if (verbose_ < 1) return;
    print(inspect(obj != null ? obj.toString() : null, "W"));
  }

  /**
   * Log as ERROR for the error object.
   * @param error The error object to be output.
   */
  public function error(error:Error):void {
    print(inspect(error.getStackTrace(), "E"));
  }

  /**
   * Log down the detail of an object.
   * @param obj The object to be output.
   */
  public function log(obj:Object):void {
    print(inspect(obj, "L", class_));
  }
  
  /**
   * An object inpetcor function. It's very useful to look at values inside a target. 
   * It will recursively go into each public fields in this object.
   * @param obj The object to be inspected.
   * @return The output string. 
   */  
  public static function inspect(obj:Object, prefix:String, theClass:Class = null):String {
    var buffer:Array = [];
    buffer.push(prefix, " [", new Date().toLocaleTimeString(), "] ");
    if (theClass != null) {
      buffer.push(String(theClass), "\n> ");
    }
    var inspect:Function = function(obj:Object, buffer:Array, opt_prefix:String = ""):void {
      if (obj == null) {
        buffer.push("NULL\n");
      } else if (obj is String || 
                 obj is Boolean || 
                 obj is Number || 
                 obj is Date || 
                 obj is Function) {
        buffer.push(obj, "\n");
      } else if (obj is Error) {
        buffer.push("#", (obj as Error).errorID, ":", (obj as Error).message, "\n");
      } else {
        buffer.push("<", getQualifiedClassName(obj), ">\n");
        for(var key:String in obj) {
          buffer.push(opt_prefix, "\t", key, "\t  ");
          
          var value:* = obj[key];
          buffer.push("<", getQualifiedClassName(value), ">\t : ");
          
          inspect(obj[key], buffer, opt_prefix + "\t")
        }
      }
    };
    inspect(obj, buffer);
    return buffer.join("");
  }
}

}
