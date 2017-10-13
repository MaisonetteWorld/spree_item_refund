class AddRefundTypeToSpreeItemRefunds < ActiveRecord::Migration
  def change
    change_table :spree_item_refunds do |t|
      t.string :refund_type
    end
  end
end
