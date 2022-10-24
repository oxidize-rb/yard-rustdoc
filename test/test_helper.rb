# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "yard"
require "yard-rustdoc"

require "minitest/autorun"

class Minitest::Test
  private

  def parse_example
    Dir.chdir("test/samples/example-ext") do
      parse_file("rustdoc.json")
    end
  end

  def parse_file(src)
    YARD::Registry.clear
    YARD::Parser::SourceParser.parse(src)
  end
end
