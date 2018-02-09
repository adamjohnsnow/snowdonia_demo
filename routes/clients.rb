class FactorySettingsElemental < Sinatra::Base

    post '/add-client' do
      params.tap { |k| k.delete(:captures) }
      Client.create(params)
      redirect '/clients'
    end

    post '/add-site' do
      params.tap { |k| k.delete(:captures) }
      Site.create(params)
      redirect '/clients'
    end

    post '/save-site' do
      site = Site.get(params[:site_id])
      params.tap { |k| k.delete(:captures) && k.delete(:site_id) }
      site.update(params)
      redirect '/clients'
    end

    get '/client-site' do
      if params[:site_id]
        @site = Site.get(params[:site_id])
        erb :edit_site
      else
        @client = Client.get(params[:client_id])
        erb :edit_client
      end
    end

  private

end
