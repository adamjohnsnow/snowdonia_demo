class FactorySettingsElemental < Sinatra::Base

  post '/new-project' do
    project = new_project(params)
    redirect '/project-summary?project_id=' + project.id.to_s
  end

  get '/project-summary' do
    @dropdowns = get_dropdowns
    @project = Project.get(params[:project_id])
    if params[:version_id]
      @current_version = ProjectVersion.get(params[:version_id])
    else
      @current_version = @project.project_versions.last(:current_version => true)
    end
    update_prices if @current_version.current_version
    @totals = Totals.new.summarise_project(@current_version)
    @current_version.elements.sort_by! { |el| el['el_order']}
    @pm = User.get(@project.user_id)
    erb :project_summary
  end

  post '/save-project' do
    project_id = do_update_project(params)
    redirect '/project-summary?project_id=' + project_id
  end

  post '/update-project' do
    project = Project.get(params[:project_id])
    @current_version = project.project_versions.last(:current_version => true)
    @current_version.update(
      :last_update => Date.today.strftime("%d/%m/%Y") + ' by ' + session[:user]
    )
    @current_version.elements.all.update(:quote_include => false)
    loop_through_elements(params)
    MarkupUpdater.new.update_project(@current_version)
    redirect '/project-summary?project_id=' + params[:project_id]
  end

  post '/update-materials' do
    params.each do |param|
      if param[0].include? 'order'
        mat_id = param[0].chomp(' order').to_i
        ElementMaterial.get(mat_id).update(:mat_order => param[1])
      elsif param[0].include? 'units'
        mat_id = param[0].chomp(' units').to_i
        ElementMaterial.get(mat_id).update(:units => param[1].to_f)
      elsif param[0].include? 'notes'
        mat_id = param[0].chomp(' notes').to_i
        ElementMaterial.get(mat_id).update(:notes => param[1])
      end
    end
    Element.get(params[:element_id]).project_version.update(
      :last_update => Date.today.strftime("%d/%m/%Y") + ' by ' + session[:user]
    )
    redirect '/element?id=' + params[:element_id] + '#materials'
  end

  get '/project-labour' do
    @dropdowns = get_dropdowns
    @project = Project.get(params[:project_id])
    if params[:version_id]
      @current_version = ProjectVersion.get(params[:version_id])
    else
      @current_version = @project.project_versions.last(:current_version => true)
    end
    @current_version.elements.sort_by! { |el| el['el_order']}
    @pm = User.get(@project.user_id)
    erb :project_labour
  end

  post '/update-labour' do
    update_labour(params)
    redirect '/project-labour?project_id=' + params[:project_id] + '&version_id=' + params[:version_id] + '#labour-list'
  end

  get '/versions' do
    @project = Project.get(params[:id])
    erb :versions
  end

  post '/new-version' do
    params[:title] == "" ? title = "Unnamed Version" : title = params[:title]
    @project = Project.get(params[:project_id])
    @current_version = @project.project_versions.last(:current_version => true)
    @new_version = ProjectVersion.create(
      :project_id => params[:project_id],
      :created_by => session[:user],
      :version_name => title
    )
    VersionUpdater.new(@current_version, @new_version)
    redirect '/project-summary?project_id=' + params[:project_id]
  end

  get '/remove-my' do
    ProjectUser.get(session[:user_id], params[:project_id]).destroy!
    redirect '/home'
  end

  get '/add-my' do
    project = Project.get(params[:project_id])
    project.users << User.get(session[:user_id])
    project.save!
    redirect '/project-summary?project_id=' + params[:project_id]
  end
  private

  def new_project(params)
    redirect '/home' if params[:new] == ""
    project = Project.create(:title => params[:new], :site_id => 1, :client_id => 1, :user_id => session[:user_id])
    ProjectVersion.create(
      :project_id => project.id,
      :version_name => 'v0.1',
      :created_by => session[:user],
      :last_update => Date.today.strftime("%d/%m/%Y") + ' by ' + session[:user]
    )
    project.users << User.get(session[:user_id])
    project.save!
    return project
  end

  def do_update_project(params)
    update_version(params)
    update_project(params)
    @project.id.to_s
  end

  def update_version(params)
    @project = Project.get(params[:project_id])
    current_version = @project.project_versions.last(:current_version => true)
    current_version.update(
      :status => params[:status],
      :last_update => Date.today.strftime("%d/%m/%Y") + ' by ' + session[:user],
      :contingency => params[:contingency].to_f,
      :overhead => params[:overhead].to_f,
      :profit => params[:profit].to_f,
      :subcontractor => params[:subcontractor].to_f
    )
    if params[:contracted] == 'on'
      @project.project_versions.all.update(:contracted => false)
      current_version.update(:contracted => true)
    else
      current_version.update(:contracted => false)
    end
    MarkupUpdater.new.update_project(current_version)
  end

  def update_project(params)
    @project.update(
      :title => params[:title],
      :job_code => params[:job_code],
      :user_id => params[:user_id],
      :workshop_deadline => params[:workshop_deadline],
      :on_site => params[:on_site],
      :client_id => params[:client_id],
      :site_id => params[:site_id],
      :summary => params[:summary],
      :technical_requirements => params[:technical_requirements],
      :terms => params[:terms]
    )
  end

  def loop_through_elements(params)
    params.each do |param|
      if param[0].include? 'el_order'
        @el_id = param[0].chomp(' el_order').to_i
        Element.get(@el_id).update(:el_order => param[1].to_i)
      elsif param[0].include? 'quantity'
        @el_id = param[0].chomp(' quantity')
        Element.get(@el_id).update(:quantity => param[1])
      elsif param[0].include? 'include'
        @el_id = param[0].chomp(' include').to_i
        Element.get(@el_id).update(:quote_include => true)
      end
    end
  end

  def update_labour(params)
    @current_version = ProjectVersion.get(params[:version_id])
    params.each do |param|
      id_sym = param[0].split
      if id_sym.length == 2
        labour = ElementLabour.get(id_sym[0].to_i)
        labour.update(id_sym[1].to_sym => param[1])
      end
    end
  end

  def update_prices
    PriceUpdater.new(
      @current_version.elements.element_materials.all,
      @current_version.elements.element_materials.materials.all
    )
  end
end
