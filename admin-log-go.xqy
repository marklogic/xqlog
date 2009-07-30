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
  let $title := xdmp:get-request-field("title")
  let $content := xdmp:get-request-field("content")

  (: Get the old category, then try getting the new category with the first :)
  (: value acting as a fallback default. :)
  let $category := xdmp:get-request-field("old-category", "")
  let $category :=
    if ($category = "") then
      xdmp:get-request-field("new-category", "")
    else
      $category
  let $logid := xdmp:get-request-field("logid")
  let $state := xdmp:get-request-field("state", "")

  let $cancel := xdmp:get-request-field("cancel")
  return

  (: Do some input data checking :)
  if ($cancel) then
    xdmp:redirect-response("admin.xqy")
  else if ($logid = "") then
    <span>
      <div class="error">The 'logid' parameter is missing</div>
      { xblogd:print-go-home() }
    </span>
  else if (not($logid castable as xs:integer)) then
    <span>
      <div class="error">The 'logid' parameter must be an integer</div>
      { xblogd:print-go-home() }
    </span>
  else if (normalize-space($title) = "") then
    <span>
      <div class="error">No title provided</div>
      { xblogd:print-go-admin() }
    </span>
  else if (normalize-space($content) = "") then
    <span>
      <div class="error">No content provided</div>
      { xblogd:print-go-admin() }
    </span>
  else if ($category = "") then 
    <span>
      <div class="error">No category provided</div>
      { xblogd:print-go-admin() }
    </span>
  else

  let $log := xblog:get-log(xs:integer($logid))
  return
  
  if (empty($log)) then
    <span>
      <div class="error">Log id '{ $logid }' unknown</div>
      { xblogd:print-go-admin() }
    </span>
  else
  
  let $chg := xblog:change-log($log, $category, $title, $content, $state)
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
