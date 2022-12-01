# frozen_string_literal: true

module YARD::Handlers
  module Rustdoc
    class Base < YARD::Handlers::Base
      include YARD::Parser::Rustdoc

      def self.statement_class(klass = nil)
        @statement_classes ||= []
        @statement_classes << klass

        nil
      end

      def self.handles?(statement, processor)
        handles = true
        if @statement_classes.any?
          handles &&= @statement_classes.any? { |klass| statement.is_a?(klass) }
        end

        handles
      end

      def register_file_info(object, file = statement.file, line = statement.line, comments = statement.docstring)
        super
      end

      def register_docstring(object, docstring = statement.docstring, stmt = statement)
        super
      end
    end

    class StructHandler < Base
      statement_class(Statements::Struct)

      process do
        obj = statement.code_object_class.new(:root, statement.name)
        register(obj)

        push_state(namespace: obj) do
          parser.process(statement.methods)
        end
      end
    end

    class MethodHandler < Base
      statement_class(Statements::Method)

      process do
        obj = MethodObject.new(namespace, statement.name, statement.scope)
        obj.parameters = statement.parameters if statement.parameters
        register(obj)
      end
    end
  end
end
