
require_relative 'gml_file'

class CoachGraph

  def initialize
    @teams = []
    @edges = {}
    @coaches = {}
  end

  def read(dirpath, years)
    [years].flatten.each do |y|
      @teams += File.open(File.join(dirpath, "#{y}.json")) do |file|
        JSON.parse(file.read)
      end
    end
    self
  end

  def for_year(year)
    @teams.select{ |t| t['year'].to_i == year.to_i }
  end

  def as_undirected()
    @edges.clear
    @coaches.clear
    @teams.each do |staff|
      staff.delete('year')
      staff.delete('team')
      staff = staff.values.uniq.sort_by{ |c| c['guid'] }
      while !staff.empty? do
        c = staff.shift
        @coaches[c['guid']] = c
        staff.each do |s|
          (@edges[c['guid']] ||= Hash.new{ 0 })[s['guid']] += 1
        end
      end
    end
    self
  end

  def write_gml(path)
    gml = GmlFile.new
    @coaches.each_pair.each_with_index do |pair, index|
      guid, attrs = pair
      # XXX: shouldn't modify in place.
      attrs['label'] = attrs.delete('name')
      # Need int ID for igraph.
      attrs['id'] = index
      gml.add_node(attrs)
    end
    @edges.each do |from, list|
      list.each do |to, count|
        from_id = @coaches[from]['id']
        to_id = @coaches[to]['id']
        gml.add_edge(from_id, to_id, { 'value' => count } )
      end
    end
    gml.write(path)
  end

end
