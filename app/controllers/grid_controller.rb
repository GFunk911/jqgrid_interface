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
    @tables = ['players']
  end
  def table_setup_js
    gp = GridParams.new(params[:gp])
    puts "rendering table_setup_js with table_id #{gp.table_id}"
    render :partial => 'table_setup_js', :locals => {:gp => gp}
  end
  def grid_data
    gp = GridParams.new(params[:gp])
    @rows = gp.get_rows(params)
    render :partial => 'grid_data', :locals => {:gp => gp}
  end
  def new_doc
    raise "can't create new flows"
    Flow.new
  end
  def find_obj(params)
    app = App.get(params[:app])
    #GraphManager.instance.db.flows(:detail => detail).find { |x| x.id == obj_id }
    app.get_table(params[:table]).docs.find { |x| x.id == params[:id] }
  end
  def update
    respond_to do |format|
      format.js do
        puts params.inspect
        detail = (params[:detail].to_s == 'true')
        obj = (params[:id] and params[:id] != '_empty') ? find_obj(params) : new_doc
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
