describe ElementMaterial do
  before do
    DatabaseCleaner.clean
  end

  context 'element material creation' do

    it 'create element material' do
      ElementMaterial.create(:element_id => 1, :material_id => 1)
      expect(ElementMaterial.all.count).to eq 1
      expect(ElementMaterial.first.element_id).to eq 1
      expect(ElementMaterial.first.subcontract).to eq false
      expect(ElementMaterial.first.units).to eq 1
      DatabaseCleaner.clean
    end
  end
end
