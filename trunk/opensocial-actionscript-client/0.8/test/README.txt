Uniitests for OpenSocial Actionscript Client SDK with FlexUnit and JsUnit.
(Currently the jsunit tests only work in Firefox.)

Usage:
  1. If you want to run the tests on your local machine, make sure you 
     have read and finish the "Local Running Configuration" section below.
  2. Run buildTestRunner.bat  to build the "FlexUnitTestRunner.mxml" 
     Application. The output will be "/bin/FlexUnitTestRunner.swf" .
  3. Use Firefox to open the "AllTests.html" and click the link to run 
     the tests.


Local Running Configuration: 
  1. For the first time to run it locally in Firefox, you need to set the 
     "security.fileuri.strict_origin_policy" to FALSE in "about:config"
     page in Firefox to make the browser able read the scripts on local disk.
     
  2. The flexunit tests requires a Local-Trusted sandbox of flash 
      player, otherwise an Error #2060 will occure. So for the first time 
      running it, please visit this site to customize your flash player:
      http://www.macromedia.com/support/documentation/en/flashplayer/help/settings_manager04.html
      Click the "Edit localtions..." to add the running target 
      "/bin/FlexUnitTestRunner.swf" to the "Always trusted files" box.

