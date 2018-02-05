require 'sinatra/base'
require 'sinatra/flash'
require 'pry'
require_relative './data_mapper_setup'
require_relative './models/totals'

ENV['RACK_ENV'] ||= 'development'

class FactorySettingsElemental < Sinatra::Base
  enable :sessions
  set :session_secret, ENV['SESSION_SECRET'] || 'something'
  register Sinatra::Flash

  STATUS = ['New', 'Tender', 'In Design', 'In Build', 'On Site', 'Complete', 'Cancelled']

  before do
    redirect '/' unless session[:user_id] || request.path_info == '/' || request.path_info == '/sign-in'
  end

  get '/' do
    erb :index, :layout => false
  end

  get '/home' do
    @user = User.get(session[:user_id])
    @projects = @user.projects.all
    erb :home
  end

  get '/projects' do
    @projects = Project.all(:order => [ :title.asc ])
    erb :projects
  end

  get '/clients' do
    @clients = Client.all
    erb :clients
  end

  post '/new-project' do
    project = new_project(params)
    redirect '/project-summary?project_id=' + project.id.to_s
  end

  get '/project-summary' do
    @dropdowns = get_dropdowns
    @project = Project.get(params[:project_id])
    if params[:version_id]
      @current_version = ProjectVersion.get(params[:version_id])
    else
      @current_version = @project.project_versions.last(:current_version => true)
    end
    @totals = Totals.new(@current_version).project_summary
    p @totals
    @current_version.elements.sort_by! { |el| el['el_order']}
    @pm = User.get(@project.user_id)
    erb :project_summary
  end

  post '/save-project' do
    project_id = update_project(params)
    redirect '/project-summary?project_id=' + project_id
  end

  post '/update-project' do
    project = Project.get(params[:project_id])
    current_version = project.project_versions.last(:current_version => true)
    current_version.update(
      :status => params[:status],
      :last_update => Date.today.strftime("%d/%m/%Y") + ' by ' + session[:user]
    )
    loop_through_elements(params)
    redirect '/project-summary?project_id=' + params[:project_id]
  end

  get '/project-labour' do
    @dropdowns = get_dropdowns
    @project = Project.get(params[:project_id])
    @current_version = @project.project_versions.last(:current_version => true)
    @pm = User.get(@project.user_id)
    erb :project_labour
  end

  post '/update-materials' do
    params.each do |param|
      if param[0].include? 'order'
        mat_id = param[0].chomp(' order').to_i
        ElementMaterial.get(mat_id).update(:mat_order => param[1].to_i)
      elsif param[0].include? 'units'
        mat_id = param[0].chomp(' units').to_i
        ElementMaterial.get(mat_id).update(:units => param[1].to_i)
      elsif param[0].include? 'notes'
        mat_id = param[0].chomp(' notes').to_i
        ElementMaterial.get(mat_id).update(:notes => param[1])
      elsif (param[0].include? 'after') && (param[1] != "")
        mat_id = param[0].chomp(' after').to_i
        ElementMaterial.get(mat_id).update(:units_after_drawing => param[1].to_i)
      end
    end
    Element.get(params[:element_id]).project_version.update(
      :last_update => Date.today.strftime("%d/%m/%Y") + ' by ' + session[:user]
    )
    redirect '/element?id=' + params[:element_id] + '#materials'
  end

  post '/update-labour' do
    element_id = params[:element_labour_id]
    params.tap{ |keys| keys.delete(:captures) && keys.delete(:element_labour_id) }
    params.each do |param|
      ElementLabour.get(element_id).update(param[0] => param[1].to_f)
    end
    Element.get(params[:element_id]).project_version.update(
      :last_update => Date.today.strftime("%d/%m/%Y") + ' by ' + session[:user]
    )
    redirect '/element?id=' + params[:element_id] + '#labour'
  end

  get '/versions' do
    @project = Project.get(params[:id])
    erb :versions
  end

  post '/new-version' do
    params[:title] == "" ? title = "Unnamed Version" : title = params[:title]
    @project = Project.get(params[:project_id])
    @current_version = @project.project_versions.last(:current_version => true)
    @new_version = ProjectVersion.create(
                    :project_id => params[:project_id],
                    :created_by => session[:user],
                    :version_name => title
                  )
    VersionUpdater.new(@current_version, @new_version)
    redirect '/project-summary?project_id=' + params[:project_id]
  end

  post '/add-material' do
    @el_id = params[:element_id]
    params.tap{ |keys| keys.delete(:element_id) && keys.delete(:captures) }
    process_material(params)
    Element.get(@el_id).project_version.update(
      :last_update => Date.today.strftime("%d/%m/%Y") + ' by ' + session[:user]
    )
    redirect '/element?id=' + @el_id + '#new-material'
  end

  get '/element-material' do
    @el_mat = ElementMaterial.get(params[:elmat_id])
    erb :element_material
  end

  private

  def get_dropdowns
    return { status: STATUS,
      clients: Client.all,
      sites: Site.all,
      users: User.all(:order => [ :firstname.asc ])
    }
  end

  def new_project(params)
    redirect '/home' if params[:new] == ""
    project = Project.create(:title => params[:new], :site_id => 1, :client_id => 1, :user_id => session[:user_id])
    ProjectVersion.create(
      :project_id => project.id,
      :version_name => 'v0.1',
      :created_by => session[:user],
      :last_update => Date.today.strftime("%d/%m/%Y") + ' by ' + session[:user]
    )
    project.users << User.get(session[:user_id])
    project.save!
    return project
  end

  def update_project(params)
    update_version(params)
    current_version = @project.project_versions.last(:current_version => true)
    current_version.update(:status => params[:status], :last_update => Date.today.strftime("%d/%m/%Y") + ' by ' + session[:user])
    params.tap{ |keys| keys.delete(:captures) &&
      keys.delete(:project_id) &&
      keys.delete(:status) &&
      keys.delete(:contracted)
    }
    @project.update(params)
    @project.id.to_s
  end

  def update_version(params)
    @project = Project.get(params[:project_id])
    current_version = @project.project_versions.last(:current_version => true)
    current_version.update(:status => params[:status], :last_update => Date.today.strftime("%d/%m/%Y") + ' by ' + session[:user])
    if params[:contracted] == 'on'
      @project.project_versions.all.update(:contracted => false)
      current_version.update(:contracted => true)
    else
      current_version.update(:contracted => false)
    end
  end

  def get_next_mat_order
    materials = ElementMaterial.all(:element_id => @el_id)
    if materials == []
      1
    else
      materials.max_by{ |mat| mat[:mat_order]}[:mat_order] + 1
    end
  end

  def process_material(params)
    if params[:materials] != ""
      add_material(params[:materials].to_i)
    elsif params[:import] != ""
      import_materials(params[:import])
    else
      make_new_material(params)
    end
  end

  def add_material(id)
    ElementMaterial.create(
      :element_id => @el_id,
      :material_id => id,
      :last_update => Date.today,
      :price => Material.get(id).current_price,
      :mat_order => get_next_mat_order
    )
  end

  def make_new_material(params)
    params.tap{ |keys| keys.delete(:materials) && keys.delete(:import) }
    project_id = Element.get(@el_id).project_version.project_id
    new_material = Material.create(params)
    add_material(new_material.id)
  end

  def import_materials(id)
    Element.get(id).element_materials.each do |material|
      add_material(material.material_id)
    end
  end

  def loop_through_elements(params)
    params.each do |param|
      if param[0].include? 'el_order'
        @el_id = param[0].chomp(' el_order').to_i
        Element.get(@el_id).update(:el_order => param[1].to_i)
      elsif param[0].include? 'quantity'
        @el_id = param[0].chomp(' quantity').to_i
        Element.get(@el_id).update(:quantity => param[1].to_i)
      elsif param[0].include? 'include'
        @el_id = param[0].chomp(' include').to_i
        Element.get(@el_id).update(:quote_include => true)
      end
    end
    inc_param = "#{@el_id} include"
    Element.get(@el_id.to_i).update(:quote_include => false) if !params[inc_param]
  end
end

require_relative 'routes/init'
