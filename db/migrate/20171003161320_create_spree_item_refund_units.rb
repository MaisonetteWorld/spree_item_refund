class CreateSpreeItemRefundUnits < ActiveRecord::Migration
  def change
    create_table "spree_order_item_refund_units", force: :cascade do |t|
      t.integer  "item_refund_id"
      t.integer  "inventory_unit_id"
      t.datetime "deleted_at"
    end
  end
end
