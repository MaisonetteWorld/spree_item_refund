class AddRefundTypeToSpreeItemRefunds < ActiveRecord::Migration[4.2]
  def change
    change_table :spree_item_refunds do |t|
      t.string :refund_type
    end
  end
end
