require 'rubygems'
require 'google_chart'
require 'hpricot'
require 'open-uri'
require 'yaml'

class Chart
  def pull_data
    result = []
    puts "Pulling data from meetup site..."
    
    key = YAML::load(File.open("config/meetup.yml"))['key']
    after = (Date.today - 270).strftime('%m%d%Y')
    before = Date.today.strftime('%m%d%Y')
    doc = open("http://api.meetup.com/events.xml?group_urlname=raleighrb&after=#{after}&before=#{before}&status=past&format=xml&key=#{key}") { |f| Hpricot.XML(f) }
    
    (doc/"results/items/item").map do |item|
      venue_id = (item/"venue_id").inner_html
      next unless Venue.all.include?(venue_id)
      month = Date.parse((item/"time").inner_html).strftime('%b')
      count = (item/"rsvpcount").inner_html.to_i
      result << [month, count]
    end
    
    result
  end
  
  def url
    result = ""
    
    data = pull_data
    months = data.collect{|e| e.first}
    attendance = data.collect{|e| e.last}
    
    GoogleChart::BarChart.new("250x150", "", :vertical, false) do |lc|
      lc.show_legend = false
      lc.width_spacing_options :bar_width => "a", :bar_spacing => 10, :group_spacing => 10
      lc.data "Attendance", attendance, "555"
      lc.axis :y, :range => [0,attendance.max], :font_size => 14, :alignment => :center
      lc.axis :x, :labels => months, :font_size => 14, :alignment => :center
      lc.grid :x_step => 100.0/10.0, :y_step => 100.0/10.0, :length_segment => 1, :length_blank => 0
      puts "Google chart generated"
      result = lc.to_url
    end
    result
  end
  
  def self.update
    `wget -O public/images/chart.png "#{Chart.new.url}"`
  end
end

class Venue
  RED_HAT = "25606"
  ICONTACT = "390501"
  WEBASSIGN = "1440374"
  
  def self.all
    [RED_HAT, ICONTACT, WEBASSIGN]
  end
end
