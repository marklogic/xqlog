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

module "http://www.w3.org/2003/05/xpath-functions"

import module "http://www.w3.org/2003/05/xpath-functions" at "xqlog-lib.xqy"

define variable $app-title { "xqlog" }

define function get-title() as xs:string
{
  $app-title
}

define function print-user() as element()
{
  if (is-login())
  then
    <span>login:
      <a href="login.xqy?logout=logout" title="Logout">{get-user()}</a>
    </span>
  else
    <a href="login.xqy" title="Login">Login</a>
}

define function print-go-home() as element()
{
  <div class="go-home">
    <a href="default.xqy">Return to the main listing</a></div>
}

define function print-go-admin() as element()
{
  <div class="go-admin">
    <a href="admin.xqy">Return to the admin listing</a></div>
}

define function print-intro() as element()
{
  (
  <h1 class="title">{$app-title}</h1>,
  <div class="intro">
    <p class="l">This BLOG is powered by Content Interaction Server.</p>
    <p class="r">{print-user()}</p>
  </div>
  )
}

define function print-search() as element()
{
  <form action="search.xqy" class="search-box">
    <input type="text" name="q"/>
    <input type="submit" value="Search"/>
  </form>
}

define function print-category($cat as xs:string) as element()
{
  <span>
    <h1>{$cat}</h1>
    {
      for $entry in get-sorted-live-entries($cat)
      return print-entry($entry)
    }
	<p class="return"><a href="#top">Return to top</a></p>
  </span>
}

(: Takes element(log) and element(reply) :)
define function is-new($item as element()) as xs:boolean
{
  let $threshold := xdt:dayTimeDuration("PT12H")
  let $threshold-moment := current-dateTime() - $threshold
  return xs:dateTime($item/date) > $threshold-moment
}

define function print-entry($entry as element(entry)) as element()
{
  let $user := get-user()
  let $log := $entry/log
  let $live-replies := $entry/reply[state="live" or author=$user]
  return
  <span xml:space="preserve">
  <dl class="xqlog">
    <dt>
      {if (is-new($log)) then <span>New!</span> else ()}
      {print-preserving($log/title/text())}
    </dt>
    <dd class="log">{print-preserving($log/content/text())}</dd>
    <dt/>
    {
      for $reply in $live-replies
      return <dd>{if (is-new($reply)) then <span>New! </span> else ()}
                 {print-preserving($reply/text/text())}
      </dd>
    }
  </dl>

  {
  if (is-login())
  then
    <p class="add-reply">
      <a href="add-reply.xqy?logid={$log/@id}">Submit a new reply</a>
    </p>
  else
    ()
  }
  </span>
}


define function print-state-select-all($name as xs:string,
                                       $starter as xs:string) as element(select)
{
  let $sel := <x selected="selected"/>/@selected
  return
  <select name="{$name}">
    <option>
      { if ($starter = "all") then $sel else () } all
    </option>
    <option>
      { if ($starter = "submitted") then $sel else () } submitted
    </option>
    <option>
      { if ($starter = "live") then $sel else () } live
    </option>
    <option>
      { if ($starter = "dead") then $sel else () } dead
    </option>
  </select>
}

define function print-state-select($name as xs:string,
                                   $starter as xs:string) as element(select)
{
  let $sel := <x selected="selected"/>/@selected
  return
  <select name="{$name}">
    <option>
      { if ($starter = "submitted") then $sel else () } submitted
    </option>
    <option>
      { if ($starter = "live") then $sel else () } live
    </option>
    <option>
      { if ($starter = "dead") then $sel else () } dead
    </option>
  </select>
}

define function limit-string($str as xs:string, $max as xs:integer) as xs:string
{
  if (string-length($str) > $max) then
    concat(substring($str, 0, $max), "...")
  else
    $str
}

define function print-admin-entry($entry as element(entry),
                                  $states as xs:string*)
as element()
{
  (: print the log regardless of state :)
  <dl>
  <dt>{ print-admin-log($entry/log) }</dt>
  {
    for $reply in $entry//reply[state = $states]
    return <dd>{print-admin-reply($reply)}</dd>
  }
  <dd><a href="add-reply.xqy?logid={$entry/log/@id}">Submit a new reply</a></dd>
  </dl>
}

define function print-admin-log($log as element(log))
as element()
{
  let $id := data($log/@id)
  let $title-str := limit-string(string($log/title/text()), 80)
  let $content-str := limit-string(string($log/content/text()), 80)
  return
  <div>
    <span class="{$log/state/text()}">
      <a href="admin-log.xqy?logid={$id}">Entry {$id}</a>: { $title-str }
    </span>
    <br/>
    {$content-str}
  </div>
}

define function print-admin-reply($reply as element(reply))
as element()
{
  let $id := data($reply/@id)
  let $str := limit-string(string($reply/text/text()), 80)
  return
  <div class="{$reply/state/text()}">
  <a href="admin-reply.xqy?repid={$id}">Reply {$id}</a>: { $str }
  </div>
}


define function print-preserving($texts as text()*) as item()*
{
  print-preserve-code(string-join($texts, ""))
}

define function print-preserve-code($str as xs:string) as item()*
{
  let $before-begin := substring-before($str, "<code>")
  let $after-begin := substring-after($str, "<code>")
  return
    if ($before-begin = "" and $after-begin = "")
    then preserve-newlines($str)
    else
  let $middle := substring-before($after-begin, "</code>")
  let $middle := if ($middle = "") then $after-begin else $middle
  let $after-end := substring-after($after-begin, "</code>")
  return (preserve-newlines($before-begin),
          <pre>{$middle}</pre>,
          print-preserve-code($after-end))
}

define function preserve-newlines($str as xs:string) as node()*
{
  for $line in tokenize($str, "\n")
  return ($line, <br/>)
}

