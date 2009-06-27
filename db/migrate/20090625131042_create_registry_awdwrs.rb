class CreateRegistryAwdwrs < ActiveRecord::Migration
  def self.up
    create_table :registry_awdwrs do |t|
      t.string :name
      t.string :xmpp
      t.string :openid
      t.string :level

      t.timestamps
    end
  end

  def self.down
    drop_table :registry_awdwrs
  end
end
