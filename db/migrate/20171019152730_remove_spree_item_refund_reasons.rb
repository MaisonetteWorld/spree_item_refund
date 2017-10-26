class RemoveSpreeItemRefundReasons < ActiveRecord::Migration[4.2]
  def up
    drop_table :spree_item_refund_reasons
    change_table :spree_item_refunds do |t|
      t.integer :refund_reason_id
    end
  end
end
