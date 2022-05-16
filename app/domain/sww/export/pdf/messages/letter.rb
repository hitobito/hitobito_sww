#  Copyright (c) 2022, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

module Sww::Export::Pdf::Messages::Letter
  extend ActiveSupport::Concern

  MEMBERSHIP_CARD_MARGIN = 2.cm

  def sections
    @sections ||= if membership_card?
                    [Export::Pdf::Messages::Letter::MembershipCard.new(pdf,
                                                                       @letter,
                                                                       @options.slice(:debug, :stamped))] + super
                  else
                    super
                  end
  end

  def render_options
    super.merge(margin: margin)
  end

  def margin
    membership_card? ? MEMBERSHIP_CARD_MARGIN : MARGIN
  end

  def membership_card?
    @letter.membership_card?
  end
end
