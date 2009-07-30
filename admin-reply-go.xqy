(:
 : Copyright (c) 2004 raff@aromatic.org
 : original source: xfaqtor (see following copyright)
 :
 :
 : Copyright (c) 2004 Mark Logic Corporation
 :
 : Licensed under the Apache License, Version 2.0 (the "License");
 : you may not use this file except in compliance with the License.
 : You may obtain a copy of the License at
 :
 : http://www.apache.org/licenses/LICENSE-2.0
 :
 : Unless required by applicable law or agreed to in writing, software
 : distributed under the License is distributed on an "AS IS" BASIS,
 : WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 : See the License for the specific language governing permissions and
 : limitations under the License.
 :
 : The use of the Apache License does not indicate that this project is
 : affiliated with the Apache Software Foundation.
 :)
xquery version "1.0-ml";
import module namespace xblog = "http://www.marklogic.com/xqlog-lib" at "xqlog-lib.xqy";
import module namespace xblogd = "http://www.marklogic.com/xqlog-display" at "xqlog-display.xqy";

if (not(xblog:is-login()))
then
  xdmp:redirect-response("login.xqy")
else
xdmp:set-response-content-type("text/html"),

<html xml:space="preserve">
<head>
<link rel="stylesheet" type="text/css" href="style.css" />
<title>{xblogd:get-title()}</title>
</head>
<body class="help">

<h1 class="title">Edit Reply</h1>
{
  let $repid := xdmp:get-request-field("repid")
  let $text := xdmp:get-request-field("text")
  let $state := xdmp:get-request-field("state", "")

  let $cancel := xdmp:get-request-field("cancel")
  return

  (: Do some input data checking :)
  if ($cancel) then
    xdmp:redirect-response("admin.xqy")
  else if ($repid = "") then
    <span>
      <div class="error">The 'repid' parameter is missing</div>
      { xblogd:print-go-home() }
    </span>
  else if (not($repid castable as xs:integer)) then
    <span>
      <div class="error">The 'repid' parameter must be an integer</div>
      { xblogd:print-go-admin() }
    </span>
  else if (normalize-space($text) = "") then
    <span>
      <div class="error">No reply text provided</div>
      { xblogd:print-go-admin() }
    </span>
  else if (not($state = ("submitted", "live", "dead"))) then
    <span>
      <div class="error">State '{$state}' unknown</div>
      { xblogd:print-go-admin() }
    </span>
  else

  let $reply := xblog:get-reply(xs:integer($repid))
  return

  if (empty($reply)) then
    <span>
      <div class="error">Reply id '{ $repid }' unknown</div>
      { xblogd:print-go-admin() }
    </span>
  else

  let $chg := xblog:change-reply($reply, $text, $state)
  return
  <span>
    <div class="action-explain">
      Your changes have been made.
    </div>
    { xblogd:print-go-admin() }
  </span>
}

</body>
</html>
