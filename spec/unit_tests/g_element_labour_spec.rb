describe ElementLabour do
  context 'element creation' do

    it 'create element' do
      ElementLabour.create(:element_id => 1)
      expect(ElementLabour.all.count).to eq 1
    end

    it { expect(ElementLabour.first.carpentry).to eq 0.0 }
    it { expect(ElementLabour.first.project_management).to eq 0.0 }
    it { expect(ElementLabour.first.draughting_cost).to eq 180.0 }
    it { expect(ElementLabour.first.element_id).to eq 1 }

  end

end
