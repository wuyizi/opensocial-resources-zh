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
 * @fileoverview Unitests of OACS javascript codes. Run it with jsunit and TestPage-JsUnit.html
 * @version M3
 * @author yiziwu@google.com (Yizi Wu)
 */

// ======================== Helper variables and functions for uniitests ===========================
var mockKernel;
var mockApi;
var backupGadgets;
var backupOpensocial;

var checkPoints = (function() {
  var map = {};
  return {
    reset : function() {
      map = {};
      return checkPoints;
    },
    expect : function(name, num) {
      map[name] = num;
      return checkPoints;
    },
    check : function(name) {
      assertNotUndefined('ASSERT checkpoint name defined', map[name]);
      map[name] = map[name] - 1;
      return checkPoints;
    },
    verify : function() {
      for (var name in map) {
        assertEquals('ASSERT check point [' + name + '] cleared', 0, map[name]);
      }
      return checkPoints;
    }
  };
})();


function getTestBed() {
  return document.getElementById('testBed');
};

function checkError(e, callback) {
  if (e['name'] == 'OpensocialError') {
    callback();
  } else {
    throw e;
  }
};

function mockFunc(opt_value) {
  return function(opt_rtValue) {return opt_value || opt_rtValue || {};};
};


function mockVoidFunc() {
  return function() {};
};


function mockNullFunc() {
  return function() {return null;};
};


function mockErrorFunc(message) {
  message = message || 'Mock Error';
  return function() {var e = new Error(message); e['name'] = "OpensocialMockError"; throw e};
};


function mockReqAddFunc(expectReqObject, expectKey) {
  return function(req, key) {
    assertObjectEquals('ASSERT req object as expected', expectReqObject, req);
    assertObjectEquals('ASSERT req key as expected', expectKey, key);
  };
};


function mockReqSendFunc() {
  return function(callback) {
    assertTrue('ASSERT callback is Function', callback instanceof Function);
    callback();
  };
};


function mockUnwrapFunc(expectRawObject, expectType, returnVal) {
  return function(rawObject, type) {
    assertObjectEquals('ASSERT raw object as expected', expectRawObject, rawObject);
    assertEquals('ASSERT type as expected', expectType, type);
    return returnVal;
  }
};


function setUp() {
  assertNotNull('ASSERT gadgets is not null', gadgets);
  assertNotNull('ASSERT opensocial is not null',opensocial);
  mockKernel = new opensocial.flash.kernel();
  mockApi = mockKernel.api;
  backupGadgets = mockKernel.clone(gadgets);
  backupOpensocial = mockKernel.clone(opensocial);
  checkPoints.reset();
  getTestBed().innerHTML = "";
};


function tearDown() {
  delete mockKernel;
  delete mockApi;
  gadgets = backupGadgets;
  opensocial = backupOpensocial;
  checkPoints.verify();
};


// ================================ Unittests for public methods ===================================

function testJsReady() {
  var swfObjFunc;
  mockKernel.thisMovie = function(objectId) {
    assertEquals('ASSERT objectId as expected', 'someObjectId', objectId);
    return swfObjFunc();
  };
  
  var returnValue;
  mockKernel.swfObj = null;
  swfObjFunc = mockFunc();
  returnValue = mockApi.jsReady('someObjectId');
  assertTrue('ASSERT jsReady is true', returnValue);
  
  mockKernel.swfObj = null;
  swfObjFunc = mockNullFunc();
  returnValue = mockApi.jsReady('someObjectId');
  assertFalse('ASSERT jsReady is false', returnValue);
  
  mockKernel.swfObj = null;
  swfObjFunc = mockErrorFunc('Simulated error in testJsReady');
  returnValue = mockApi.jsReady('someObjectId');
  assertFalse('ASSERT jsReady throws error', returnValue);
};


function testEmbedFlash() {
  // TODO
};


function testGetFlash() {
  mockKernel.thisMovie = function(opt_name) {
    assertEquals('ASSERT opt_name as expected', 'someName', opt_name);
  };
  mockApi.getFlash('someName');
};


function testEnvironment() {
  opensocial.getEnvironment = function() {
    var env = new opensocial.Environment();
    env.getDomain = function() {
      return 'some.domain.com';
    };
    env.supportsField = function(objectType, field) {
      assertEquals('someObjectType', objectType);
      if (field == 'someSupportedField') {
        return true;
      } else {
        return false;
      }
    };
    return env;
  };
  assertEquals('some.domain.com', mockApi.getDomain());
  assertEquals(true, mockApi.supportsField('someObjectType', 'someSupportedField'));
  assertEquals(false, mockApi.supportsField('someObjectType', 'someRandomField'));
};


function testGetContainerDomain() {
  mockKernel.thisDoc = function() {
    return {'referrer': 'http://some.domain.com:1234/somePage?someUserId=someId&somaAppId=someId'};
  };
  assertEquals('ASSERT domain extraction', 'some.domain.com', mockApi.getContainerDomain());
};


