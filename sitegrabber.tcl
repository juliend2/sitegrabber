package require http
package require xml

set stylesheets [list]
set javascripts [list]

proc download {url path {encoding "utf-8"}} {
  # Download the file:
  set token [http::geturl $url]
  set body [http::data $token]
  # Write it to a local file:
  set file_name [file tail $url]
  set channel [open $file_name w]
  fconfigure $channel -encoding $encoding ; # We need to set the encoding
  puts $channel $body
  return $body
}

proc parser_element_start {name attlist args} {
  # we modify the upper scope's stylesheets list
  global stylesheets
  global javascripts
  if { $name == "link" && [dict exists $attlist type] && [dict get $attlist type] == "text/css" } {
    lappend stylesheets [dict get $attlist href]
  }
  if { $name == "script" && [dict exists $attlist src] } {
    lappend javascripts [dict get $attlist src]
  }
}

proc get_asset_sheets {html} {
  # grab all the css file urls from the HTML
  set parser [::xml::parser -elementstartcommand parser_element_start]
  return [$parser parse $html]
}

proc main {argv} {
  global stylesheets
  global javascripts
  set destination_path [lindex $argv 0]
  set url [lindex $argv 1]
  if { [file exists $destination_path] == 0 } {
    puts "The folder $destination_path was not found."
    exit
  }
  set token [http::geturl $url]
  set body [http::data $token]
  set page [download $url $destination_path "iso8859-1"]
  catch {get_asset_sheets $page} errmsg
  puts "StyleSheets: $stylesheets"
  puts "JavaScripts: $javascripts"
}

# Let there be light...
main $argv

