class CreateStocksTable < ActiveRecord::Migration[6.0]
  def change
    create_table  :stocks do |t|
      t.string    :ticker,          null: false # Purposefully not using Company model in this situation since we also load index fund data
      t.datetime  :date,            null: false
      t.money     :price,           null: false
      t.timestamps
    end
  end
end