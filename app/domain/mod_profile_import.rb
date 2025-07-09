# frozen_string_literal: true

#  Copyright (c) 2012-2025, Schweizer Wanderwege. This file is part of
#  hitobito_sww and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sww.

module ModProfileImport
  class Source
    attr_reader :target, :lines, :filter
    def initialize(file, lines: nil, filter: nil)
      @target = Wagons.all[0].root.join("tmp/#{file}.csv")
      @lines = lines
      @filter = filter
    end

    def csv = @csv ||= filtered(CSV.parse(lines ? target.readlines.take(lines).join : target.read, headers: true))

    def filtered(csv) = filter ? csv.select { |row| filter.call(row) } : csv
  end

  GENDERS = [[:m, 1], [:w, 2]].to_h.invert

  MAPPING = [
    [:profile_id, :sww_cms_profile_id],
    [:profile_salutation, :gender, ->(v) { GENDERS[v.to_i] }],
    [:profile_prename, :first_name],
    [:profile_lastname, :last_name],
    [:profile_address, :street],
    [:profile_streetnr, :housenumber],
    [:profile_zip, :zip_code],
    [:profile_city, :town],
    [:profile_country, :country, ->(v) { v if Countries.codes.include?(v.to_s.upcase) }],
    [:profile_birthday, :birthday, ->(v) { Time.zone.at(v.to_i).to_date if v.to_i.positive? }],
    [:profile_email, :email, ->(v) { Truemail.validate(v.to_s, with: :regex).result.email }],
    [:profile_lang, :language, ->(v) { v.presence || "de" }],
    [:profile_phone, :phone, ->(v) { Phonelib.parse(nil).sanitized.presence }],
    [:profile_password, :encrypted_password],
    [:profile_password_salt, :sww_cms_legacy_password_salt]
  ]

  class Row < Struct.new(*MAPPING.map(&:second), keyword_init: true)
    attr_reader :attrs

    delegate :valid?, :errors, to: :person

    def initialize(attrs)
      @attrs = attrs.to_h.symbolize_keys
      super(convert)
    end

    def person
      @person ||= ::Person.find_or_initialize_by(email:).tap do |person|
        person.skip_confirmation_notification!
        person.attributes = to_h.except(:phone)
        person.phone_numbers.build(label: "Privat", number: phone) if phone
        person.roles.find_or_initialize_by(group_id: group_id, type: Group::Benutzerkonten::Benutzerkonto.sti_name).tap do |role|
          role.created_at = role_activation_date
        end
      end
    end

    def to_s(details: false)
      values = to_h.except(:first_name, :last_name, :encrypted_password, :sww_cms_legacy_password_salt).values.join(",")
      ["#{status} #{person} (#{details ? [sww_cms_profile_id, values].join(",") : sww_cms_profile_id})", (full_error_messages if details)].compact_blank.join(": ")
    end

    def status = errors.none? ? "✔" : "✖"

    def full_error_messages = (errors.full_messages if errors.any?)

    private

    def convert
      MAPPING.map do |source, target, conversion|
        value = attrs.fetch(source)
        [target, conversion ? conversion.call(value) : value]
      end.to_h.compact_blank
    end

    def group_id = @@group_id ||= Group.root.children.find_by(type: Group::Benutzerkonten.sti_name).id

    def role_activation_date = (Time.zone.at(attrs[:profile_activation_date].to_i) if attrs[:profile_activation_date].to_i.positive?)
  end

  # rubocop:disable Rails/Output
  class Runner
    def run
      Person.validate_zip_code = false
      Truemail.configuration.default_validation_type = :regex

      puts "Looking at #{rows.size} new emails out of #{row_candidates.size}"
      valid, invalid = rows.partition(&:valid?)
      puts "Running validations for #{rows.size} models, stand by .. "
      puts "valid: #{valid.size}, invalid: #{invalid.size}"
      log(invalid)
      save(valid)
    end

    private

    def save(valid)
      valid.each do |row|
        row.person.save!
        puts row
      end
    end

    def log(invalid)
      invalid.each do |row|
        puts row.to_s(details: true)
      end
    end

    def emails = @emails ||= Person.distinct.pluck("LOWER(email)").compact

    def rows = row_candidates.select { |row| row.email.present? && emails.exclude?(row.email) }

    def row_candidates = Source.new(:mod_profile).csv.map { |row| Row.new(row.to_h) }
  end
  # rubocop:enable Rails/Output
end
