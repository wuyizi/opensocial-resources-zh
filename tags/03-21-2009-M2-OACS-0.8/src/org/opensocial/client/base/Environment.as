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
 * Wrapper of <code><j>opensocial.Environment</j></code> in javascript.
 * <p>
 * This class is just used as a namespace for these constants.
 * </p>
 * 
 * @see http://code.google.com/apis/opensocial/docs/0.8/reference/#opensocial.Environment 
 *      opensocial.Environment
 * 
 * @author yiziwu@google.com (Yizi Wu)
 */
public class Environment extends BaseType {
  
  /**
   * <code><j>opensocial.Environment.ObjectType</j></code> constants.
   * @see http://code.google.com/apis/opensocial/docs/0.8/reference/#opensocial.Environment.Field 
   *      opensocial.Environment.ObjectType
   */ 
  public static const ObjectType:ConstType = new ConstType(
      "opensocial.Environment.ObjectType", {
          PERSON        : 'person',
          ADDRESS       : 'address',
          BODY_TYPE     : 'bodyType',
          EMAIL         : 'email',
          NAME          : 'name',
          ORGANIZATION  : 'organization',
          PHONE         : 'phone',
          URL           : 'url',
          ACTIVITY      : 'activity',
          MEDIA_ITEM    : 'mediaItem',
          MESSAGE       : 'message',
          MESSAGE_TYPE  : 'messageType',
          SORT_ORDER    : 'sortOrder',
          FILTER_TYPE   : 'filterType'
      });
}
}
