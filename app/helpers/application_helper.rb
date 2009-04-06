# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def include_jqgrid_interface_js_and_css
    render :partial => 'grid/app_includes'
  end
  def render_grid(ops)
    ops[:sopt] ||= 'eq'
    gp = GridParams.new(ops)
    render :partial => 'grid/table', :object => gp
  end
  def render_whole_grid(t)
    render_grid :table => t, :searchString => t, :searchField => 'table'
  end
end