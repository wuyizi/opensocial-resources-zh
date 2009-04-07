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

var shindig = shindig || {};

shindig.monitor = (function() {

  function log(obj) {
    if (window.console) {
      window.console.log(obj);
    }
  };

  function info(text) {
    if (window.console) {
      window.console.info(text);
    }
  };
  
  function isIE() {
    if (navigator.appName.indexOf('Microsoft') != -1) {
      return true;
    } else {
      return false;
    }
  };
  
  
  function genKey(url, params) {
    return url + params;
  };
  
  var monitors_ = {};
  
  var Monitor = function(gadget) {
    var me = this;
    var ifr = document.getElementById(gadget.getIframeId());
    var win = ifr.contentWindow;
    var done = function() {
      if (isIE()) {
        if (ifr.readyState != 'loaded' && ifr.readyState != 'complete') {
          return; // still loading
        }
        ifr.onreadystatechange = null;
      }
      
      me['iframeReadyTime'] = new Date().getTime();
    };
    if (isIE()) {
      ifr.onreadystatechange = done;
    } else {
      ifr.onload = done;
    }
    
    me['title'] = gadget['title'];
    me['iframeId'] = gadget.getIframeId();
    me['ioTimes'] = {};
    me['ioTemps'] = {};
  };
  
  var IOTime = function(url) {
    this.url = url;
    this.items = [];
    this.addItem = function(timeKey, params, length, isProxied) {
      this.items.push({
        REQUEST_TIME : timeKey['start'],
        RESPONSE_TIME : timeKey['end'],
        METHOD : params.METHOD || 'GET',
        CONTENT_TYPE : params.CONTENT_TYPE || 'TEXT',
        POST_DATA : params.POST_DATA || '',
        AUTHORIZATION : params.AUTHORIZATION || 'NONE',
        LENGTH : length,
        IS_PROXIED : isProxied
      });
    };
  };
  
  return {
    all: monitors_,
  
    init: function() {
      gadgets.rpc.register('shindig.monitor.get', shindig.monitor.get);
      gadgets.rpc.register('shindig.monitor.onAppReady', shindig.monitor.onAppReady);
      gadgets.rpc.register('shindig.monitor.onRequest', shindig.monitor.onRequest);
      gadgets.rpc.register('shindig.monitor.onResponse', shindig.monitor.onResponse);
    },
    
    add: function(gadget) {
      var monitor = new Monitor(gadget);
      monitors_[gadget.getIframeId()] = monitor;
      monitor['startTime'] = new Date().getTime();
    },

    get: function() {
      return monitors_[this.f];
    },
    
    onAppReady: function() {
      var monitor = monitors_[this.f];
      monitor['appReadyTime'] = new Date().getTime();
    },

    onRequest: function(url, params) {
      var timeKey = {};
      timeKey['start'] = new Date().getTime();
      
      var monitor = monitors_[this.f];
      monitor['ioTemps'][timeKey] = url;
      
      params['TIMES_KEY'] = timeKey;
    },

    onResponse: function(url, params, length, isProxied) {
      var timeKey = params['TIMES_KEY'];
      timeKey['end'] = new Date().getTime();
      
      var monitor = monitors_[this.f];
      delete monitor['ioTemps'][timeKey];
      
      monitor['ioTimes'][url] = monitor['ioTimes'][url] || new IOTime(url);
      monitor['ioTimes'][url].addItem(timeKey, params, length, isProxied);
    },
    
    clear: function() {
      for (var ifrId in monitors_) {
        var monitor = monitors_[ifrId];
        monitor['ioTimes'] = {};
        monitor['ioTemps'] = {};
      }
      shindig.monitor.report();
    },
      
    dump: function() {
      for (var ifrId in monitors_) {
        var monitor = monitors_[ifrId];
        info(ifrId + ' - appReady : ' + (monitor['appReadyTime'] - monitor['startTime']));    
        info(ifrId + ' - iframeReady : ' + (monitor['iframeReadyTime'] - monitor['startTime']));
        var ioTimes = monitor['ioTimes'];
        for (var url in ioTimes) {
          var ioTime = ioTimes[url];
          for (var index = 0; index < ioTime.items.length; index++) {
            var item = ioTime.items[index];
            info(ifrId + ' - ' + 
                [item.IS_PROXIED ? 'PROXIED' : 'NON_PROXIED', 
                 item.RESPONSE_TIME - item.REQUEST_TIME,
                 item.LENGTH,
                 item.METHOD,
                 item.CONTENT_TYPE,
                 item.AUTHORIZATION,
                 url,
                 item.POST_DATA, ].join(',\t'));
          }
        }
      }
    },
    
    report: function() {
      var elMain = $('#monitor-report');
      elMain.empty();
      var elAppList = $('<ul class="app-list"></ul>').appendTo(elMain);
      
      var header = $('<li id="report-header">' + 
                       '<div>App Title</div>' +
                       '<ul class="timer-list">' +
                         '<li><div>Timer</div>' +
                           '<ul class="item-list"><li></li></ul>' +
                         '</li>' + 
                       '</ul>' +
                     '</li>').appendTo(elAppList);
      
      header.find('.item-list > li').append('<div>Latency</div>')
                                    .append('<div>Length</div>')
                                    .append('<div>Method</div>')
                                    .append('<div>Content</div>')
                                    .append('<div>Auth</div>')
                                    .append('<div class="long">Url</div>')
                                    .append('<div class="long">PostData</div>');
      
      for (var ifrId in monitors_) {
        var monitor = monitors_[ifrId];
       
        var elApp = $('<li></li>').append('<div>' + monitor['title'] + '</div>')
                                  .appendTo(elAppList);
        
        var elTimerList = $('<ul class="timer-list"></ul>').appendTo(elApp);
        
        var elAppReady = $('<li></li>').append('<div>App Ready</div>').appendTo(elTimerList);
        var appReadyLatency = monitor['appReadyTime'] - monitor['startTime'];
        $('<ul class="item-list"></ul>').append('<li><div>' + appReadyLatency + '</div></li>')
                                        .appendTo(elAppReady);

        var elIfrReady = $('<li></li>').append('<div>Iframe Ready</div>').appendTo(elTimerList);
        var ifrReadyLatency = (monitor['iframeReadyTime'] - monitor['startTime']);
        $('<ul class="item-list"></ul>').append('<li><div>' + ifrReadyLatency + '</div></li>')
                                        .appendTo(elIfrReady);

        var elNpXhr = $('<li></li>').append('<div>NonProxied Xhr</div>').appendTo(elTimerList);
        var elNpXhrList = $('<ul class="item-list"></ul>').appendTo(elNpXhr);
        
        var elPXhr = $('<li></li>').append('<div>Proxied Xhr</div>').appendTo(elTimerList);
        var elPXhrList = $('<ul class="item-list"></ul>').appendTo(elPXhr);
        
        var ioTimes = monitor['ioTimes'];
        for (var url in ioTimes) {
          var ioTime = ioTimes[url];
          for (var index = 0; index < ioTime.items.length; index++) {
            var item = ioTime.items[index];
            var elItem = $('<li></li>').append('<div>' + (item.RESPONSE_TIME - item.REQUEST_TIME) + '</div>')
                                       .append('<div>' + item.LENGTH + '</div>')
                                       .append('<div>' + item.METHOD + '</div>')
                                       .append('<div>' + item.CONTENT_TYPE + '</div>')
                                       .append('<div>' + item.AUTHORIZATION + '</div>')
                                       .append('<div class="long"><a href="' + url + '">' + url + '</a></div>')
                                       .append('<div class="long" title="' + 
                                               gadgets.util.escape(item.POST_DATA) + '">' 
                                               + (item.POST_DATA || '&nbsp;') + '</div>');
            
            if (item.IS_PROXIED) {
              elItem.appendTo(elPXhrList);
            } else {
              elItem.appendTo(elNpXhrList);
            }
          }
        }
      }
    }
  };
})();


