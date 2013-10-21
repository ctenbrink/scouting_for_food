require 'rake'
require 'rake/clean'
require './lib/map_boundary'
require 'yaml'
require 'net/http'
require 'prawn'

$html_dir = 'html'
$pdf_dir = 'pdf'
CLEAN.include("#{$html_dir}/*.html")
CLEAN.include("#{$html_dir}/*.png")
CLEAN.include("#{$pdf_dir}/*.png")
CLEAN.include("#{$pdf_dir}/*.pdf")

STYLE=<<STYLE_HERE_DOC
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
STYLE_HERE_DOC

CONTENTS=<<CONTENTS_HERE_DOC
<html>
<head>
<title>Old Missions Scouting for Food 2013</title>

#{STYLE}

<center>
<h1>SCOUTING FOR FOOD 2013</h1>
</center>

<h2>Old Missions District, November 9, 2013</h2>

<p>
It is time once again for the annual Scouting for Food Good Turn.  The Old Missions District and the Inland Northwest Council anticipate that this will result again in the largest collection of its kind in our community.</p>

<p>
Your role as the Unit Leader is to organize your unit to help carry out this project.  There are a couple of things you will need to do to get ready:
</p>

<ol>
<li>Register your unit's participation. The council would like to keep better track of how many units are planning to participate in this event. You can register your unit on <a href=http://www.nwscouts.org/form/formjump.asp?bidx=0&surveyID=23901&OrgKey=778>www.nwscouts.org</a>. Units who submit a roster of participants will recieve a patch for each Scout.</li>
<li>Find your assigned collection area. (Collection areas are mostly the same as last year, but may contain minor changes.) See the list below for assigned collection areas. You may print a map of your assigned area from your web browser.  It is imperative that you stay in your assigned area.  If you are interested in a neighbor's area please work out the changes with them and contact Chris Tenbrink at <a href=mailto:scout4food@gmail.com>scout4food@gmail.com</a> to update the assigned areas.</li>
<li>Pickup bags at Roundtable or the North Idaho Service Center.</li>
</ol>

<p>
All Scouts and registered Unit Leaders should be in uniform.  This makes us easy to identify and also promotes Scouting to the community.  With your help, we can make a difference for the people in need in our community.  We can make the holidays special for many children and adults throughout our district. Please drop off the food your unit collects at one of the food banks listed below. Food banks are expecting deliveries between 10 AM and 3 PM on Saturday, November 9. 
</p>
<p>
Please call the North Idaho Service Center at 772-2455 with any questions you may have.
</p>

<!--
<ul>
<li>Coeur d'Alene, 664-8757</li>
<li>Post Falls, 773-0139</li>
<li>Rathdrum, 687-3696</li>
<li>Kellogg, 783-4901</li>
<li>St. Maries, 245-9090</li>
<li>Athol, 683-2101</li>
<li>Spirit Lake, 623-3107</li>
</ul>
-->
<center>
<table cellspacing="1" cellpadding="8">
  <tbody>
    <th colspan="3"><p align="center">Drop-off Locations</p></th></tr>
    <tr><td>Coeur d'Alene</td><td>Community Action Partnership Food Bank</td><td>4942 Industrial Ave. East, Coeur d'Alene</td></tr>
    <tr><td>Post Falls</td><td>Post Falls Food Bank</td><td>415 E. 3rd St., Post Falls</td></tr>
    <tr><td>Rathdrum</td><td>Rathdrum Food Bank</td><td>827 Main St., Rathdrum</td></tr>
    <tr><td>Kellogg</td><td>Shoshone County Food Bank</td><td>311 Main St., Kellogg</td></tr>
    <tr><td>St. Maries</td><td>Community Action Partnership Food Bank</td><td>416 Main St., St. Maries</td></tr>
    <tr><td>Spirit Lake</td><td>Spirit Lake Food Bank</td><td>32154 4th St., Spirit Lake</td></tr>
    <tr><td>Pinehurst</td><td>Real Life Ministries Food Room</td><td>S. 10 Division St., Pinehurst</td></tr>
  </tbody>
</table>
</center>
<p>
<p>
<center>
<table cellspacing="1" cellpadding="8">
<tr align="center">
<th>Unit</th>
<th>Area</th>
</tr>
CONTENTS_HERE_DOC

desc 'Generate an HTML file with links to maps.'
task :generate_simple_html do
  map_data = File.read "./data/scouting_for_food_maps.yaml"
  map_ary = YAML.load(map_data)

  unit_data = File.read "./data/unit_assignments.yaml"
  unit_hsh = YAML.load(unit_data)

  html_file = 'simple.html' 
  mkdir $html_dir unless File.exists? $html_dir
  File.open("#{$html_dir}/#{html_file}", 'w') do |outfile|
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

