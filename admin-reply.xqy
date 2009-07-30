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
  let $sel := <x selected="selected"/>/@selected
  let $repid := xdmp:get-request-field("repid")
  return

  if ($repid = "") then
    <span>
      <div class="error">The 'repid' parameter is missing</div>
      { xblogd:print-go-home() }
    </span>
  else if (not($repid castable as xs:integer)) then
    <span>
      <div class="error">The 'repid' parameter must be an integer</div>
      { xblogd:print-go-admin() }
    </span>
  else

  let $reply := xblog:get-reply(xs:integer($repid))
  return

  if (empty($reply)) then
    <span>
      <div class="error">Reply id '{ $repid }' unknown</div>
      { xblogd:print-go-home() }
    </span>
  else

  <form action="admin-reply-go.xqy" method="post" class="xqlog-reply">
    <input type="hidden" name="repid" value="{$repid}"/>

    <dl class="entrybox">
    <dt>Edit Reply:</dt>
    <dd><textarea name="text" cols="40" rows="5">{$reply/text/text()}</textarea></dd>
    </dl>
  
    <dl>
    <dt>Edit State:</dt>
    <dd> { xblogd:print-state-select("state", $reply/state) } </dd>
    </dl>
  
    <input type="submit" name="change" value="Change!"/>
    <input type="submit" name="cancel" value="Cancel"/>
  </form>
}

</body>
</html>
