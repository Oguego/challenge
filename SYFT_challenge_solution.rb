class PromotionalRule
  attr_reader :type_id, :json_detail, :description

  def initialize(type_id:, json_detail:, description:)
    @type_id = type_id
    @json_detail = json_detail
    @description = description
  end

  def self.individual_price(items, rules, individual_item)
    case individual_item.code
    when '001'
      without_rule = true
      lavender_hearts_rule = nil
      rules.each do |rule| 
        next unless rule.type_id == 1
        lavender_hearts_rule = rule 
        break
      end
      return individual_item.price if lavender_hearts_rule.nil?
      lavender_hearts = 0
      items.each {|e| lavender_hearts += 1 if e.code == '001' }
      if lavender_hearts >= lavender_hearts_rule.json_detail[:number_items]
        return lavender_hearts_rule.json_detail[:new_price] 
      else
        return individual_item.price
      end
    when '002'
      individual_item.price
    when '003'
      individual_item.price      
    else
      0
    end
  end

  def self.total_promotional_rule_type(partial_amount, rules)
    total_amount = partial_amount
    rules.each do |rule|
      case rule.type_id 
        when 0
          total_amount *= (1 - rule.json_detail[:discount]) if partial_amount > rule.json_detail[:over]
        else
      end
    end
    total_amount
  end

end

class Item
  attr_reader :code, :name, :price

  def initialize(code:, name:, price:)
    @code  = code
    @name = name
    @price = price
  end

end

class Checkout

  def initialize(promotional_rules)
    @items = []
    @promotional_rules = promotional_rules
  end

  def scan(item)
    @items << item
  end

  def total
    total_price = 0
      @items.each do |item|
        #print 'Price: '
       # puts PromotionalRule.individual_price(@items, @promotional_rules, item)
        #puts '--------------'
          total_price += PromotionalRule.individual_price(@items, @promotional_rules, item)
    end

    PromotionalRule.total_promotional_rule_type(total_price, @promotional_rules)
    
  end
end


 promotional_rules = []
 promotional_rules << PromotionalRule.new(type_id: 0, 
                                          json_detail: { over: 60, discount: 0.10 }, 
                                          description: 'If you spend over £60, then you get 10% of your purchase' )

 promotional_rules << PromotionalRule.new(type_id: 1, 
                                          json_detail: { number_items: 2, new_price: 8.50 }, 
                                          description: 'If you buy 2 or more lavender hearts then the price drops to £8.50' )                                          
  items = []
  items << Item.new(code: '001', name: 'Lavender heart', price: 9.25 )
  items << Item.new(code: '002', name: 'Personalised cufflinks', price: 45.00 )
  items << Item.new(code: '003', name: 'Kids T-shirt', price: 19.95 )
 
  co = Checkout.new(promotional_rules)
  co.scan(items[0])
  co.scan(items[0])
  co.scan(items[1])
  co.scan(items[2])
  price = co.total #Expecting 73.76

  puts 'Price: £'+price.to_s

  co = Checkout.new(promotional_rules)
  co.scan(items[0])
  co.scan(items[0])
  co.scan(items[2])
  price = co.total #Expecting £36.95

  puts 'Price: £'+price.to_s


  co = Checkout.new(promotional_rules)
  co.scan(items[0])
  co.scan(items[1])
  co.scan(items[2])
  price = co.total #Expecting £66.78

  puts 'Price: £'+price.to_s