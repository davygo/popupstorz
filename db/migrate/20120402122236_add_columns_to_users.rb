# -*- encoding : utf-8 -*-
class AddColumnsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :verify_email, :string
    add_column :users, :mobile_phone, :integer
    add_column :users, :gender, :boolean
    add_column :users, :date_of_birth, :date
    add_column :users, :activity, :string
    add_column :users, :security_question, :string
    add_column :users, :security_answer, :string
    add_column :users, :address1, :string
    add_column :users, :address2, :string
    add_column :users, :zip_code, :string
    add_column :users, :city, :string
    add_column :users, :country, :string
    add_column :users, :description, :string
    add_column :users, :admin, :boolean, :default => false

  end


  def self.down
    remove_column :users, :first_name
    remove_column :users, :last_name
    remove_column :users, :verify_email
    remove_column :users, :mobile_phone
    remove_column :users, :gender
    remove_column :users, :date_of_birth
    remove_column :users, :activity
    remove_column :users, :security_question
    remove_column :users, :security_answer
    remove_column :users, :address1
    remove_column :users, :address2
    remove_column :users, :zip_code
    remove_column :users, :city
    remove_column :users, :country
    remove_column :users, :description
    remove_column :users, :admin
  end
end
