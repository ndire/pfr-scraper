
require_relative 'pfr_scraper'
require_relative 'coach_graph'

task :download, [:year] do |t, args|
  years = args.year ? [ args.year ] : (1980..2013).to_a

  years.each do |y|
    puts y
    doc = PfrScraper.get_url(['years', y.to_s])
    teams = PfrScraper.get_team_links(doc, 'AFC') + PfrScraper.get_team_links(doc, 'NFC')
    coaches = teams.map{ |team|
      PfrScraper.get_coaches(team).merge({ :year => y })
    }.to_a
    File.open(File.join('data', y.to_s + '.json'), 'wb') do |file|
      file.write(coaches.to_json)
    end
  end
end

task :dump, [:year] do |t, args|
  cg = CoachGraph.new
  cg.read('data', args.year)
  cg.for_year(args.year).each{ |t| 
    puts "#{t['team']} #{t['Head']['id']}"
  }
end

task :write, [:year]  do |t, args|
  years = args.year ? [ args.year ] : (1980..2013).to_a

  cg = CoachGraph.new
  cg.read('data', years)
  cg.as_undirected.write_gml('coaches.gml')
end
