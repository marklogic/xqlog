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
declare default function namespace "http://www.w3.org/2005/xpath-functions";

xdmp:set-response-content-type("text/html"),

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

<h1 class="title">Edit log</h1>
{
  let $sel := <x selected="selected"/>/@selected
  let $logid := xdmp:get-request-field("logid")
  return

  (: Do some input data checking :)
  if ($logid = "") then
    <span>
      <div class="error">The 'logid' parameter is missing</div>
      { xblogd:print-go-home() }
    </span>
  else if (not($logid castable as xs:integer)) then
    <span>
      <div class="error">The 'logid' parameter must be an integer</div>
      { xblogd:print-go-home() }
    </span>
  else

  let $log := xblog:get-log(xs:integer($logid))
  return

  if (empty($log)) then
    <span>
      <div class="error">Question id '{ $logid }' unknown</div>
      { xblogd:print-go-admin() }
    </span>
  else

  <form action="admin-log-go.xqy" method="post" class="xqlog-ask">
    <input type="hidden" name="logid" value="{$logid}"/>
  
    <dl class="entrybox">
    <dt>Edit Title:</dt>
    <dd><textarea name="title" 
      cols="40" rows="5">{$log/title/text()}</textarea></dd>
    <dt>Edit Content:</dt>
    <dd><textarea name="content"
      cols="40" rows="5">{$log/content/text()}</textarea></dd>
    </dl>
  
    <dl>
    <dt>Edit Category:</dt>
    {
      <dd>
      <select name="old-category">
        {
          for $cat in xblog:get-all-category-names()
          return
          <option>
            { if ($log/category = $cat) then $sel else () } {$cat}
          </option>
        }
      </select>
      </dd>
    }
    </dl>
    <dl>
    <dt>Or Create a New Category</dt>
    <dd><input type="text" name="new-category"/></dd>
    </dl>
  
    <dl>
    <dt>Edit State:</dt>
    <dd> { xblogd:print-state-select("state", $log/state) } </dd>
    </dl>
  
    <input type="submit" name="change" value="Change!"/>
    <input type="submit" name="cancel" value="Cancel"/>
  </form>
}

</body>
</html>
