describe Site do

  context 'site creation' do
    it 'create site' do
      Site.create(:name => 'Made Up Site', :address => '1 Site Road, Siteville, CL1 1CL')
      expect(Site.all.count).to eq 1
    end

    it 'add second site' do
      Site.create(:name => 'Another Site', :address => '2 Site Road, Siteville, CL1 1CL')
      expect(Site.all.count).to eq 2
    end

    it { expect(Site.first.name).to eq 'Made Up Site' }
    it { expect(Site.first.address).to eq '1 Site Road, Siteville, CL1 1CL' }
  end
end
