class SetExtensions < ActiveRecord::Migration[6.0]
  def change
    enable_extension 'uuid-ossp'
    enable_extension "pgcrypto"
    enable_extension "plpgsql"
  end
end