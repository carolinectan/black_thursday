require 'date'
require_relative '../lib/modules/hashable'

class SalesAnalyst
  include Hashable

  def initialize(engine)
    @engine = engine
  end

  def average_items_per_merchant
    (@engine.items.all.length / @engine.merchants.all.length.to_f).round(2)
  end

  def items_by_merch_count
    merch_items_hash.values.map do |item_array|
      item_array.count
    end
  end

  def average_items_per_merchant_standard_deviation
    numerator = items_by_merch_count.sum do |num|
      (num - average_items_per_merchant) ** 2
    end
    denominator = (items_by_merch_count.length - 1).to_f
    Math.sqrt(numerator / denominator).round(2)
  end

  def merchants_with_high_item_count
    merch_high_count = merch_items_hash.select do |merch_id, items|
      items.length > (average_items_per_merchant + average_items_per_merchant_standard_deviation)
    end
    merch_high_count.keys.map do |merch_id|
      @engine.merchants.find_by_id(merch_id)
    end
  end

  def price_of_items_for_merch(merchant_id)
    merch_items_hash[merchant_id].map do |item|
      item.unit_price
    end
  end

  def average_item_price_for_merchant(merchant_id)
    (price_of_items_for_merch(merchant_id).sum / price_of_items_for_merch(merchant_id).length).round(2)
  end

  def average_average_price_per_merchant
    avg_price_per_merch = merch_items_hash.keys.map do |id|
      average_item_price_for_merchant(id)
    end
    (avg_price_per_merch.sum / avg_price_per_merch.length).floor(2)
  end

  def item_price_set
    @engine.items.all.map do |item|
      item.unit_price_to_dollars
    end
  end

  def average_price_per_item
    (item_price_set.sum / item_price_set.length).round(2)
  end

  def average_price_per_item_standard_deviation
    numerator = item_price_set.sum do |num|
      (num - average_price_per_item) ** 2
    end
    denominator = (item_price_set.length - 1).to_f
    Math.sqrt(numerator / denominator).round(2)
  end

  def golden_items
    @engine.items.all.select do |item|
      item.unit_price_to_dollars > (average_price_per_item +
        (average_price_per_item_standard_deviation * 2))
    end
  end

  def average_invoices_per_merchant
    (@engine.invoices.all.length / @engine.merchants.all.length.to_f).round(2)
  end

  def invoices_by_merch_count
    count = merch_invoices_hash.values.map do |invoice_array|
      invoice_array.count
    end
    count
  end

  def average_invoices_per_merchant_standard_deviation
    numerator = invoices_by_merch_count.sum do |num|
      (num - average_invoices_per_merchant) ** 2
    end
    denominator = (invoices_by_merch_count.length - 1).to_f
    Math.sqrt(numerator / denominator).round(2)
  end

  def top_merchants_by_invoice_count
    merch_high_count = merch_invoices_hash.select do |merch_id, invoices|
      invoices.length > (average_invoices_per_merchant + (2 * average_invoices_per_merchant_standard_deviation))
    end
    merch_high_count.keys.map do |merch_id|
      @engine.merchants.find_by_id(merch_id)
    end
  end

  def bottom_merchants_by_invoice_count
    merch_high_count = merch_invoices_hash.select do |merch_id, invoices|
      invoices.length < (average_invoices_per_merchant + (2 * average_invoices_per_merchant_standard_deviation))
    end
    merch_high_count.keys.map do |merch_id|
      @engine.merchants.find_by_id(merch_id)
    end
  end

  def pull_day_from_invoice
    dates = @engine.invoices.all.map do |invoice|
      invoice.created_at
    end
    dates.map do |date_stamp|
      date_stamp.wday
    end
  end

  def average_invoices_per_day
    (@engine.invoices.all.length.to_f / 7).round(2)
  end

  def avg_inv_per_day_std_dev
    numerator = days_invoices_hash.sum do |day, count|
      (count - average_invoices_per_day) ** 2
    end
    average_invoices_per_day_std_dev = Math.sqrt(numerator / 6.0).round(2)
  end

  def top_days_by_invoice_count
    days_high_count = days_invoices_hash.select do |days, invoices|
      invoices > (average_invoices_per_day + avg_inv_per_day_std_dev)
    end
    days_high_count.keys
  end

  def invoice_status(invoice_status)
    invoices = @engine.invoices.all.select do |invoice|
      invoice.status.to_sym == invoice_status
    end
    ((invoices.length / @engine.invoices.all.length.to_f) * 100).round(2)
  end
########## Iteration 4
  def invoice_id_with_successful_payments
    @engine.transactions.find_all_by_result(:success).map do |transaction|
      transaction.invoice_id
    end
  end

  def total_revenue_by_date(date)
    invoice_ids = @engine.invoices.find_all_by_date(date).map do |invoice|
      invoice.id
    end
    invoice_ids.sum do |id|
      revenue_by_invoice[id]
    end
  end

  def top_revenue_earners(num)
    merch_invoices_hash
    revenue_by_invoice
  end

  def merchants_with_pending_invoices
    pending_invoices = @engine.invoices.all.select do |invoice|
      !invoice_id_with_successful_payments.include?(invoice.id)
    end
    merchant_id = pending_invoices.map do |invoice|
      invoice.merchant_id
    end
    @engine.merchants.all.select do |merchant|
      merchant_id.include?(merchant.id)
    end
  end

  def merchants_with_only_one_item
    merchants = []
    merch_items_hash.each do |merch, item|
      merchants << merch if item.count == 1
    end
    @engine.merchants.all.select do |merchant|
      merchants.include?(merchant.id)
    end
  end

  def merchants_with_only_one_item_registered_in_month(month)
    month_to_num = {
                      'January' => 1,
                      'February' => 2,
                      'March'=> 3,
                      'April' => 4,
                      'May' => 5,
                      'June' => 6,
                      'July' => 7,
                      'August' => 8,
                      'September' => 9,
                      'October' => 10,
                      'November' => 12,
                      'December' => 12
                    }
    num = month_to_num.find do |name, num|
      month == name
    end
  end
end
