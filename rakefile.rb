require 'rake'
require 'lib/map_boundary'
require 'yaml'

CONTENTS=<<CONTENTS_HERE_DOC
<html>
<head>
  <title>Scouting for Food 2010</title>
<style type="text/css">
  body { 
    margin-left: 10%; 
    margin-right: 10%; 
    font-family: sans-serif
  }
  h2 { margin-top: 1em }
  h2,h3,h4,h5,h6 { margin-left: -3% }
  pre {
     color: green; font-weight: bold;
     white-space: pre; font-family: "Courier New", monospace;
  }
  tt { color: green }
  em { font-style: italic; font-weight: bold }
  strong { text-transform: uppercase; font-weight: bold }
  .navbar {text-align: center }
  .example {
    color: rgb(153,0,51);
    border: none;
    padding: 0.5em;
    width: 100%;
    background-color: rgb(255,255,153)
  }
  pre.example {
    font-family: "Lucida Console", "Courier New", monospace;
    white-space: pre;
  }
  table {
    margin-left: -4%;
    font-family: sans-serif;
    background: white;
    border-width: 2px;
    border-color: white;
  }
  th { font-family: sans-serif; background: rgb(204, 204, 153) }
  td { font-family: sans-serif; background: rgb(255, 255, 153) }
  table.centered {
    margin-left: auto;
    margin-right: auto;
  }
</style>

<center>
<h1>SCOUTING FOR FOOD 2010</h1>
</center>

<h2>Old Missions District, November 6 and 13, 2010</h2>

<p>
It is time once again for the annual Scouting for Food Good Turn.  The Old Missions District and the Inland Northwest Council anticipate that this will result again in the largest collection of its kind in our community.</p>

<p>
Your role as the Unit Leader is to organize your Unit to help carry out this project.  There are a couple of things you will need to do to get ready:
</p>

<ol>
<li>Find your assigned collection area. (Collection areas are mostly the same as last year, but may contain minor changes.) See the list below for assigned collection areas. You may print a map of your assigned area from your web browser.  It is imperative that you stay in your assigned area.  If your'e interested in a neighbor's area please work it out the changes with them and contact Chris Tenbrink at <a href=mailto:scout4food@gmail.com>scout4food@gmail.com</a> to update the assigned areas.</li>
<li>Pickup bags at Roundtable or the North Idaho Service Center.</li>
</ol>

<p>
There are two options for handing out bags:
<ol>
<li>To make it a two-weekend event, drop off bags on Saturday, November 6th and pick up bags on Saturday, November 14.</li>
<li>For a one-weekend event, drop off and collect the bags on the same day on Saturday, November 13th.</li>
</ol>

<p>
We recommend that you make this a one-weekend event.
</p>

<p>
All Scouts and registered Unit Leaders should be in uniform.  This makes us easy to identify and also promotes Scouting to the community.  With your help, we can make a difference for the people in need in our community.  We can make the holidays special for many children and adults throughout our District.  There are food banks at different locations throughout the area. A list of drop-off locations will be provided on October 15th.
</p>
<p>
Please call the North Idaho Service Center at 772-2455 with any questions you may have.
</p>


<center>
<table cellspacing="1" cellpadding="8">
<tr align="center">
<th>Unit</th>
<th>Area</th>
</tr>
CONTENTS_HERE_DOC

desc 'Generate an HTML file with links to maps.'
task :generate_html do
  map_data = File.read "./data/scouting_for_food_maps.yaml"
  map_ary = YAML.load(map_data)

  unit_data = File.read "./data/unit_assignments.yaml"
  unit_hsh = YAML.load(unit_data)

  html_dir = 'html'
  html_file = 'index.html' 
  mkdir html_dir unless File.exists? html_dir
  File.open("#{html_dir}/#{html_file}", 'w') do |outfile|
    outfile << CONTENTS
    map_ary.each do |el|
      unit = unit_hsh[el.name]
      outfile.puts "<tr align=\"center\">"
      outfile.puts "<td>#{unit.nil? ? "" : unit}</td>"
      outfile.puts "<td>#{el.name} (<a href = #{el.get_url}>map</a>)</td>"
      outfile.puts "</tr>"
    end
    
    outfile.puts "</table>"
    outfile.puts "</center>"
  end
end
