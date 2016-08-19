# frozen_string_literal: true
require 'minitest/autorun'
require_relative '../../lib/page/house_wikidata'

describe 'HouseWikidata' do
  subject do
    Page::HouseWikidata.new(country: 'austria', house: 'nationalrat', index: index_at_known_sha)
  end

  it 'should return a house' do
    subject.house.name.must_equal 'Nationalrat'
  end

  it 'should return a page_title' do
    subject.page_title.must_equal 'EveryPolitician: Austria — Nationalrat'
  end

  it 'should have popolo with wikidata' do
    andrea = '0eedf2c9-01ea-44f4-bc6e-e5e4bf6d2add'
    subject.popolo.persons.find_by(id: andrea).wikidata.must_equal 'Q493950'
  end
end