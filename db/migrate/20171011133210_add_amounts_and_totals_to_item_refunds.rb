class AddAmountsAndTotalsToItemRefunds < ActiveRecord::Migration
  def change
    change_table :spree_item_refunds do |t|
      t.decimal  :total,
                 precision: 12, scale: 4, default: 0.0, null: false
    end

    change_column :spree_item_refund_units, :pre_tax_amount, :decimal,
                  precision: 12, scale: 4, default: 0.0, null: false

    change_table :spree_item_refund_units do |t|
      t.decimal  :included_tax_total,
                 precision: 12, scale: 4, default: 0.0, null: false
      t.decimal  :additional_tax_total,
                 precision: 12, scale: 4, default: 0.0, null: false
    end
  end
end
