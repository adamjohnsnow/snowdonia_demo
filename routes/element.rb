class FactorySettingsElemental < Sinatra::Base

  post '/new-element' do
    params[:title] = 'Unnamed Element' if params[:title] == ''
    make_new_element(params)
    redirect '/project-summary?project_id=' + params[:project_id] + '&version_id=' + params[:project_v_id] + '#elements-list'
  end

  get '/element' do
    @element = Element.get(params[:id])
    @matlist = Material.all(:project_id => @element.project_version.project.id, :active => true) + Material.all(:global => true, :active => true)
    @costcodes = Costcode.all
    erb :element
  end

  post '/update-element' do
    @element_id = params[:element_id]
    params.tap{ |keys| keys.delete(:captures) && keys.delete(:element_id) }
    update_element(params)
    Element.get(@element_id).project_version.update(
      :last_update => Date.today.strftime("%d/%m/%Y") + ' by ' + session[:user]
    )
    redirect '/element?id=' + @element_id
  end

  post '/update-element-labour' do
    element_id = params[:element_labour_id]
    params.tap{ |keys| keys.delete(:captures) && keys.delete(:element_labour_id) }
    params.each do |param|
      ElementLabour.get(element_id).update(param[0] => param[1].to_f)
    end
    Element.get(params[:element_id]).project_version.update(
      :last_update => Date.today.strftime("%d/%m/%Y") + ' by ' + session[:user]
    )
    redirect '/element?id=' + params[:element_id] + '#labour'
  end

  post '/add-material' do
    @el_id = params[:element_id]
    if params[:costcode_id] == '' && params[:materials] =='' && params[:import] == ''
      flash[:notice] = 'Please select either new, existing or import material'
      redirect '/element?id=' + @el_id
    end
    params.tap{ |keys| keys.delete(:element_id) && keys.delete(:captures) }
    process_material(params)
    Element.get(@el_id).project_version.update(
      :last_update => Date.today.strftime("%d/%m/%Y") + ' by ' + session[:user]
    )
    redirect '/element?id=' + @el_id + '#new-material'
  end

  get '/delete-element' do
    element = Element.get(params[:element_id])
    project_version = element.project_version
    destroy_element(element)
    redirect '/project-summary?project_id=' + project_version.project.id.to_s + '&version_id=' + project_version.id.to_s
  end

  private

  def make_new_element(params)
    next_order = get_next_order(params[:project_v_id])
    current_version = ProjectVersion.get(params[:project_v_id])
    el = Element.create(
      :title => params[:title],
      :project_version_id => params[:project_v_id],
      :reference => params[:reference],
      :client_ref => params[:client_ref],
      :el_order => next_order,
      :contingency => current_version.contingency,
      :overhead => current_version.overhead,
      :profit => current_version.profit,
      :subcontractor => current_version.subcontractor,
      :last_update => Date.today.strftime("%d/%m/%Y") + ' by ' + session[:user]
    )
    current_version.update(:last_update => Date.today.strftime("%d/%m/%Y") + ' by ' + session[:user])
    ElementLabour.create(:element_id => el.id)
  end

  def update_element(params)
    params[:quote_include] ? params[:quote_include] = true : params[:quote_include] = false
    params[:markup_defaults] ? params[:markup_defaults] = true : params[:markup_defaults] = false
    params.each do |param|
      Element.get(@element_id).update(param[0] => param[1])
    end
    Element.get(@element_id).update(
      :last_update => Date.today.strftime("%d/%m/%Y") + ' by ' + session[:user]
    )
    MarkupUpdater.new.update_element(Element.get(@element_id), Element.get(@element_id).project_version)
  end

  def get_next_order(id)
    elements = Element.all(:project_version_id => id)
    if elements == []
      1
    else
      elements.max_by{ |el| el[:el_order]}[:el_order] + 1
    end
  end

  def get_next_mat_order
    materials = ElementMaterial.all(:element_id => @el_id)
    if materials == []
      1
    else
      materials.max_by{ |mat| mat[:mat_order]}[:mat_order] + 1
    end
  end

  def process_material(params)
    if params[:materials] != ""
      add_material(params[:materials].to_i)
    elsif params[:import] != ""
      import_materials(params[:import])
    elsif params[:costcode_id] != '' && (params[:description] == '' || params[:supplier] == '' || params[:current_price] == '')
      flash[:notice] = 'Please enter description, supplier and price for new material'
      redirect '/element?id=' + @el_id
    else
      make_new_material(params)
    end
  end

  def add_material(id)
    element = Element.get(@el_id)
    ElementMaterial.create(
      :element_id => @el_id,
      :material_id => id,
      :last_update => Date.today,
      :price => Material.get(id).current_price,
      :mat_order => get_next_mat_order,
      :contingency => element.contingency,
      :overhead => element.overhead,
      :profit => element.profit,
      :subcontractor => element.subcontractor
    )
  end

  def make_new_material(params)
    params.tap{ |keys| keys.delete(:materials) && keys.delete(:import) }
    project_id = Element.get(@el_id).project_version.project_id
    new_material = Material.create(params)
    add_material(new_material.id)
  end

  def import_materials(id)
    Element.get(id).element_materials.each do |material|
      add_material(material.material_id)
    end
  end

  def destroy_element(element)
    element.element_materials.all.destroy!
    element.element_labour.destroy!
    element.destroy!
  end
end
