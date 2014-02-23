module Seria
  class BaseConverter

    attr_reader :record

    def field_value
      record.read_attribute(Seria.config.fields.value)
    end

    def initialize record
      @record = record
    end

    def type_matches? klass
      field_value.is_a?(klass) ||
          (field_value.is_a?(String) && (record.field_type == klass.to_s || record.field_type == klass))
    end

    def time?
      type_matches?(DateTime) || type_matches?(Time) || type_matches?(ActiveSupport::TimeWithZone)
    end

    def fixnum?
      type_matches? Fixnum
    end

    def float?
      type_matches? Float
    end

    def boolean?
      type_matches?(TrueClass) || type_matches?(FalseClass)
    end

    def string?
      record.field_type.blank? && field_value.is_a?(String) ||
          record.field_type == 'String' ||
          record.field_type == String
    end

    def no_type?
      record.field_type.blank?
    end

    def big_decimal?
      type_matches? BigDecimal
    end

    def null?
      type_matches? NilClass
    end

    def needs_cast?
      field_value.is_a?(String) && record.field_type != 'String' && record.field_type != String
    end
  end

  class DefaultConverter < BaseConverter
    def value
      if string? || no_type? #easiest case - no cast
        field_value
      elsif needs_cast?
        if time?
          record.field_value = Time.parse(field_value).in_time_zone
        elsif fixnum?
          field_value.to_i
        elsif float?
          field_value.to_f
        elsif boolean?
          !["0", "false", "no"].include?(field_value.to_s.downcase)
        elsif big_decimal?
          field_value.to_d
        elsif null?
          nil
        else
          field_value
        end
      else
        field_value
      end
    end

    def to_db
      record.field_value = record.field_value #force cast back from varchar in case not a new entry
      value = record.read_attribute(Seria.config.fields.value)

      if time?
        record.field_value = value.utc if value
      end
      record.field_type = value.class.to_s
    end

  end

  class BigDecimalConverter < BaseConverter
    def needs_cast?
      field_value && !field_value.is_a?(BigDecimal)
    end

    def value
      if needs_cast?
        record.field_value = field_value.to_d
      end
      field_value
    end

    def to_db
      record.field_type = BigDecimal.to_s
    end
  end
end