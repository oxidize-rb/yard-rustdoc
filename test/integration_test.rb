# frozen_string_literal: true

require "test_helper"

class IntegrationTest < Minitest::Test
  def setup
    super
    parse_example
  end

  def test_class_can_be_renamed
    assert_defined("Example::Renamed")
  end

  def test_method_can_be_renamed
    assert_defined("Example::Foo#renamed")
  end

  def test_only_tagged_code_is_documented
    assert_defined("Example::Foo.new")
    assert_defined("Example::Foo#bar")
    assert_defined("Example::SomeEnum")
    refute_defined("Example::Foo#secret")
    refute_defined("Example::Secret")
  end

  def test_rb_self_as_first_param_defines_instance_method
    refute_defined("Example::Foo.with_rb_self")
    assert_defined("Example::Foo#with_rb_self")
  end

  def test_self_and_rb_self_works_with_ruby_arg
    refute_defined("Example::Foo.with_ruby_and_self")
    assert_defined("Example::Foo#with_ruby_and_self")

    refute_defined("Example::Foo.with_ruby_and_rb_self")
    assert_defined("Example::Foo#with_ruby_and_rb_self")
  end

  def test_params_are_extracted_from_def
    foo_bar = YARD::Registry.at("Example::Foo#bar")
    params = foo_bar.parameters.to_h
    expected = {
      "req" => nil,
      "opt" => "[]",
      "*args" => nil,
      "reqkw:" => nil,
      "optkw:" => "nil",
      "**kwargs" => nil,
      "&block" => nil
    }

    assert_equal(expected, params)
  end

  def test_removes_atyard_tag
    foobar = YARD::Registry.at("Example::Foo#bar")
    refute(foobar.has_tag?("yard"), "@yard tag should be removed")
  end

  def test_struct_can_be_a_module
    not_class = YARD::Registry.at("NotClass")
    assert_equal(:module, not_class.type)
  end

  private

  def assert_defined(id)
    refute_nil(YARD::Registry.at(id), "#{id} should be defined")
  end

  def refute_defined(id)
    assert_nil(YARD::Registry.at(id), "#{id} should not exist")
  end
end
