def run_test
  order = create_order(%w[BOB10171 PAB10004 PAB10018])
  ship_sku(order, 'BOB10171')
  item_refund = create_item_refund(order, %w[PAB10004 PAB10018])
  order.reload

  pp order.shipments
  pp item_refund
  pp "/admin/orders/#{order.number}/edit"

  order
end

order = run_test
