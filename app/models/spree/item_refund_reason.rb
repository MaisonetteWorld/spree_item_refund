module Spree
  class ItemRefundReason < Spree::Base
    acts_as_paranoid

    validates :name, presence: true
  end
end
