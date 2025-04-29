# frozen_string_literal: true

#  Copyright (c) 2012-2025, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

module Sww::Event::ParticipationMailer
  private

  def localize_email_sender(message)
    super

    if custom_sender_name.present?
      message.from = custom_sender(message)
    end

    message
  end

  def custom_sender(message)
    "#{custom_sender_name} <#{message.from.first}>"
  end

  def custom_sender_name
    event.groups.first.then { _1.event_sender || _1.layer_group.event_sender }
  end
end
