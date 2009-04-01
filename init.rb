# Include hook code here

require File.dirname(__FILE__) + "/app/helpers/application_helper"
require File.dirname(__FILE__) + "/app/helpers/grid_helper"

class JSLink
  def plugin_js
    File.expand_path(File.dirname(__FILE__) + "/public/javascripts")
  end
  def link_path
    File.expand_path(File.dirname(__FILE__) + "/../../../public/javascripts/jqgrid_interface")
  end
  def make_link_raw!
    puts "making link at #{link_path} to #{plugin_js}"
    puts `ln -s "#{plugin_js}" "#{link_path}"`
  end
  def make_link!
    if FileTest.exists?(link_path)
      puts "link already exists"
    else
      make_link_raw!
    end
  end
end
  
JSLink.new.make_link!