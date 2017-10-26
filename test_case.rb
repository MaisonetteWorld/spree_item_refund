reload!

def create_test_order
  # skus = %w[BOB10171 PAB10004 PAB10018 PAB10003 TNY11679 TNY10024]
  skus = %w[BOB10171 PAB10004 PAB10018]
  variants = skus.map { |sku| Spree::Variant.find_by_sku(sku) }

  variants.each do |variant|
    stock_item = variant.stock_items.find_by("count_on_hand > 0")
    next if variant.blank?
    stock_item.set_count_on_hand(20)
  end
  puts "Variants' stock restored"

  address = Spree::Address.new(
    firstname: 'CLIfirstname',
    lastname: "CLIlastname",
    country: Spree::Country.find_by(iso: 'US'),
    state: Spree::Country.find_by(iso: 'US').states.find_by(abbr: 'CA'),
    address1: 'Test Street',
    city: 'Test City',
    phone: '1234567890',
    zipcode: '12345'
  )

  order = Spree::Order.new
  puts "Order created"
  variants.each do |variant|
    order.contents.add(variant, 1)
    puts "Variant #{variant.sku} added"
  end
  puts "Products added"

  order.email = 'pawel@praesens.co'
  order.ship_address = address
  order.bill_address = address
  order.next
  order.save
  order = Spree::Order.find_by_number(order.number)
  puts "Order state: #{order.state}"
  order.next
  order.save
  order = Spree::Order.find_by_number(order.number)
  puts "Order state: #{order.state}"
  order.create_tax_charge!
  order.update_totals
  order.next
  order.save
  order = Spree::Order.find_by_number(order.number)
  puts "Order state: #{order.state}"
  payment_method = Spree::PaymentMethod.find_by(type: "Spree::PaymentMethod::Check")
  payment = Spree::Payment.create(
    amount: order.total,
    order: order,
    payment_method: payment_method
  )
  order.payments << payment
  puts "Payment created"
  order.next
  order.save
  order = Spree::Order.find_by_number(order.number)
  puts "Order state: #{order.state}"
  order.next
  order.save
  order = Spree::Order.find_by_number(order.number)
  puts "Order state: #{order.state}"
  payment.capture!
  puts "Payment captured"
  order
end

def create_test_item_refund(order, skus)
  item_refund = Spree::ItemRefund.create!(
    order_id: order.id,
    refund_reason: Spree::RefundReason.first,
    refund_type: "Spree::ItemRefundTypes::OriginalPayment"
  )

  skus.each do |sku|
    inventory_unit = order.inventory_units.joins(:variant).where(spree_variants: { sku: sku }).first
    Spree::ItemRefundUnit.
      create!(item_refund: item_refund, inventory_unit_id: inventory_unit.id).
      tap(&:set_default_pre_tax_amount).
      save
  end
  item_refund
end

def run_test
  order = create_test_order
  item_refund = create_test_item_refund(order, %w[BOB10171 PAB10004])
  item_refund.prepare!
  item_refund.refund!
  order.reload

  pp order.shipments
  pp item_refund
  pp "/admin/orders/#{order.number}/edit"

  order
end

order = run_test
