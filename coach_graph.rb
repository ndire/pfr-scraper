
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

  def add_edge(from, to)
    (@edges[from['guid']] ||= Hash.new{ 0 })[to['guid']] += 1
  end

  def analyze(peer=false)
    @edges.clear
    @coaches.clear
    @teams.each do |staff|
      staff_coaches = staff.reject{ |k, v| ['year', 'team'].include?(k) }
      staff_coaches.values.each{ |c| @coaches[c['guid']] = c }
      if peer
        # Add all, canonicalize by guid alpha order.
        staff_coaches = staff_coaches.values
        staff_coaches.uniq.sort_by{ |c| c['guid'] }
        while !staff_coaches.empty? do
          c = staff_coaches.shift
          staff_coaches.each do |s|
            add_edge(c, s)
          end
        end
      else
        # Just add head -> coords
        head = staff_coaches['Head']
        staff_coaches.each do |role, coach|
          if role != 'Head' && head != coach
            add_edge(head, coach)
          end
        end
      end
    end
    self
  end

  def as_peer()
    analyze(true)
  end

  def as_tree()
    analyze(false)
  end

  def write_gml(path)
    gml = GmlFile.new
    indexed_coaches = {}
    @coaches.each_pair.each_with_index do |pair, index|
      guid, attrs = pair
      attrs = attrs.clone
      attrs['label'] = attrs.delete('name')
      # Need int ID for igraph.
      attrs['id'] = index
      indexed_coaches[attrs['guid']] = attrs
      gml.add_node(attrs)
    end
    @edges.each do |from, list|
      list.each do |to, count|
        from_id = indexed_coaches[from]['id']
        to_id = indexed_coaches[to]['id']
        gml.add_edge(from_id, to_id, { 'value' => count } )
      end
    end
    gml.write(path)
  end

end
