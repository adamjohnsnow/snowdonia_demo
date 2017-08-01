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
    redirect '/home'
  end

  get '/new-user' do
    erb :new_user
  end

  post '/new-user' do
    params[:password] == params[:verify_password] ? register_user(params) : bad_password
  end

  get '/project' do
    @user_id = session[:user_id]
    if params[:new]
      redirect '/home' if params[:new] == ""
      @project = Project.create(:title => params[:new], :site_id => 1, :client_id => 1, :pm_id => @user_id)
      @project.users << User.get(session[:user_id])
      @project.save!
    else
      @project = Project.get(params[:id])
    end
    @status = STATUS
    @clients = Client.all
    @sites = Site.all
    @users = User.all(:order => [ :firstname.asc ])
    erb :project
  end

  post '/project' do
    @project = Project.get(params[:project_id])
    params.tap{ |keys| keys.delete(:project_id) && keys.delete(:captures) }
    @project.update(params)
    @project.save!
    redirect '/project-summary?project_id=' + @project.id.to_s
  end

  get '/project-summary' do
    @project = Project.get(params[:project_id])
    @pm = User.get(@project.pm_id)
    erb :project_summary
  end

  post '/new-element' do
    Element.create(:title => params[:title], :project_id => params[:project_id])
    redirect '/project-summary?project_id=' + params[:project_id]
  end

  get '/element' do
    @element = Element.get(params[:id])
    @materials = @element.element_materials(:order => [ material.category_id.asc ])
    @totals = Totals.new(@materials)
    erb :element
  end

  get '/logout' do
    session.destroy
    redirect '/'
  end
  private

  def register_user(params)
    @user = User.create(params[:firstname], params[:surname],
    params[:email], params[:password])
    session[:user] = @user.firstname
    session[:user_id] = @user.id
    redirect '/home'
  end

  def bad_password
    flash.next[:notice] = 'your passwords did not match, try again'
    redirect '/'
  end

  def bad_sign_in
    flash.next[:notice] = 'you could not be signed in, try again'
    redirect '/'
  end
end
