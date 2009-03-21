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

/**
 * @fileoverview A wrapper SDK for opensocial javascript API into actionscript.
 * <p>
 * It works with the Opensocial Actionscript Client SDK lib. In this file, it communicates between
 * swf functions and the gadgets/opensocial javascript API functions.
 * </p>
 * <p>
 * TODO: Provide a compiled version.
 * </p>
 *
 * @see <a href="http://code.google.com/apis/opensocial/docs/0.8/reference/">Opensocial 0.8 Reference</a>
 * @version M3
 * @author yiziwu@google.com (Yizi Wu)
 */

//======================== External Namespace and Flags ==================================
/**
 * @static
 * @namespace External namespace for <code>gadgets</code> for internal reference.
 * @name gadgets
 * @see <a href="http://opensocial-resources.googlecode.com/svn/spec/0.8/gadgets/">Gadgets Spec</a>
 */
var gadgets = window['gadgets'];
if (!gadgets) {
  alert('gadgets.* not found.');
}


/**
 * @static
 * @namespace External namespace for <code>opensocial</code> for internal reference.
 * @name opensocial
 * @see <a href="http://opensocial-resources.googlecode.com/svn/spec/0.8/opensocial/">Opensocial Spec</a>
 */
var opensocial = window['opensocial'];
if (!opensocial) {
  alert('opensocial.* not found.');
  opensocial = {};
}

/**
 * Flag for release version or testing version. Set to true before loading this script to get the
 * testbed object to run the jsunit tests.
 * @static
 * @type {boolean}
 * @ignore
 */
var TESTING = TESTING;

/**
 * Flag for release version or debug version. Set to true to get debug info on firebug console.
 * @static
 * @type {boolean}
 * @ignore
 */
var DEBUG = TESTING || DEBUG;



//======================== Opensocial Flash Namespace ==================================
/**
 * @static
 * @namespace Namespace for top-level api functions.
 * @requires opensocial
 * @requires gadgets
 * @name opensocial.flash
 */
