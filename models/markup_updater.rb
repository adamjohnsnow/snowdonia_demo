class MarkupUpdater

  def update_project(project)
    project = project
    project.elements.each do |element|
      update_element(element, project)
    end
  end

  def update_element(element, project)
    @element = element
    if @element.markup_defaults
      @element.update(
        :contingency => project.contingency,
        :overhead => project.overhead,
        :profit => project.profit,
        :subcontractor => project.subcontractor
      )
    end
    @element.element_materials.each do |material|
      update_material(material)
    end
  end

  def update_material(material)
    if material.markup_defaults
      material.update(
        :contingency => @element.contingency,
        :overhead => @element.overhead,
        :profit => @element.profit,
        :subcontractor => @element.subcontractor
      )
    end
  end
end
