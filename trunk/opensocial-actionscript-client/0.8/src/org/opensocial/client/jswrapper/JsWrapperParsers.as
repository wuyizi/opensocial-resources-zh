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
  
import org.opensocial.client.base.*;  

/**
 * Collection of parser functions for <code>JsWrapperClient</code>.
 * @author yiziwu@google.com (Yizi Wu)
 */
internal class JsWrapperParsers {

  public static function parseParams(params:Array):Array {
    if (params != null) {
      params = params.map(function(param:*):* {
        if (param is MutableDataType) {
          return (param as MutableDataType).toRawObject();
        } else {
          return param;
        }
      });
    }
    return params;
  }

  public static function parseError(error:OpenSocialError):ResponseItem {
    return new ResponseItem(null, error.code, error.message);
  }

  public static function parsePerson(data:*):ResponseItem {
    if (data is OpenSocialError) return parseError(data);
    return new ResponseItem(new Person(data));
  }

  public static function parsePeopleCollection(data:*):ResponseItem {
    if (data is OpenSocialError) return parseError(data);
    return new ResponseItem(new Collection(data, Person));
  }

  public static function parseActivitiesCollection(data:*):ResponseItem {
    if (data is OpenSocialError) return parseError(data);
    return new ResponseItem(new Collection(data, Activity));
  }

  public static function parseRawData(data:*):ResponseItem {
    if (data is OpenSocialError) return parseError(data);
    return new ResponseItem(data);
  }

  public static function parseEmpty(data:*):ResponseItem {
    if (data is OpenSocialError) return parseError(data);
    return ResponseItem.SIMPLE_SUCCESS;
  }
}

}
