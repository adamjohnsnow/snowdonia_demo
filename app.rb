require 'sinatra/base'
require 'sinatra/flash'
require 'pry'
require_relative './data_mapper_setup'

ENV['RACK_ENV'] ||= 'development'

class FactorySettingsElemental < Sinatra::Base
  enable :sessions
  set :session_secret, ENV['SESSION_SECRET'] || 'something'
  register Sinatra::Flash

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
