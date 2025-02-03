# frozen_string_literal: true

require "test_helper"

class IntegrationTest < Minitest::Test
  SUPPORTED_VERSIONS = ["v33", "v39"].freeze

  def self.test(name, &block)
    SUPPORTED_VERSIONS.each do |version|
      define_method(:"test_#{name}_#{version}") do
        parse_example(version)
        instance_exec(&block)
      end
    end
  end

  test("class_can_be_renamed") do
    assert_defined("Example::Renamed")
  end

  test("method_can_be_renamed") do
    assert_defined("Example::Foo#renamed")
  end

  test("only_tagged_code_is_documented") do
    assert_defined("Example::Foo.new")
    assert_defined("Example::Foo#bar")
    assert_defined("Example::SomeEnum")
    refute_defined("Example::Foo#secret")
    refute_defined("Example::Secret")
  end

  test("rb_self_as_first_param_defines_instance_method") do
    refute_defined("Example::Foo.with_rb_self")
    assert_defined("Example::Foo#with_rb_self")
  end

  test("self_works_with_ruby_arg") do
    refute_defined("Example::Foo.with_ruby_and_rb_self")
    assert_defined("Example::Foo#with_ruby_and_rb_self")
  end

  test("params_are_extracted_from_def") do
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

  test("removes_atyard_tag") do
    foobar = YARD::Registry.at("Example::Foo#bar")
    refute(foobar.has_tag?("yard"), "@yard tag should be removed")
  end

  test("struct_can_be_a_module") do
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
