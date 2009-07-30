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
import module namespace xblog="http://www.marklogic.com/xqlog-lib" at "xqlog-lib.xqy";
import module namespace xblogd="http://www.marklogic.com/xqlog-display" at "xqlog-display.xqy";
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

<h1 class="title">Enter a new log</h1>
<p class="intro">Your log will be submitted to the moderator before posting.</p>

<form action="add-log-go.xqy" method="get" class="xqlog-ask">
  <dl class="entrybox">
  <dt>Your Post title:</dt>
  <dd><textarea name="title" cols="40" rows="5">&nbsp;</textarea></dd>
  </dl>

  <dl class="entrybox">
  <dt>Your Post content:</dt>
  <dd><textarea name="content" cols="40" rows="5">&nbsp;</textarea></dd>
  </dl>

  <dl>
  <dt>Choose a Category:</dt>
  {
    <dd>
    <select name="old-category">
      <option value="">Choose a Category</option>
      {
        for $cat in xblog:get-live-category-names()
        return <option>{$cat}</option>
      }
    </select>
    </dd>
  }
  </dl>

  <dl>
  <dt>Or Create a New Category</dt>
  <dd><input type="text" name="new-category"/></dd>
  </dl>
 
  <input type="submit" name="post" value="Post!"/>
  <input type="submit" name="cancel" value="Cancel"/>
</form>

<p class="intro">Hint: Use &lt;code&gt; tags around code blocks for better
   formatting.</p>

</body>
</html>
