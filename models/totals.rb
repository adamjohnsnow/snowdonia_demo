class Totals
attr_reader :materials, :labour, :days

  def initialize
    @materials = { at_cost: 0, markup: 0, with_markup: 0}
    @labour = { at_cost: 0, markup: 0, with_markup: 0}
    @days = { draw: 0, build: 0, paint: 0, site: 0, pm: 0}
  end

  def summarise_project(project)
    project.elements.each { |element| count_costs(element.element_materials, element.quantity) }
    return self
  end

  def summarise_element(element)
    @materials = { at_cost: 0, markup: 0, with_markup: 0}
    @labour = { at_cost: 0, markup: 0, with_markup: 0}
    @days = { draw: 0, build: 0, paint: 0, site: 0, pm: 0}
    count_costs(element, 1)
  end

  def count_costs(element, quantity)
    element.each do |unit|
      if unit.material.category.type == 'Labour'
        subtotal = @labour
        count_days(unit, quantity)
      else
        subtotal = @materials
      end
      cost = unit.material.unit_cost * unit.units
      subtotal[:at_cost] += (cost * quantity)
      subtotal[:markup] += (cost * unit.markup * quantity)
      subtotal[:with_markup] += (cost * (1 + unit.markup) * quantity)
    end
  end

  def count_days(unit, quantity)
    case unit.material.description
    when 'Project Management'
      @days[:pm] += (unit.units * quantity)
    when 'Draughting'
      @days[:draw] += (unit.units * quantity)
    when 'On Site days'
      @days[:site] += (unit.units * quantity)
    when /.Paint/
      @days[:paint] += (unit.units * quantity)
    else
      @days[:build] += (unit.units * quantity)
    end
  end
end
