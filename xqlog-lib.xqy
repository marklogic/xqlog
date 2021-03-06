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

module namespace xblog = "http://www.marklogic.com/xqlog-lib";
declare default function namespace "http://www.w3.org/2005/xpath-functions";

(: Define the paths for the log id and the log entry
:)
declare variable $log-dir := ( "/xqlog/" );
declare variable $log-id  := ( "/xqlog/ids.xml" );
declare variable $log-base :=( "/xqlog/log-" );

(: Return the currently "logged in" user
:)
declare function xblog:get-user() as xs:string
{
  xdmp:get-session-field("xqlog-user", "") 
};

declare function xblog:is-login()
{
  if (xblog:get-user())
  then
    true()
  else
    false()
};

(: Return a monotonically increasing integer (xs:integer) value.              
   Store the value in the root node of doc($log-id).                   
   You could enhance this file to store IDs for multiple uses.          
   Logic is to fetch the current id, add one if it exists or assign the
   value to one if it doesn't yet exist, then replace or insert the new
   value before returning it.
:)
declare function xblog:next-id() as xs:integer
{
  let $id := doc($log-id)/id
  let $next-val :=
    if ($id castable as xs:integer) then xs:integer($id) + 1
    else 1
  let $next-node := <id>{$next-val}</id>
  let $insert :=
    if ($id) then xdmp:node-replace($id, $next-node)
    else xdmp:document-insert($log-id, $next-node)
  return $next-val
};

(: Update a node with the specified elements
 :)
declare function xblog:update-node($root, $changes) {

  element { node-name($root) }
  { 
    $root/@*,

    for $ele in $root/*
      let $new := $changes[node-name(.) = node-name($ele)]
      return if (empty($new)) then $ele else $new
  }
};


(: Return all category strings. :)
declare function xblog:get-live-category-names() as xs:string*
{
  let $user := xdmp:get-session-field("xqlog-user")
  for $s in distinct-values(xdmp:directory($log-dir, "1")
    //log[state="live" or author=$user]/category)
  return xs:string($s)
};

declare function xblog:get-all-category-names() as xs:string*
{
  for $s in distinct-values(xdmp:directory($log-dir, "1")//log/category)
  return xs:string($s)
};

declare function xblog:get-sorted-live-entries($category as xs:string)
as element(entry)*
{
  let $user := xdmp:get-session-field("xqlog-user")
  for $entry in xdmp:directory($log-dir, "1")
    /entry[log/state="live" or log/author=$user][log/category = $category]
  order by xs:dateTime($entry/log/date)
  return $entry
};


(: Search for a word or phrase across all live log text blocks,
   then return the containing <log> element.
:)
declare function xblog:search-logs($phrase as xs:string)
as element(log)*
{
  let $user := xdmp:get-session-field("xqlog-user")
  return
  cts:search(
    xdmp:directory($log-dir, "1")//log[state="live" or author=$user],
    cts:or-query((
      cts:element-word-query(xs:QName("title"), $phrase),
      cts:element-word-query(xs:QName("content"), $phrase))))
};

(: Similar to the above but queries against live replies.
:)
declare function xblog:search-replies($phrase as xs:string)
as element(reply)*
{
  let $user := xdmp:get-session-field("xqlog-user")
  return
  cts:search(xdmp:directory($log-dir, "1")//reply[state="live" or author=$user],
      cts:element-word-query(xs:QName("text"), $phrase))[1 to 20]
};

(: Search for a word or phrase across all live logs or replies.
   The returned values are relevance ranked.  The results have a numeric
   "score" but here we're not utilizing it.  We just return the containing
   <entry> element.
:)
declare function xblog:search-entries($phrase as xs:string)
as element(entry)*
{
  let $user := xdmp:get-session-field("xqlog-user")
  return
  cts:search(xdmp:directory($log-dir, "1")//*[state = "live" or author=$user],
    cts:or-query((
      cts:element-word-query(xs:QName("title"), $phrase),
      cts:element-word-query(xs:QName("content"), $phrase),
      cts:element-word-query(xs:QName("text"), $phrase))))
    [1 to 20]/ancestor::entry
};


declare function xblog:get-log($id as xs:integer) as element(log)?
{
  xdmp:directory($log-dir, "1")//log[@id = $id]
};

declare function xblog:get-reply($id as xs:integer) as element(reply)?
{
  xdmp:directory($log-dir, "1")//reply[@id = $id]
};


declare function xblog:get-entries-in-categories($categories as xs:string*)
as element(entry)*
{
  let $user := xdmp:get-session-field("xqlog-user")
  return
  xdmp:directory($log-dir, "1")/entry[log/category = $categories]
               [log/state = "live" or log/author=$user]
};


declare function xblog:get-entries-in-states($state as xs:string*)
as element(entry)*
{
  (:
   : XXX: should I check for get-current-user ?
   :)
  xdmp:directory($log-dir, "1")/entry[log/state=$state or reply/state=$state]
};

declare function xblog:add-log($category as xs:string,
                        $title as xs:string,
                        $content as xs:string) as element(log)
{
  if ($title = "") then error("Add log called with empty title") else
  if ($content = "") then error("Add log called with empty content") else
  let $next-id := xblog:next-id()
  let $new-log :=
    <log id="{$next-id}">
      <category>{$category}</category>
      <state>submitted</state>
      <author>{xdmp:get-session-field("xqlog-user")}</author>
      <date>{current-dateTime()}</date>
      <title xml:space="preserve">{$title}</title>
      <content xml:space="preserve">{$content}</content>
    </log>
  let $insert := xdmp:document-insert(
                         concat($log-base, xs:string($next-id)),
                         <entry>{$new-log}</entry>)
  return $new-log
};

declare function xblog:change-log($log as element(log),
                                $category as xs:string,
                                $title as xs:string,
                                $content as xs:string,
                                $state as xs:string) as element(log)
{
  if ($title = "") then error("Change log called with empty title") else
  if ($content = "") then error("Change log called with empty content") else
  if (not($state = ("submitted", "live", "dead"))) then error("No state") else
  let $new-log := xblog:update-node($log, (
        <state>{ $state }</state>,
        <title xml:space="preserve">{$title}</title>,
        <content xml:space="preserve">{$content}</content>
      ))
  let $replace := xdmp:node-replace($log, $new-log)
  return $new-log
};

declare function xblog:add-reply($log as element(log),
                           $text as xs:string) as element(reply)
{
  let $new-reply := 
    if ($text = "") then error("Add reply called with empty text") else
    <reply id="{xblog:next-id()}">
      <state>submitted</state>
      <author>{xdmp:get-session-field("xqlog-user")}</author>
      <date>{current-dateTime()}</date>
      <text xml:space="preserve">{$text}</text>
    </reply>
  let $insert := xdmp:node-insert-child($log/.., $new-reply)
  return $new-reply
};

declare function xblog:change-reply($reply as element(reply),
                              $text as xs:string,
                              $state as xs:string) as element(reply)
{
  if ($text = "") then error("Change reply called with empty text") else
  let $new-reply := xblog:update-node($reply, (
        <state>{$state}</state>,
        <text xml:space="preserve">{$text}</text>
      ))
  let $replace := xdmp:node-replace($reply, $new-reply)
  return $new-reply
};



(:
 - - - - - Destructive calls below here - - - - -
 - - - - - These shouldn't be exposed in normal use of the app - - - - -
:)

declare function xblog:delete-entries($entries as element(entry)*)
{
  for $entry in $entries
  return xdmp:node-delete($entry)
};

declare function xblog:delete-reply($replies as element(reply)*)
{
  for $r in $replies
  return xdmp:node-delete($r)
};

