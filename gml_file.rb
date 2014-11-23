
class GmlFile

  def initialize
    @nodes = []
    @edges = []
  end

  def add_node(node)
    @nodes << node
  end

  def add_edge(from, to, attributes)
    @edges << [from, to, attributes]
  end

  def self.fmt_attr(key, value)
    s = value.is_a?(Integer) ? value.to_s : "\"#{value}\""
    "#{key} #{s}"
  end

  def self.fmt_node(file, node)
    [ "node [",  
      node.map{ |k, v| fmt_attr(k, v) },
      "]" ].flatten.join("\n") + "\n"
  end

  def self.fmt_edge(file, edge)
    from, to, attributes = edge
    ["edge [", 
     "source #{from}",
     "target #{to}", 
     attributes.map{ |k, v| fmt_attr(k, v) },
     "]" ].flatten.join("\n") + "\n"
  end

  def write(path)
    File.open(path, 'wb') do |file|
      file.write("graph\n")
      file.write("[\n")
      @nodes.each{ |n| file.write(self.class.fmt_node(file, n)) }
      @edges.each{ |e| file.write(self.class.fmt_edge(file, e)) }
      file.write("]\n")
    end
  end

end

