class Totals
attr_reader :materials, :labour

  def initialize(element)
    @materials = { at_cost: 0, markup: 0, with_markup: 0}
    @labour = { at_cost: 0, markup: 0, with_markup: 0}
    summarise(element)
  end

  def summarise(element)
    element.each do |unit|
      unit.material.category.type == 'Labour' ? subtotal = @labour : subtotal = @materials
      cost = unit.material.unit_cost * unit.units
      subtotal[:at_cost] += cost
      subtotal[:markup] += cost * unit.markup
      subtotal[:with_markup] += cost * (1 + unit.markup)
    end
  end
end