function testViews() {
  assertNotNull('ASSERT gadgets.views not null', gadgets.views);
  
  var someParams = {'view' : 'profile', 'someKey' : 'someValue'};
  
  gadgets.views.getCurrentView = function() {
    var view = new gadgets.views.View();
    view.getName = function() {return gadgets.views.ViewType.CANVAS;};
    view.isOnlyVisibleGadget = function() {return true;};
    return view;
  };
  gadgets.views.getParams = function() {
    return someParams;
  };

  assertEquals('ASSERT currentView as expected',
               gadgets.views.ViewType.CANVAS, mockApi.getCurrentView());
  
  assertEquals('ASSERT isOnlyVisible as expected', true, mockApi.isOnlyVisible());
  assertObjectEquals('ASSERT viewParams as expected', someParams, mockApi.getViewParams());
};


function testSetStageWidth() {
  mockKernel.swfObj = {'width' : '600'};
  mockApi.setStageWidth('500');
  assertEquals('ASSERT result width as expected', '500', mockKernel.swfObj.width);
};


function testSetStageHeight() {
  assertNotNull('ASSERT gadgets.window not null', gadgets.window);
  checkPoints.expect('req', 1);
  
  gadgets.window.adjustHeight = function(newHeight) {
    assertEquals('ASSERT adjustHeight is called as expected', '500', newHeight);
    checkPoints.check('req');
  };
  mockKernel.swfObj = {'height' : '600'};
  mockApi.setStageHeight('500');
  assertEquals('ASSERT result height as expected', '500', mockKernel.swfObj.height);
};


function testSetTitle() {
  assertNotNull('ASSERT gadgets.window not null', gadgets.window);
  checkPoints.expect('req', 1);
  gadgets.window.setTitle = function(newTitle) {
    assertEquals('ASSERT setTitle is called as expected', 'someTitle', newTitle);
    checkPoints.check('req');
  };
  mockApi.setTitle('someTitle');
};


function testFetchPerson() {
  checkPoints.expect('req', 2).expect('resp', 1).expect('err', 1);

  var someParams = {};
  var someReqObject = {};
  var somePerson = new opensocial.Person();

  opensocial.newDataRequest = function() {
    var req = new opensocial.DataRequest();
    req.add = mockReqAddFunc(someReqObject, 'p');
    req.send = mockReqSendFunc();
    req.newFetchPersonRequest = function(id, opt_params) {
      assertEquals('ASSERT id in request', 'somePersonId', id);
      assertObjectEquals('ASSERT opt_params in request', someParams, opt_params);
      checkPoints.check('req');
      return someReqObject;
    };
    return req;
  };

  mockKernel.wrapObject = mockFunc();
  mockKernel.swfObj = {
    'handleAsync' : function(reqID, person) {
      assertEquals('ASSERT reqID in normal response', 'someReqID', reqID);
      assertObjectEquals('ASSERT person in normal response', somePerson, person);
      checkPoints.check('resp');
    },
    'handleError' : function(reqID, e) {
      assertEquals('ASSERT reqID in failed response', 'someReqID', reqID);
      assertTrue('ASSERT error in failed response', e instanceof Error);
      checkPoints.check('err');
    }
  };

  mockKernel.getData = mockFunc(somePerson);
  mockApi.fetchPerson('someReqID', 'somePersonId', someParams);
  
  mockKernel.getData = mockErrorFunc('Simulated error in testFetchPerson');
  mockApi.fetchPerson('someReqID', 'somePersonId', someParams);
};


function testFetchPeople() {
  checkPoints.expect('req', 2).expect('resp', 1).expect('err', 1);
  
  var someRawIdSpec = {};
  var someIdSpec = new opensocial.IdSpec();
  var someParams = {};
  var someReqObject = {};
  var somePeople = new opensocial.Collection();

  opensocial.newDataRequest = function() {
    var req = new opensocial.DataRequest();
    req.add = mockReqAddFunc(someReqObject,'f');
    req.send = mockReqSendFunc();
    req.newFetchPeopleRequest = function(idSpec, opt_params) {
      assertObjectEquals('ASSERT idSpec in request', someIdSpec, idSpec);
      assertObjectEquals('ASSERT opt_params in request', someParams, opt_params);
      checkPoints.check('req');
      return someReqObject;
    };
    return req;
  };
  
  mockKernel.unwrapObject = mockUnwrapFunc(someRawIdSpec, opensocial.IdSpec, someIdSpec);
  mockKernel.wrapObject = mockFunc();
  mockKernel.swfObj = {
    'handleAsync' : function(reqID, people) {
      assertEquals('ASSERT reqID in normal response', 'someReqID', reqID);
      assertObjectEquals('ASSERT people in normal response', somePeople, people);
      checkPoints.check('resp');
    },
    'handleError' : function(reqID, e) {
      assertEquals('ASSERT reqID in failed response', 'someReqID', reqID);
      assertTrue('ASSERT error in failed response', e instanceof Error);
      checkPoints.check('err');
    }
  };
  
  mockKernel.getData = mockFunc(somePeople);
  mockApi.fetchPeople('someReqID', someRawIdSpec, someParams);
  
  mockKernel.getData = mockErrorFunc('Simulated error in testFetchPeople');
  mockApi.fetchPeople('someReqID', someRawIdSpec, someParams);
};


