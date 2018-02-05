class FactorySettingsElemental < Sinatra::Base

  post '/new-element' do
    params[:title] = 'Unnamed Element' if params[:title] == ''
    next_order = get_next_order(params[:project_v_id])
    el = Element.create(
      :title => params[:title],
      :project_version_id => params[:project_v_id],
      :reference => params[:reference],
      :client_ref => params[:client_ref],
      :el_order => next_order
    )
    el.project_version.update(:last_update => Date.today.strftime("%d/%m/%Y") + ' by ' + session[:user])
    ElementLabour.create(:element_id => el.id)
    redirect '/project-summary?project_id=' + params[:project_id] + '&version_id=' + params[:project_v_id]
  end

  get '/element' do
    @element = Element.get(params[:id])
    @matlist = Material.all(:project_id => @element.project_version.project.id) + Material.all(:global => true)
    @costcodes = Costcode.all
    @totals = { days: 23, cost: 1798.0 }
    erb :element
  end

  post '/update-element' do
    params[:quote_include] ? params[:quote_include] = true : params[:quote_include] = false
    element_id = params[:element_id]
    params.tap{ |keys| keys.delete(:captures) && keys.delete(:element_id) }
    params.each do |param|
      Element.get(element_id).update(param[0] => param[1])
    end
    Element.get(element_id).project_version.update(
      :last_update => Date.today.strftime("%d/%m/%Y") + ' by ' + session[:user]
    )
    redirect '/element?id=' + element_id
  end

  private

  def get_next_order(id)
    elements = Element.all(:project_version_id => id)
    if elements == []
      1
    else
      elements.max_by{ |el| el[:el_order]}[:el_order] + 1
    end
  end
  
end
