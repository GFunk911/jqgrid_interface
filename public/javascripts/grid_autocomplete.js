function getTableForInput(el) {
	return el.parent().parent().parent().parent()
}

$(function() {
   $('input').live('keypress',function() {
	  if ($(this).attr('class') != 'ac_input') {
		//alert('setting autocomplete ' + kp + " input id " + $(this).attr('id'))
	    //$(this).autocomplete(['10','11','12','13','14','50','51','5','52'])
	    t = getTableForInput($(this))
	    table = t.attr('table-type')
	    app = t.attr('app')
	    $(this).autocomplete("/grid/autocomplete_values?table="+table+"&app="+app+"&input_id="+$(this).attr('id'))
	    //$(this).search()
	  }
   })
})