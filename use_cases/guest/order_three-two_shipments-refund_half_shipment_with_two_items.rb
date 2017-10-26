def run_test
  order = create_order(%w[BOB10171 PAB10004 PAB10018])
  item_refund = create_item_refund(order, %w[PAB10018])
  order.reload

  pp order.shipments
  pp item_refund
  pp "/admin/orders/#{order.number}/edit"

  order
end

order = run_test
