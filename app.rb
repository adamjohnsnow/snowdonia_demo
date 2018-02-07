require 'sinatra/base'
require 'sinatra/flash'
require 'pry'
require_relative './data_mapper_setup'

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

  get '/materials' do
    sort = params[:sort_by].to_sym
    if params[:direction] == 'asc'
      @materials = Material.all(:order => [ sort.asc ])
      @order = 'desc'
    else
      @materials = Material.all(:order => [ sort.desc ])
      @order = 'asc'
    end
    erb :materials
  end

  get '/costcodes' do
    @costcodes = Costcode.all
    erb :costcodes
  end

  post '/new-costcode' do
    Costcode.create(
      :code => params[:code],
      :description => params[:description],
      :owner => params[:owner]
    )
    redirect '/costcodes'
  end

  get '/pdf' do
    url     = 'http://localhost:9292'
    options = { :margin => "1cm"}
    Shrimp::Phantom.new(url, options).to_pdf("output.pdf")
  end
  private

  def get_dropdowns
    return { status: STATUS,
      clients: Client.all,
      sites: Site.all,
      users: User.all(:order => [ :firstname.asc ])
    }
  end
end
require_relative 'routes/init'
