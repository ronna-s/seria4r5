class InfoTableGenerator < Rails::Generators::NamedBase
  include Rails::Generators::Migration
  source_root File.expand_path('../templates', __FILE__)

  def suffix
    Seria.table_suffix
  end

  def migration_template
    source = "#{self.class.generator_name}.rb"
    destination = "db/migrate/create_#{file_name}_#{suffix}.rb"

    source = File.expand_path(find_in_source_paths(source.to_s))

    set_migration_assigns!(destination)
    context = instance_eval("binding")

    dir, base = File.split(destination)
    numbered_destination = File.join(dir, ["%migration_number%", base].join("_"))

    create_migration numbered_destination, nil, {} do
      ERB.new(::File.binread(source), nil, "-", "@output_buffer").result(context)
    end
  end

  def self.next_migration_number(dirname) #:nodoc:
    next_migration_number = current_migration_number(dirname) + 1
    if ActiveRecord::Base.timestamped_migrations
      [Time.now.utc.strftime("%Y%m%d%H%M%S"), "%.14d" % next_migration_number].max
    else
      "%.3d" % next_migration_number
    end
  end
end