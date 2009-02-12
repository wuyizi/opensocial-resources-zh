/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements. See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership. The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License. You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations under the License.
 */

/**
 * @fileoverview This library augments gadets.payment with functionality
 * to pay virtual currency from a user for an app on container.
 */

var gadgets = gadgets || {};

/**
 * @static
 * @class Provides the virtual currecy payment features on app side.
 * @name gadgets.payment
 */
gadgets.payment = (function() {

  /**
   * The state indicating if the counter panel is on or off.
   * @type {boolean}
   */
  var isOpened = false;

  /**
   * The callback to the app
   * @type {Function}
   */
  var callback;

  /**
   * Handles the response via rpc from container's payment processor after 
   * user's action on counter panel and the call the callback function in the 
   * app with the response parameters.
   * @param {Object} resParams The response parameters set.
   */
  function paymentCallback(resParams) {
    isOpened = false;
    if (callback) {
      callback(resParams);
    }
  };

  return /** @scope gadgets.payment */ {
    /**
     * Requests to pay some virtual currency to container.
     * @param {String} checkoutUrl
     * @param {Object} reqParams The request parameters set.
     * @param {Function} opt_callback The function for callback. It takes one
              object as argument, which is the response parameters set.
     */
    requestPay: function(checkoutUrl, reqParams, opt_callback) {

      if (isOpened) {
        // Shouldn't continue if the counter is already opened.
        try {
          callback({'RESPONSE_CODE': 'PAYMENT_PROCESSOR_ALREADY_OPENED'});
        } finally {
          return;
        }
      }
      isOpened = true;
      callback = opt_callback;
      gadgets.rpc.register('payment-callback', paymentCallback);
      gadgets.rpc.call(null, 'payment', null, checkoutUrl, reqParams);
    }
  };

})();

gadgets.payment.RequestParameters = gadgets.util.makeEnum([
  "AMOUNT",
  "PARAMETERS",
  "MESSAGE"
]);

gadgets.payment.ResponseParameters = gadgets.util.makeEnum([
  "RESPONSE_CODE",
  "RESPONSE_MESSAGE",
  "ORDER_ID",
  "ORDERED_TIME",
  "COMMITTED_TIME",
  "EXECUTED_TIME",
]);

gadgets.payment.ResponseCode = gadgets.util.makeEnum([
  "INSUFFICIENT_MONEY",
  "INVALID_TOKEN",
  "MALFORMED_REQUEST",
  "APP_NETWORK_FAILURE",
  "APP_LOGIC_ERROR",
  "PAYMENT_ERROR",
  "OK",
  "PAYMENT_PROCESSOR_ALREADY_OPENED",
  "NOT_IMPLEMENTED",
  "USER_CANCELLED",
  "UNKNOWN_ERROR"
]);

