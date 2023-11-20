class CreateTransactions < ActiveRecord::Migration[6.0]
  def change
    create_table  :transactions do |t|
      t.integer   :company_id,      null: false
      t.string    :document_url,    null: false, index: {unique: false}
      t.datetime  :document_date,   null: true
      t.money     :amount
      t.jsonb     :data,            null: false,  default: '{}'
      t.timestamps
    end
  end
end

