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

{ xblogd:print-intro() }

{
  let $state := xdmp:get-request-field("state", "all") (: default = all :)
  let $states :=
    if ($state = "all") then ("submitted", "live", "dead") else $state
  return
  
  <span>
    <form>
      Limit view to state: { xblogd:print-state-select-all("state", $state) }
      <input type="submit" value="Change State"/>
    </form>
  
    {
      for $entry in xblog:get-entries-in-states($states)
      return xblogd:print-admin-entry($entry, $states)
    }
  
    {
      xblogd:print-go-home()
    }
  </span>
}

</body>
</html>
