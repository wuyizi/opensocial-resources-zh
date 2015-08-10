# AS3: OpenSocial's development model evolving #

Current (callback mode, all functionalities excepts RESTful api are supported, beta version on code.google.com) - use case:
```
    /**
     * Initialize OpenSocial client
     */
    var client:JsWrapperClient = new JsWrapperClient(...);
    ...  // configure client
    client.start();

    /**
     * OpenSocial data requests, which includes FetchPeople / UpdatePersonAppData / MakeRequest, etc.
     */
    client.opensocial.fetchPeople(idSpec, function callback_function(resp:ResponseItem):void {...}, params);
    client.io.makeRequest("web_address", callback_function, param1, param2 ...);

    // a special case for paging
    client.opensocial.fetchPeople(idSpec, function paging(resp:ResponseItem):void {
      ...  // do something
      if (needsPaging(resp)) {
        client.opensocial.fetchPeople(idSpec, paging, ... the_next_page);  // recursively call itself
      }
    }, params);

    // It doesn't support event model natively, however, customer could build their own event
    // model by creating event dispatchers themselves.
    var dispatcher:EventDispatcher = new EventDispatcher();
    dispatcher.addEventListener(Event.COMPLETE, handler);
    client.opensocial.fetchPeople(idSpec, function event_dispatcher(resp:ResponseItem):void {
      var event:Event = new Event(Event.COMPLETE, resp);
      dispatcher.dispatchEvent(event);
    }, params);

    /**
     * Inter-frame RPC request.
     */
    client.rpc.call(null, function callback_function(returnValue:Object):void {...}, param1, param2, ...);
```

Pre-release (event mode, excepts RESTful api, target release by EOQ1) - use case:
```
    /**
     * Initialize OpenSocial client
     */
    var client:JsWrapperClient = new JsWrapperClient(...);
    ...  // configure client
    client.start();

    /**
     * OpenSocial data requests, which includes FetchPeople / UpdatePersonAppData / MakeRequest, etc.
     */
    var peopleLoader:DataLoader = client.opensocial.fetchPeople(idSpec, params);
    peopleLoader.addEventListener(IOEvent.READY, handler);  // Ordinary event model
    peopleLoader.onReady(callback_function);  // Possible callback style
    peopleLoader.execute();

    // It can't trigger paging behaivor on the same event-dispatching object.

    // kinda hacky way (currying style): compacts all stuffs in one line with callback function.
    // A dummy object refers to the created data request object in order to avoid auto garbage-collection.
    var dummy:DataLoader = client.opensocial.fetchPeople(idSpec, params).onReady(callback).execute();

    /**
     * Inter-frame RPC request - still using callback model (TODO)
     */
    client.rpc.call(null, function callback_function(returnValue:Object):void {...}, param1, param2, ...);
```

Future Proposal (event mode, will support RESTful api, target launch TBD) - use case:
```
    /**
     * Initialize OpenSocial clients.
     */
    var jsClient:OpenSocialClient = new JsWrapperClient(...);
    ...  // configure client

    var restfulClient:OpenSocialClient = new RestfulClient(...);
    ...  // configure client

    /**
     * OpenSocial data requests, which includes FetchPeople / UpdatePersonAppData / MakeRequest, etc.
     */
    var peopleRequest:OpenSocialDataRequest =
        new OpenSocialDataRequest(OpenSocialDataRequest.FETCH_PEOPLE);  // specify the request type

    peopleRequest.setFetchPeopleArgs(idSpec, param...);  // specify the parameters

    var params = OpenSocialDataRequest.getFetchPeopleParams(idSpec, param);

    // registers handlers and (possible) callback functions.
    peopleRequest.addEventListener(Event.COMPLETE, handler);  // Ordinary event model
    peopleRequest.addComplete(callback_function);  // Possible callback style

    // a special case for paging, need to use Event here.
    peopleRequest.addEventListener(Event.COMPLETE, function paging(event:OpenSocialDataEvent):void {
      var resp:RequestItem = event.response;
      var peopleRequest:OpenSocialDataRequest = event.currentTarget;
      if (needsPaging(resp)) {
        // Specify more parameters in the original Request object and fire it.
        // This case is very useful givn some logical components (handlers) have already listening the
        // Request object, and they don't bother to register on a new created object.
        peopleRequest.setArgs(idSpec, ... the_next_page);
        peopleRequest.send(jsClient);  // or, peopleRequest.send(resfulClient);
      }
    });

    // execute
    peopleRequest.send(jsClient);  // or, peopleRequest.send(resfulClient);

    // kinda hacky way (currying style): compacts all stuffs in one line with callback function.
    // A dummy object refers to the created data request object in order to avoid auto garbage-collection.
    var dummy:OpenSocialDataRequest = new OpenSocialDataRequest(OpenSocialDataRequest.FETCH_PEOPLE).setArgs(... args).addComplete(callback).send(jsClient);

    /**
     * Inter-frame RPC request.
     */
    var rpcRequest:RpcRequest = new RpcRequest(RpcRequest.RPC);  // specify the request type
    rpcRequest.setArgs(... args);  // specify the parameters

    // registers handlers and (possible) callback functions.
    rpcRequest.addEventListener(Event.COMPLETE, handler);
    rpcRequest.addComplete(callback_function);

    // execute
    rpcRequest.send(jsClient);  // rpcRequest.send(resfulClient) will trigger a run-time error since RESTful api may not support this.
```