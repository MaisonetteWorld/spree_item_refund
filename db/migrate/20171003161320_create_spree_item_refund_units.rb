class CreateSpreeItemRefundUnits < ActiveRecord::Migration[4.2]
  def change
    create_table :spree_item_refund_units, force: :cascade do |t|
      t.integer  :item_refund_id
      t.integer  :inventory_unit_id
      t.decimal  :pre_tax_amount, precision: 8, scale: 2
      t.decimal  :amount, precision: 8, scale: 2
      t.datetime :deleted_at
      t.timestamps null: false
    end
  end
end
