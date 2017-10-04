class CreateSpreeItemRefundUnits < ActiveRecord::Migration
  def change
    create_table "spree_order_item_refund_units", force: :cascade do |t|
      t.string "name"
      t.datetime "deleted_at"
    end
  end
end
