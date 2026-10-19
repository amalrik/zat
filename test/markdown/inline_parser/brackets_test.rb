# frozen_string_literal: true

require "test_helper"
require "zat/markdown"

class BracketsTest < Minitest::Test
  def setup
    @brackets = Zat::Markdown::InlineParser::Brackets.new
  end

  def test_pops_the_innermost_opener
    @brackets.push(index: 0, image: false)
    @brackets.push(index: 3, image: true)

    assert_equal [3, true], @brackets.pop.then { [it.index, it.image] }
    assert_equal 0, @brackets.pop.index
    assert_nil @brackets.pop
  end

  def test_a_closed_link_kills_the_links_below_it_but_not_images
    @brackets.push(index: 0, image: false)
    @brackets.push(index: 1, image: true)
    @brackets.push(index: 2, image: false)
    @brackets.link_closed

    assert_nil @brackets.pop
    assert_equal 1, @brackets.pop.index
    assert_nil @brackets.pop
  end

  def test_openers_pushed_after_a_link_are_alive
    @brackets.push(index: 0, image: false)
    @brackets.link_closed
    @brackets.push(index: 5, image: false)

    assert_equal 5, @brackets.pop.index
    assert_nil @brackets.pop
  end

  def test_the_dead_height_drops_with_the_stack
    @brackets.push(index: 0, image: false)
    @brackets.push(index: 1, image: false)
    @brackets.link_closed
    2.times { @brackets.pop }
    @brackets.push(index: 7, image: false)

    assert_equal 7, @brackets.pop.index
  end
end
