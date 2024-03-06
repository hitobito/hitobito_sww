# frozen_string_literal: true

#  Copyright (c) 2023, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

require 'spec_helper'

describe Sww::Export::Tabular::People::PeopleFull do

  let(:person) { people(:berner_wanderer) }
  let(:list) { [person] }
  let(:people_list) { Export::Tabular::People::PeopleFull.new(list) }

  subject { people_list }

  its(:attributes) do
    should match_array [
      :first_name,
      :last_name,
      :company_name,
      :nickname,
      :company,
      :email,
      :address,
      :zip_code,
      :town,
      :country,
      :gender,
      :birthday,
      :additional_information,
      :language,
      :custom_salutation,
      :magazin_abo_number,
      :title,
      :name_add_on,
      :layer_group,
      :roles,
      :tags,
      :id,
      :sww_salutation,
      :member_number
    ]
  end

  context '#attribute_labels' do
    subject { people_list.attribute_labels }

    its([:sww_salutation]) { should eq 'Anrede' }
  end

end

