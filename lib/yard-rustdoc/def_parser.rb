# frozen_string_literal: true

require "syntax_tree"

module YARD
  module Rustdoc
    class DefParser
      # The name of the `def`'d method
      attr_reader(:name)

      # The params of the `def`'d method
      # @return [Array<[String, [String, nil]]>] An array of tuple where 0 is
      #   the name of the arg with its specifier (&, **, :) and 1 is the default.
      attr_reader(:parameters)

      def initialize(string)
        @string = string
        @name = nil
        @parameters = []
        parse!
      end

      private

      def parse!
        string = "def #{@string}; end"
        def_node = begin
          SyntaxTree.parse(string) # Program
            .child_nodes.first # Statements
            .child_nodes.first # Def
        rescue => e
          log.debug(e)
          return log.error("failed to extract def node from #{@string}\n  #{e.message}")
        end
        @name = def_node.name.value

        params = def_node.params
        params = params.contents if params.is_a?(SyntaxTree::Paren)

        params.requireds.each { |name| add_param(name) }
        params.optionals.each { |name, default| add_param(name, default) }
        add_param(params.rest) if params.rest
        params.posts.each { |name| add_param(name) }
        params.keywords.each { |name, default| add_param(name, default) }
        add_param(params.keyword_rest) if params.keyword_rest

        add_param(params.block) if params.block
      end

      def format(node)
        formatter = SyntaxTree::Formatter.new(nil)
        node.format(formatter)
        formatter.flush
        formatter.output
      end

      def add_param(node, default = nil)
        default = format(default) if default

        @parameters << [format(node), default]
      end
    end
  end
end
