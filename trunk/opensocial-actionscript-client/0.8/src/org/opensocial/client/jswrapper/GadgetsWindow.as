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

import org.opensocial.client.base.OpensocialError;

/**
 * Wrapper of functions in <code><j>opensocial.window</j></code> and namespace in javascript.
 * 
 * @see http://code.google.com/apis/opensocial/docs/0.8/reference/gadgets/#gadgets.window 
 *      gadgets.window
 * 
 * @author yiziwu@google.com (Yizi Wu)
 */
public class GadgetsWindow extends JsFeature {

  /**
   * Default constructor.
   * <p>
   * NOTE: This constructor is internally used. Do not call this constructor directly outside 
   * this package.
   * </p>
   * @param client The jswrapper client.
   * @private
   */
  public function GadgetsWindow(client:JsWrapperClient) {
    super(client);
  }


  /**
   * Sets the app's witdh. This will resize the swf object's width.
   * @param width The new width.
   * @return False if the feature is not supported.
   */ 
  public function setStageWidth(width:Number):Boolean {
    assertReady();
    return ExternalInterface.call(getJsFuncName("setStageWidth"), width);
  }
  
  /**
   * Sets the app's height. 
   * This will resize the swf object's height. It will also adjust the iframe's
   * height if the 'dynamicHeight' feature is required.
   * @param height The new height.
   * @return False if the feature is not supported.
   */
  public function setStageHeight(height:Number):Boolean {
    assertReady();
    return ExternalInterface.call(getJsFuncName("setStageHeight"), height);
  }
    
    
}

}
