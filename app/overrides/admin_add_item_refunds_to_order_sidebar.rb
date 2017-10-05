Deface::Override.new(
  virtual_path: 'spree/admin/shared/_order_tabs',
  name: 'admin_add_item_refunds_to_order_sidebar',
  insert_before: '[data-hook="admin_order_tabs_state_changes"]',
  partial: 'spree/admin/shared/order_tabs_item_refunds'
)
