class CreateProducts < ActiveRecord::Migration[7.0]
  def change
    create_table :products do |t|
      t.integer :amountAvailable
      t.monetize :cost
      t.string :productName

      t.timestamps
    end
  end
end
