require 'abstract_unit'

class JqueryUiHelperTest < ActionView::TestCase
  tests ActionView::Helpers::JqueryUiHelper.send(:include, ActionView::Helpers::JqueryHelper)

  def url_for(options)
    url =  "http://www.example.com/"
    url << options[:action].to_s if options and options[:action]
    url
  end

  def test_effect
    assert_equal "$(\"#posts\").effect(\"highlight\",{});", visual_effect(:highlight, "posts")
    assert_equal "$(\"#posts\").effect(\"highlight\",{});", visual_effect("highlight", :posts)
    assert_equal "$(\"#posts\").effect(\"highlight\",{});", visual_effect(:highlight, :posts)
    assert_equal "$(\"#fademe\").hide(\"fade\",{duration:4000});", visual_effect(:fade, "fademe", :duration => 4.0)
    assert_equal "$(this).effect(\"shake\",{});", visual_effect(:shake)
    assert_equal "$(\"#dropme\").hide(\"drop\",{direction:'down', queue:'end'});", visual_effect(:drop_out, 'dropme', :queue => :end)
    assert_equal "$(\"#status\").effect(\"highlight\",{endcolor:'#EEEEEE'});", visual_effect(:highlight, 'status', :endcolor => '#EEEEEE')
    assert_equal "$(\"#status\").effect(\"highlight\",{restorecolor:#500000, startcolor:'#FEFEFE'});", visual_effect(:highlight, 'status', :restorecolor => '#500000', :startcolor => '#FEFEFE')

    # chop the queue params into a comma separated list
    beginning, ending = '$("#dropme").hide("drop",{direction:\'down\', queue:{', '}});'
    ve = [
      visual_effect(:drop_out, 'dropme', :queue => {:position => "end", :scope => "test", :limit => 2}),
      visual_effect(:drop_out, 'dropme', :queue => {:scope => :list, :limit => 2}),
      visual_effect(:drop_out, 'dropme', :queue => {:position => :end, :scope => :test, :limit => 2})
    ].collect { |v| v[beginning.length..-ending.length-1].split(',') }

    assert ve[0].include?("limit:2")
    assert ve[0].include?("scope:'test'")
    assert ve[0].include?("position:'end'")

    assert ve[1].include?("limit:2")
    assert ve[1].include?("scope:'list'")

    assert ve[2].include?("limit:2")
    assert ve[2].include?("scope:'test'")
    assert ve[2].include?("position:'end'")
  end

  def test_toggle_effects
    assert_equal "$(\"#posts\").toggle(\"fade\",{});", visual_effect(:toggle_appear,  "posts")
    assert_equal "$(\"#posts\").toggle(\"slide\",{direction:'up'});",  visual_effect(:toggle_slide,   "posts")
    assert_equal "$(\"#posts\").toggle(\"blind\",{direction:'vertical'});",  visual_effect(:toggle_blind,   "posts")
    assert_equal "$(\"#posts\").toggle(\"fade\",{});", visual_effect("toggle_appear", "posts")
    assert_equal "$(\"#posts\").toggle(\"slide\",{direction:'up'});",  visual_effect("toggle_slide",  "posts")
    assert_equal "$(\"#posts\").toggle(\"blind\",{direction:'vertical'});",  visual_effect("toggle_blind",  "posts")
  end


  def test_sortable_element
    assert_dom_equal %(<script>\n//<![CDATA[\n$("#mylist").sortable({dropOnEmpty:false, update:function(){$.ajax({data:$(this).sortable('serialize',{key:"mylist"}), dataType:'script', type:'post', url:'http://www.example.com/order'})}})\n//]]>\n</script>),
      sortable_element("mylist", :url => { :action => "order" })
    assert_equal %(<script>\n//<![CDATA[\n$("#mylist").sortable({axis:'x', dropOnEmpty:false, items:'> div', update:function(){$.ajax({data:$(this).sortable('serialize',{key:"mylist"}), dataType:'script', type:'post', url:'http://www.example.com/order'})}})\n//]]>\n</script>),
      sortable_element("mylist", :tag => "div", :constraint => "horizontal", :url => { :action => "order" })
    assert_dom_equal %|<script>\n//<![CDATA[\n$("#mylist").sortable({axis:'x', connectWith:['#list1','#list2'], dropOnEmpty:false, update:function(){$.ajax({data:$(this).sortable('serialize',{key:"mylist"}), dataType:'script', type:'post', url:'http://www.example.com/order'})}})\n//]]>\n</script>|,
      sortable_element("mylist", :containment => ['list1','list2'], :constraint => "horizontal", :url => { :action => "order" })
    assert_dom_equal %(<script>\n//<![CDATA[\n$("#mylist").sortable({axis:'x', connectWith:'#list1', dropOnEmpty:false, update:function(){$.ajax({data:$(this).sortable('serialize',{key:"mylist"}), dataType:'script', type:'post', url:'http://www.example.com/order'})}})\n//]]>\n</script>),
      sortable_element("mylist", :containment => 'list1', :constraint => "horizontal", :url => { :action => "order" })
  end

  def test_draggable_element
    assert_dom_equal %(<script>\n//<![CDATA[\nnew Draggable(\"product_13\", {})\n//]]>\n</script>),
      draggable_element("product_13")
    assert_equal %(<script>\n//<![CDATA[\nnew Draggable(\"product_13\", {revert:true})\n//]]>\n</script>),
      draggable_element("product_13", :revert => true)
  end

  def test_drop_receiving_element
    assert_dom_equal %(<script>\n//<![CDATA[\nDroppables.add(\"droptarget1\", {onDrop:function(element){$.ajax({data:'id=' + encodeURIComponent(element.id), dataType:'script', type:'post', url:'http://www.example.com/'})}})\n//]]>\n</script>),
      drop_receiving_element("droptarget1")
    assert_dom_equal %(<script>\n//<![CDATA[\nDroppables.add(\"droptarget1\", {accept:'products', onDrop:function(element){$.ajax({data:'id=' + encodeURIComponent(element.id), dataType:'script', type:'post', url:'http://www.example.com/'})}})\n//]]>\n</script>),
      drop_receiving_element("droptarget1", :accept => 'products')
    assert_dom_equal %(<script>\n//<![CDATA[\nDroppables.add(\"droptarget1\", {accept:'products', onDrop:function(element){$.ajax({data:'id=' + encodeURIComponent(element.id), success:function(request){$('#infobox').html(request);}, type:'post', url:'http://www.example.com/'})}})\n//]]>\n</script>),
      drop_receiving_element("droptarget1", :accept => 'products', :update => 'infobox')
    assert_dom_equal %(<script>\n//<![CDATA[\nDroppables.add(\"droptarget1\", {accept:['tshirts','mugs'], onDrop:function(element){$.ajax({data:'id=' + encodeURIComponent(element.id), success:function(request){$('#infobox').html(request);}, type:'post', url:'http://www.example.com/'})}})\n//]]>\n</script>),
      drop_receiving_element("droptarget1", :accept => ['tshirts','mugs'], :update => 'infobox')
    assert_dom_equal %(<script>\n//<![CDATA[\nDroppables.add(\"droptarget1\", {hoverclass:'dropready', onDrop:function(element){if (confirm('Are you sure?')) { $.ajax({data:'id=' + encodeURIComponent(element.id), dataType:'script', type:'post', url:'http://www.example.com/update_drop'}); }}})\n//]]>\n</script>),
    drop_receiving_element('droptarget1', :hoverclass=>'dropready', :url=>{:action=>'update_drop'}, :confirm => 'Are you sure?')

  end
  def protect_against_forgery?
    false
  end
end
