class FactorySettingsElemental < Sinatra::Base

  get '/costcode-report' do
    @project = ProjectVersion.get(params[:version_id])
    @materials = @project.elements.element_materials.materials.all.flatten
    @project_materials = @project.elements.element_materials.all.flatten
    @summary = get_costcode_report(params[:version_id])
    erb :costcode_report
  end

  def get_costcode_report(version_id)
    summary = []
    Costcode.all.each do |costcode|
      @costcode_summary = {
        id: costcode.id,
        code: costcode.code,
        description: costcode.description
      }
      get_materials
      summary << @costcode_summary
    end
    summary
  end

  def get_materials
    select = @materials.select { |m| m.costcode_id == @costcode_summary[:id] }
    @costcode_summary[:materials] = select
  end
end
