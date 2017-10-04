class CreateSpreeItemRefunds < ActiveRecord::Migration
  def change
    create_table "spree_order_item_refunds", force: :cascade do |t|
      t.integer  "item_refund_reason_id"
      t.datetime "deleted_at"
    end
  end
end
