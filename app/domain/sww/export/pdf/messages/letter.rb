#  frozen_string_literal: true

#  Copyright (c) 2022-2024, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

module Sww::Export::Pdf::Messages::Letter
  extend ActiveSupport::Concern

  MEMBERSHIP_CARD_MARGIN = 2.cm

  def sections
    @sections ||= if membership_card?
                    membership_card_sections
                  else
                    super
                  end
  end

  def membership_card_sections
    [
      ::Sww::Export::Pdf::Messages::Letter::MembershipCard,
      ::Sww::Export::Pdf::Messages::Letter::MembershipCards::Header,
      ::Sww::Export::Pdf::Messages::Letter::MembershipCards::Content
    ].collect do |section|
      section.new(pdf,
                  @letter,
                  @options.slice(:debug, :stamped))
    end
  end

  def render_options
    super.merge(margin: margin)
  end

  def margin
    if membership_card?
      MEMBERSHIP_CARD_MARGIN
    else
      Export::Pdf::Messages::Letter::MARGIN
    end
  end

  def membership_card?
    @letter.membership_card?
  end

  private

  def customize
    super
    ::Export::Pdf::Font.new(pdf).customize
  end
end
