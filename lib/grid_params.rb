require 'mharris_ext'

class BaseGridParams
  def self.base_vars
    [:table, :table_id, :searchField, :searchString, :subtitle, :sopt, :grid_type]
  end
  def self.vars
    base_vars
  end
  attr_accessor *vars
  include FromHash
  def locals
    (self.class.vars-[:table]).inject({}) { |h,k| h.merge(k => send(k)) }
  end
  fattr(:table_id) { table + "_" + rand(1000000000).to_i.to_s }
  def table_setup_js_url
   base = "/grid/table_setup_js?format=js&"
   query = self.class.vars.map { |x| "gp[#{x}]=#{send(x)}" }.join("&")
   base + query
  end
  def grid_data_url
   base = '/grid/grid_data?format=xml&'
   query = self.class.vars.map { |x| "gp[#{x}]=#{send(x)}" }.join("&")
   base + query
  end
  def title
    table.gsub(/_/," ").camelize.pluralize + (subtitle ? " - #{subtitle}" : "")
  end
  def get_app
    App.get(app)
  end
  fattr(:cls) do
    get_app.get_table(table)
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
  def sorted(arr,ops)
    puts "sorted_by_params #{ops.inspect}"
    col = ops[:sidx] || (return arr)
    res = arr.sort_by { |x| x.send(col).to_appr_type }
    res = res.reverse if ops[:sord] == 'desc' and col != 'id'
    res
  end
  def get_rows(params)
    gp=self
    detail = (params[:detail].to_s == 'true')
    route_grid = (gp.grid_type == 'full_route')
    if route_grid
      rows = gp.cls.docs
      rows = rows.map { |x| x.flows }.flatten
      rows = gp.filtered(rows)
      raise "should be one row, not #{rows.size}" unless rows.size == 1
      rows = rows.first.flows_to_dest
      rows
    else
      rows = gp.cls.docs
      rows = gp.sorted(rows,params)
      rows = gp.filtered(rows)
      rows = rows.map { |x| x.flows }.flatten if detail
      rows = rows
      rows
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

class GridParams < BaseGridParams
end