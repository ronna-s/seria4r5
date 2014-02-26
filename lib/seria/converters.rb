module Seria
  class DefaultConverter
    attr_reader :value, :type
    def initialize(value, type)
      @value, @type = value, type
    end

    def klass
      if type.present?
        type
      else
        value.class.to_s
      end
    end

    def conversions
      @conversions ||=
          {
              'Fixnum' => lambda { value.to_i },
              'BigDecimal' => lambda { value.to_d },
              'Float' => lambda { value.to_f },
              'NilClass' => nil,
              'FalseClass' => false,
              'TrueClass' => true,
              'String' => lambda { value.to_s },
              'Time' => lambda { Time.parse(value) },
              'DateTime' => lambda { DateTime.parse(value) },
              'Date' => lambda { Date.parse(value) },
              'ActiveSupport::TimeWithZone' => lambda { Time.zone.parse(value) }
          }
    end

    def convert
      if value.class.to_s != klass
        conversion = conversions[klass]
        if conversion.is_a?(Proc)
          conversion.call
        else
          conversion
        end
      else
        value
      end
    end

    def to_db
      value
    end
  end

  class BigDecimalConverter
    attr_reader :value, :type
    def initialize(value, type)
      @value, @type = value, type
    end

    def convert
      if value && !value.is_a?(BigDecimal)
        value.to_d
      else
        value
      end
    end

    def to_db
      value
    end
  end
end