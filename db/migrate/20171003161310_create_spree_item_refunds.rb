class CreateSpreeItemRefunds < ActiveRecord::Migration
  def change
    create_table :spree_item_refunds, force: :cascade do |t|
      t.string   :number, limit: 32
      t.string   :state, default: :new
      t.integer  :order_id
      t.integer  :item_refund_reason_id
      t.integer  :created_by_id
      t.integer  :refunded_by_id
      t.text     :description
      t.datetime :refunded_at
      t.datetime :deleted_at
      t.timestamps null: false
    end
  end
end
