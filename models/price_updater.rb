class PriceUpdater

  def initialize(element_materials, materials_list)
    element_materials.each do |el_material|
      this_mat = materials_list.get(el_material[:material_id])
      el_material.update(:price => this_mat.current_price)
    end
  end

end
