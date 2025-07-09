# frozen_string_literal: true

#  Copyright (c) 2012-2025, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.


require 'spec_helper'

describe PaperTrail::VersionDecorator, :draper_with_helpers, versioning: true do

  include Rails.application.routes.url_helpers

  let(:person)    { people(:zuercher_wanderer) }
  let(:version)   { PaperTrail::Version.where(main_id: person.id).order(:created_at, :id).last }
  let(:decorator) { PaperTrail::VersionDecorator.new(version) }

  before { PaperTrail.request.whodunnit = nil }

  context '#author' do
    subject { decorator.author }

    context 'without current user' do
      before { update }
      it { is_expected.to be_nil }
    end

    context 'with current user' do
      before do
        PaperTrail.request.whodunnit = person.id.to_s
        update
      end

      context 'and permission to link' do
        it do
          expect(decorator.h).to receive(:can?).with(:show, person).and_return(true)
          is_expected.to match(/^<a href=".+">#{person}<\/a>$/)
        end
      end

      context 'and no permission to link' do
        it do
          expect(decorator.h).to receive(:can?).with(:show, person).and_return(false)
          is_expected.to eq(person.to_s)
        end
      end
    end

    context 'with service token' do
      let(:service_token) { service_tokens(:permitted_top_layer_token) }

      before do
        PaperTrail.request.whodunnit = service_token.id.to_s
        PaperTrail.request.controller_info = { whodunnit_type: ServiceToken.sti_name }
        update
      end

      context 'and permission to link' do
        it do
          expect(decorator.h).to receive(:can?).with(:show, service_token).and_return(true)
          is_expected.to match(/^<a href=".+">API-Key: Permitted<\/a>$/)
        end
      end

      context 'and no permission to link' do
        it do
          expect(decorator.h).to receive(:can?).with(:show, service_token).and_return(false)
          is_expected.to eq('API-Key: Permitted')
        end
      end
    end

    context 'with service token and specific_author' do
      let(:service_token) { service_tokens(:permitted_top_layer_token) }

      before do
        PaperTrail.request.whodunnit = service_token.id.to_s
        PaperTrail.request.controller_info = {
          whodunnit_type: ServiceToken.sti_name,
          specific_author: 'It was I'
        }
        update
      end

      context 'and permission to link' do
        it do
          expect(decorator.h).to receive(:can?).with(:show, service_token).and_return(true)
          is_expected.to match(/^<a href=".+">&quot;It was I&quot; via API-Key: Permitted<\/a>$/)
        end
      end

      context 'and no permission to link' do
        it do
          expect(decorator.h).to receive(:can?).with(:show, service_token).and_return(false)
          is_expected.to eq('&quot;It was I&quot; via API-Key: Permitted')
        end
      end
    end
  end

  def update
    person.update!(town: 'Bern', zip_code: '3007')
  end

end
