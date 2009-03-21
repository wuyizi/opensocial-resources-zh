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

import flash.text.TextField;
import flash.text.TextFormat;

/**
 * A text field printer.
 * Apps can add it to the flash stage wherelse visible.
 * 
 * @author yiziwu@google.com (Yizi Wu)
 */
public class TextFieldPrinter extends TextField implements IPrinter {

  /**
   * The constructor.
   * @param x The x position, default = 0.
   * @param y The y position, default = 0.
   * @param width The width dimension, default = 400.
   * @param height The height dimension, default = 120.
   * @param color The text color, default = white.
   */  
  public function TextFieldPrinter(x:Number = 0,
                                   y:Number = 0,
                                   width:Number = 400,
                                   height:Number = 120,
                                   color:uint = 0xFFFFFF) {
    multiline = true;
    mouseWheelEnabled = true;
    selectable = true; 
    wordWrap = true;
    var txtfmt:TextFormat = new TextFormat();
    txtfmt.size = 11;
    txtfmt.font = "Courier New";
    txtfmt.color = color;
    this.defaultTextFormat = txtfmt;
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
  }

  /**
   * Prints the text to the info box. 
   * @param text The text to output.
   */  
  public function print(text:String):void {
    this.appendText(text);
    this.scrollV = this.maxScrollV;
  }
}
}