function testFetchPersonAppData() {
  checkPoints.expect('req', 2).expect('resp', 1).expect('err', 1);

  var someRawIdSpec = {};
  var someIdSpec = new opensocial.IdSpec();
  var someKeys = [];
  var someParams = {};
  var someReqObject = {};
  var someDataSet = {};

  opensocial.newDataRequest = function() {
    var req = new opensocial.DataRequest();
    req.add = mockReqAddFunc(someReqObject,'d');
    req.send = mockReqSendFunc();
    req.newFetchPersonAppDataRequest = function(idSpec, keys, opt_params) {
      assertObjectEquals('ASSERT idSpec in request', someIdSpec, idSpec);
      assertObjectEquals('ASSERT keys in request', someKeys, keys);
      assertObjectEquals('ASSERT opt_params in request', someParams, opt_params);
      checkPoints.check('req');
      return someReqObject;
    };
    return req;
  };

  mockKernel.unwrapObject = mockUnwrapFunc(someRawIdSpec, opensocial.IdSpec, someIdSpec);
  mockKernel.swfObj = {
    'handleAsync' : function(reqID, dataSet) {
      assertEquals('ASSERT reqID in normal response', 'someReqID', reqID);
      assertObjectEquals('ASSERT dataSet in normal response', someDataSet, dataSet);
      checkPoints.check('resp');
    },
    'handleError' : function(reqID, e) {
      assertEquals('ASSERT reqID in failed response', 'someReqID', reqID);
      assertTrue('ASSERT error in failed response', e instanceof Error);
      checkPoints.check('err');
    }
  };
  
  mockKernel.getData = mockFunc(someDataSet);
  mockApi.fetchPersonAppData('someReqID', someRawIdSpec, someKeys, someParams);
  
  mockKernel.getData = mockErrorFunc('Simulated error in testFetchPersonAppData');
  mockApi.fetchPersonAppData('someReqID', someRawIdSpec, someKeys, someParams);
};


function testUpdatePersonAppData() {
  checkPoints.expect('req', 2).expect('resp', 1).expect('err', 1);
  
  var someValue = {};
  var someReqObject = {};
  
  opensocial.newDataRequest = function() {
    var req = new opensocial.DataRequest();
    req.add = mockReqAddFunc(someReqObject, 'u');
    req.send = mockReqSendFunc();
    req.newUpdatePersonAppDataRequest = function(id, key, value) {
      assertEquals('ASSERT id in request', 'somePersonId', id);
      assertEquals('ASSERT key in request', 'someKey', key);
      assertObjectEquals('ASSERT value in request', someValue, value);
      checkPoints.check('req');
      return someReqObject;
    };
    return req;
  };
  
  mockKernel.swfObj = {
    'handleAsync' : function(reqID) {
      assertEquals('ASSERT reqID in normal response', 'someReqID', reqID);
      checkPoints.check('resp');
    },
    'handleError' : function(reqID, e) {
      assertEquals('ASSERT reqID in failed response', 'someReqID', reqID);
      assertTrue('ASSERT error in failed response', e instanceof Error);
      checkPoints.check('err');
    }
  };
  
  mockKernel.getData = mockFunc();
  mockApi.updatePersonAppData('someReqID', 'somePersonId', 'someKey', someValue);
  
  mockKernel.getData = mockErrorFunc('Simulated error in testUpdatePersonAppData');
  mockApi.updatePersonAppData('someReqID', 'somePersonId', 'someKey', someValue);
};


function testRemovePersonAppData() {
  checkPoints.expect('req', 2).expect('resp', 1).expect('err', 1);
  
  var someKeys = [];
  var someReqObject = {};
  
  opensocial.newDataRequest = function() {
    var req = new opensocial.DataRequest();
    req.add = mockReqAddFunc(someReqObject, 'r');
    req.send = mockReqSendFunc();
    req.newRemovePersonAppDataRequest = function(id, keys) {
      assertEquals('ASSERT id in request', 'somePersonId', id);
      assertObjectEquals('ASSERT keys in request', someKeys, keys);
      checkPoints.check('req');
      return someReqObject;
    };
    return req;
  };
  
  mockKernel.swfObj = {
    'handleAsync' : function(reqID) {
      assertEquals('ASSERT reqID in normal response', 'someReqID', reqID);
      checkPoints.check('resp');
    },
    'handleError' : function(reqID, e) {
      assertEquals('ASSERT reqID in failed response', 'someReqID', reqID);
      assertTrue('ASSERT error in failed response', e instanceof Error);
      checkPoints.check('err');
    }
  };
  
  mockKernel.getData = mockFunc();
  mockApi.removePersonAppData('someReqID', 'somePersonId', someKeys);
  
  mockKernel.getData = mockErrorFunc('Simulated error in testRemovePersonAppData');
  mockApi.removePersonAppData('someReqID', 'somePersonId', someKeys);
};


