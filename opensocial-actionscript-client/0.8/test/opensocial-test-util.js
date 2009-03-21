
window.osTestUtil = (function() {
  
  var barrier = 0;
  var loadDone = null;
  
  function addBarrier(num) {
    barrier += num;
  };
  
  function checkBarrier() {
    barrier--;
    if (barrier <= 0) {
      barrierDone();
    }
  };
  
  function barrierDone() {
    if (loadDone) {
      loadDone();
    }
  };
  
  function isIE() {
    if (navigator.appName.indexOf('Microsoft') != -1) {
      return true;
    } else {
      return false;
    }
  };
  
  function loadJs(scriptName) {
    var script = document.createElement("script");
    script.src = scriptName;
    script.type = "text/javascript";
    var done = function() {
      if (isIE()) {
        if (script.readyState != 'loaded' && script.readyState != 'complete') {
          return; // still loading
        }
        script.onreadystatechange = null;
      }
      checkBarrier();
    };
    
    if (isIE()) {
      script.onreadystatechange = done;
    } else {
      script.onload = done;
    }
    document.getElementsByTagName("head")[0].appendChild(script);
    
  };
  
  return {
    loadScripts: function(loadDoneFunc, extraScripts) {
      loadDone = loadDoneFunc;
      
      window.gadgets = {};
      
      var specScripts = [
          "gadgets/json.js",
          "gadgets/util.js",
          "gadgets/io.js",
          "gadgets/prefs.js",
          
          "gadgets/dynamic-height.js",
          "gadgets/flash.js",
          "gadgets/rpc.js",
          "gadgets/settitle.js",
          "gadgets/views.js",
          
          "opensocial/opensocial.js",
          "opensocial/environment.js",
          "opensocial/enum.js",
          "opensocial/address.js",
          "opensocial/bodyType.js",
          "opensocial/email.js",
          "opensocial/name.js",
          "opensocial/organization.js",
          "opensocial/phone.js",
          "opensocial/url.js",
          "opensocial/idspec.js",
          "opensocial/mediaitem.js",
          "opensocial/message.js",
          "opensocial/navigationparameters.js",
          "opensocial/activity.js",
          "opensocial/person.js",
          "opensocial/collection.js",
          "opensocial/responseitem.js",
          "opensocial/datarequest.js",
          "opensocial/dataresponse.js"
      ];
      
      addBarrier(specScripts.length);
      for (var i = 0; i < specScripts.length; i++) {
        loadJs("http://opensocial-resources.googlecode.com/svn/spec/0.8/" + specScripts[i]);
      }
      
      if (extraScripts) {
        addBarrier(extraScripts.length);
        for (var j = 0; j < extraScripts.length; j++) {
          loadJs(extraScripts[j]);
        }
      }
    }
  };
})();
