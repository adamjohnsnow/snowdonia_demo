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
    erb :index
  end

  get '/home' do
    @user = User.get(session[:user_id])
    @projects = @user.projects.all
    erb :home
  end

  post '/sign-in' do
    @user = User.login(params)
    bad_sign_in if @user.nil?
    session[:user] = @user.firstname
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

  get '/project' do
    @user_id = session[:user_id]
    if params[:new]
      @project = new_project(params)
    else
      @project = Project.get(params[:id])
    end
    @dropdowns = get_dropdowns
    erb :project
  end

  post '/project' do
    @project = Project.get(params[:project_id])
    params.tap{ |keys| keys.delete(:project_id) && keys.delete(:captures) }
    @project.update(params)
    @project.add_user(params[:pm_id])
    @project.save!
    redirect '/project-summary?project_id=' + @project.id.to_s
  end

  get '/project-summary' do
    @project = Project.get(params[:project_id])
    @pm = User.get(@project.pm_id)
    @totals = Totals.new
    @grand_total = Totals.new
    @grand_total.summarise_project(@project)
    erb :project_summary
  end

  post '/new-element' do
    params[:title] = 'Unnamed Element' if params[:title] == ''
    Element.create(:title => params[:title], :project_id => params[:project_id])
    redirect '/project-summary?project_id=' + params[:project_id]
  end

  get '/element' do
    @element = Element.get(params[:id])
    @materials = @element.element_materials
    @totals = Totals.new
    @totals.summarise_element(@materials)
    @categories = Category.all
    @labour_types = Material.all(:category_id => 3)
    erb :element
  end

  get '/material' do
    if params[:id]
      @element_material = ElementMaterial.get(params[:id])
      @element_id = @element_material.element_id
      @materials = Material.all(:category_id => @element_material.material.category_id)
    else
      @element_id = params[:element]
      if params[:category] == "0"
        @materials = Material.all
      else
        @materials = Material.all(:category_id => params[:category])
      end
    end
    erb :add_material
  end

  post '/material' do
    params[:markup] = (params[:markup].to_f / 100)
    params.tap{ |keys| keys.delete(:captures) }
    if params[:element_material_id]
      element_material = ElementMaterial.get(params[:element_material_id])
      params.tap{ |keys| keys.delete(:element_material_id) }
      element_material.update(params)
      element_material.save!
    else
      element_material = ElementMaterial.create(params)
    end
    redirect '/element?id=' + params[:element_id]
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
    params[:email], params[:password])
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
    project = Project.create(:title => params[:new], :site_id => 1, :client_id => 1, :pm_id => session[:user_id])
    project.add_user(session[:user_id])
    project.save!
    return project
  end
end
