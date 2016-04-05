require 'abstract_unit'

class JavaScriptHelperTest < ActionView::TestCase
  tests ActionView::Helpers::JavaScriptHelper

  def _evaluate_assigns_and_ivars() end

  attr_accessor :formats, :output_buffer

  def update_details(details)
    @details = details
    yield if block_given?
  end

  def setup
    super
    ActiveSupport.escape_html_entities_in_json  = true
    @template = self
  end

  def teardown
    ActiveSupport.escape_html_entities_in_json  = false
  end
  
  def test_link_to_function_with_rjs_block
    html = link_to_function( "Greet me!" ) do |page|
      page.replace_html 'header', "<h1>Greetings</h1>"
    end
    assert_dom_equal %(<a href="#" onclick="$(&quot;#header&quot;).html(&quot;\\u003ch1\\u003eGreetings\\u003c/h1\\u003e&quot;);; return false;">Greet me!</a>), html
  end

  def test_link_to_function_with_rjs_block_and_options
    html = link_to_function( "Greet me!", :class => "updater" ) do |page|
      page.replace_html 'header', "<h1>Greetings</h1>"
    end
    assert_dom_equal %(<a href="#" class="updater" onclick="$(&quot;#header&quot;).html(&quot;\\u003ch1\\u003eGreetings\\u003c/h1\\u003e&quot;);; return false;">Greet me!</a>), html
  end

  def test_link_to_function_with_inner_block_does_not_raise_exception
    html = link_to_function( "Greet me!" ) do |page|
      page.replace_html 'header', (content_tag :h1 do
        'Greetings'
      end)
    end
    assert_dom_equal %(<a href="#" onclick="$(&quot;#header&quot;).html(&quot;\\u003ch1\\u003eGreetings\\u003c/h1\\u003e&quot;);; return false;">Greet me!</a>), html
  end
  
  def test_button_to_function_with_rjs_block
    html = button_to_function( "Greet me!" ) do |page|
      page.replace_html 'header', "<h1>Greetings</h1>"
    end
    assert_dom_equal %(<input type="button" onclick="$(&quot;#header&quot;).html(&quot;\\u003ch1\\u003eGreetings\\u003c/h1\\u003e&quot;);;" value="Greet me!" />), html
  end

  def test_button_to_function_with_rjs_block_and_options
    html = button_to_function( "Greet me!", :class => "greeter" ) do |page|
      page.replace_html 'header', "<h1>Greetings</h1>"
    end
    assert_dom_equal %(<input class="greeter" type="button" value="Greet me!" onclick="$(&quot;#header&quot;).html(&quot;\\u003ch1\\u003eGreetings\\u003c\/h1\\u003e&quot;);;" />), html
  end
end
