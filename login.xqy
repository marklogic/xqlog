(:
 : Copyright (c) 2004 raff@aromatic.org
 :)
import module "http://www.w3.org/2003/05/xpath-functions" at "xqlog-lib.xqy"
import module "http://www.w3.org/2003/05/xpath-functions" at "xqlog-display.xqy"

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
<title>{get-title()}</title>
</head>
<body class="help">

{ print-intro() }

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

{ print-go-home() }

</body>
</html>
