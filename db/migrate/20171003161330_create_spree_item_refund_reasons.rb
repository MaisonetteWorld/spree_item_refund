class CreateSpreeItemRefundReasons < ActiveRecord::Migration
  def change
    create_table :spree_item_refund_reasons, force: :cascade do |t|
      t.string :name
      t.boolean :active, default: true
      t.boolean :mutable, default: true
      t.datetime :deleted_at
      t.timestamps null: false
    end
  end
end
