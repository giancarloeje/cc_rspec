require 'spec_helper'
require 'factories'
require 'rack'

describe 'Audit Trail API', type: :request do

  before(:each) do
    @company = FactoryBot.create(:company)
    @application = FactoryBot.create(:application, company: @company)
    define_record_factory(nil, @application)
    @user = FactoryBot.create(:user, authentication_token: '1234')
  end

  it 'should read an audit trail based on a given query (XML format)' do

    @field = FactoryBot.create(:field, key: 'name', name: 'name', application: @application)
    record = create_record(@application)
    record.name = 'bob'
    record.save_and_audit!
    record.name = 'liza'
    record.save_and_audit!

    query = URI.encode('{"system.record_id":"'+record.system.record_id+'"}')

    post '/'+@company.key+'/'+@application.key+'/records/history.xml?auth_token=1234&query='+query
    assert response.body.include?("<field path='name'><old_val>bob</old_val><new_val>liza</new_val></field>")
  end

  it 'should read an audit trail based on a given query (JSON format)' do
    #create records
    @field = FactoryBot.create(:field, key: 'name', name: 'name', application: @application)
    record = create_record(@application)
    record.name = 'bob'
    record.save_and_audit!
    record.name = 'liza'
    record.save_and_audit!
    query = URI.encode('{"system.record_id":"'+record.system.record_id+'"}')
    post '/'+@company.key+'/'+@application.key+'/records/history.json?auth_token=1234&query='+query, '',"CONTENT_TYPE" => "application/json"
    assert response.body.include?('{"path":"name","old_value":"bob","new_value":"liza"}')
  end

  it 'should return an error if query parameter is missing (JSON format)' do
    post '/'+@company.key+'/'+@application.key+'/records/history.json?auth_token=1234', '',"CONTENT_TYPE" => "application/json"
    assert response.body.include?('Invalid request. Missing query parameter.')
  end

  it 'should return an error if query parameter is missing (XML format)' do
    post '/'+@company.key+'/'+@application.key+'/records/history.json?auth_token=1234', '',"CONTENT_TYPE" => "application/json"
    assert response.body.include?('Invalid request. Missing query parameter.')
  end

  it 'should return no result if record id indicated does not exist (JSON format)' do
    query = URI.encode('{"system.record_id":"1234"}')
    post '/'+@company.key+'/'+@application.key+'/records/history.json?auth_token=1234&query='+query, '',"CONTENT_TYPE" => "application/json"
    assert response.body.include?('query returned no result')
  end

  it 'should return no result if record id indicated does not exist (XML format)' do
    query = URI.encode('{"system.record_id":"1234"}')
    post '/'+@company.key+'/'+@application.key+'/records/history.xml?auth_token=1234&query='+query, '',"CONTENT_TYPE" => "application/json"
    assert response.body.include?('query returned no result')
  end

  it 'should not be able to read an audit trail when auth token is missing (JSON format)' do
    @field = FactoryBot.create(:field, key: 'name', name: 'name', application: @application)
    record = create_record(@application)
    record.name = 'bob'
    record.save_and_audit!
    record.name = 'liza'
    record.save_and_audit!

    query = URI.encode('{"system.record_id":"'+record.system.record_id+'"}')

    post '/'+@company.key+'/'+@application.key+'/records/history.json?auth_token=&query='+query, '',"CONTENT_TYPE" => "application/json"
    assert response.body.include?('Invalid user')
  end

  it 'should not be able to read an audit trail when auth token is missing (XML format)' do
    @field = FactoryBot.create(:field, key: 'name', name: 'name', application: @application)
    record = create_record(@application)
    record.name = 'bob'
    record.save_and_audit!
    record.name = 'liza'
    record.save_and_audit!

    query = URI.encode('{"system.record_id":"'+record.system.record_id+'"}')

    post '/'+@company.key+'/'+@application.key+'/records/history.xml?auth_token=&query='+query, '',"CONTENT_TYPE" => "application/json"
    assert response.body.include?('Invalid user')
  end

  it 'should not be able to read an audit trail when auth token is invalid (JSON format)' do

    @field = FactoryBot.create(:field, key: 'name', name: 'name', application: @application)
    record = create_record(@application)
    record.name = 'bob'
    record.save_and_audit!
    record.name = 'liza'
    record.save_and_audit!

    query = URI.encode('{"system.record_id":"'+record.system.record_id+'"}')

    post '/'+@company.key+'/'+@application.key+'/records/history.json?auth_token=invalid&query='+query, '',"CONTENT_TYPE" => "application/json"
    assert response.body.include?('Invalid user')
  end

  it 'should not be able to read an audit trail when auth token is invalid  (XML format)' do

    @field = FactoryBot.create(:field, key: 'name', name: 'name', application: @application)
    record = create_record(@application)
    record.name = 'bob'
    record.save_and_audit!
    record.name = 'liza'
    record.save_and_audit!

    query = URI.encode('{"system.record_id":"'+record.system.record_id+'"}')

    post '/'+@company.key+'/'+@application.key+'/records/history.xml?auth_token=invalid&query='+query, '',"CONTENT_TYPE" => "application/json"
    assert response.body.include?('Invalid user')
  end

end