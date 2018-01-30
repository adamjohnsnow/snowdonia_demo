describe Client do

  context 'client creation' do

    it 'create client' do
      Client.create(:name => 'Made Up Client', :address => '1 Client Road, Clientville, CL1 1CL', :manager => 'Mrs Client')
      expect(Client.all.count).to eq 1
    end

    it 'add second client' do
      Client.create(:name => 'Another Client', :address => '2 Client Road, Clientville, CL1 1CL', :manager => 'Mr Client')
      expect(Client.all.count).to eq 2
    end

    it { expect(Client.first.name).to eq 'Made Up Client' }
    it { expect(Client.first.address).to eq '1 Client Road, Clientville, CL1 1CL' }

  end

end