function testFetchActivities() {
  checkPoints.expect('req', 2).expect('resp', 1).expect('err', 1);
  
  var someRawIdSpec = {};
  var someIdSpec = new opensocial.IdSpec();
  var someParams = {};
  var someReqObject = {};
  var someActivities = {};
  
  opensocial.newDataRequest = function() {
    var req = new opensocial.DataRequest();
    req.add = mockReqAddFunc(someReqObject,'a');
    req.send = mockReqSendFunc();
    req.newFetchActivitiesRequest = function(idSpec, opt_params) {
      assertObjectEquals('ASSERT idSpec in request', someIdSpec, idSpec);
      assertObjectEquals('ASSERT opt_params in request', someParams, opt_params);
      checkPoints.check('req');
      return someReqObject;
    };
    return req;
  };
  
  mockKernel.unwrapObject = mockUnwrapFunc(someRawIdSpec, opensocial.IdSpec, someIdSpec);
  mockKernel.wrapObject = mockFunc();
  mockKernel.swfObj = {
    'handleAsync' : function(reqID, activities) {
      assertEquals('ASSERT reqID in normal response', 'someReqID', reqID);
      assertObjectEquals('ASSERT activities in normal response', someActivities, activities);
      checkPoints.check('resp');
    },
    'handleError' : function(reqID, e) {
      assertEquals('ASSERT reqID in failed response', 'someReqID', reqID);
      assertTrue('ASSERT error in failed response', e instanceof Error);
      checkPoints.check('err');
    }
  };

  mockKernel.getData = mockFunc(someActivities);
  mockApi.fetchActivities('someReqID', someRawIdSpec, someParams);
  
  mockKernel.getData = mockErrorFunc('Simulated error in testFetchActivities');
  mockApi.fetchActivities('someReqID', someRawIdSpec, someParams);
};


function testRequestCreateActivity() {
  checkPoints.expect('req', 2).expect('resp', 1).expect('err', 1);

  var someRawActivity = {};
  var someActivity = new opensocial.Activity();

  opensocial.requestCreateActivity = function(activity, priority, callback) {
    assertObjectEquals('ASSERT activity in request', someActivity, activity);
    assertEquals('ASSERT priority in request', 'somePriority', priority);
    assertTrue('ASSERT callback is Function', callback instanceof Function);
    checkPoints.check('req');
    callback();
  };

  mockKernel.unwrapObject = mockUnwrapFunc(someRawActivity, opensocial.Activity, someActivity);
  mockKernel.swfObj = {
    'handleAsync' : function(reqID) {
      assertEquals('ASSERT reqID in normal response', 'someReqID', reqID);
      checkPoints.check('resp');
    },
    'handleError' : function(reqID, e) {
      assertEquals('ASSERT reqID in failed response', 'someReqID', reqID);
      assertTrue('ASSERT error in failed response', e instanceof Error);
      checkPoints.check('err');
    }
  };

  mockKernel.getDataItem = mockFunc();
  mockApi.requestCreateActivity('someReqID', someRawActivity, 'somePriority');

  mockKernel.getDataItem = mockErrorFunc('Simulated error in testRequestCreateActivity');
  mockApi.requestCreateActivity('someReqID', someRawActivity, 'somePriority');
};


function testRequestSendMessage() {
  checkPoints.expect('req', 2).expect('resp', 1).expect('err', 1);

  var someRecipients = [];
  var someRawMessage = {};
  var someMessage = new opensocial.Message();

  opensocial.requestSendMessage = function(recipients, message, callback) {
    assertObjectEquals('ASSERT recipients in request', someRecipients, recipients);
    assertObjectEquals('ASSERT message in request', someMessage, message);
    assertTrue('ASSERT callback is Function', callback instanceof Function);
    checkPoints.check('req');
    callback();
  };

  mockKernel.unwrapObject = mockUnwrapFunc(someRawMessage, opensocial.Message, someMessage);
  mockKernel.swfObj = {
    'handleAsync' : function(reqID) {
      assertEquals('ASSERT reqID in normal response', 'someReqID', reqID);
      checkPoints.check('resp');
    },
    'handleError' : function(reqID, e) {
      assertEquals('ASSERT reqID in failed response', 'someReqID', reqID);
      assertTrue('ASSERT error in failed response', e instanceof Error);
      checkPoints.check('err');
    }
  };

  mockKernel.getDataItem = mockFunc();
  mockApi.requestSendMessage('someReqID', someRecipients, someRawMessage);

  mockKernel.getDataItem = mockErrorFunc('Simulated error in testRequestSendMessage');
  mockApi.requestSendMessage('someReqID', someRecipients, someRawMessage);
};


function testRequestShareApp() {
  checkPoints.expect('req', 2).expect('resp', 1).expect('err', 1);

  var someRecipients = [];
  var someRawReason = {};
  var someReason = new opensocial.Message();

  opensocial.requestShareApp = function(recipients, reason, callback) {
    assertObjectEquals('ASSERT recipients in request', someRecipients, recipients);
    assertObjectEquals('ASSERT reason in request', someReason, reason);
    assertTrue('ASSERT callback is Function', callback instanceof Function);
    checkPoints.check('req');
    callback();
  };

  mockKernel.unwrapObject = mockUnwrapFunc(someRawReason, opensocial.Message, someReason);
  mockKernel.swfObj = {
    'handleAsync' : function(reqID) {
      assertEquals('ASSERT reqID in normal response', 'someReqID', reqID);
      checkPoints.check('resp');
    },
    'handleError' : function(reqID, e) {
      assertEquals('ASSERT reqID in failed response', 'someReqID', reqID);
      assertTrue('ASSERT error in failed response', e instanceof Error);
      checkPoints.check('err');
    }
  };

  mockKernel.getDataItem = mockFunc();
  mockApi.requestShareApp('someReqID', someRecipients, someRawReason);

  mockKernel.getDataItem = mockErrorFunc('Simulated error in testRequestShareApp');
  mockApi.requestShareApp('someReqID', someRecipients, someRawReason);
};


