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
    @projects = Project.all
    erb :projects
  end

  get '/materials' do
    @materials = Material.all(:order => [ :costcode_id.asc ])
    erb :materials
  end

  get '/clients' do
    @clients = Client.all
    erb :clients
  end

  post '/sign-in' do
    @user = User.login(params)
    bad_sign_in if @user.nil?
    session[:user] = @user.firstname + ' ' + @user.surname
    session[:user_id] = @user.id
    session[:user_auth] = @user.level
    redirect '/home'
  end

  get '/users' do
    redirect '/home' if session[:user_auth] < 3
    @users = User.all
    erb :users
  end

  post '/new-user' do
    redirect '/home' if session[:user_auth] < 3
    params[:password] == params[:verify_password] ? register_user(params) : bad_password
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
    @current_version.elements.sort_by! { |el| el['el_order']}
    @pm = User.get(@project.user_id)
    erb :project_summary
  end

  post '/save-project' do
    project_id = update_project(params)
    redirect '/project-summary?project_id=' + project_id
  end

  post '/update-project' do
    params.each do |param|
      if param[0].include? 'el_order'
        el_id = param[0].chomp(' el_order').to_i
        Element.get(el_id).update(:el_order => param[1].to_i)
      elsif param[0].include? 'quantity'
        el_id = param[0].chomp(' quantity').to_i
        Element.get(el_id).update(:quantity => param[1].to_i)
      elsif param[0].include? 'include'
        el_id = param[0].chomp(' include').to_i
        Element.get(el_id).update(:quote_include => param[1])
      end
    end
    redirect '/project-summary?project_id=' + params[:project_id]
  end

  get '/project-labour' do
    @dropdowns = get_dropdowns
    @project = Project.get(params[:project_id])
    @current_version = @project.project_versions.last(:current_version => true)
    @pm = User.get(@project.user_id)
    erb :project_labour
  end

  post '/new-element' do
    params[:title] = 'Unnamed Element' if params[:title] == ''
    next_order = get_next_order(params[:project_v_id])
    el = Element.create(
      :title => params[:title],
      :project_version_id => params[:project_v_id],
      :reference => params[:reference],
      :el_order => next_order
    )
    ElementLabour.create(:element_id => el.id)
    redirect '/project-summary?project_id=' + params[:project_id] + '&version_id=' + params[:project_v_id]
  end

  get '/element' do
    @element = Element.get(params[:id])
    @elements = @element.project_version.elements.all
    @materials = @element.element_materials
    @matlist = Material.all(:project_id => @element.project_version.project.id) + Material.all(:global => true)
    @costcodes = Costcode.all
    @totals = { days: 23, cost: 1798.0 }
    erb :element
  end

  post '/update-element' do
    element_id = params[:element_id]
    params.tap{ |keys| keys.delete(:captures) && keys.delete(:element_id) }
    params.each do |param|
      Element.get(element_id).update(param[0] => param[1])
    end
    redirect '/element?id=' + element_id
  end

  post '/update-materials' do
    params.each do |param|
      if param[0].include? 'units'
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
    redirect '/element?id=' + params[:element_id]
  end

  post '/update-labour' do
    element_id = params[:element_labour_id]
    params.tap{ |keys| keys.delete(:captures) && keys.delete(:element_labour_id) }
    params.each do |param|
      ElementLabour.get(element_id).update(param[0] => param[1].to_f)
    end
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
    p params
    if params[:materials] != ""
      add_material(params[:materials].to_i)
    elsif params[:import] != ""
      import_materials(params[:import])
    else
      make_new_material(params)
    end
    redirect '/element?id=' + @el_id
  end

  post '/update-element' do
    params[:quote_include] ? params[:quote_include] = 't' : params[:quote_include] = 'f'
    @element = Element.get(params[:element_id])
    params.tap{ |keys| keys.delete(:element_id) && keys.delete(:captures) }
    @element.update(params)
    redirect '/element?id=' + @element.id.to_s
  end

  get '/edit-user' do
    redirect '/home' if session[:user_auth] < 3
    @user = User.get(params[:id])
    erb :edit_user
  end

  post '/edit-user' do
    redirect '/home' if session[:user_auth] < 3
    update_user(params)
    redirect '/users'
  end

  get '/logout' do
    session.clear
    redirect '/'
  end

  private

  def get_dropdowns
    return { status: STATUS,
      clients: Client.all,
      sites: Site.all,
      users: User.all(:order => [ :firstname.asc ])
    }
  end

  def register_user(params)
    @user = User.create(params[:firstname], params[:surname],
    params[:email], params[:password], params[:role])
    redirect '/users'
  end

  def bad_password
    flash.next[:notice] = 'Passwords did not match, try again'
    redirect '/users'
  end

  def bad_sign_in
    flash.next[:notice] = 'you could not be signed in, try again'
    redirect '/'
  end

  def update_user(params)
    user = User.get(params[:user_id])
    params.tap{ |keys| keys.delete(:captures) && keys.delete(:user_id) }
    user.update(params)
    user.save!
  end

  def new_project(params)
    redirect '/home' if params[:new] == ""
    project = Project.create(:title => params[:new], :site_id => 1, :client_id => 1, :user_id => session[:user_id])
    ProjectVersion.create(:project_id => project.id, :version_name => 'v0.1', :created_by => session[:user])
    project.users << User.get(session[:user_id])
    project.save!
    return project
  end

  def update_project(params)
    update_version(params)
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

  def get_next_order(id)
    elements = Element.all(:project_version_id => id)
    if elements == []
      1
    else
      elements.max_by{ |el| el[:el_order]}[:el_order] + 1
    end
  end

  def add_material(id)
    ElementMaterial.create(
      :element_id => @el_id,
      :material_id => id,
      :last_update => Date.today,
      :price => Material.get(id).current_price
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
end