opensocial.flash = (function() {

  //======================== Debugging Tools (private) ===========================================
  /**
   * For debugging, return the object's keys and values.
   * @param {Object?} obj Any object to be looked into.
   * @param {string?} opt_prefix The prefix string of each output line.
   * @param {string?} opt_rendered The rendered string passing between recursions.
   * @return {string?} A tree-style string to represent the object.
   * @private
   */
  var INSPECT = function(obj, opt_prefix, opt_rendered) {
    if (!opt_rendered) opt_rendered = '\n';
    if (!opt_prefix) opt_prefix = '';
    if (obj == null) return opt_rendered || "";
    for (var k in obj) {
      opt_rendered +=
          (opt_prefix + k + '[' + (typeof obj[k]) + '] : ' + obj[k] + '\n');
      if ((typeof obj[k]) == 'object') {
        opt_rendered = INSPECT(obj[k], opt_prefix + '\t', opt_rendered);
      }
    }
    return opt_rendered || "";
  };

  /**
   * For debugging, export the local variables to global.
   * Only available when DEBUG = true.
   * @param {string} name The nathis.
   * @param {Object?} value The value.
   * @private
   */
  var EXPORT = function(name, value) {
    if (DEBUG && opensocial.flash) {
      opensocial.flash['export'] = opensocial.flash['export'] || {};
      opensocial.flash['export'][name] = value;
    }
  };

  /**
   * For debugging, output text information to firebug console.
   * Only available when DEBUG = true.
   * @param {Object?} content The content to be logged.
   * @private
   */
  var INFO = function(content) {
    if (DEBUG && window.console) {
      window.console.info(content);
    }
  };

  /**
   * For debugging, log the object to firebug console.
   * Only available when DEBUG = true.
   * @param {Object?} content The content to be logged.
   * @private
   */
  var LOG = function(content) {
    if (DEBUG && window.console) {
      window.console.log(content);
    }
  };

  // Export these debugging functions for shortcuts
  if (DEBUG) {
    window["INFO"] = INFO;
    window["LOG"] = LOG;
    window["INSPECT"] = INSPECT;
    window["EXPORT"] = EXPORT;
  }


  //======================== Kernel Object (private) =============================================

  /**
   * The underlying object holds all variables and functions for the opensocial.flash module.
   * @type {Object}
   * @private
   */
  var kernel = function() {

    /**
     * Alias for 'this' to avoid misusing the 'this' reference in difference scopes or closures.
     * @type {Object}
     * @private;
     */
    var me = this;


    //======================== Flash Embeded Object Varibles (private) ===========================
    /**
     * The flash movie object which apply this API.
     * This object is initialized in <code>opensocial.flash.jsReady</code> function.
     * @type {HTMLElement}
     * @private
     */
    me.swfObj;

    /**
     * The default flash id embeded in container.
     * @type {string}
     * @constant
     * @private
     */
    me.DEFAULT_FLASH_ID = "flashObj";


    //======================== Common Utilities Helper Functions (private) =========================
    /**
     * Returns the document object.
     * @return {HTMLDocument} the document object of current context.
     * @private
     */
    me.thisDoc = function() {
      return document;
    };

    /**
     * Returns the window object.
     * @return {Window} the window object of current context.
     * @private
     */
    me.thisWin = function() {
      return window;
    };

    /**
     * Returns the navigator object.
     * @return {Navigator} the navigator object of current context.
     * @private
     */
    me.thisBrowser = function() {
      return navigator;
    };

    /**
     * Gets the swf object.
     * @param {string?} opt_name The object/embed tag's id or name
     * @return {HTMLElement} the swf object.
     * @private
     */
    me.thisMovie = function(opt_name) {
      opt_name = opt_name || me.DEFAULT_FLASH_ID;
      if ((me.thisBrowser()).appName.indexOf('Microsoft') != -1) {
        return me.thisDoc()[opt_name];
      } else {
        return me.thisDoc().getElementById(opt_name);
      }
    };

    /**
     * Checks if the object is an array.
     * @param {Object} obj object to be check.
     * @return {boolean} True if the object is an array.
     * @private
     */
    me.isArray = function(obj) {
      if (!obj) return false;
      if (Array) {
        return obj instanceof Array;
      } else {
        if ((typeof obj == 'object') &&
            (typeof obj.length == 'number') &&
            (typeof obj.splice != 'undefined')) {
          return true;
        } else {
          return false;
        }
      }
    };

    /**
     * Iterates an array, calls the function for each item.
     * @param {Array} array The array to be iterated.
     * @param {Function} f The function to be applied.
     * @param {Object} opt_thisObj The this object for the function.
     * @private
     */
    me.forEach = function(array, f, opt_thisObj) {
      if (typeof array.length != 'number') {
        return;
      }
      var l = array.length;
      for (var i = 0; i < l; i++) {
        if (i in array) {
          if (false == f.call(opt_thisObj, array[i], i, array)) {
            break;
          };
        }
      }
    };


    /**
     * Deeply clones an non-native object.
     * @param {Object?} obj The original object.
     * @return {Object?} The cloned object.
     * @private
     */
    me.clone = function(obj) {
      if(obj == null) return null;
      switch (typeof obj){
        case 'function':
          return obj;
        case 'object':
          var newObj = new obj.constructor();
          for(var key in obj) newObj[key] = me.clone(obj[key]);
          return newObj;
        default:
          return obj.valueOf();
      }
    };

    //======================== Opensocial Data Helper Functions (private) ==========================
    /**
     * Gets data object from resoponse.
     * @param {opensocial.DataResponse} dataResponse The response object.
     * @param {string} key The data key in the response object.
     * @throws {Error} When the RPC meets error.
     * @return {Object?} The data, can be any instance of the opensocial.* data type.
     * @private
     */
    me.getData = function(dataResponse, key) {
      // for debug
      EXPORT('DATA_RESPONSE', {'key': key, 'data': dataResponse});

      if (!dataResponse) return null;
      if (dataResponse.hadError()) {
        var e = new Error(dataResponse.getErrorMessage());
        e['name'] = "OpensocialError";
        throw e;
      }
      if (!key) return null;

      return me.getDataItem(dataResponse.get(key));
    };

    /**
     * Gets data object from response item.
     * @param {opensocial.ResponseItem} responseItem The response item object.
     * @throws {Error} When the items have errors.
     * @return {Object?} The data, can be any instance of the opensocial.* data type.
     * @private
     */
    me.getDataItem = function(responseItem) {
      if (!responseItem) return null;
      if (responseItem.hadError()) {
        var e = new Error(responseItem.getErrorMessage());
        e['name'] = "OpensocialError";
        e['code'] = responseItem.getErrorCode();
        throw e;
      }
      return responseItem.getData();
    };

    me.dataTypes = ['Address', 'BodyType', 'Email', 'Name', 'Organization', 'Phone', 'Url',
        'Enum', 'Person', 'Activity', 'IdSpec', 'MediaItem', 'Message', 'NavigationParameters',
        'Collection'];
    /**
     * Gets the constructor function for opensocial data object.
     * @param {Object} dataObj The object to be checked.
     * @return {Function?} The type of the object.
     * @private
     */
    me.checkType = function(dataObj) {
      if (!dataObj) return null;
      var type = null;
      me.forEach(me.dataTypes, function(typeItem) {
        if (typeItem in opensocial && dataObj instanceof opensocial[typeItem]) {
          type = opensocial[typeItem];
          return false;
        }
      });
      return type;
    };

    /**
     * Wraps the opensocial rich object (with functions) to a JSON-like flat serializable object.
     * So the object can pass through the <code>ExternalInterface</code> to the swf.
     * @param {Object} dataObj The object to be wrapped.
     * @param {Object?} opt_this The flat object as a container to hold the wrapped fields.
     * @return {Object?} A wrapped flat object, ready to pass to swf.
     * @private
     */
    me.wrapObject = function(dataObj, opt_this) {
      if (dataObj == null) return null;

      var type = me.checkType(dataObj);

      if (type == null) {
        // treat it as string
        return dataObj;
      }

      // fix fields
      opt_this = opt_this || {};

      if ('Field' in type) {
        opt_this['fields'] = opt_this['fields'] || {};

        // Grabs the fields data from each structures recursively.
        for (var k in type.Field) {
          var key = type.Field[k];
          var value = dataObj.getField(key);
          if (value != null) {
            if (me.isArray(value)) {
              opt_this['fields'][key] = [];
              me.forEach(value, function(item) {
                opt_this['fields'][key].push(me.wrapObject(item));
              });
            } else {
              opt_this['fields'][key] = me.wrapObject(value);
            }
          }
        }
      }

      // fix properties.
      if (type == opensocial.Person) {
        opt_this['displayName'] = dataObj.getDisplayName();
        opt_this['isOwner'] = dataObj.isOwner();
        opt_this['isViewer'] = dataObj.isViewer();
        opt_this['id'] = dataObj.getId();

      } else if (type == opensocial.Activity) {
        opt_this['id'] = dataObj.getId();

      } else if (type == opensocial.Enum) {
        opt_this['key'] = dataObj.getKey();
        opt_this['displayValue'] = dataObj.getDisplayValue();

      } else if (type == opensocial.Collection) {
        opt_this['size'] = dataObj.size();
        opt_this['offset'] = dataObj.getOffset();
        opt_this['totalSize'] = dataObj.getTotalSize();

        var array = dataObj.asArray();
        opt_this['array'] = [];
        me.forEach(array, function(item) {
          opt_this['array'].push(me.wrapObject(item));
        });

      }
      return opt_this || {};
    };

    /**
     * Unwraps the flattened object to a rich opensocial data object. The flattened object is come
     * from the swf via <code>ExternalInterface</code>.
     * @param {Object} obj The object to be unwrapped. Only those 5 types with <code>setField</code>
     *                 method and <code>opensocial.newXXXX</code> creator can be unwrapped.
     * @param {Function} type The object's target type to be unwrapped.
     * @throws {Error} When the type is not correct.
     * @return {Object} Unwrapped rich opensocial data object, ready to use in javascript.
     * @private
     */
    me.unwrapObject = function(obj, type) {
      if (obj && 'fields' in obj) {
        var fields = obj['fields'];

        if (type == opensocial.IdSpec) {
          return opensocial.newIdSpec(fields);

        } else if (type == opensocial.NavigationParameters) {
          return opensocial.newNavigationParameters(fields);

        } else if (type == opensocial.MediaItem) {
          return opensocial.newMediaItem(fields[opensocial.MediaItem.Field.MIME_TYPE],
                                         fields[opensocial.MediaItem.Field.URL],
                                         fields);

        } else if (type == opensocial.Message) {
          return opensocial.newMessage(fields[opensocial.Message.Field.BODY],
                                       fields);

        } else if (type == opensocial.Activity) {
          var flatItems = fields[opensocial.Activity.Field.MEDIA_ITEMS];
          if (me.isArray(flatItems)) {
            var richItems = [];
            me.forEach(flatItems, function(item) {
              richItems.push(me.unwrapObject(item, opensocial.MediaItem));
            });
            fields[opensocial.Activity.Field.MEDIA_ITEMS] = richItems;
          }
          return opensocial.newActivity(fields);
        }

      }
      // If reaches here, codes are wrong.
      var e = new Error('The object does not has fields values or type mismatched.');
      e['name'] = "OpensocialError";
      throw e;
    };

    /**
     * When any data request error happens, log down the error and callback to swf.
     * @param {string} reqID The request ID.
     * @param {Error} error The error thrown during the response.
     * @private
     */
    me.handleError = function(reqID, error) {
      INFO(error);
      me.swfObj.handleError(reqID, error);
    };

    /**
     * When any data request error happens, log down the error and callback to swf.
     * @param {string} reqID The request ID.
     * @param {Object?} opt_data Some data to pass back
     * @private
     */
    me.handleAsync = function(reqID, opt_data) {
      var args = [];
      me.forEach(arguments, function(arg) {
        args.push(arg);
      });
      me.swfObj.handleAsync.apply(me.swfObj, args);
    };
    
    
    //======================== Opensocial Rpc Helper Functions (private) ==========================
    
    /**
     * Stores the running rpc instances.
     * @private
     */
    me.rpcStore = {};
    
    /**
     * Pushes the running rpc instance to the store and returns an unique callID. It is used by
     * asynchronous rpc register service.
     * @param {Object} rpc The rpc instance defined in <code>gadgets.rpc</code>.
     * @return {string} The callID.
     * @private
     */
    me.pushRpc = function(rpc) {
      var callID = String(rpc.s) + '_' + String(rpc.c);  // 'your-service-name_#'
      me.rpcStore[callID] = rpc;
      return callID;
    };
    
    /**
     * Pops the running rpc instance from the store with the callID. It is used by
     * asynchronous rpc register service.
     * @param {string} callID The callID of the rpc instance to be popped and removed.
     * @return {Object} The rpc instance defined in <code>gadgets.rpc</code>.
     * @private
     */
    me.popRpc = function(callID) {
      var rpc = me.rpcStore[callID];
      delete me.rpcStore[callID];
      return rpc;
    };



    //======================== Public API functions ================================================

    me.api = /** @scope opensocial.flash */ {

      //======================== Flash Embeded Object Functions ====================================
      /**
       * Indicates if the opensocial library is loaded and initialize the flash element.
       * <p>
       * The objectId of the swf is defined in gagdet spec. If the swf is embeded by calling
       * <code>opensocial.flash.embedFlash</code> function, the detault objectId will be 'flashObj'.
       * </p><p>
       * This function is called by the swf's <code>ExternalInterface</code> continuingly until it
       * returns true.
       * </p>
       *
       * @param {string?} objectId The object Id passed from the swf.
       * @return {boolean} true if all javascripts are loaded.
       *
       * @member opensocial.flash
       */
      jsReady : function(objectId) {
        try {
          if (!me.swfObj) {
            me.swfObj = me.thisMovie(objectId);
          }
          return !!me.swfObj;
        } catch (e) {
          INFO(e);
          return false;
        }
      },

      /**
       * Because <code>gadgets.flash.embedFlash</code> cannot auto activate it in IE6, so here we
       * need a special one.
       * <p>
       * NOTE: to be deprecated.
       * </p>
       *
       * @requires gadgets.flash
       *
       * @param {string} swfUrl  The swf file's location.
       * @param {string} swfContainer  The HTML element id.
       * @param {string?} opt_playerVersion Required flash player version.
       * @param {Object.<string, string>?} opt_params Flash object's parameters.
       * @param {string?} opt_upgradeMsgHTML The message if the flashplayer version is too old.
       * @return {boolean} True if the flash object is successfully embeded.
       *
       * @member opensocial.flash
       */
      embedFlash : function(swfUrl, swfContainer,
                            opt_playerVersion, opt_params, opt_upgradeMsgHTML) {

        opt_params = opt_params || {};

        // Check container element
        var container = me.thisDoc().getElementById(swfContainer);
        if (!container) return false;

        // Check version
        var version = opt_playerVersion.match(/(\d+)(?=[\.,]?)/g);
        var expectMajorVer = (version != null ? Number(version[0]) : 9);

        EXPORT("PLAYER_CURRENT_VER", gadgets.flash.getMajorVersion());
        EXPORT("PLAYER_EXPECED_VER", expectMajorVer);

        if (gadgets.flash.getMajorVersion() < expectMajorVer) {
          opt_upgradeMsgHTML = opt_upgradeMsgHTML ||
              '<span style="font-size:small;color:#777;"> ' +
              'Please install or upgrade to ' +
              '<a href="http://www.adobe.com/cn/products/flashplayer/" ' +
              'style="color:#36C;" target="_blank">Flash Player 9.0</a>.</span>';
          container.innerHTML = opt_upgradeMsgHTML;
          return false;
        };

        /*
        opt_params['id'] = me.DEFAULT_FLASH_ID;
        opt_params['name'] = me.DEFAULT_FLASH_ID;
        return gadgets.flash.embedFlash(swfUrl, container, version, opt_params);
        */
        // Generate the flash object element
        var html = "";
        if (me.thisBrowser().plugins &&
            me.thisBrowser().mimeTypes &&
            me.thisBrowser().mimeTypes.length) {
          // netscape plugin architecture
          html = '<embed src="'+ swfUrl +
                 '" id="' + me.DEFAULT_FLASH_ID +
                 '" name="' + me.DEFAULT_FLASH_ID +
                 '" type="application/x-shockwave-flash"';
          for(var key in opt_params){
            html += key +'="'+ opt_params[key] +'" ';
          }
          html += '/>';
        } else {
          // PC IE
          html = '<object id="' + me.DEFAULT_FLASH_ID +
                 '" classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000"';
          var params = '<param name="movie" value="'+ swfUrl +'" />';
          for(var key in opt_params) {
            if (key == 'width' || key == 'height') {
              html += ' ' + key + '="' + opt_params[key] + '"';
            } else {
              params += '<param name="'+ key +'" value="'+ opt_params[key] +'" />';
            }
          }
          html += '>' + params + "</object>";
        }
        container.innerHTML = html;

        return true;

      },

      /**
       * Get the swf object.
       * @param {string?} opt_name The object/embed tag's id or name
       * @return {HTMLElement} the swf object.
       * @member opensocial.flash
       */
      getFlash : function(opt_name) {
        return me.thisMovie(opt_name);
      },

      //======================== Environment Wrapped Accessors ===========================
      
      /**
       * Check if the field is supported in the object type.
       * @param {opensocial.Environment.ObjectType | string} objectType The enum name of the type.
       * @param {string} The enum name of the field, defined in opensocial.XXXX.Field enums.
       * @return {boolean} True if supported.
       */
      supportsField : function(objectType, field) {
        return opensocial.getEnvironment().supportsField(objectType, field);
      },

      /**
       * Returns the domain from environment instance.
       * @return {string} The domain
       * @member opensocial.flash 
       */
      getDomain : function() {
        return opensocial.getEnvironment().getDomain();
      },

      /**
       * Returns the domain from the referer.
       * @return {string} The domain.
       * @member opensocial.flash
       */
      getContainerDomain : function() {
        var pattern = /(\w+):\/\/([\w.]+)(:\d+)?\/(\S*)/;
        var result = me.thisDoc().referrer.match(pattern);
        return result == null ? '' : result[2];
      },

      /**
       * Returns the name of the in gadgets.views static class.
       * @requires gadgets.views
       * @return {gadgets.views.ViewType | string} The view name.
       * @member opensocial.flash
       */
      getCurrentView : function() {
        if (gadgets && gadgets.views) {
          return gadgets.views.getCurrentView().getName();
        } else {
          return null;
        }
      },

      /**
       * Returns the parameters passed into this gadget for this view.
       * @requires gadgets.views
       * @return {Object.<string, string>} The param object.
       * @member opensocial.flash
       */
      getViewParams : function() {
        if (gadgets && gadgets.views) {
          return gadgets.views.getParams();
        } else {
          return null;
        }
      },

      /**
       * Indicates if the app is only one gadget on the page or not.
       * @requires gadget.views
       * @return {Boolean} True if it's the only one gadget.
       * @member opensocial.flash
       */
      isOnlyVisible : function() {
        if (gadgets && gadgets.views) {
          return gadgets.views.getCurrentView().isOnlyVisibleGadget();
        } else {
          return true;
        }
      },

      /**
       * Sets the width for the flash stage. It is very usefull for dynamic loading and view
       * switching.
       * @param {number} newWidth New width (in pixel) to be applied.
       * @member opensocial.flash
       */
      setStageWidth : function(newWidth) {
        if (me.swfObj.width != newWidth) {
          me.swfObj.width = newWidth;
        }
      },


      /**
       * Sets the height for the flash stage. It is very usefull for dynamic loading and view
       * switching.
       * @requires gadgets.window
       * @param {number} newHeight New height (in pixel) to be applied.
       * @member opensocial.flash
       */
      setStageHeight : function(newHeight) {
        if (me.swfObj.height != newHeight) {
          me.swfObj.height = newHeight;
          if (gadgets && gadgets.window && gadgets.window.adjustHeight) {
            gadgets.window.adjustHeight(newHeight);
          }
        }
      },
      
      /**
       * Sets the title of this app.
       * @requires gadgets.window
       * @param {string} newTitle New title to be applied.
       * @member opensocial.flash
       */
      setTitle: function(newTitle) {
        if (gadgets && gadgets.window && gadgets.window.setTitle) {
          gadgets.window.setTitle(newTitle);
        }
      },

      //======================== Opensocial Data RPCs ===========================
      /**
       * Sends out the request for a person.
       *
       * @param {string} reqID The request id.
       * @param {opensocial.IdSpec.PersonId | string} id OWNER or VIEWER.
       * @param {Object.<opensocial.DataRequest.PeopleRequestField, Object>} opt_params
       *            A map of <code>opensocial.DataRequest.PeopleRequestField</code> names and values.
       * @member opensocial.flash
       */
      fetchPerson : function(reqID, id, opt_params) {
        var req = opensocial.newDataRequest();
        req.add(req.newFetchPersonRequest(id, opt_params), 'p');
        req.send(function(dataResponse) {
          try {
            var person = me.wrapObject(me.getData(dataResponse, 'p'));
            me.handleAsync(reqID, person);
          } catch (e) {
            me.handleError(reqID, e);
          }
        });
      },

      /**
       * Sends out the request for friends of a person.
       *
       * @param {string} reqID The request id.
       * @param {Object} idSpec A wrapped <code>opensocial.IdSpec</code> object.
       * @param {Object.<opensocial.DataRequest.PeopleRequestField, Object>} opt_params
       *            A map of <code>opensocial.DataRequest.PeopleRequestField</code> names and values.
       * @member opensocial.flash
       */
      fetchPeople : function(reqID, idSpec, opt_params) {
        idSpec = me.unwrapObject(idSpec, opensocial.IdSpec);
        var req = opensocial.newDataRequest();
        req.add(req.newFetchPeopleRequest(idSpec, opt_params), 'f');
        req.send(function(dataResponse) {
          try {
            var people = me.wrapObject(me.getData(dataResponse, 'f'));
            me.handleAsync(reqID, people);
          } catch (e) {
            me.handleError(reqID, e);
          }
        });
      },

      /**
       * Sends out the request for personal app data.
       *
       * @param {string} reqID The request id.
       * @param {Object} idSpec A wrapped <code>opensocial.IdSpec</code> object.
       * @param {Array.<string>} keys App keys, '*' for all.
       * @param {Object.<opensocial.DataRequest.DataRequestField, Object>?} opt_params
       *            A map of <code>opensocial.DataRequest.DataRequestField</code> names and values.
       * @member opensocial.flash
       */
      fetchPersonAppData : function(reqID, idSpec, keys, opt_params) {
        idSpec = me.unwrapObject(idSpec, opensocial.IdSpec);
        var req = opensocial.newDataRequest();
        req.add(req.newFetchPersonAppDataRequest(idSpec, keys, opt_params), 'd');
        req.send(function(dataResponse) {
          try {
            var dataSet = me.getData(dataResponse, 'd');
            //dataSet is a Object.<opensocial.IdSpec.PersonId, Object.<string, Object>> object.
            me.handleAsync(reqID, dataSet);
          } catch (e) {
            me.handleError(reqID, e);
          }
        });
      },


      /**
       * Sends out the update request for personal app data.
       *
       * @param {string} reqID The request id.
       * @param {opensocial.IdSpec.PersonId | string} id only VIEWER is valid
       * @param {string} key A data key.
       * @param {Object} value New value.
       * @member opensocial.flash
       */
      updatePersonAppData : function(reqID, id, key, value) {
        var req = opensocial.newDataRequest();
        req.add(req.newUpdatePersonAppDataRequest(id, key, value), 'u');
        req.send(function(dataResponse) {
          try {
            me.getData(dataResponse, 'u');
            me.handleAsync(reqID);
          } catch (e) {
            me.handleError(reqID, e);
          }
        });
      },


      /**
       * Sends out the remove request for personal app data.
       *
       * @param {string} reqID The request id.
       * @param {opensocial.IdSpec.PersonId | string} id only VIEWER is valid
       * @param {Array.<string>} keys App keys, '*' for all.
       * @member opensocial.flash
       */
      removePersonAppData : function(reqID, id, keys) {
        var req = opensocial.newDataRequest();
        req.add(req.newRemovePersonAppDataRequest(id, keys), 'r');
        req.send(function(dataResponse) {
          try {
            me.getData(dataResponse, 'r');
            me.handleAsync(reqID);
          } catch (e) {
            me.handleError(reqID, e);
          }
        });
      },

      /**
       * Sends out the request for personal activities.
       *
       * @param {string} reqID The request id.
       * @param {Object} idSpec A wrapped <code>opensocial.IdSpec</code> object.
       * @param {Object.<opensocial.DataRequest.ActivityRequestField, Object>?} opt_params
       *            A map of <code>opensocial.DataRequest.ActivityRequestField</code> names and
       *            values.
       * @member opensocial.flash
       */
      fetchActivities : function(reqID, idSpec, opt_params) {
        idSpec = me.unwrapObject(idSpec, opensocial.IdSpec);
        var req = opensocial.newDataRequest();
        req.add(req.newFetchActivitiesRequest(idSpec, opt_params), 'a');
        req.send(function(dataResponse) {
          try {
            var activities = me.wrapObject(me.getData(dataResponse, 'a'));
            me.handleAsync(reqID, activities);
          } catch (e) {
            me.handleError(reqID, e);
          }
        });
      },

      /**
       * Sends out the request to creat an activity.
       *
       * @param {string} reqID The request id.
       * @param {Object} activity A wrapped <code>opensocial.Activity</code> object.
       * @param {opensocial.CreateActivityPriority | string} priority
       *            An <code>opensocial.CreateActivityPriority</code> value.
       * @member opensocial.flash
       */
      requestCreateActivity : function(reqID, activity, priority) {
        activity = me.unwrapObject(activity, opensocial.Activity);
        opensocial.requestCreateActivity(activity, priority, function(responseItem) {
          try {
            me.getDataItem(responseItem);
            me.handleAsync(reqID);
          } catch (e) {
            me.handleError(reqID, e);
          }
        });
      },

      /**
       * Sends out the request to send a message.
       * <p>TODO: <code>opensocial.NavigationParameters opt_params</code> is not implemented.</p>
       *
       * @param {string} reqID The request id.
       * @param {Array.<string>} recipients An ID, array of IDs, or a group reference, like
       *            VIEWER, OWNER, VIEWER_FRIENDS, OWNER_FRIENDS.
       * @param {Object} message A wrapped <code>opensocial.Message</code> object.
       * @member opensocial.flash
       */
      requestSendMessage : function(reqID, recipients, message) {
        message = me.unwrapObject(message, opensocial.Message);
        opensocial.requestSendMessage(recipients, message, function(responseItem) {
          try {
            me.getDataItem(responseItem);
            me.handleAsync(reqID);
          } catch (e) {
            me.handleError(reqID, e);
          }
        });
      },

      /**
       * Sends out the request to share the app.
       * <p>TODO: <code>opensocial.NavigationParameters opt_params</code> is not implemented.</p>
       *
       * @param {string} reqID The request id.
       * @param {Array.<string>} recipients An ID, array of IDs, or a group reference, like
       *            VIEWER, OWNER, VIEWER_FRIENDS, OWNER_FRIENDS.
       * @param {Object} reason A wrapped <code>opensocial.Message</code> object.
       * @member opensocial.flash
       */
      requestShareApp : function(reqID, recipients, reason) {
        reason = me.unwrapObject(reason, opensocial.Message);
        opensocial.requestShareApp(recipients, reason, function(responseItem) {
          try {
            me.getDataItem(responseItem);
            me.handleAsync(reqID);
          } catch (e) {
            me.handleError(reqID, e);
          }
        });
      },

      /**
       * Sends out the request permissions.
       *
       * @param {string} reqID The request id.
       * @param {Array.<opensocial.Permission | string>} permissions An array of
       *            <code>opensocial.Permission</code> values.
       * @param {string} reason Text of the reason to request the permissions.
       * @member opensocial.flash
       */
      requestPermission : function(reqID, permissions, reason) {
        opensocial.requestPermission(permissions, reason, function(responseItem) {
          try {
            me.getDataItem(responseItem);
            me.handleAsync(reqID);
          } catch (e) {
            me.handleError(reqID, e);
          }
        });
      },

      /**
       * Sends request to a remote site to get or post data.
       *
       * @param {string} reqID The request id.
       * @param {string} url The remote site
       * @param {Object.<gadgets.io.RequestParameters, Object>?} opt_params
       *            Parameters for the request
       * @member opensocial.flash
       */
      makeRequest : function(reqID, url, opt_params) {
        opt_params = opt_params || {}
        var postData = opt_params[gadgets.io.RequestParameters.POST_DATA];
        if (postData) {
          opt_params[gadgets.io.RequestParameters.POST_DATA] = gadgets.io.encodeValues(postData);
        }
        gadgets.io.makeRequest(url, function(obj) {
          try {
            if (obj['error'] || obj['rc'] != 200) {
              var err = new Error(obj['text']);
              err['name'] = 'OpensocialError';
              throw err;
            }
            me.handleAsync(reqID, obj.data);
          } catch (e) {
            me.handleError(reqID, e);
          }
        }, opt_params);
      },

      /**
       * Sends the rpc call request to a service on another app or container on the page.
       *
       * @param {string} reqID The request id.
       * @param {string?} targetId The target app id, null to call the parent.
       * @param {string} serviceName The service name registered on the target.
       * @param {Array.<Object>?} argsArray The array of args to be passed to the service.
       * @member opensocial.flash
       */
      callRpc : function(reqID, targetId, serviceName, argsArray) {
        var reqArgs = [targetId, serviceName, function() {
          if (arguments.length > 0) {
            me.handleAsync(reqID, arguments[0]);
          } else {
            me.handleAsync(reqID);
          }
        }];
        if (argsArray) {
          me.forEach(argsArray, function(arg) {
            reqArgs.push(arg);
          });
        }
        gadgets.rpc.call.apply(null, reqArgs);
      },

      /**
       * Sends the return value to to last received rpc service back to the caller app. Only 
       * callback if the returnValue is available.
       * @param {string} callID The call id for the rpc called by the caller app.
       * @param {Object?} opt_returnValue The return value of the rpc service. 
       */
      returnRpcService : function(callID, opt_returnValue) {
        var rpc = me.popRpc(callID);
        if (opt_returnValue != null) {
          rpc.callback(opt_returnValue);
        }
      },

      /**
       * Sends the rpc register request to container to register a service on this app.
       *
       * @param {string} serviceName The service to be register.
       * @param {string} handlerName The handler function name on the flash object.
       * @member opensocial.flash
       */
      registerRpcService : function(serviceName, handlerName) {
        var handler = function() {
          try {
            var callID = me.pushRpc(this);
            var args = [callID];
            me.forEach(arguments, function(arg) {
              args.push(arg);
            });
            me.swfObj[handlerName].apply(me.swfObj, args);
            // no return here, call rpcReturn in flash to return the result.
          } catch(e) {
            me.handleError(null, e);
            return null;
          }
        };
        
        if (serviceName == null) {
          gadgets.rpc.registerDefault(handler);
        } else {
          gadgets.rpc.register(serviceName, handler);
        }
      },

      /**
       * Sends the rpc unregister request to container.
       *
       * @param {string} serviceName The service to be unregister.
       * @member opensocial.flash
       */
      unregisterRpcService : function(serviceName) {
        if (serviceName == null) {
          gadgets.rpc.unregisterDefault();
        } else {
          gadgets.rpc.unregister(serviceName);
        }
      }


    };


    if (TESTING) {
      /**
       * Only visible when testing. It exports the kernel object constructor to public.
       * @type {Function} the kernel constructor.
       * @ignore
       */
      me.api.kernel = kernel;
    }
  };

  // The public API functions set
  return new kernel().api;

})();