function testRequestPermission() {
  checkPoints.expect('req', 2).expect('resp', 1).expect('err', 1);

  opensocial.requestPermission = function(permissions, reason, callback) {
    assertEquals('ASSERT permissions in request', 'somePermission', permissions);
    assertEquals('ASSERT reason in request', 'someReason', reason);
    assertTrue('ASSERT callback is Function', callback instanceof Function);
    checkPoints.check('req');
    callback();
  };

  mockKernel.swfObj = {
    'handleAsync' : function(reqID) {
      assertEquals('ASSERT reqID in normal response', 'someReqID', reqID);
      checkPoints.check('resp');
    },
    'handleError' : function(reqID, e) {
      assertEquals('ASSERT reqID in failed response', 'someReqID', reqID);
      assertTrue('ASSERT error in failed response', e instanceof Error);
      checkPoints.check('err');
    }
  };

  mockKernel.getDataItem = mockFunc();
  mockApi.requestPermission('someReqID', 'somePermission', 'someReason');

  mockKernel.getDataItem = mockErrorFunc('Simulated error in testRequestPermission');
  mockApi.requestPermission('someReqID', 'somePermission', 'someReason');
};


function testMakeRequest() {
  assertNotNull('ASSERT gadgets.io not null', gadgets.io);
  checkPoints.expect('req', 3).expect('resp', 1).expect('err', 2);

  var someParams = {};
  var someData = {};
  var dataResponseFunc;

  gadgets.io.makeRequest = function(url, callback, opt_params) {
    assertEquals('ASSERT url in request', 'someUrl', url);
    assertTrue('ASSERT callback is Function', callback instanceof Function);
    assertObjectEquals('ASSERT opt_params in request', someParams, opt_params);
    checkPoints.check('req');
    callback(dataResponseFunc());
  };

  mockKernel.swfObj = {
    'handleAsync' : function(reqID, data) {
      assertEquals('ASSERT reqID in normal response', 'someReqID', reqID);
      assertObjectEquals('ASSERT data in normal response', someData, data);
      checkPoints.check('resp');
    },
    'handleError' : function(reqID, e) {
      assertEquals('ASSERT reqID in failed response', 'someReqID', reqID);
      assertTrue('ASSERT error in failed response', e instanceof Error);
      checkPoints.check('err');
    }
  };

  dataResponseFunc = mockFunc({'rc': '200', 'data': someData});
  mockApi.makeRequest('someReqID', 'someUrl', someParams);

  dataResponseFunc = mockFunc({'rc': '404', 'text': 'Simulated rc404 error in testMakeRequest'});
  mockApi.makeRequest('someReqID', 'someUrl', someParams);

  dataResponseFunc = mockFunc({'error': 'someError', 'text': 'Simulated random error in testMakeRequest'});
  mockApi.makeRequest('someReqID', 'someUrl', someParams);
};


function testCallRpc() {
  assertNotNull('ASSERT gadgets.rpc not null', gadgets.rpc);
  checkPoints.expect('req', 1).expect('resp', 1);
  
  var someArgs = ['someArg0', 'someArg1'];
  var someReturnValue = {};
  
  gadgets.rpc.call = function(targetId, serviceName, callback) {
    assertEquals('ASSERT targetId in request', 'someTargetId', targetId);
    assertEquals('ASSERT serviceName in request', 'someServiceName', serviceName);
    assertTrue('ASSERT callback is Function', callback instanceof Function);
    assertObjectEquals('ASSERT args[0] in request', someArgs[0], arguments[3]);
    assertObjectEquals('ASSERT args[1] in request', someArgs[1], arguments[4]);
    checkPoints.check('req');
    callback(someReturnValue);
  }
  mockKernel.swfObj = {
    'handleAsync' :  function(reqID, returnValue){
      assertEquals('ASSERT reqID in normal response', 'someReqID', reqID);
      assertObjectEquals('ASSERT returnValue in normal response', someReturnValue, returnValue);
      checkPoints.check('resp');
    },
  };
  
  mockApi.callRpc('someReqID', 'someTargetId', 'someServiceName', someArgs);
};


function testReturnRpcService() {
  checkPoints.expect('poprpc', 2).expect('return', 1);
  
  var someReturnValue = {};
  
  mockKernel.popRpc = function(callID) {
    checkPoints.check('poprpc');
    return {
      'callback': function(returnValue) {
        assertEquals('ASSERT someReturnValue as expected', someReturnValue, returnValue);
        checkPoints.check('return');
      }
    };
  }
  
  mockApi.returnRpcService('someCallID', someReturnValue);
  mockApi.returnRpcService('someCallID');
};


