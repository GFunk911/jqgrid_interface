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
    res = CouchRest::Document.new
    res['app'] = 'lunch'
    res.database = App.get('lunch').db
    res
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
        make_new = (params[:id] and params[:id] != '_empty')
        obj = make_new ? find_obj(params) : new_doc
        [:id,:authenticity_token,:action,:controller,:oper,:detail].each { |x| params.delete(x) }
        raise "nil obj" unless obj
        params.each { |k,v| obj.send("#{k}=",v) }
        obj.save
        TableManager.instance! if make_new
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
  def show
    @app = App.get(params[:app])
    @table = @app.get_table(params[:table])
    @row = @table.docs.find { |x| x.id == params[:id] }
  end
  def new_table
    app = App.get(params[:table][:app])
    table = app.get_table(params[:table][:table])
    table.create!
    redirect_to :controller => 'grid', :action => 'index'
  end
  def autocomplete_values_old
    col = params[:input_id].split("_")[1..-1].join("_")
    app = App.get(params[:app])
    letter = params[:q]
    vals = Column.new(:app => app, :table => params[:table], :column => 'person').possible_values
    vals = vals.select { |x| x =~ /^#{letter}/i } unless letter.blank?
    str = vals.join("\n")
    render :text => str
    #render :text => (1..100).to_a.join("\n")
  end 
  def autocomplete_values
    render :text => AutoCompleter.new(params).values_str
  end
end

class AutoCompleter
  attr_accessor :app, :table, :column, :letter
  def initialize(params)
    @column = params[:input_id].split("_")[1..-1].join("_")
    @table = params[:table]
    @app = App.get(params[:app])
    @letter = params[:q]
  end
  fattr(:column_obj) { Column.new(:app => app, :table => table, :column => column) }
  def values
    res = column_obj.possible_values
    res = res.select { |x| x =~ /^#{letter}/i } unless letter.blank?
    res
  end
  def values_str
    values.join("\n")
  end
end
