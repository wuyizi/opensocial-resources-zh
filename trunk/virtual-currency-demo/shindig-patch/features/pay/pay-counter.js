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
 * @fileoverview Container-side codes as a counter for the virtual currency
 * payment functionality.
 */

var gadgets = gadgets || {};

/**
 * @static
 * @class Provides the virtual currency payment counter features on container
          side. Handles the payment request from app, prompts the container
          counter page for user to confirm the payment, and passes the
          response back to the app. The container need to implement four
          hook functions to fulfill the functionality.
 * @name gadgets.paycounter
 */
gadgets.paycounter = (function() {

  /**
   * The state indicating if the counter panel is on or off.
   * @type {boolean}
   */
  var isOpened = false;

  /**
   * The state indicating if the counter panel is committed.
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
   * A set of hook functions which allow customizing the UI and actions of the
   * counter panel by container.
   * @type {Object.<string, Function>}
   */
  var hooks = {};

  /**
   * Handles the request called via rpc from gadgets.pay.requestPay on the
   * app side. Turns on the counter and initializes the reqParams and
   * resParams.
   *
   * The 'this' in this function is the rpc object, thus contains
   * some information of the app.
   *
   * @param {Object} appReqParams The request parameters set from the app,
            with AMOUNT, MESSAGE and CALLBACK and other parameters.
   */
  function open(appReqParams) {
    var frameId = this.f;

    if (!appReqParams ||
        !appReqParams['AMOUNT']) {
      // TODO: Need more check on the AMOUNT value.
      try {
        gadgets.rpc.call(frameId, 'pay-callback', null, appReqParams,
                         {'RESPONSE_CODE': 'MALFORMED_REQUEST'});
      } finally {
        return;
      }
    }

    if (isOpened) {
      // Shouldn't continue if the counter is already opened.
      try {
        gadgets.rpc.call(frameId, 'pay-callback', null, appReqParams,
                         {'RESPONSE_CODE': 'COUNTER_ALREADY_OPENED'});
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

    isOpened = true;
    isCommitted = false;

    // Call the container's open hook to display the counter panel UI.
    if (hooks.open) {
      hooks.open(reqParams, resParams, commit, cancel);
    } else {
      // The open hook is not optional.
      // If not set, then close the counter.
      resParams['RESPONSE_CODE'] = 'COUNTER_NOT_IMPLEMENTED';
      close();
    }
  };

  /**
   * Handles the commit button click event by the user.
   * It calls the commit hook to the pay request to container
   * virtual currency api with Ajax POST.
   */
  function commit() {
    if (!isOpened) {
      return;
    }
    // The committed time is the time when user click the commit button.
    resParams['COMMITTED_TIME'] = new Date().getTime();

    // Call the container's commit hook to actual do the virtual currency
    // change on container backend via Ajax POST.
    // The resParams's RESPONSE_CODE and EXCUTED_TIME will be set in this hook.
    if (hooks.commit) {
      hooks.commit(reqParams, resParams, close);
      isCommitted = true;
    } else {
      // The commit hook is not optional.
      // If not set, then close the counter.
      resParams['RESPONSE_CODE'] = 'COUNTER_NOT_IMPLEMENTED';
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

    resParams['RESPONSE_CODE'] = 'USER_CANCELED';

    // Call the container's cancel hook to do some UI change if needed.
    if (hooks.cancel) {
      hooks.cancel(reqParams, resParams, close);
    } else {
      // The cancel hook is optional.
      // If not set, close the counter directly.
      close();
    }
  };

  /**
   * Closes the counter panel.
   * It hide the counter panel itself in the close hook.
   */
  function close() {
    if (!isOpened) {
      return;
    }

    // Call the container's close hook to hide the counter panel.
    if (hooks.close) {
      hooks.close(reqParams, resParams);
    }
    // The close hook is optional. If not set, do nothing.
    // (NOTE that the panel is still visible if do nothing...)

    isOpened = false;

    try {
      // Call the app back via rpc.
      gadgets.rpc.call(reqParams['FRAME_ID'], 'pay-callback', null,
                       reqParams, resParams);
    } finally {
      reqParams = null;
      resParams = null;
    }
  };

  return /** @scope gadgets.paycounter */ {
    /**
     * Initializes the 'pay' rpc. It's called by container counter page in
     * onload function.
     * @param {Function} openHook The hook function for handling the opening
     *        UI.
     * @param {Function} commitHook The hook function for real interaction
     *        with the container api server.
     * @param {Function} cancelHook The hook function for handling the
     *        cancel action UI.
     * @param {Function} closeHook The hook function for handling the
     *        disposing UI.
     */
    init: function(openHook, commitHook, cancelHook, closeHook) {
      hooks.open = openHook;
      hooks.commit = commitHook;
      hooks.cancel = cancelHook;
      hooks.close = closeHook;
      gadgets.rpc.register('pay', open);
    }
  };

})();
