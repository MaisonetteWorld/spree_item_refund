module Spree
  class ItemRefund
    module StateMachine
      extend ActiveSupport::Concern

      included do
        state_machine initial: :new do
          event :renew do
            transition from: :prepared, to: :new
          end

          event :prepare do
            transition from: :new, to: :prepared
          end
          before_transition to: :prepared, do: :ensure_units_not_empty
          after_transition to: :prepared, do: :calculate_totals

          event :refund do
            transition from: :prepared, to: :refunded
          end
          before_transition to: :refunded, do: :perform_refund
        end
      end
    end
  end
end
