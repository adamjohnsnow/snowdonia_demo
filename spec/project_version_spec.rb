describe ProjectVersion do

  context 'project version creation' do

    before do
      ProjectVersion.create(:project_id => 1, :version_no => '0.1')
    end

    it { expect(ProjectVersion.first.project_id).to eq 1 }
    it { expect(ProjectVersion.first.version_no).to eq '0.1' }
  end
end
