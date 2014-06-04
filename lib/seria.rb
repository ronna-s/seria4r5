require "seria/version"
require "seria/info_table"
require 'ostruct'

module Seria
  @config = OpenStruct.new
  @config.descriptor = :info
  @config.converters = {}
  @config.perform_lookup_on_method_missing = false
  @config.fields = OpenStruct.new(
      {
          key: :field_name,
          value: :field_value,
          type: :field_type
      })
  def self.configure
    yield @config
  end

  def self.descriptor
    config.descriptor.to_s
  end
  def self.table_suffix
    descriptor.tableize
  end
  def self.config
    @config
  end
end
