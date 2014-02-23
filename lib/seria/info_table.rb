require "seria/version"
require 'seria/converters'

module Seria

  module InfoTable

    extend ActiveSupport::Concern

    included do
      klass_name = self.name.gsub(Seria.descriptor.camelize, '')
      belongs_to klass_name.downcase.to_sym
      alias_method :owner, klass_name.downcase.to_sym

      before_save :to_db
      after_commit proc{self.owner.touch}
      attr_reader :in_memory
    end

    def convert
      val =
          if @in_memory
            read_attribute(Seria.config.fields.value)
          else
            converter.value
          end
      @in_memory = true
      val
    end

    def converters
      Seria.config.converters || {}
    end

    def converter
      (converters[field_name] || converters[field_type] || DefaultConverter).new(self)
    end

    def field_name
      read_attribute Seria.config.fields.key
    end

    def field_value
      convert
    end
    def field_value=(val)
      write_attribute(Seria.config.fields.value, val)
    end

    def to_db
      converter.to_db
      @in_memory = false
      true
    end

    def self.define_info_table(class_name)
      if !eval("defined?(#{class_name}) && #{class_name}.is_a?(Class)")
        Object.const_set class_name, Class.new(ActiveRecord::Base)
      end
      klass = class_name.constantize
      klass.send(:include, Seria::InfoTable) unless klass.include? Seria::InfoTable
      klass.send(:attr_accessible, *(Seria.config.fields.marshal_dump.values))
    end

  end

  module InfoTableOwner

    extend ActiveSupport::Concern

    included do
      InfoTable::define_info_table class_name

      has_many class_name.tableize.to_sym, class_name: class_name, :autosave => true do

        def []= key, val
          info = lookup(key)
          if info
            info.field_value = val
            info.field_type = val.class.name
          else
            build(
                Seria.config.fields.key => key,
                Seria.config.fields.value => val,
                Seria.config.fields.type => val.class.name
            )
          end
          val
        end
        def [] key
          info = lookup(key)
          info.field_value if info
        end
        def lookup key
          to_a.select{|i| i.field_name == key}.first
        end
      end
      alias_method :my_infos, class_name.tableize.to_sym
      alias_method Seria.table_suffix.to_sym, class_name.tableize.to_sym
    end

    module ClassMethods

      def class_name
        "#{self.to_s}#{Seria.descriptor.camelize}"
      end

    end

  end
end