function testRegisterRpcService() {
  assertNotNull('ASSERT gadgets.rpc not null', gadgets.rpc);
  checkPoints.expect('regdef', 1).expect('reg', 3).expect('pushrpc', 3);
  checkPoints.expect('call', 1).expect('callerr', 2);
  
  var someArgs= ['someCallID', 'someArg0', 'someArg1'];
  var someCallbacks = {};
  
  gadgets.rpc.registerDefault = function(callback) {
    someCallbacks['defaultService'] = callback;
    checkPoints.check('regdef');
  };
  gadgets.rpc.register = function(serviceName, callback) {
    someCallbacks[serviceName] = callback;
    checkPoints.check('reg');
  };
  
  mockKernel.swfObj = {
    'someHandler' :  function(){
      assertEquals('ASSERT someCallID in normal callback', 'someCallID', arguments[0]);
      assertObjectEquals('ASSERT args[0] in normal callback', someArgs[0], arguments[1]);
      assertObjectEquals('ASSERT args[1] in normal callback', someArgs[1], arguments[2]);
      checkPoints.check('call');
    },
    'someErrorHandler' : mockErrorFunc(),
    'handleError' : function(reqID, e) {
      assertNull('ASSERT null reqID in failed response', reqID);
      assertTrue('ASSERT error in failed response', e instanceof Error);
      checkPoints.check('callerr');
    }
  };
  mockKernel.pushRpc = function(rpc) {
    checkPoints.check('pushrpc');
    return 'someCallID';
  };
  
  mockApi.registerRpcService('someService', 'someHandler');
  mockApi.registerRpcService('someErrorService', 'someErrorHandler');
  mockApi.registerRpcService('someNotExistService', 'someNotExistHandler');
  mockApi.registerRpcService(null, 'someHandler');
  
  someCallbacks['someService'].apply(null, someArgs);
  someCallbacks['someErrorService'].apply(null, someArgs);
  someCallbacks['someNotExistService'].apply(null, someArgs);
  
  assertNotUndefined('ASSERT default reg not null', someCallbacks['defaultService']);
};


function testUnregisterRpcService() {
  checkPoints.expect('unregdef', 1).expect('unreg', 1);
  
  assertNotNull('ASSERT gadgets.rpc not null', gadgets.rpc);
  
  gadgets.rpc.unregisterDefault = function() {
    checkPoints.check('unregdef');
  };
  gadgets.rpc.unregister = function(serviceName) {
    assertEquals('ASSERT serviceName in request', 'someService', serviceName);
    checkPoints.check('unreg');
  };
  
  mockApi.unregisterRpcService(null);
  mockApi.unregisterRpcService('someService');
};



// ================================ Unittests for private methods ==================================

function testIsArray() {
  var obj = [];
  assertTrue('ASSERT normal array', mockKernel.isArray(obj));
  assertFalse('ASSERT null', mockKernel.isArray(null));
  assertFalse('ASSERT object', mockKernel.isArray({}));
  assertFalse('ASSERT number', mockKernel.isArray(1));
  var arrayCtor = Array;
  Array = null;
  assertTrue('ASSERT normal array without Array', mockKernel.isArray(obj));
  assertFalse('ASSERT object without Array', mockKernel.isArray(null));
  assertFalse('ASSERT function without Array', mockKernel.isArray(function(){}));
  Array = arrayCtor;
};


function testForEach() {
  checkPoints.expect('one', 2).expect('two', 2).expect('three', 0).expect('four', 0);
  var someThis= {'someField' : 'someValue'};
  var someArray = ['one', 'two', 'three', 'four'];
  var someFunc = function(item, index, array) {
    if (index >= 2) {
      return false;
    }
    assertEquals('ASSERT this pointer', 'someValue', this.someField);
    assertEquals('ASSERT item matches original array', someArray[index], item);
    assertEquals('ASSERT item matches passed-in array', array[index], item);

    checkPoints.check(item);
  };
  mockKernel.forEach(someArray, someFunc, someThis);

  (function() {
    mockKernel.forEach(arguments, someFunc, someThis);
  })('one', 'two', 'three');  
  
};


function testClone() {
  var someArray = [1,2,'abc'];
  clonedArray = mockKernel.clone(someArray);
  assertObjectEquals('ASSERT same array values', someArray, clonedArray);
  assertNotEquals('ASSERT different array pointer', someArray, clonedArray);
  
  var someObject = {'a': 123, 'b': {'c' : 456}};
  clonedObject = mockKernel.clone(someObject);
  assertObjectEquals('ASSERT same object values', someObject, clonedObject);
  assertNotEquals('ASSERT different object pointer', someObject, clonedObject);
  
  var someNumber = 123;
  clonedNumber = mockKernel.clone(someNumber);
  assertEquals('ASSERT same number', someNumber, clonedNumber);
  
  var someString = 'abc';
  clonedString = mockKernel.clone(someString);
  assertEquals('ASSERT same string', someString, clonedString);
  
  var someFunction = new Function();
  clonedFunction = mockKernel.clone(someFunction);
  assertEquals('ASSERT same function', someFunction, clonedFunction);
  
  assertNull('ASSERT null cloneable', mockKernel.clone(null));
  
  var someComplex = new opensocial.Person();
  clonedComplex = mockKernel.clone(someComplex);
  assertObjectEquals('ASSERT same complex object values', someComplex, clonedComplex);
  assertNotEquals('ASSERT different complex object pointer', someComplex, clonedComplex);
};


