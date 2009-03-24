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
 * Tests for Activity.as
 * 
 * @author yiziwu@google.com (Yizi Wu)
 */
public class ActivityTest extends TestCase {
  
  override public function setUp():void {
    ConstType.setUseDefault(true);
  }
  
  public function testNewInstance():void {
    var activity:Activity = Activity.newInstance("testTitle", "testBody");
    Assert.assertEquals("testTitle", activity.getFieldString(Activity.Field.TITLE));
    Assert.assertEquals("testBody", activity.getFieldString(Activity.Field.BODY));
    Assert.assertNull(activity.getFieldString(Activity.Field.ID));
  }
  
  public function testGetId():void {
    // Simulate the javascript wrapObject function.
    var rawObject:Object = {"id": "testId", "fields": {}};
    var activity:Activity = new Activity(rawObject);
    Assert.assertEquals("testId", activity.getId());
  }
  
  public function testToString():void {
    var activity:Activity = Activity.newInstance("testTitle", "testBody");
    assertEquals("testTitle", activity.toString());
  }
 
  public function testField():void {
    // No test if javascript is not available.
    if (!ExternalInterface.available) return;
    var realField:Object = ExternalInterface.call(
        "function() {return opensocial.Activity.Field;}");
    for (var name:String in Activity.Field) {
      Assert.assertEquals(realField[name], Activity.Field[name]);
    }
  } 
}
}
