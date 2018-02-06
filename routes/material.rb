class FactorySettingsElemental < Sinatra::Base

  get '/element-material' do
    @el_mat = ElementMaterial.get(params[:elmat_id])
    erb :element_material
  end

  private

end
