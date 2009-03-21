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
 * OpenSocial related errors in this package.
 * 
 * @author yiziwu@google.com (Yizi Wu)
 */
public class OpenSocialError extends Error {
  
  protected var code_:String = "";
  
  /**
   * Constructor of the Error. 
   * @param message The error message text.
   */  
  public function OpenSocialError(message:String = "", code:String = "") {
    super("[OpenSocial] " + message, 17785);
    code_ = code;
  }
  
  /**
   * Returns the code information of this error. 
   * @return The code.
   */  
  public function get code():String {
    return code_;
  }

}
}
