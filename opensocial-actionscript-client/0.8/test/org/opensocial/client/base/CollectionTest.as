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
 * Tests for Collection.as
 * 
 * @author yiziwu@google.com (Yizi Wu)
 */
public class CollectionTest extends TestCase {
  
  
  public function testAccessorsSuccess():void {
    var a1:Activity = Activity.newInstance("a1");
    var a2:Activity = Activity.newInstance("a2");
    var rawObject:Object = {"array" : [a1, a2], "size" : 2, "offset": 6, "totalSize" : 10};
    var collection:Collection = new Collection(rawObject, Activity);
    Assert.assertEquals(2, collection.getSize());
    Assert.assertEquals(6, collection.getOffset());
    Assert.assertEquals(10, collection.getTotalSize());
    Assert.assertEquals(8, collection.getNextOffset());
    Assert.assertEquals(2, collection.getRemainingSize());
    Assert.assertEquals(Activity, collection.getElementType());
    Assert.assertTrue(ObjectUtil.compare([a1, a2], collection.getArray()) == 0);
  }

  public function testAccessorsWarnings():void {
    var rawObject:Object = {"array" : [], "size" : 2, "offset": 9, "totalSize" : 10};
    var collection:Collection = new Collection(rawObject, Activity);
    Assert.assertEquals(0, collection.getRemainingSize());
    Assert.assertEquals(10, collection.getNextOffset());
  }


  public function testAppend():void {
    var a1:Activity = Activity.newInstance("a1");
    var a2:Activity = Activity.newInstance("a2");
    var a3:Activity = Activity.newInstance("a3");
    var a4:Activity = Activity.newInstance("a4");
    var m:Message = Message.newInstance("msg");

    var o1:Object = {"array" : [a1, a2], "size" : 2, "offset": 6, "totalSize" : 10};
    var c1:Collection = new Collection(o1, Activity);
    var o2:Object = {"array" : [a3, a4], "size" : 2, "offset": 4, "totalSize" : 10};
    var c2:Collection = new Collection(o2, Activity);
    var o3:Object = {"array" : [a3, a4], "size" : 2, "offset": 4, "totalSize" : 11};
    var c3:Collection = new Collection(o3, Activity);
    var o4:Object = {"array" : [a3, a4], "size" : 2, "offset": 5, "totalSize" : 10};
    var c4:Collection = new Collection(o4, Activity);
    var o5:Object = {"array" : [m], "size" : 1, "offset": 5, "totalSize" : 10};
    var c5:Collection = new Collection(o5, Message);
    
    var r2:Boolean = c2.append(c1);
    Assert.assertTrue(r2);
    Assert.assertEquals(4, c2.getSize());
    Assert.assertEquals(8, c2.getNextOffset());
    Assert.assertEquals(2, c2.getRemainingSize());
    Assert.assertTrue(ObjectUtil.compare([a3, a4, a1, a2], c2.getArray()) == 0);
    
    var r3:Boolean = c3.append(c1);
    Assert.assertFalse(r3);

    var r4:Boolean = c4.append(c1);
    Assert.assertFalse(r4);
    
    var r5:Boolean = c5.append(c1);
    Assert.assertFalse(r5);
  }
  
  public function testToDebugString():void {
    var a1:Activity = Activity.newInstance("a1");
    var a2:Activity = Activity.newInstance("a2");
    var rawObject:Object = {"array" : [a1, a2], "size" : 2, "offset": 6, "totalSize" : 10};
    var collection:Collection = new Collection(rawObject, Activity);
    Assert.assertEquals("10|2|6|8|2", collection.toDebugString());
  }
  
}
}
