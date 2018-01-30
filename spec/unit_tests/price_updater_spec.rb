describe PriceUpdater do
  before do
    @element_materials = [{ material_id: 4, price: 5.5 }]
    @materials = [{ id: 1, current_price: 5.5 }, { id: 4, current_price: 7.2 }]
  end

  context 'updates prices' do
    it 'updates a price' do
      PriceUpdater.new(@element_materials, @materials)
      expect(@element_materials[0]).to include(:price => 7.2)
    end
  end
end
