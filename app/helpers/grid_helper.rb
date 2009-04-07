module GridHelper
  def column_desc(col,table,app,last)
    comma = (last ? "" : ",")
    col_obj = Column.new(:table => table, :column => col, :app => app)
    # "{name:'#{col}', index:'#{col}', editable:'true', width:'250'}"
    eb = col_obj.editable?
    h = {:name => col, :index => col, :editable => eb, :width => 150, :sortable => true}
    if col_obj.dropdown?
      h[:edittype] = 'select'
      str = col_obj.possible_values.map { |x| "#{x}:#{x}" }.join(";")
      h[:editoptions] = {:value => str, :class => 'gridSelect'}.to_js_hash
    end
    if col_obj.column == 'link'
      #h[:formatter] = 'link'
      h[:formatter] = 'myLink'
    end
    if col_obj.column == 'foo'
    #  h[:formatter] = 'fooFormatter'
    end
  
    h.to_js_hash.gsub(/'myLink'/,"myLink") + comma
  end
  def pretty_title(table,column)
    str = column.gsub(/_/," ").camelize
    delete_url = "/grid/remove_column?table=#{table}&column=#{column}"
    str
  end
end

class Hash
  def to_js_hash
    "{" + map do |k,v|
      v = "'#{v}'" unless %w(true false).include?(v.to_s) or v.to_s =~ /^\d+$/ or v.to_s[0..0] == "{"
      "#{k}:#{v}"
    end.join(", ") + "}"
  end
end
module FromHash
  def from_hash(ops)
    ops.each do |k,v|
      send("#{k}=",v)
    end
  end
  def initialize(ops={})
    from_hash(ops)
  end
end
class Column
  attr_accessor :table, :column, :app
  include FromHash
  def possible_values
    return [] unless map_row
    map_row.possible_values
  end
  fattr(:map_row) do
    app.constraints(ForeignKey).find { |x| x.child_table == table and x.child_column == column }
  end
  def dropdown?
    !!map_row
  end
  def all_values
    CouchTable.new(table).possible_values(column)
  end
  def editable?
    cols = app.constraints.select { |x| x.child_table == table and x.child_column == column }
    return true if cols.empty?
    cols.any? { |x| x.child_editable? }
  end
  def pretty_name
    column.gsub(/_/," ").split(" ").map { |x| x.camelize }.join(" ")
  end
end