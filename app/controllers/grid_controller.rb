class Column
  attr_accessor :column
end

class Object
  def to_appr_type
    to_s.to_appr_type
  end
end

class NilClass
  def to_appr_type
    nil
  end
end

class Numeric
  def to_appr_type
    self
  end
end

class String
  def to_appr_type
    return self if self == ''
    if self =~ /^[0-9\.]+$/
      to_f
    else
      self
    end
  end
end

class GridController < ApplicationController
  def index
    @tables = []
  end
  def table_setup_js
    gp = GridParams.new(params[:gp])
    puts "rendering table_setup_js with table_id #{gp.table_id}"
    render :partial => 'table_setup_js', :locals => {:gp => gp}
  end
  def get_rows(gp,params)
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
      rows = sorted_by_params(rows,params)
      rows = gp.filtered(rows)
      rows = rows.map { |x| x.flows }.flatten if detail
      rows = rows
      rows
    end
  end
  def grid_data
    gp = GridParams.new(params[:gp])
    @rows = get_rows(gp,params)
    render :partial => 'grid_data', :locals => {:gp => gp}
  end
  def sorted_by_params(arr,ops)
    col = params[:sidx] || (return arr)
    res = arr.sort_by { |x| x.send(col).to_appr_type }
    res = res.reverse if params[:sord] == 'desc' and col != 'id'
    res
  end
  def new_doc
    raise "can't create new flows"
    Flow.new
  end
  def update
    respond_to do |format|
      format.js do
        puts params.inspect
        detail = (params[:detail].to_s == 'true')
        obj = (params[:id] and params[:id] != '_empty') ? GraphManager.instance.db.flows(:detail => detail).find { |x| x.id == params[:id] } : new_doc
        [:id,:authenticity_token,:action,:controller,:oper,:table,:detail].each { |x| params.delete(x) }
        raise "nil obj" unless obj
        params.each { |k,v| obj.send("#{k}=",v) }
        obj.save
        render :text => 'sup'
      end
    end
  end
  def new_column
    col = params[:column][:column]
    CouchTable.new(params[:table]).add_column(col)
    redirect_to :controller => 'grid', :action => 'index'
  end
  def remove_column
    col = params[:column]
    CouchTable.new(params[:table]).remove_column(col)
    redirect_to :controller => 'grid', :action => 'index'
  end
  def showx
    @table = CouchTable.new(params[:table])
    @row = @table.docs.find { |x| x.id == params[:id] }
  end
  def new_table
    table = params[:table][:column]
    CouchTable.new(table).create!
    redirect_to :controller => 'grid', :action => 'index'
  end
    
end
