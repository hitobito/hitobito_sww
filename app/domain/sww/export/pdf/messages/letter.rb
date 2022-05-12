#  Copyright (c) 2022, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

module Sww::Export::Pdf::Messages::Letter
  extend ActiveSupport::Concern

  def sections
    @sections ||= [Export::Pdf::Messages::Letter::MembershipCard.new(pdf,
                                                                     @letter,
                                                                     @options.slice(:debug, :stamped))] + super
  end
end
