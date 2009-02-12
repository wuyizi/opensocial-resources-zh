<?php
require_once("../oauth-handler.php");

if ($signature_valid == true) {
  $a = $payload["post"]["AMOUNT"];
  $res = array();
  if ($a == 500) {
    header ("HTTP/1.0 500 Server Unavailable", true, 500);
    echo "<h1>Server Unavailable</h1>";
  } else if ($a == 404) {
    header ("HTTP/1.0 404 Not Found", true, 404);
    echo "<h1>Not Found</h1>";
  } else if ($a == 999) {
    $res["RESPONSE_CODE"] = "APP_LOGIC_ERROR";
    $res["RESPONSE_MESSAGE"] = "This is just a fake logic error.";
    echo json_encode($res);
  } else {
    $res["RESPONSE_CODE"] = "OK";
    $res["RESPONSE_MESSAGE"] = "You have checked out those items which cost for ".$a.".";
    echo json_encode($res);
  }
} else {
  header ("HTTP/1.0 400 Bad Request", true, 400);
  echo "<h1>Invalid OAuth Signiture</h1>";

}
// echo json_encode($payload);
?>
