(:
 : Copyright (c) 2004 raff@aromatic.org
 :)
xquery version "1.0-ml";
import module namespace xblog = "http://www.marklogic.com/xqlog-lib" at "xqlog-lib.xqy";
import module namespace xblogd = "http://www.marklogic.com/xqlog-display" at "xqlog-display.xqy";

xdmp:set-response-content-type("text/html"),

let $logout := xdmp:get-request-field("logout"),
    $user := if ($logout) then "" else xdmp:get-request-field("user")

return
if ($user or $logout)
then
(
  let $next := xdmp:get-request-field("next", "")
  return
  (
    xdmp:set-session-field("xqlog-user", $user),
    xdmp:redirect-response("default.xqy")
(:
      if (empty($next)) then "default.xqy" else xdmp:url-decode($next)
:)
  )
)
else
<html xml:space="preserve">
<head>
<link rel="stylesheet" type="text/css" href="style.css" />
<title>{xblogd:get-title()}</title>
</head>
<body class="help">

{ xblogd:print-intro() }

<form action="login.xqy" method="POST" class="xqlog-ask">
  <div>&#160;</div>
  <dl class="entrybox">
  <dt>Enter a user name or e-mail to post</dt>
  <dd>
    <input type="text" name="user" value=""/>
    <input type="submit" value="Login"/>
    {
(:
      if (xdmp:get-request-header("Referer", ""))
      then
        <input type="hidden" 
          name="next" value="{xdmp:get-request-header("Referer")}"/>
      else
        ()
:)
    }
  </dd>
  </dl>
</form>

{ xblogd:print-go-home() }

</body>
</html>
