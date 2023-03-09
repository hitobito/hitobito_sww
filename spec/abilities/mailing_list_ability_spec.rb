# encoding: utf-8

#  Copyright (c) 2012-2013, Jungwacht Blauring Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

require 'spec_helper'

describe MailingListAbility do

  let(:user) { role.person }
  let(:group) { role.group }
  let(:list) { Fabricate(:mailing_list, group: group) }

  subject { Ability.new(user.reload) }

  context 'support' do
    let(:role) { Fabricate(Group::SchweizerWanderwege::Support.name.to_sym, group: groups(:schweizer_wanderwege)) }

    context 'in own layer' do
      it 'may show mailing lists' do
        is_expected.to be_able_to(:show, list)
      end

      it 'may update mailing lists' do
        is_expected.to be_able_to(:update, list)
      end

      it 'may index subscriptions' do
        is_expected.to be_able_to(:index_subscriptions, list)
      end
    end

    context 'in group in lower layer' do
      let(:group) { groups(:berner_wanderwege) }

      it 'may show mailing lists' do
        is_expected.to be_able_to(:show, list)
      end

      it 'may update mailing lists' do
        is_expected.to be_able_to(:update, list)
      end

      it 'may index subscriptions' do
        is_expected.to be_able_to(:index_subscriptions, list)
      end
    end

    context 'in group in upper layer' do
      let(:role) { Fabricate(Group::Mitglieder::Aktivmitglied.name.to_sym, group: groups(:zuercher_mitglieder)) }
      let(:group) { groups(:schweizer_wanderwege) }

      it 'may not show mailing lists' do
        is_expected.not_to be_able_to(:show, list)
      end

      it 'may not update mailing lists' do
        is_expected.not_to be_able_to(:update, list)
      end

      it 'may not index subscriptions' do
        is_expected.not_to be_able_to(:index_subscriptions, list)
      end
    end
  end
end
