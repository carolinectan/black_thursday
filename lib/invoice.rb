require_relative '../lib/modules/timeable'

class Invoice
  include Timeable
  
  attr_reader :id,
              :customer_id,
              :merchant_id,
              :status,
              :created_at,
              :updated_at

  def initialize(data)
    @id           = data[:id].to_i
    @customer_id  = data[:customer_id].to_i
    @merchant_id  = data[:merchant_id].to_i
    @status       = data[:status].to_sym
    @created_at   = update_time(data[:created_at].to_s)
    @updated_at   = update_time(data[:updated_at].to_s)
  end

  def update(attributes)
    @status     = attributes[:status] unless attributes[:status].nil?
    @updated_at = update_time('')
  end
end
