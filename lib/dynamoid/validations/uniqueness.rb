module Dynamoid
  module Validations
    class UniquenessValidator < ActiveModel::EachValidator # :nodoc:
      def initialize(options)
        if options[:conditions] && !options[:conditions].respond_to?(:call)
          raise ArgumentError, "#{options[:conditions]} was passed as :conditions but is not callable. " \
            "Pass a callable instead: `conditions: -> { where(approved: true) }`"
        end

        super({ case_sensitive: true }.merge!(options))
      end

      # Unfortunately, we have to tie Uniqueness validators to a class.
      def setup(klass)
        @klass = klass
      end

      def validate_each(record, attribute, value)
        if record.class.exists?(attribute => value)
          error_options = options.except(:case_sensitive, :scope, :conditions)
          error_options[:value] = value

          record.errors.add(attribute, :taken, error_options)
        end
      end
    end

    module ClassMethods
      def validates_uniqueness_of(*attr_names)
        validates_with UniquenessValidator, _merge_attributes(attr_names)
      end
    end
  end
end
