require 'spree_core'
require 'spree_item_refund/engine'
require 'spree_item_refund/version'

module SpreeItemRefund
  class Configuration
    attr_accessor :store_credit_category_name

    def initialize
      @store_credit_category_name = 'Item Refund'
    end
  end

  class << self
    attr_accessor :configuration
    def configure
      self.configuration ||= Configuration.new
      yield(configuration)
    end
  end
end
