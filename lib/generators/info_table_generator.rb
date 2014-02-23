require 'rails/generators/named_base'
module Seria
  module Generators
    module Migration
      class InfoTableGenerator < Rails::Generators::NamedBase
        include Rails::Generators::Migration
        namespace "info_table"
        source_root File.expand_path('../templates', __FILE__)

        def create_migration
          migration_template(
              "#{self.class.generator_name}.rb",
              "db/migrate/create_#{file_name}_#{suffix}.rb"
          )
        end

        def self.next_migration_number(dirname) #:nodoc:
          next_migration_number = current_migration_number(dirname) + 1
          if ActiveRecord::Base.timestamped_migrations
            [Time.now.utc.strftime("%Y%m%d%H%M%S"), "%.14d" % next_migration_number].max
          else
            "%.3d" % next_migration_number
          end
        end

        def suffix
          Seria.table_suffix
        end
      end
    end
  end
end