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

import module "http://www.w3.org/2003/05/xpath-functions" at "xqlog-lib.xqy"
import module "http://www.w3.org/2003/05/xpath-functions" at "xqlog-display.xqy"

if (not(is-login()))
then
  xdmp:redirect-response("login.xqy")
else
xdmp:set-response-content-type("text/html"),

<html xml:space="preserve">
<head>
<link rel="stylesheet" type="text/css" href="style.css" />
<title>{get-title()}</title>
</head>
<body class="help">

<h1 class="title">Post a reply.</h1>

{
  let $logid := xdmp:get-request-field("logid")
  let $text := xdmp:get-request-field("text")

  let $cancel := xdmp:get-request-field("cancel")
  return

  (: Do some input data checking :)
  if ($cancel) then
    xdmp:redirect-response("default.xqy")
  else if ($logid = "") then
    <span>
      <div class="error">The 'logid' parameter is missing</div>
      { print-go-home() }
    </span>
  else if (not($logid castable as xs:integer)) then
    <span>
      <div class="error">The 'logid' parameter must be an integer</div>
      { print-go-home() }
    </span>
  else if (normalize-space($text) = "") then
    <span>
      <div class="error">No reply text provided</div>
      { print-go-home() }
    </span>
  else
  
  let $log := get-log(xs:integer($logid))
  return
  
  if (empty($log)) then
    <span>
      <div class="error">Log id '{ $logid }' unknown</div>
      { print-go-home() }
    </span>
  else
  
  let $add := add-reply($log, $text)
  return

  <span>
    <div class="action-explain">
      Your reply has been recorded.  After administrator review it will be 
      posted on the live site.
    </div>
    { print-go-home() }
  </span>
}

</body>
</html>
