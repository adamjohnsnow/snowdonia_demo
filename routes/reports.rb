require 'csv'
class FactorySettingsElemental < Sinatra::Base

  LABOURTYPES= [
    :carpentry,
    :steelwork,
    :scenic,
    :onsite_paint,
    :onsite_day,
    :draughting,
    :project_management
  ]

  get '/costcode-report' do
    erb :costcode_report
  end

  get '/report' do
    @type = params[:type].to_sym
    @project = ProjectVersion.get(params[:version_id])
    @materials = @project.elements.element_materials.all
    if @project.current_version
      PriceUpdater.new(@materials, @materials.materials.all)
    end
    write_csvs if @type != :draughting
    erb @type
  end

  get '/download' do
     send_file "./report_outputs/" +  params[:report], :filename => params[:report], :type => 'Application/octet-stream'
  end

  def sum_markup(element_materials)
    markup = 0
    element_materials.each do |el_mat|
      if el_mat.subcontract
        markup += el_mat.price * el_mat.units * (1 + el_mat.subcontractor / 100)
      else
        markup += (
          (
            el_mat.price * el_mat.units * (1 + el_mat.contingency / 100)
            ) * (1 + el_mat.overhead / 100)
          ) * (1 + el_mat.profit / 100)
      end
    end
    markup
  end

  def total_cc(cc_id)
    total = 0
    markup = 0
    @materials.materials.all(:costcode_id => cc_id).each do |mat|
      element_materials = @materials.all(:material_id => mat.id)
      total += element_materials[0].price * element_materials.sum(:units)
      markup += sum_markup(element_materials)
    end
    [total, markup]
  end

  def total_labour_days
    @project.elements.element_labours.aggregate(
      :carpentry,
      :steelwork,
      :scenic,
      :onsite_paint,
      :onsite_day,
      :draughting,
      :project_management
    )
  end

  def total_labour_costs
    total = 0
    markup = 0
    @project.elements.element_labours.each do |labour|
      sub_total = (labour[:carpentry] * labour[:carpentry_cost])
      sub_total += (labour[:steelwork] * labour[:steelwork_cost])
      sub_total += (labour[:scenic] * labour[:scenic_cost])
      sub_total += (labour[:onsite_paint] * labour[:onsite_paint_cost])
      sub_total += (labour[:onsite_day] * labour[:onsite_day_cost])
      sub_total += (labour[:draughting] * labour[:draughting_cost])
      sub_total += (labour[:project_management] * labour[:project_management_cost])
      total += sub_total
      sub_total = sub_total * (1 + labour.element.contingency / 100)
      sub_total = sub_total * (1 + labour.element.overhead / 100)
      sub_total = sub_total * (1 + labour.element.profit / 100)
      markup += sub_total
    end
    [total, markup]
  end

  def summarise_labour(symbol)
    total = 0
    markup = 0
    @project.elements.element_labours.each do |labour|
      cost_sym = (symbol.to_s + '_cost').to_sym
      sub_total = (labour[symbol] * labour[cost_sym])
      total += sub_total
      sub_total = sub_total * (1 + labour.element.contingency / 100)
      sub_total = sub_total * (1 + labour.element.overhead / 100)
      sub_total = sub_total * (1 + labour.element.profit / 100)
      markup += sub_total
    end
    [total, markup]
  end

  def write_csvs
    filename = "./report_outputs/user_#{session[:user_id]}_#{@project.project.title}_#{@project.version_name}_#{@type.to_s}.csv"
    make_costcode_rows if @type == :costcode_report
    make_ordersheet_rows if @type == :ordersheet
    IO.write(filename, @rows.map(&:to_csv).join)
  end

  def make_ordersheet_rows
    @rows = [['Costcode', 'Description', 'Supplier', 'Unit Cost', 'Qty', 'Total Cost']]
    @materials.materials.all(:order => [ :costcode_id.asc ]).each do |material|
      cost = @materials.first(:material_id => material.id).price
      qty = @materials.all(:material_id => material.id).sum(:units)
      if qty > 0
        @rows << [material.costcode.code, material.description, material.supplier, cost, qty, (cost * qty).round(2)]
      end
    end
  end

  def make_costcode_rows
    @rows = [['Costcode', 'Description', 'Qty', 'Total Cost', 'With Markup']]
    @materials.materials.costcodes.all.each do |cc|
      total = 0
      markup = 0
      @materials.materials.all(:costcode_id => cc.id).each do |mat|
        element_materials = @materials.all(:material_id => mat.id)
        total += element_materials[0].price * element_materials.sum(:units)
        markup += sum_markup(element_materials)
      end
      @rows << [cc.code, cc.description, '', total.round(2), markup.round(2)]
    end
    @rows << ['Labour', '', total_labour_days.flatten.inject(:+), total_labour_costs[0].round(2), total_labour_costs[1].round(2)]
  end
end
