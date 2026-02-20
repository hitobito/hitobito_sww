# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Wanderwege. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww

module People::SplitHelper
  def split_form_header_row
    People::SplitHelper.split_form_row(
      context: self,
      label: "",
      person_1_col: content_tag(:strong, captionize(:person_1, People::SplitForm)),
      person_2_col: content_tag(:strong, captionize(:person_2, People::SplitForm))
    )
  end

  def split_form_attr_row(form, attr, &block)
    label = form.captionize(attr, Person)
    person_1_col = People::SplitHelper.field_for_person(
      context: self, form:, attr:, person_sym: :person_1, &block
    )
    person_2_col = People::SplitHelper.field_for_person(
      context: self, form:, attr:, person_sym: :person_2, &block
    )

    People::SplitHelper.split_form_row(context: self, label:, person_1_col:, person_2_col:)
  end

  class << self
    # Internal helper methods, implemented as class methods to avoid polluting the view context
    # and prevent name clashes with other helper methods.

    def split_form_row(context:, label:, person_1_col:, person_2_col:)
      context.content_tag(:div, class: "row mb-2") do
        [
          context.content_tag(:div, label, class: "col-2 text-md-end"),
          context.content_tag(:div, person_1_col, class: "col-5"),
          context.content_tag(:div, person_2_col, class: "col-5")
        ].join.html_safe
      end
    end

    def field_for_person(context:, form:, attr:, person_sym:, &block)
      form.fields_for(person_sym, include_id: false) do |fields|
        block_given? ? context.instance_exec(fields, &block) : fields.input_field(attr)
      end
    end
  end
end
