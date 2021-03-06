# frozen_string_literal: true

require 'everypolitician'
require 'open-uri'
require 'fileutils'

module EveryPolitician
  module CountryExtension
    def person_count
      legislatures.map(&:person_count).inject(:+)
    end
  end

  module LegislatureExtension
    # UK.legislature('Commons').term(65)
    def term(termid)
      after, current, before = [nil, legislative_periods, nil]
                               .flatten
                               .each_cons(3)
                               .find do |_, term, _|
        term.id.split('/').last == termid.to_s
      end
      current.define_singleton_method(:prev) { before }
      current.define_singleton_method(:next) { after }
      current
    end
  end

  module LegislativePeriodExtension
    def memberships
      @memberships ||= legislature.popolo.memberships.select do |mem|
        mem.legislative_period_id == id
      end
    end

    def memberships_at_end
      memberships.select do |mem|
        mem.end_date.to_s.empty? || mem.end_date == end_date
      end
    end

    def people
      @people ||= memberships.map(&:person).uniq(&:id)
    end

    def identifier_map
      @identifier_map ||= people.select(&:identifiers).map { |p| p.identifiers.map { |i| i.merge(id: p.id) } }.flatten
    end

    def top_identifiers
      @top_identifiers ||= identifier_map.reject { |i| i[:scheme] == 'everypolitician_legacy' }
                                         .group_by { |i| i[:scheme] }
                                         .sort_by { |s, ids| [-ids.size, s] }
                                         .map { |s, _ids| s }
    end
  end
end

EveryPolitician::Country.include EveryPolitician::CountryExtension
EveryPolitician::Legislature.include EveryPolitician::LegislatureExtension
EveryPolitician::LegislativePeriod.include EveryPolitician::LegislativePeriodExtension
