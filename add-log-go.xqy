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

<h1 class="title">Enter new Post</h1>

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
  
  let $cancel := xdmp:get-request-field("cancel")
  return

  (: Do some input data checking :)
  if ($cancel) then
    xdmp:redirect-response("default.xqy")
  else if ($category = "") then 
    <span>
      <div class="error">No category provided</div>
      { print-go-home() }
    </span>
  else if (normalize-space($title) = "") then
    <span>
      <div class="error">No post title provided</div>
      { print-go-home() }
    </span>
  else if (normalize-space($content) = "") then
    <span>
      <div class="error">No post content provided</div>
      { print-go-home() }
    </span>
  else

  let $add-title := add-log($category, $title, $content)
  return

  <span>
    <div class="action-explain">
      Your post has been recorded.  After administrator review it will be
      posted on the live site.
    </div>
    { print-go-home() }
  </span>
}

</body>
</html>
