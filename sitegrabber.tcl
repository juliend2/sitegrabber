package require http
package require xml

set stylesheets [list]

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

proc element_start {name attlist args} {
  # we modify the upper scope's stylesheets list
  global stylesheets
  if { [dict exists $attlist type] && [dict get $attlist type] == "text/css" } {
    # puts [dict get $attlist href]
    # by appending stylesheets to it
    lappend stylesheets [dict get $attlist href]
  }
}

proc get_style_links {html} {
  # grab all the css file urls from the HTML
  set parser [::xml::parser -elementstartcommand element_start]
  return [$parser parse $html]
}

proc main {argv} {
  global stylesheets
  set destination_path [lindex $argv 0]
  set url [lindex $argv 1]
  if { [file exists $destination_path] == 0 } {
    puts "The folder $destination_path was not found."
    exit
  }
  set token [http::geturl $url]
  set body [http::data $token]
  # puts $body
  set page [download $url $destination_path "iso8859-1"]
  catch {get_style_links $page} errmsg
  puts $stylesheets
}

# Let there be light...
main $argv

