# Copyright:: (c) Autotelik Media Ltd 2011
# Author ::   Tom Statter
# Date ::     Aug 2010
# License::   MIT
#
#  Details::  Base class for generators, which provide services to describe a Model in an external format
#
module DataShift

  class GeneratorBase

    attr_accessor :headers, :remove_list

    def initialize()
      @headers = Headers.new(:na)
      @remove_list =[]
    end

    def self.rails_columns
      @rails_standard_columns ||= [:id, :created_at, :created_on, :updated_at, :updated_on]
    end


    # Parse options and build collection of headers
    # Provide a ModelMethods::collection

    # Default is to include *everything*
    #
    # * <tt>:exclude</tt> - Association TYPE(s) to exclude completely.
    #
    #     Possible association_type values are given by ModelMethod.supported_types_enum
    #       ... [:assignment, :belongs_to, :has_one, :has_many]
    #
    # * <tt>:remove</tt> - Array of header names to remove
    #
    # Rails DB columns like id, created_at, updated_at are removed by default
    #
    # * <tt>:include_rails</tt> - Specify to keep Rails columns in mappings
    #
    def prepare_model_headers(collection, options = {})

      op_type_list = ModelMethod.supported_types_enum.to_a - [ *options[:exclude] ]

      @headers = Headers.new(collection.klass)

      op_type_list.each do |assoc_type|

        model_methods = collection.for_type(assoc_type)

        model_methods.each do |mm|
          #comparable_association = md.operator.to_s.downcase.to_sym
          #i = remove_list.index { |r| r == comparable_association }
          #(i) ? remove_list.delete_at(i) : @headers << "#{md.operator}"
          @headers << mm.operator
        end
      end

      remove_headers(options)

      @headers

    end

    alias_method :collection_to_headers, :prepare_model_headers


    # Parse options and remove  headers
    # Specify columns to remove with :
    #   options[:remove]
    # Rails columns like id, created_at are removed by default,
    #  to keep them in specify
    #   options[:include_rails]
    #
    def remove_headers(options)
      remove_list = prep_remove_list( options )

      #TODO - more efficient way ?
      headers.delete_if { |h| remove_list.include?( h.to_sym ) } unless(remove_list.empty?)
    end


    # Take options and create a list of symbols to remove from headers
    # Rails columns like id, created_at etc are added to the remove list by default
    # Specify :include_rails to keep them in
    def prep_remove_list( options )
      remove_list = [ *options[:remove] ].compact.collect{|x| x.to_s.downcase.to_sym }

      remove_list += GeneratorBase::rails_columns unless(options[:include_rails])

      remove_list
    end

  end

end