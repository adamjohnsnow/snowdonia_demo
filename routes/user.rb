class FactorySettingsElemental < Sinatra::Base
  get '/users' do
    redirect '/home' if session[:user_auth] < 2
    @users = User.all
    erb :users
  end

  post '/sign-in' do
    @user = User.login(params)
    bad_sign_in if @user.nil?
    session[:user] = @user.firstname + ' ' + @user.surname
    session[:user_id] = @user.id
    session[:user_auth] = @user.level
    redirect '/home'
  end

  post '/new-user' do
    redirect '/home' if session[:user_auth] < 3
    params[:password] == params[:verify_password] ? register_user(params) : bad_password
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

  def register_user(params)
    @user = User.create(params[:firstname], params[:surname],
    params[:email], params[:password], params[:role], params[:level])
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
end
