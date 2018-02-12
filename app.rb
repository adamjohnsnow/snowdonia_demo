require 'sinatra/base'
require 'sinatra/flash'
require 'pry'
require_relative './data_mapper_setup'

ENV['RACK_ENV'] ||= 'development'

class FactorySettingsElemental < Sinatra::Base
  enable :sessions
  configure do
    use Rack::Session::Cookie,
    :expire_after => 43200,
    :secret => ENV['SESSION_SECRET'] || 'something'
  end
  register Sinatra::Flash

  STATUS = ['New', 'Costing', 'Draughting', 'In Build', 'On Site', 'Site Clearance', 'Complete', 'Cancelled']

  before do
    redirect '/' unless session[:user_id] || request.path_info == '/' || request.path_info == '/sign-in'
  end

  get '/' do
    erb :index, :layout => false
  end

  get '/home' do
    @user = User.get(session[:user_id])
    @projects = @user.projects.project_versions.all(:current_version => true)
    @projects = @projects - @projects.all(:status => 'Cancelled')
    @projects = @projects - @projects.all(:status => 'Complete')
    erb :home
  end

  get '/projects' do
    @projects = Project.all(:order => [ :title.asc ])
    erb :projects
  end

  get '/clients' do
    @clients = Client.all(:order => [ :name.asc ])
    @sites = Site.all(:order => [ :name.asc ])
    erb :clients
  end

  get '/materials' do
    @sort = params[:sort_by].to_sym
    if params[:direction] == 'asc'
      @materials = Material.all(:active => true, :order => [ @sort.asc ])
      @order = 'desc'
    else
      @materials = Material.all(:active => true, :order => [ @sort.desc ])
      @order = 'asc'
    end
    erb :materials
  end

  get '/delete-material' do
    Material.get(params[:id]).update(:active => false)
    redirect '/materials?sort_by=' + params[:sort_by] + '&direction=' + params[:direction]
  end

  post '/update-all-materials' do
    params.each do |param|
      if param[0].include? 'current_price'
        mat_id = param[0].chomp('_current_price').to_i
        Material.get(mat_id).update(:current_price => param[1].to_f)
        ProjectVersion.all(:current_version => true).elements.element_materials(:material_id => mat_id).update(:price => param[1].to_f)
      elsif param[0].include? 'global'
        mat_id = param[0].chomp('_global').to_i
        Material.get(mat_id).update(:global => true)
      end
    end
    redirect '/materials?sort_by=' + params[:sort_by] + '&direction=' + params[:direction]
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
