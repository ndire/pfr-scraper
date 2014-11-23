
require 'rubygems'
require 'bundler/setup'

require 'restclient'
require 'nokogiri'
require 'pp'

require 'irb'

module PfrScraper

  BASE_URL='http://www.pro-football-reference.com'

  def self.get_url(path)
    response = RestClient.get [ BASE_URL, path ].flatten.join('/')
    Nokogiri::HTML(response.to_s)
  end

  def self.get_team_links(doc, conf)
    afc = doc.xpath("//table[@id='#{conf}']")
    afc.xpath("descendant::a").map{ |link|
      href = link.attribute('href')
      href if href.to_s.start_with?('/teams')
    }.compact
  end

  def self.get_coaches(team_path)
    doc = get_url(team_path)

    team_name = doc.xpath("//h1").first.text()
    team_name = team_name.gsub(/\d{4}/, '').strip

    elements = doc.xpath("//span[text()='Coach']").first.parent.children

    coaches = { 'team' => team_name }
    key = 'Head'
    elements.each do |e|
      if e.name == 'a' && key
        href =  e.attribute('href').value
        guid = File.basename(href, '.htm')
        coaches[key] = { :href => href, :guid => guid, :name => e.text }
        key = nil
      elsif e.text.include?('Offensive')
        key = 'Offensive'
      elsif e.text.include?('Defensive')
        key = 'Defensive'
      end
    end
    coaches
  end

end
