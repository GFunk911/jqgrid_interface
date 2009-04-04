require 'mharris_ext'

class GridParams
  def self.vars
    [:table, :table_id, :searchField, :searchString, :subtitle, :sopt, :grid_type]
  end
  attr_accessor *vars
  include FromHash
  def locals
    (klass.vars-[:table]).inject({}) { |h,k| h.merge(k => send(k)) }
  end
  fattr(:table_id) { table + "_" + rand(1000000000).to_i.to_s }
  def table_setup_js_url
    "/grid/table_setup_js?format=js&gp[table]=#{table}&gp[table_id]=#{table_id}&gp[searchField]=#{searchField}&gp[searchString]=#{searchString}&gp[sopt]=#{sopt}"
  end
  def title
    table.gsub(/_/," ").camelize.pluralize + (subtitle ? " - #{subtitle}" : "")
  end
  fattr(:cls) do
    CouchTable.get(table)
  end
  def columns
    cls.keys
  end
  def column_names
    cls.respond_to?(:column_names) ? cls.column_names : columns
  end
  def filtered(arr)
    col = searchField || (return arr)
    val = searchString.to_s
    return arr if col == '' or val == ''
    if sopt == 'eq'
      arr.select { |x| x.send(col).to_s == val }
    elsif sopt == 'cn'
      arr.select { |x| x.send(col).to_s =~ /#{val}/ }
    else
      raise "invalid comparison operator #{sopt}"
    end
  end
  def calc_grid_type
    return grid_type if grid_type and grid_type.strip != ''
    return 'route_grid' if table_id == 'route-grid'
    return 'subgrid' if table_id =~ /_t$/
    'grid'
  end
  def has_subgrid?
    calc_grid_type == 'grid'
  end
  def subgrid?
    calc_grid_type == 'subgrid'
  end
end