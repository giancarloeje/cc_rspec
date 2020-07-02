require 'rails_helper'
require 'factories'

describe 'Audit Trail', type: :model do

  before(:each) do
    @application = FactoryBot.create(:application)
    define_record_factory(nil, @application)
  end

  it 'should capture changes to the the updated_at field when using save_and_audit!' do
    @encrypted_field = FactoryBot.create(:field, key: 'dummy_field', name: 'Dummy field', application: @application)
    record = create_record(@application)
    @application.generate_mongoid_model true, @application
    record.dummy_field = 'first save'
    record.save_and_audit!({silent: 1})
    record.dummy_field = 'second save'
    record.save_and_audit!({silent: 1})
    expect(record.events_tracks[1]).not_to eq(nil)
  end

  it 'should not capture changes to the the updated_at field when using save!' do
    @encrypted_field = FactoryBot.create(:field, key: 'dummy_field', name: 'Dummy field', application: @application)
    record = create_record(@application)
    record.dummy_field = 'first save'
    record.save_and_audit!({silent: 1})
    record.dummy_field = 'second save'
    record.save_and_audit!({silent: 1})
    expect(record.events_tracks[0].d.modified.try(:[], "system").try(:[], "updated_at")).to eq(nil)
  end

  it 'should not insert event record when audit trail is disabled (CMOSD-609)' do
    @encrypted_field = FactoryBot.create(:field, key: 'dummy_field', name: 'Dummy field', application: @application)
    record = create_record(@application)
    record.dummy_field = 'first save'
    record.save!
    expect(record.events_tracks[0]).to eq(nil)
  end

  it 'should insert event record when audit trail is enabled (CMOSD-609)' do
    @encrypted_field = FactoryBot.create(:field, key: 'dummy_field', name: 'Dummy field', application: @application)
    record = create_record(@application)
    record.dummy_field = 'first save'
    record.save_and_audit!({silent: 1})
    expect(record.events_tracks[0]).not_to eq(nil)
  end

  it 'should insert event record when using save_and_audit! even when audit trail is disabled' do
    @encrypted_field = FactoryBot.create(:field, key: 'dummy_field', name: 'Dummy field', application: @application)
    record = create_record(@application)
    record.dummy_field = 'first save'
    record.save_and_audit!({silent: 1})
    expect(record.events_tracks[0]).not_to eq(nil)
  end

  it 'should insert event record when using save_and_audit' do
    @encrypted_field = FactoryBot.create(:field, key: 'dummy_field', name: 'Dummy field', application: @application)
    record = create_record(@application)
    record.dummy_field = 'first save'
    record.save_and_audit!({silent: 1})
    expect(record.events_tracks[0]).not_to eq(nil)
  end

end
