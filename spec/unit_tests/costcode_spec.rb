describe Costcode do

  context 'costcode creation' do

    it 'create costcode' do
      Costcode.create(
        :code => 'C001',
        :description => 'Test costcode',
        :user_id => 1
      )
      expect(Costcode.all.count).to eq 1
    end

    it { expect(Costcode.first.code).to eq 'C001' }
    it { expect(Costcode.first.description).to eq 'Test costcode' }

  end
end
