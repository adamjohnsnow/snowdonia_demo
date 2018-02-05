class FactorySettingsElemental < Sinatra::Base

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
  
  private

end
