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

xdmp:set-response-content-type("text/html"),

let $q := xdmp:get-request-field("q")
let $entries := search-entries($q)

return

<html xml:space="preserve">
<head>
<link rel="stylesheet" type="text/css" href="style.css" />
<title>{get-title()}</title>
</head>
<body class="help">

{ print-intro() }

<form action="search.xqy">
  <input type="text" name="q" value="{$q}"/>
  <input type="submit" value="Search"/>
</form>

{ print-go-home() }

<hr />
<h2>Search results for "{ $q }":</h2>

{
  if (empty($entries)) then <div class="error">No entries</div> else
  for $entry in $entries
  return print-entry($entry)
}

</body>
</html>