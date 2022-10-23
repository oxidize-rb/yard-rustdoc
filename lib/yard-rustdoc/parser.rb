# frozen_string_literal: true

module YARD::Parser::Rustdoc
  class Parser < YARD::Parser::Base
    # This default constructor does nothing. The subclass is responsible for
    # storing the source contents and filename if they are required.
    # @param [String] source the source contents
    # @param [String] filename the name of the file if from disk
    def initialize(source, filename)
      @source = source
      @rustdoc_json = JSON.parse(@source).fetch("index") do
        raise "Expected `index` top-level key in Rustdoc json format"
      end
      @filename = filename
      @entries = []
    end

    # Override inspect instead of dumping the file content because it is huge.
    def inspect
      "<#{self.class.name} @filename=#{@filename.inspect}>"
    end

    # Finds Rust Struct for the current crate marked with @yard and extract all
    # the marked methods.
    # @return [Base] this method should return itself
    def parse
      @entries = []

      @rustdoc_json.each do |id, entry|
        next unless relevant_entry?(entry)
        next unless entry["kind"] == "struct"

        methods = entry
          .dig("inner", "impls")
          .flat_map { |impl_id| @rustdoc_json.dig(impl_id, "inner", "items") }
          .filter_map do |method_id|
            method_entry = @rustdoc_json.fetch(method_id)
            next unless relevant_entry?(method_entry)

            Statements::Method.new(method_entry)
          end

        @entries << Statements::Struct.new(entry, methods)
      end

      self
    end

    def tokenize
      raise "Rustdoc Parser does not tokenize"
    end

    # This method should be implemented to return a list of semantic tokens
    # representing the source code to be post-processed. Otherwise the method
    # should return nil.
    #
    # @abstract
    # @return [Array] a list of semantic tokens representing the source code
    #   to be post-processed
    # @return [nil] if no post-processing should be done
    def enumerator
      @entries
    end

    private

    def relevant_entry?(entry)
      return false unless entry["crate_id"].zero?
      return false unless entry["docs"]&.include?("@yard")

      true
    end
  end
end
