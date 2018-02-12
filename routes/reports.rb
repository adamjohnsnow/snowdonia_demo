require 'csv'
require_relative '../models/report_writer'

class FactorySettingsElemental < Sinatra::Base

  LABOURTYPES= [
    :carpentry,
    :steelwork,
    :scenic,
    :onsite_paint,
    :onsite_day,
    :draughting,
    :project_management
  ]

  get '/report' do
    @type = params[:type].to_sym
    @project = ProjectVersion.get(params[:version_id])
    get_all_variables
    if @project.current_version
      PriceUpdater.new(@materials, @materials.materials.all)
    end
    @reporter = ReportWriter.new(@type, @project, @materials, @totals, session[:user_id]) if @type != :terms
    erb @type
  end

  get '/download' do
     send_file "./report_outputs/" +  params[:report], :filename => params[:report], :type => 'Application/octet-stream'
  end

  def get_all_variables
    @materials = @project.elements.element_materials.all
    @totals = Totals.new.summarise_project(@project)
    @grand_totals = @totals.inject{|memo, el| memo.merge( el ){|k, old_v, new_v| old_v + new_v}}
    @grand_totals.tap{ |keys| keys.delete(:id) }
  end
end
