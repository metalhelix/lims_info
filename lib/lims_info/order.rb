
module LimsInfo
  class Order
    def self.start args
      order = Order.new
      order.run(args)
    end

    def initialize
    end

    def run args
      order_number = clean_order(args[0])
    end

    def clean_order order
      puts order
      order
    end

    def find_order_page order_number
    end
  end
end
