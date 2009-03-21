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

package org.opensocial.client.core {
  
/**
 * Base class for all features API. Core and abstract functionalities of the OpenSocial API are 
 * defined in sub classes of this class.
 * 
 * @author yiziwu@google.com (Yizi Wu)
 */
internal class ClientHelper {

  private var client_:OpenSocialClient;
  
  /**
   * Initializes the feature instance.
   * @param client The client instance.
   */  
  public function ClientHelper(client:OpenSocialClient) {
    client_ = client;
  }
  
  /**
   * Gets the client 
   * @return The client
   */  
  protected function get client():OpenSocialClient {
    return client_;
  }
  
}
}