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

package org.opensocial.client.base {

/**
 * Wrapper of <code><j>gadgets.views</j></code> namespace in javascript. 
 * <p>
 * This class is just used as a namespace for static constants.
 * </p>
 * 
 * @see http://code.google.com/apis/opensocial/docs/0.8/reference/gadgets/#gadgets.views
 *      gadgets.views
 * @author yiziwu@google.com (Yizi Wu)
 */
public class GadgetsViews extends BaseType {
  
  /**
   * <code><j>gadgets.views.ViewType</j></code> constants.
   * @see http://code.google.com/apis/opensocial/docs/0.8/reference/gadgets/#gadgets.views.ViewType
   *      gadgets.views.ViewType
   */ 
  public static const ViewType:ConstType = new ConstType(
    "gadgets.views.ViewType", {
       CANVAS   : "CANVAS",
       HOME     : "HOME",
       PREVIEW  : "PREVIEW",
       PROFILE  : "PROFILE"
    });

}
}