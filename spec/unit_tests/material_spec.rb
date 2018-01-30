describe Material do
  before do
    DatabaseCleaner.clean
    Material.create(:description => 'test material', :costcode_id => 1, :current_price => 2.5, :price_updated => (Date.today - 7))
  end

  context 'material creation' do

    it 'create material' do
      expect(Material.all.count).to eq 1
      expect(Material.first.costcode_id).to eq 1
      expect(Material.first.description).to eq 'test material'
      DatabaseCleaner.clean
    end
  end

  context 'price update' do

    it 'updates price' do
      material = Material.first
      material.update_price(8.9)
      expect(Material.first.current_price).to eq 8.9
      expect(Material.first.price_updated).to eq Date.today
    end
  end
end