def download_maps(map_ary, dest_dir)
  map_ary.each do |el|
    print "Downloading map for Area #{el.name}..."
    Net::HTTP.start(el.get_domain) do |http|
      response = http.get("#{el.get_path}#{el.get_query}")
      File.open("#{dest_dir}/#{el.name}.png", "wb") do |outfile|
        outfile.write(response.body)
      end
    end
    print "done\n"
  end
end

desc 'Generate an HTML file with links to static pages with local maps.'
task :generate_local_html do
  map_data = File.read "./data/scouting_for_food_maps.yaml"
  map_ary = YAML.load(map_data)

  unit_data = File.read "./data/unit_assignments.yaml"
  unit_hsh = YAML.load(unit_data)

  mkdir $html_dir unless File.exists? $html_dir  

  download_maps(map_ary, $html_dir)

  map_ary.each do |el|
    print "Writing html for Area #{el.name}..."
    File.open("#{$html_dir}/#{el.name}.html", 'w') do |outfile|
      unit = unit_hsh[el.name]
      outfile.puts "<html>"
      outfile.puts "<head>"
      outfile.puts "<title>Scouting for Food 2013 - Area #{el.name}</title>"
      outfile.puts "#{STYLE}"
      outfile.puts "<h2>Area #{el.name}</h2>"
      unless( unit.nil? ) 
        outfile.puts "<h2>#{unit}</h2>"
      end
      outfile.puts "<p>"
      outfile.puts "<img src=\"#{el.name}.png\" alt=\"Area #{el.name} Map\" />"
      outfile.puts "</p>"
    end
    print "done\n"
  end


  html_file = 'local.html' 
  File.open("#{$html_dir}/#{html_file}", 'w') do |outfile|
    outfile << CONTENTS
    map_ary.each do |el|
      unit = unit_hsh[el.name]
      outfile.puts "<tr align=\"center\">"
      outfile.puts "<td>#{unit.nil? ? "" : unit}</td>"
      outfile.puts "<td>#{el.name} (<a href = #{el.name}.html>map</a>)</td>"
      outfile.puts "</tr>"
    end
    
    outfile.puts "</table>"
    outfile.puts "</center>"
  end
end

desc 'Generate a pdf file containing maps for each unit.'
task :generate_local_pdf do
  map_data = File.read "./data/scouting_for_food_maps.yaml"
  map_ary = YAML.load(map_data)

  unit_data = File.read "./data/unit_assignments.yaml"
  unit_hsh = YAML.load(unit_data)

  mkdir $pdf_dir unless File.exists? $pdf_dir  

  download_maps(map_ary, $pdf_dir)

  Prawn::Document.generate "./#{$pdf_dir}/ScoutingForFoodMapBook.pdf" do
    move_down 80
    font_size 28 
    text "Old Missions District", :align=>:center, :style=>:bold_italic
    text "Scouting For Food Map Book", :align=>:center, :style=>:bold_italic
    text "2013", :align=>:center, :style=>:bold_italic
    start_pg_number = 4
    cur_pg = start_pg_number
    pgs = []
    map_ary.each do |el|
      pgs << {:pg_title => "Area #{el.name} - #{unit_hsh[el.name]}", 
              :pg_image => "./#{$pdf_dir}/#{el.name}.png",
              :pg_number => cur_pg
             }
      cur_pg += 1
    end
      
    start_new_page
    font_size 18
    text "Table of Contents", :align=>:center, :font_size=>14, :style=>:bold_italic
    move_down 40
    font_size 12
    num_chars = 75
    font "Courier" do
      pgs.each do |el|
        num_dots = num_chars - (el[:pg_title].length + el[:pg_number].to_s.length)
        dots = "."*num_dots 
        text "#{el[:pg_title]}#{dots}#{el[:pg_number]}", :kerning => false
      end
    end

    font_size 18
    pgs.each do |el|
      start_new_page
      outline.page :title => el[:pg_title], :destination => el[:pg_number]
      text el[:pg_title]
      move_down 20
      image el[:pg_image], :width=>480, :position=>:center
    end

    options = { :at => [bounds.right - 150, 0],
                :width => 150,
                :align => :right,
                :page_filter => lambda{|pg| pg >= start_pg_number},
                :start_count_at => start_pg_number
              }
    number_pages "<page>", options
  end
 
end
