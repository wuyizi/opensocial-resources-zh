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

import flash.external.ExternalInterface;

import flexunit.framework.Assert;
import flexunit.framework.TestCase;

/**
 * Tests for Address.as
 * 
 * @author yiziwu@google.com (Yizi Wu)
 */
public class AddressTest extends TestCase {
  
  override public function setUp():void {
    ConstType.setUseDefault(true);
  }
  
  public function testToString():void {
    // Simulate the javascript wrapObject function.
    var rawObject:Object = {"fields": {"country": "China", "locality": "Beijing"}};
    var address:Address = new Address(rawObject);
    Assert.assertEquals("China  Beijing", address.toString());
    
    rawObject = {"fields": {"country": "China"}};
    address = new Address(rawObject);
    Assert.assertEquals("China", address.toString());
    
    rawObject = {"fields": {"locality": "Beijing"}};
    address = new Address(rawObject);
    Assert.assertEquals("Beijing", address.toString());
    
    rawObject = {"fields": {}};
    address = new Address(rawObject);
    Assert.assertEquals(null, address.toString());
  }
 
  public function testFields():void {
    // No test if javascript is not available.
    if (!ExternalInterface.available) return;
    var realFields:Object = ExternalInterface.call(
        "function() {return opensocial.Address.Field;}");
    for (var name:String in Address.Field) {
      Assert.assertEquals(realFields[name], Address.Field[name]);
    }
  } 
}
}
