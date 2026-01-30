# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Wanderwege. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww

module People::SplitHelper
  def split_form_header_row
    split_form_row(
      label: "",
      person_1_col: content_tag(:strong, captionize(:person_1, People::SplitForm)),
      person_2_col: content_tag(:strong, captionize(:person_2, People::SplitForm))
    )
  end

  def split_form_attr_row(form, attr, &block)
    label = form.captionize(attr, Person)
    person_1_col = field_for_person(form, attr, :person_1, &block)
    person_2_col = field_for_person(form, attr, :person_2, &block)

    split_form_row(label:, person_1_col:, person_2_col:)
  end

  private

  module_function def split_form_row(label:, person_1_col:, person_2_col:)
    content_tag(:div, class: "row mb-2") do
      [
        content_tag(:div, label, class: "col-2 text-md-end"),
        content_tag(:div, person_1_col, class: "col-5"),
        content_tag(:div, person_2_col, class: "col-5")
      ].join.html_safe
    end
  end

  module_function def field_for_person(form, attr, person_sym)
    form.fields_for(person_sym, include_id: false) do |fields|
      block_given? ? yield(fields) : fields.input_field(attr)
    end
  end
end
