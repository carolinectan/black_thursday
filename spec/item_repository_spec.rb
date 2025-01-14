require 'SimpleCov'
SimpleCov.start

require_relative '../lib/item_repository'

RSpec.describe ItemRepository do
  before :each do
    @ir = ItemRepository.new('./spec/fixture_files/item_fixture.csv')
  end
  it 'exists' do
    expect(@ir).to be_an_instance_of(ItemRepository)
  end

  it 'can create item objects' do
    expect(@ir.all[0]).to be_an_instance_of(Item)
  end

  it 'returns a list of items' do
    expect(@ir.all.length).to eq(5)
  end

  it 'can find item by ID' do
    expect(@ir.find_by_id(1).name).to eq('Pencil')
    expect(@ir.find_by_id(2).name).to eq('Pen')
  end

  it 'finds an item by name' do
    expect(@ir.find_by_name('Pen').name).to eq('Pen')
    expect(@ir.find_by_name('Pencil').name).to eq('Pencil')
  end

  it 'finds item by description' do
    expected  = @ir.find_all_with_description('You can use it to write things')
    expected2 = @ir.find_all_with_description('Help me')

    expect(expected.length).to eq(3)
    expect(expected2.length).to eq(0)
  end

  it 'finds all instances of an item by price' do
    price  = BigDecimal(10)
    price2 = BigDecimal(12)
    price3 = BigDecimal(15)

    expected  = @ir.find_all_by_price(price)
    expected2 = @ir.find_all_by_price(price2)
    expected3 = @ir.find_all_by_price(price3)

    expect(expected.length).to eq(1)
    expect(expected2.length).to eq(2)
    expect(expected3.length).to eq(0)
  end

  it 'can find all instances in price range' do
    expected  = @ir.find_all_by_price_in_range(8..15)
    expected2 = @ir.find_all_by_price_in_range(0..7)
    expected3 = @ir.find_all_by_price_in_range(16.00..25.00)

    expect(expected.length).to eq(3)
    expect(expected2.length).to eq(0)
    expect(expected3.length).to eq(1)
  end

  it 'finds all instances based on merchant ID' do
    expected  = @ir.find_all_by_merchant_id(6)
    expected2 = @ir.find_all_by_merchant_id(9)
    expected3 = @ir.find_all_by_merchant_id(7)


    expect(expected.length).to eq(1)
    expect(expected2.length).to eq(0)
    expect(expected3.length).to eq(3)
  end

  it 'creates a new instance with attributes' do
    expected = @ir.create({
                             :name        => 'Golden Fountain Pen',
                             :description => 'You can write REALLY fancy things',
                             :unit_price  => 12009,
                             :merchant_id => 4
                          })

    expect(@ir.all.length).to eq(6)
    expect(expected.id).to eq(6)
  end

  it 'finds item by ID and update attributes' do
    data = {
              :description => 'You can write REALLY fancy things',
              :unit_price  => BigDecimal(379.99, 5)
           }
    @ir.update(3, data)
    expected = @ir.find_by_id(3)

    expect(expected.name).to eq('Marker')
    expect(expected.description).to eq('You can write REALLY fancy things')
    expect(expected.unit_price_to_dollars).to eq(379.99)
  end

  it 'finds and deletes item by ID' do
    @ir.delete(2)
    expect(@ir.all.length).to eq(4)
  end
end
