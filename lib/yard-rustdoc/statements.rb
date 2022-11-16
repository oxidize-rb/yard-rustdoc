# frozen_string_literal: true

module YARD::Parser::Rustdoc
  module Statements
    class Base
      def initialize(rustdoc)
        @rustdoc = rustdoc
        @name = nil
        @parameters = []
      end

      def docstring
        @rustdoc.fetch("docs")
      end

      def source
        return if file.nil?

        File.read(file)
          .lines
          .slice(line_index_range)
          .join
      rescue Errno::ENOENT
        log.warn("can't read '#{file}', cwd='#{Dir.pwd}'")

        ""
      end

      def line
        line_range.first
      end

      def line_range
        @rustdoc.dig("span", "begin", 0)...@rustdoc.dig("span", "end", 0)
      end

      def file
        @rustdoc.dig("span", "filename")
      end

      def show
        @rustdoc.to_s
      end

      # Not sure what should go here either
      def comments_hash_flag
      end

      def comments_range
      end

      private

      def line_index_range
        (@rustdoc.dig("span", "begin", 0) - 1)..@rustdoc.dig("span", "end", 0)
      end
    end

    class Struct < Base
      attr_reader(:methods)

      def initialize(rustdoc, methods)
        super(rustdoc)
        @methods = methods
      end

      def name
        return $1.strip if docstring =~ /^@rename\s*(.+)/

        @rustdoc["attrs"].each do |attr|
          next unless attr.include?("magnus")

          # Extract class name from magnus attrs that define classes such as:
          #   - #[magnus::wrap(class = "ClassName")]
          #   - #[magnus(class = "ClassName")]
          return $1.strip if attr =~ /class\s*=\s*"([^"]+)"/
        end

        # Fallback to the struct's name
        @rustdoc.fetch("name")
      end
    end

    class Method < Base
      def name
        parse_def!

        @name || @rustdoc.fetch("name")
      end

      def scope
        first_arg = @rustdoc.dig("inner", "decl", "inputs", 0, 0)
        if first_arg == "self" || first_arg == "rb_self"
          :instance
        else
          :class
        end
      end

      # Parses the parameters from the @def annotations in the docstring
      def parameters
        parse_def!

        @parameters
      end

      private

      # Extract @def tag from the docstring. Has to be done before we create
      # the CodeObject in the `handler` because:
      #   1. The method name can be overriden -- it's too late for that once
      #   the method code object exists.
      #   2. The docstring parser runs automatically after the code object is
      #   created, and emits warning on udnefined `@param`. We need to set the
      #   method's parameters before then.
      def parse_def!
        return if defined?(@def_parsed)
        @def_parsed = true

        parsed = YARD::DocstringParser.new.parse(@rustdoc.fetch("docs"))
        def_tag = parsed.tags.find do |tag|
          tag.respond_to?(:tag_name) && tag.tag_name == "def"
        end

        return unless def_tag

        parser = YARD::Rustdoc::DefParser.new(def_tag.text)
        @name = parser.name
        @parameters = parser.parameters || []
      end
    end
  end
end
