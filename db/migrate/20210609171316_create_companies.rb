class CreateCompanies < ActiveRecord::Migration[6.1]
  class User < ActiveRecord::Base
  end

  class Company < ActiveRecord::Base
  end

  def change
    create_table :companies do |t|
      t.string :name
      t.boolean :active

      t.timestamps
    end

    add_belongs_to :users, :company, foreign_key: true

    Company.reset_column_information
    User.reset_column_information

    default_company = Company.create!(name: 'Default Company', active: true)

    User.find_each do |user|
      user.update!(company_id: default_company.id)
    end
  end
end
