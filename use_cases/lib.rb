reload!

def prepare_variants(skus = nil)
  if skus.nil?
    skus = %w[BOB10171 PAB10004 PAB10018 PAB10003 TNY11679 TNY10024]
  end
  variants = skus.map { |sku| Spree::Variant.find_by_sku(sku) }
  variants.each do |variant|
    stock_item = variant.stock_items.find_by("count_on_hand > 0")
    next if variant.blank?
    stock_item.set_count_on_hand(2000)
  end
  puts "Variants' stock restored"
end

def test_address
  Spree::Address.new(
    firstname: 'CLIfirstname',
    lastname: "CLIlastname",
    country: Spree::Country.find_by(iso: 'US'),
    state: Spree::Country.find_by(iso: 'US').states.find_by(abbr: 'NY'),
    address1: 'Test Street',
    city: 'Test City',
    phone: '1234567890',
    zipcode: '12345'
  )
end

def create_order(skus, user = nil, store_credit_payment_percent = 0, store_credit_payment_count = 1)
  order = Spree::Order.new
  if user.nil?
    order.email = 'pawel@praesens.co'
    order.ship_address = test_address
    order.bill_address = test_address
  else
    order.user = user
    order.email = user.email
    order.ship_address = if user.ship_address.present?
                           user.ship_address
                         else
                           test_address
                         end
    order.bill_address = if user.bill_address.present?
                           user.bill_address
                         else
                           test_address
                         end
  end
  puts "Order created"

  variants = skus.map { |sku| Spree::Variant.find_by_sku(sku) }
  variants.each do |variant|
    order.contents.add(variant, 1)
    puts "Variant #{variant.sku} added"
  end
  puts "Products added"

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

  if user && store_credit_payment_percent > 0
    user.store_credits.delete_all
    total_store_credit = (order.total * store_credit_payment_percent / 100).round(2)
    amount_per_store_credit = (total_store_credit / store_credit_payment_count).round(2)

    store_credit_payment_count.times do
      Spree::StoreCredit.create!(
        user: user,
        amount: amount_per_store_credit,
        category: Spree::StoreCreditCategory.first,
        created_by: Spree::User.admin.first,
        memo: "Item Refund Test",
        currency: order.currency
      )
    end

    order.add_store_credit_payments
  end

  if order.order_total_after_store_credit > 0
    payment_method = Spree::PaymentMethod.find_by(type: "Spree::PaymentMethod::Check")
    payment = Spree::Payment.create(
      amount: order.order_total_after_store_credit,
      order: order,
      payment_method: payment_method
    )
    order.payments << payment
  end
  puts "Payment created"
  order.next
  order.save
  order = Spree::Order.find_by_number(order.number)
  puts "Order state: #{order.state}"
  order.next
  order.save
  order = Spree::Order.find_by_number(order.number)
  puts "Order state: #{order.state}"
  payment.capture! if payment.present?
  puts "Payment captured"
  order
end

def create_item_refund(order, skus, refund_type = "Spree::ItemRefundTypes::OriginalPayment")
  item_refund = Spree::ItemRefund.create!(
    order_id: order.id,
    refund_reason: Spree::RefundReason.first,
    refund_type: refund_type
  )

  skus.each do |sku|
    inventory_unit = order.inventory_units.joins(:variant).where(spree_variants: { sku: sku }).first
    Spree::ItemRefundUnit.
      create!(item_refund: item_refund, inventory_unit_id: inventory_unit.id).
      tap(&:set_default_pre_tax_amount).
      save
  end

  item_refund.prepare!
  item_refund.refund!

  item_refund
end

def ship_sku(order, sku)
  shipment = order.shipments.find do |s|
    s.inventory_units.size == 1 &&
      s.inventory_units.any? { |unit| unit.variant.sku == sku }
  end

  if shipment
    shipment.ship!
  end
end
