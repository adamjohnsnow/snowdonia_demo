describe Material do
  before do
    DatabaseCleaner.clean
  end

  context 'material creation' do

    it 'create material' do
      Material.create(:description => 'test material', :costcode_id => 1)
      expect(Material.all.count).to eq 1
      expect(Material.first.costcode_id).to eq 1
      expect(Material.first.description).to eq 'test material'
      DatabaseCleaner.clean
    end
  end
end
