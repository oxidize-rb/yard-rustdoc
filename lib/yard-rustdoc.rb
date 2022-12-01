# frozen_string_literal: true

require "json"
require "yard"

require_relative "yard-rustdoc/version"
require_relative "yard-rustdoc/parser"
require_relative "yard-rustdoc/statements"
require_relative "yard-rustdoc/handlers"
require_relative "yard-rustdoc/def_parser"

module YARD
  Parser::SourceParser.register_parser_type(:rustdoc, Parser::Rustdoc::Parser, "json")
  Handlers::Processor.register_handler_namespace(:rustdoc, Handlers::Rustdoc)
  Tags::Library.define_tag("Tagging docblock for yard", :yard)
  Tags::Library.define_tag("Renaming class & methods", :rename)
  Tags::Library.define_tag("Specify a method name and args", :def)
  Tags::Library.define_tag("Specify that a Struct should be a module (instead of class)", :module)
end
