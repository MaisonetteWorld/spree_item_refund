class AddItemRefundIdToSpreeRefunds < ActiveRecord::Migration
  def change
    change_table :spree_refunds do |t|
      t.integer :item_refund_id
    end
  end
end
