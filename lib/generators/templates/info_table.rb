class <%= migration_class_name %> < ActiveRecord::Migration
  def change
    create_table :<%= migration_class_name.underscore.downcase.gsub(/^create_/,'')%> do |t|
      t.string :<%= Seria.config.fields.key %>
      t.string :<%= Seria.config.fields.value %>
      t.string :<%= Seria.config.fields.type %>
      t.integer :<%=migration_class_name.underscore.downcase.gsub(/^create_/,'').gsub(/_#{suffix}$/,'')%>_id
    end
  end
end