class VersionUpdater
  def initialize(old_version, new_version)
    @old_version = old_version
    @new_version= new_version
    duplicate_elements
  end

  private

  def duplicate_elements
    @old_version.elements.each do |element|
      @old_element = element
      attributes = get_element_attributes(@old_element)
      @new_element = Element.create(attributes)
      duplicate_materials
    end
  end

  def duplicate_materials
    @old_element.element_materials.each do |el_mat|
      attributes = get_el_mat_attributes(el_mat)
      ElementMaterial.create(attributes)
    end
  end

  def get_element_attributes(item)
    attributes = item.attributes
    attributes.update(:project_version_id => @new_version.id)
    attributes.delete(:id)
    return attributes
  end
  
  def get_el_mat_attributes(item)
    attributes = item.attributes
    attributes.update(:element_id => @new_element.id)
    attributes.delete(:id)
    return attributes
  end
end
