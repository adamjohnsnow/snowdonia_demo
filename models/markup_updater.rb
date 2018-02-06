class MarkupUpdater

  def update_project(project)
    project.elements.each do |element|
      if element.markup_defaults
        element.update(
          :contingency => project.contingency,
          :overhead => project.overhead,
          :profit => project.profit,
          :subcontractor => project.subcontractor
        )
      end
      update_element(element)
    end
  end

  def update_element(element)
    element.element_materials do |material|
      if material.markup_defaults
        material.update(
          :contingency => element.contingency,
          :overhead => element.overhead,
          :profit => element.profit,
          :subcontractor => element.subcontractor
        )
      end
    end
  end
end
