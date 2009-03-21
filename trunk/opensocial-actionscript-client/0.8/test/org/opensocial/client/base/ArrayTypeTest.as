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

import flexunit.framework.Assert;
import flexunit.framework.TestCase;

import mx.utils.ObjectUtil;

/**
 * Tests for ArrayType.as
 * 
 * @author yiziwu@google.com (Yizi Wu)
 */
public class ArrayTypeTest extends TestCase {
  
  public function testConstructorSuccess():void {
    
    // Plain
    var rawObject:Object = ["abc", 123];
    var array:ArrayType = new ArrayType(rawObject);
    Assert.assertEquals("abc", array[0]);
    Assert.assertEquals(123, array[1]);
    
    // DataType
    var a1:Activity = Activity.newInstance("a1");
    var a2:Activity = Activity.newInstance("a2");
    rawObject = [a1.toRawObject(), a2.toRawObject()];
    array = new ArrayType(rawObject, Activity);
    Assert.assertTrue(ObjectUtil.compare(a1, array[0]) == 0);
    Assert.assertTrue(ObjectUtil.compare(a2, array[1]) == 0);
  }
  
  public function testConstructorWithBadRawObject():void {
    var array:ArrayType;
    // Null
    array = new ArrayType(null);
    Assert.assertTrue(ObjectUtil.compare([], array) == 0);
    // Random object
    array = new ArrayType(new Date());
    Assert.assertTrue(ObjectUtil.compare([], array) == 0);
  }
  
  public function testConstructorWithBadType():void {
    var a1:Activity = Activity.newInstance("a1");
    var a2:Activity = Activity.newInstance("a2");
    var rawObject:Object = [a1.toRawObject(), a2.toRawObject()];
    var array:ArrayType;
    try {
      // Random type 
      array = new ArrayType(rawObject, Date);
      Assert.fail();
    } catch (e:OpenSocialError) {
      Assert.oneAssertionHasBeenMade();
    }
    Assert.assertEquals(1, Assert.assetionsMade);
  }
  
  public function testFlatten():void {
    // Plain
    var rawObject:Object = ["abc", 123];
    var array:ArrayType = new ArrayType(rawObject);
    var str:String = ArrayType.flatten(array);
    
    Assert.assertEquals("abc, 123", str);
    
  }
}
}
