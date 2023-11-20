class CreateCompanies < ActiveRecord::Migration[6.0]
  def change
    create_table  :companies do |t|
      t.string    :name,        null: false
      t.string    :ticker,      null: false
      t.string    :cik,         null: true
      t.jsonb     :data,        null: false,  default: '{}'
      t.timestamps
    end
  end
end