function testGetData() {
  checkPoints.expect('err', 1);

  var someResponseItem = {};
  var someDataResponse = {
    'hadError' : function() {return false;},
    'get' : function(key) {
      assertEquals('ASSERT key in dataResponse', 'someKey', key);
      return someResponseItem;
    }
  };
  var someErrorDataResponse = {
    'hadError' : function() {return true;},
    'getErrorMessage' : function() {return 'someErrorMessage';}
  };
  
  mockKernel.getDataItem = mockFunc();
  
  var returnValue = mockKernel.getData(someDataResponse, 'someKey');
  assertObjectEquals('ASSERT response item as expected', someResponseItem, returnValue);
  assertNull('ASSERT null data response', mockKernel.getData(null, 'someKey'));
  assertNull('ASSERT null key in data response', mockKernel.getData(someDataResponse, null));
  try {
    mockKernel.getData(someErrorDataResponse, 'someKey');
    fail('FAIL someErrorDataResponse');
  } catch(e) {
    checkError(e, function() {
      assertEquals('ASSERT error message in data response', 'someErrorMessage', e['message']);
      checkPoints.check('err');
    });
  }
};


function testGetDataItem() {
  checkPoints.expect('err', 1);

  var someData = {};
  var someResponseItem = {
    'hadError' : function() {return false;},
    'getData' : function() {
      return someData;
    }
  };
  var someErrorResponseItem = {
    'hadError' : function() {return true;},
    'getErrorMessage' : function() {return 'someErrorMessage';},
    'getErrorCode' : function() {return 'someErrorCode';}
  };

  var returnValue = mockKernel.getDataItem(someResponseItem);
  assertObjectEquals('ASSERT data as expected', someData, returnValue);
  assertNull('ASSERT null data in response item', mockKernel.getDataItem(null));
  try {
    mockKernel.getDataItem(someErrorResponseItem);
    fail('FAIL someErrorResponseItem');
  } catch(e) {
    checkError(e, function() {
      assertEquals('ASSERT error message in response item', 'someErrorMessage', e['message']);
      assertEquals('ASSERT error code in response item', 'someErrorCode', e['code']);
      checkPoints.check('err');
    });
  }
};


function testCheckType() {
  assertEquals('ASSERT check Enum', opensocial.Enum, 
               mockKernel.checkType(new opensocial.Enum()));
  assertEquals('ASSERT check Name', opensocial.Name, 
               mockKernel.checkType(new opensocial.Name()));
  assertEquals('ASSERT check IdSpec',
               opensocial.IdSpec, mockKernel.checkType(new opensocial.IdSpec()));
  assertEquals('ASSERT check Person', 
               opensocial.Person, mockKernel.checkType(new opensocial.Person()));
  assertEquals('ASSERT check Activity', 
               opensocial.Activity, mockKernel.checkType(new opensocial.Activity()));
  assertEquals('ASSERT check Collection',
               opensocial.Collection, mockKernel.checkType(new opensocial.Collection()));
  
  assertNull('ASSERT random opensocial type', mockKernel.checkType(new opensocial.DataRequest()));
  assertNull('ASSERT random type', mockKernel.checkType(new Date()));
  assertNull('ASSERT null input', mockKernel.checkType(null));
};


function testWrapObject() {
  var someName = new opensocial.Name();
  someName.getField = function(key) {
    var fields = {};
    fields[opensocial.Name.Field.UNSTRUCTURED] = 'someUnstructuredName';
    fields[opensocial.Name.Field.GIVEN_NAME] = 'someGivenName';
    fields[opensocial.Name.Field.FAMILY_NAME] = 'someFamilyName';
    return fields[key];
  };
  var somePerson = new opensocial.Person();
  somePerson.getField = function(key) {
    var fields = {};
    fields[opensocial.Person.Field.NAME] = someName;
    return fields[key];
  };
  somePerson.getDisplayName = mockFunc('someDisplayName');
  somePerson.isOwner = mockFunc(true);
  somePerson.isViewer = mockFunc(true);
  somePerson.getId = mockFunc('someId');
  
  
  var someActivity = new opensocial.Activity();
  someActivity.getField = function(key) {
    var fields = {};
    fields[opensocial.Activity.Field.TITLE] = 'someTitle';
    return fields[key];
  };
  someActivity.getId = mockFunc('someId');
  
  var someEnum = new opensocial.Enum();
  someEnum.getKey = mockFunc('someKey');
  someEnum.getDisplayValue = mockFunc('somevalue');
  
  var someCollection = new opensocial.Collection();
  someCollection.size = mockFunc(2);
  someCollection.getOffset = mockFunc(3);
  someCollection.getTotalSize = mockFunc(5);
  someCollection.asArray = mockFunc([somePerson, somePerson]);
  
  var expectedPerson = {
    'displayName':'someDisplayName',
    'fields':{
      'name':{
        'fields':{
          'familyName':'someFamilyName',
          'givenName':'someGivenName',
          'unstructuredName':'someUnstructuredName'
        }
      }
    },
    'id':'someId',
    'isOwner':true,
    'isViewer':true
  };
  assertObjectEquals('ASSERT wrap Person', expectedPerson, mockKernel.wrapObject(somePerson));
  
  var expectedActivity = {
    'id':'someId',
    'fields':{
      'title':'someTitle'
    }
  };
  assertObjectEquals('ASSERT wrap Activity', expectedActivity, mockKernel.wrapObject(someActivity));
  
  var expectedEnum = {
    'displayValue':'somevalue',
    'key':'someKey'
  };
  assertObjectEquals('ASSERT wrap Enum', expectedEnum, mockKernel.wrapObject(someEnum));
  
  var expectedCollection = {
    'offset':3,
    'size':2,
    'totalSize':5,
    'array':[expectedPerson, expectedPerson]
  };
  assertObjectEquals('ASSERT wrap Collection', expectedCollection, mockKernel.wrapObject(someCollection));
};


