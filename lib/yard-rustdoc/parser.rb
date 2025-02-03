# frozen_string_literal: true

module YARD::Parser::Rustdoc
  class Parser < YARD::Parser::Base
    TOP_LEVEL_KINDS = ["struct", "enum"].freeze

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

        # "inner" is a Rust enum serialized with serde, resulting in a
        # { "variant": { ...variant fields... } } structure.
        # See https://github.com/rust-lang/rust/blob/f79a912d9edc3ad4db910c0e93672ed5c65133fa/src/rustdoc-json-types/lib.rs#L104
        kind, inner = entry["inner"].first

        next unless TOP_LEVEL_KINDS.include?(kind)

        methods = inner
          .fetch("impls")
          .flat_map do |impl_id|
            @rustdoc_json.dig(impl_id.to_s, "inner", "impl", "items")
          end
          .filter_map do |method_id|
            method_entry = @rustdoc_json.fetch(method_id.to_s)
            next unless relevant_entry?(method_entry)

            Statements::Method.new(method_entry)
          end

        @entries << Statements::Struct.new(entry, methods)
      end

      # Ensure Foo comes before Foo::Bar
      @entries.sort_by!(&:name)

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
