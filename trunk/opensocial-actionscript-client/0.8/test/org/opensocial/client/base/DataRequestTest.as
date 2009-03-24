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

import mx.utils.ObjectUtil;

/**
 * Tests for DataRequest.as
 * 
 * @author yiziwu@google.com (Yizi Wu)
 */
public class DataRequestTest extends TestCase {

  override public function setUp():void {
    ConstType.setUseDefault(true);
  }
  
  public function testNewPeopleRequestParams():void {
    var params:Object = DataRequest.newPeopleRequestParams(
        1, 2, [Person.Field.PROFILE_URL, Person.Field.EMAILS],
        DataRequest.SortOrder.TOP_FRIENDS, DataRequest.FilterType.HAS_APP);
    Assert.assertEquals(1, params[DataRequest.PeopleRequestFields.FIRST]);
    Assert.assertEquals(2, params[DataRequest.PeopleRequestFields.MAX]);
    Assert.assertTrue(ObjectUtil.compare(["profileUrl", "emails"], 
                      params[DataRequest.PeopleRequestFields.PROFILE_DETAILS]) == 0);
    Assert.assertEquals("topFriends", params[DataRequest.PeopleRequestFields.SORT_ORDER]);
    Assert.assertEquals("hasApp", params[DataRequest.PeopleRequestFields.FILTER]);
  }
  
  public function testNewActivityRequestParams():void {
    var params:Object = DataRequest.newActivityRequestParams(1, 2);
    Assert.assertEquals(1, params[DataRequest.ActivityRequestFields.FIRST]);
    Assert.assertEquals(2, params[DataRequest.ActivityRequestFields.MAX]);
  }
  
  public function testNewDataRequestParams():void {
    var params:Object = DataRequest.newDataRequestParams(Globals.EscapeType.NONE);
    Assert.assertEquals("none", params[DataRequest.DataRequestFields.ESCAPE_TYPE]);
  }
 
  public function testSortOrder():void {
    // No test if javascript is not available.
    if (!ExternalInterface.available) return;
    var realSortOrder:Object = ExternalInterface.call(
        "function() {return opensocial.DataRequest.SortOrder;}");
    for (var name:String in DataRequest.SortOrder) {
      Assert.assertEquals(realSortOrder[name], DataRequest.SortOrder[name]);
    }
  }
  
  public function testFilterType():void {
    // No test if javascript is not available.
    if (!ExternalInterface.available) return;
    var realFilterType:Object = ExternalInterface.call(
        "function() {return opensocial.DataRequest.FilterType;}");
    for (var name:String in DataRequest.FilterType) {
      Assert.assertEquals(realFilterType[name], DataRequest.FilterType[name]);
    }
  }
  
  public function testDataRequestFields():void {
    // No test if javascript is not available.
    if (!ExternalInterface.available) return;
    var realDataRequestFields:Object = ExternalInterface.call(
        "function() {return opensocial.DataRequest.DataRequestFields;}");
    for (var name:String in DataRequest.DataRequestFields) {
      Assert.assertEquals(realDataRequestFields[name], DataRequest.DataRequestFields[name]);
    }
  }
  
  public function testPeopleRequestFields():void {
    // No test if javascript is not available.
    if (!ExternalInterface.available) return;
    var realPeopleRequestFields:Object = ExternalInterface.call(
        "function() {return opensocial.DataRequest.PeopleRequestFields;}");
    for (var name:String in DataRequest.PeopleRequestFields) {
      Assert.assertEquals(realPeopleRequestFields[name], DataRequest.PeopleRequestFields[name]);
    }
  }
  
  public function testActivityRequestFields():void {
    // No test if javascript is not available.
    /* Not available yet
    if (!ExternalInterface.available) return;
    var realActivityRequestFields:Object = ExternalInterface.call(
        "function() {return opensocial.DataRequest.ActivityRequestFields;}");
    for (var name:String in DataRequest.ActivityRequestFields) {
      Assert.assertEquals(realActivityRequestFields[name], DataRequest.ActivityRequestFields[name]);
    }
    */
  }

}
}
