/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements. See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership. The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * 'License'); you may not use this file except in compliance
 * with the License. You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * 'AS IS' BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations under the License.
 */

/**
 * @fileoverview Container-side code to process virtual currency payments.
 */

var gadgets = gadgets || {};

/**
 * @static
 * @class Provides the virtual currency payment processor features on 
          container side. Handles the payment request from app, prompts the 
          container processor page for user to confirm the payment, and 
          passes the response back to the app. The container needs to implement 
          four event functions to fulfill the functionality.
 * @name gadgets.paymentprocessor
 */
gadgets.paymentprocessor = (function() {

  /**
   * The state indicating if the processor panel is on or off.
   * @type {boolean}
   */
  var isOpened = false;

  /**
   * The state indicating if the processor panel is committed.
   * @type {boolean}
   */
  var isCommitted = false;

  /**
   * A parameter set of the request. It is initialized in the open() function
   * and disposed in the close() function after the callback rpc is called.
   * @type {Object}
   */
  var reqParams;

  /**
   * A parameter set of the response. It is initialized in the open() function
   * and disposed in the close() function after the callback rpc is called.
   * @type {Object}
   */
  var resParams;

  /**
   * The app backend url for checkout the products. Null if no app backend 
   * server.
   * @type {string}
   */
  var checkoutUrl;

  /**
   * A set of event functions which allow customizing the UI and actions of the
   * processor panel by container.
   * @type {Object.<string, Function>}
   */
  var events = {};

  /**
   * Handles the request called via rpc from gadgets.pay.requestPay on the
   * app side. Turns on the processor and initializes the reqParams and
   * resParams.
   *
   * The 'this' in this function is the rpc object, which contains
   * some information of the app.
   *
   * @param {String} appCheckoutUrl The checkout url on for app backend server.
   * @param {Object} appReqParams The request parameters set from the app,
            with AMOUNT, MESSAGE and CALLBACK and other parameters.
   */
  function open(appCheckoutUrl, appReqParams) {
    var frameId = this.f;
    
    
    if (!appReqParams ||
        !appReqParams['AMOUNT'] || !(appReqParams['AMOUNT'] > 0) ) {
      // TODO: Need more check on the AMOUNT value.
      try {
        gadgets.rpc.call(frameId, 'payment-callback', null,
                         {'RESPONSE_CODE': 'MALFORMED_REQUEST'});
      } finally {
        return;
      }
    }

    if (isOpened) {
      // Shouldn't continue if the processor is already opened.
      try {
        gadgets.rpc.call(frameId, 'pay-callback', null,
                         {'RESPONSE_CODE': 'PAYMENT_PROCESSOR_ALREADY_OPENED'});
      } finally {
        return;
      }
    }
    
    // Initialize the reqParams object.
    reqParams = appReqParams;
    reqParams['MESSAGE'] = gadgets.util.escapeString(reqParams['MESSAGE']);
    reqParams['FRAME_ID'] = frameId;

    // This part need the gadgets.container service
    if (gadgets.container && gadgets.container.gadgetService) {
      reqParams['GADGET_ID'] =
          gadgets.container.gadgetService.getGadgetIdFromModuleId(frameId);
      var thisGadget = gadgets.container.getGadget(reqParams['GADGET_ID']);
      if (thisGadget) {
        reqParams['GADGET_TITLE'] = thisGadget['title'];
        reqParams['GADGET_SPEC'] = thisGadget['specUrl'];
      }
    } else {
      reqParams['GADGET_TITLE'] = 'Unable to get app title.';
      reqParams['GADGET_SPEC'] = 'Unable to get app specUrl.';
    }

    // Initialize the resParams object.
    resParams = {};
    resParams['ORDERED_TIME'] = new Date().getTime();

    checkoutUrl = appCheckoutUrl;
    
    isOpened = true;
    isCommitted = false;

    // Call the container's open event to display the processor panel UI.
    if (events.open) {
      events.open(reqParams, resParams, commit, cancel);
    } else {
      // The open event is not optional.
      // If not set, then close the processor.
      resParams['RESPONSE_CODE'] = 'NOT_IMPLEMENTED';
      close();
    }
  };

  /**
   * Handles the commit button click event by the user.
   * It calls the commit event to the pay request to container
   * virtual currency api with Ajax POST.
   */
  function commit() {
    if (!isOpened) {
      return;
    }
    // The committed time is the time when user click the commit button.
    resParams['COMMITTED_TIME'] = new Date().getTime();

    // Call the container's commit event to actually do the virtual currency
    // change on container backend via Ajax POST.
    // The resParams's RESPONSE_CODE and EXECUTED_TIME will be set in this event.
    if (events.commit) {
      events.commit(checkoutUrl, reqParams, resParams, close);
      isCommitted = true;
    } else {
      // The commit event is not optional.
      // If not set, then close the processor.
      resParams['RESPONSE_CODE'] = 'NOT_IMPLEMENTED';
      close();
    }
  };

  /**
   * Handles the cancel button click event by the user.
   */
  function cancel() {
    if (!isOpened || isCommitted) {
      return;
    }

    resParams['RESPONSE_CODE'] = 'USER_CANCELLED';

    // Call the container's cancel event to do some UI change if needed.
    if (events.cancel) {
      events.cancel(reqParams, resParams, close);
    } else {
      // The cancel event is optional.
      // If not set, close the processor directly.
      close();
    }
  };

  /**
   * Closes the processor panel.
   * It hides the processor panel itself in the close event.
   */
  function close() {
    if (!isOpened) {
      return;
    }

    // Call the container's close event to hide the processor panel.
    if (events.close) {
      events.close(reqParams, resParams);
    }
    // The close event is optional. If not set, do nothing.
    // (NOTE that the panel is still visible if do nothing...)

    isOpened = false;

    try {
      // Call the app back via rpc.
      gadgets.rpc.call(reqParams['FRAME_ID'], 'payment-callback', null,
                       resParams);
    } finally {
      reqParams = null;
      resParams = null;
    }
  };

  return /** @scope gadgets.paymentprocessor */ {
    /**
     * Initializes the 'payment' rpc. It's called by container processor page in
     * onload function.
     * @param {Function} openevent The event function for handling the opening
     *        UI.
     * @param {Function} commitevent The event function for real interaction
     *        with the container api server.
     * @param {Function} cancelevent The event function for handling the
     *        cancel action UI.
     * @param {Function} closeevent The event function for handling the
     *        disposing UI.
     */
    init: function(openEvent, commitEvent, cancelEvent, closeEvent) {
      events.open = openEvent;
      events.commit = commitEvent;
      events.cancel = cancelEvent;
      events.close = closeEvent;
      gadgets.rpc.register('payment', open);
    }
  };

})();