function testUnwrapObject() {
  checkPoints.expect('idspec', 1)
             .expect('navigationparameters', 1)
             .expect('mediaitem', 2)
             .expect('message', 1)
             .expect('activity', 1)
             .expect('err', 3);

  var someIdSpec = {'fields':{}};
  var someNavigationParameters = {'fields':{}};
  var someMediaItems = {'fields':{}};
  someMediaItems['fields'][opensocial.MediaItem.Field.MIME_TYPE] = 'someMimeType';
  someMediaItems['fields'][opensocial.MediaItem.Field.URL] = 'someUrl';
  var someMessage = {'fields':{}};
  someMessage['fields'][opensocial.Message.Field.BODY] = 'someBody';
  var someActvity = {'fields':{}};
  someActvity['fields'][opensocial.Activity.Field.MEDIA_ITEMS] = [someMediaItems];
  
  opensocial.newIdSpec = function(parameters) {
    assertObjectEquals('ASSERT unwrap IdSpec fields', someIdSpec, parameters);
    checkPoints.check('idspec');
  };
  opensocial.newNavigationParameters = function(parameters) {
    assertObjectEquals('ASSERT unwrap NavigationParameters fields', someNavigationParameters, parameters);
    checkPoints.check('navigationparameters');
  };
  opensocial.newMediaItem = function(mimeType, url, opt_params) {
    assertEquals('ASSERT unwrap MediaItem mimeType', 'someMimeType', mimeType);
    assertEquals('ASSERT unwrap MediaItem url', 'someUrl', url);
    assertObjectEquals('ASSERT unwrap MediaItem fields', someMediaItems, opt_params);
    checkPoints.check('mediaitem');
  };
  opensocial.newMessage = function(body, opt_params) {
    assertEquals('ASSERT unwrap Message body', 'someBody', body);
    assertObjectEquals('ASSERT unwrap Message fields', someMessage, opt_params);
    checkPoints.check('message');
  };
  opensocial.newActivity = function(params) {
    assertObjectEquals('ASSERT unwrap Activity fields', someActvity, params);
    checkPoints.check('activity');
  };
  
  mockKernel.unwrapObject(someIdSpec, opensocial.IdSpec);
  mockKernel.unwrapObject(someNavigationParameters, opensocial.NavigationParameters);
  mockKernel.unwrapObject(someMediaItems, opensocial.MediaItem);
  mockKernel.unwrapObject(someMessage, opensocial.Message);
  mockKernel.unwrapObject(someActvity, opensocial.Activity);
  
  try {
    mockKernel.unwrapObject(null, opensocial.IdSpec);
    fail('FAIL null object');
  } catch(e) {
    checkError(e, function() {
      checkPoints.check('err');
    });
  }
  try {
    mockKernel.unwrapObject({}, opensocial.IdSpec);
    fail('FAIL random object');
  } catch(e) {
    checkError(e, function() {
      checkPoints.check('err');
    });
  }
  try {
    mockKernel.unwrapObject(someIdSpec, opensocial.Person);
    fail('FAIL random type');
  } catch(e) {
    checkError(e, function() {
      checkPoints.check('err');
    });
  }
};


function testHandleError() {
  var someError = new Error('Mock Error');
  mockKernel.swfObj = {
    'handleError' : function(reqID, error) {
      assertEquals('ASSERT reqID as expected', 'someReqID', reqID);
      assertEquals('ASSERT error as expected', someError, error);
    }
  };
  mockKernel.handleError('someReqID', someError);
};

function testHandleAsync() {
  mockKernel.swfObj = {
    'handleAsync' : function() {
      assertEquals('ASSERT reqID as expected', 'someReqID', arguments[0]);
      assertEquals('ASSERT arg1 as expected', 'someArg1', arguments[1]);
      assertEquals('ASSERT arg2 as expected', 'someArg2', arguments[2]);
    }
  };
  mockKernel.handleAsync('someReqID', 'someArg1', 'someArg2');
};


function testPushRpc() {
  var someRpc = {
    's': 'someServiceName',
    'c': 'someCall',
  };
  mockKernel.rpcStore = {};

  var returnValue = mockKernel.pushRpc(someRpc);

  assertEquals('ASSERT returnValue as expected', 'someServiceName_someCall', returnValue);
  assertEquals('ASSERT rpcStore as expected', someRpc, mockKernel.rpcStore['someServiceName_someCall']);
};


function testPopRpc() {
  var someRpc = {'s': 'someServiceName', 'c': 'someCall' };
  mockKernel.rpcStore = {
   'someCallID' : someRpc
  };
  var returnValue = mockKernel.popRpc('someCallID');
  assertEquals('ASSERT returnValue as expected', someRpc, returnValue);
  assertUndefined('ASSERT rpcStore as expected', mockKernel.rpcStore['someCallID']);
};

