class Totals

  def summarise_project(project)
    @project_summary = []
    project.elements.each do |element|
      @element_summary = { id: element.id, materials: 0, labour: 0, markup: 0 }
      count_costs(element)
      @project_summary << @element_summary
    end
    return @project_summary
  end

  def count_costs(element)
    @element_summary[:labour] = calc_labour(element.element_labour)
    element.element_materials.each do |material|
      @element_summary[:materials] += material.price * material.units
      @element_summary[:markup] += calc_markup(material.price, material, material.units)
    end
    @element_summary[:markup] += calc_labour_markup(@element_summary[:labour], element, 1)
  end

  def calc_markup(cost, material, qty)
    if material.subcontract
      return ((cost * (material.subcontractor / 100)) * qty).round(2)
    else
      contingency = cost * (material.contingency / 100)
      overhead = (cost + contingency) * (material.overhead / 100)
      profit = (cost + contingency + overhead) * (material.profit / 100)
      return ((profit + contingency + overhead) * qty).round(2)
    end
  end

  def calc_labour_markup(cost, material, qty)
    contingency = cost * (material.contingency / 100)
    overhead = (cost + contingency) * (material.overhead / 100)
    profit = (cost + contingency + overhead) * (material.profit / 100)
    return ((profit + contingency + overhead) * qty).round(2)
  end

  def calc_labour(labour)
    total = 0
    total += (labour[:carpentry] * labour[:carpentry_cost])
    total += (labour[:steelwork] * labour[:steelwork_cost])
    total += (labour[:scenic] * labour[:scenic_cost])
    total += (labour[:onsite_paint] * labour[:onsite_paint_cost])
    total += (labour[:onsite_day] * labour[:onsite_day_cost])
    total += (labour[:drafting] * labour[:drafting_cost])
    total += (labour[:project_management] * labour[:project_management_cost])
    return total
  end

end
