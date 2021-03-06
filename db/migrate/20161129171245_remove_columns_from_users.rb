class RemoveColumnsFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :reset_password_token
    remove_column :users, :reset_password_sent_at
    remove_column :users, :remember_created_at
    remove_column :users, :sign_in_count
    remove_column :users, :current_sign_in_at
    remove_column :users, :last_sign_in_at
    remove_column :users, :current_sign_in_ip
    remove_column :users, :last_sign_in_ip
  end

  def down
    add_column :users, :reset_password_token, :string
    add_column :users, :reset_password_sent_at, :timestamp
    add_column :users, :remember_created_at, :timestamp
    add_column :users, :sign_in_count, :integer
    add_column :users, :current_sign_in_at, :timestamp
    add_column :users, :last_sign_in_at, :timestamp
    add_column :users, :current_sign_in_ip, :string
    add_column :users, :last_sign_in_ip, :string
  end
end
