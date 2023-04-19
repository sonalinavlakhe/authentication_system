class AddPhoneAttributesToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :phone_verified, :boolean
    add_column :users, :phone_verification_code, :string
  end
end
