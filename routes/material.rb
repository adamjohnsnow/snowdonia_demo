class FactorySettingsElemental < Sinatra::Base

  get '/element-material' do
    @el_mat = ElementMaterial.get(params[:elmat_id])
    erb :element_material
  end

  post '/update-element-material' do
    params[:subcontract] ? params[:subcontract] = true : params[:subcontract] = false
    params[:markup_defaults] ? params[:markup_defaults] = true : params[:markup_defaults] = false
    el_mat = ElementMaterial.get(params[:elmat_id])
    el_mat.update(
      :units => params[:units].to_f,
      :notes => params[:notes],
      :markup_defaults => params[:markup_defaults],
      :subcontract => params[:subcontract],
      :contingency => params[:contingency].to_f,
      :overhead => params[:overhead].to_f,
      :profit => params[:profit].to_f,
      :subcontractor => params[:subcontractor].to_f
    )
    MarkupUpdater.new.update_element(el_mat.element, el_mat.element.project_version)
    redirect '/element-material?elmat_id=' + params[:elmat_id]
  end

  get '/delete-element-material' do
    material = ElementMaterial.get(params[:material_id])
    element = material.element.id
    material.destroy!
    redirect '/element?id=' + element.to_s
  end

  private

end
