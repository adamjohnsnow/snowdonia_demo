describe ProjectVersion do

  context 'project version creation' do

    before do
      ProjectVersion.create(:project_id => 1, :version_name => '0.1')
    end

    it { expect(ProjectVersion.first.project_id).to eq 1 }
    it { expect(ProjectVersion.first.status).to eq 'New' }
    it { expect(ProjectVersion.first.current_version).to eq true }
    it { expect(ProjectVersion.first.version_name).to eq '0.1' }
  end
end
