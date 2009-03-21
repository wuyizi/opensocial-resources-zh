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

import flash.utils.getQualifiedClassName;

import org.opensocial.client.util.Logger;
import org.opensocial.client.util.Utils;

/**
 * Extends from <code>Array</code> to handle wrapped objects array conversion.
 * 
 * @author yiziwu@google.com (Yizi Wu)
 */
public dynamic class ArrayType extends Array {
  
  private static var logger:Logger = new Logger(ArrayType);
  
  /**
   * Convert an array of raw object to an array primitives or DataType instances.
   * <p>
   * NOTE: This constructor is internally used. Do not call this constructor directly outside 
   * this package.
   * </p>
   * @param raw The object which is an array from Js-side.
   * @param type The type of each item in this array. Null for primitives, otherwise the type 
   *             should be subtype of <code>DataType</code>.
   * @private
   */
  public function ArrayType(rawObj:Object, type:Class = null) {
    var rawArray:Array = rawObj as Array;
    if (rawArray == null) {
      logger.warning("Raw object is null or non-array in type '" + 
                     getQualifiedClassName(this) + "'.");
      return;
    }

    if (type != null && !Utils.isAncestor(DataType, type)) {
      throw new OpenSocialError("Element type '" + getQualifiedClassName(type) + 
                                "' mismatched when creating an array.");
    }
    for each (var item:Object in rawArray) {
      if (type != null) {
        this.push(new type(item));
      } else {
        this.push(item);
      }
    }
  }
  
  /**
   * Gets an array by the field key and join all items to a flat string. Use
   * comma as a delim by default.
   * @param delim The delim string.
   * @return A joined string.
   */  
  public static function flatten(array:Array, delim:String = ", "):String {
    if (array == null) return "";
    else return array.join(delim);
  }
}

}