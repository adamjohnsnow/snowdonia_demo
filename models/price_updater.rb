class PriceUpdater

  def initialize(element_materials, materials_list)
    element_materials.each do |el_material|
      this_mat = materials_list.select{ |material| material[:id] == el_material[:material_id] }
      el_material[:price] = this_mat[0][:current_price]
    end
  end

end
