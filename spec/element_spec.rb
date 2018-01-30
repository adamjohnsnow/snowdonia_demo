describe Element do

  context 'element creation' do

    it 'create element' do
      Element.create(:title => 'Test Element', :project_version_id => 1, :reference => '3.1.2')
      expect(Element.all.count).to eq 1
    end

    it { expect(Element.first.title).to eq 'Test Element' }
    it { expect(Element.first.reference).to eq '3.1.2' }
    it { expect(Element.first.quantity).to eq 1 }
    it { expect(Element.first.quote_include).to eq true }
    it { expect(Element.first.element_materials.count).to eq 0 }
    it { expect(Element.first.overhead).to eq 0.385 }

  end

end
