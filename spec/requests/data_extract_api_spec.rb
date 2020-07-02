require 'spec_helper'
require 'factories'
require 'rack'

describe 'Data Extract API', type: :request do

  before(:each) do
    @company = FactoryBot.create(:company)
    @application = FactoryBot.create(:application, company: @company)
    @user = FactoryBot.create(:user, authentication_token: '1234', :company => @company)
    define_record_factory(nil, @application)
  end

  it 'should export data extract file (XML format)'do
    @field = FactoryBot.create(:field, key: 'name', name: 'name', application: @application)
    #create records
    record = create_record(@application)
    record.name = "brandi"
    record.save!

    @env = FactoryBot.create(:environment, :name => 'test', :key => 'test', application: @application)

    #create data extract
    json = '[{"key":"system","path":"system","selected":false,"rows":2,"row_count":2,"show_index":true,"temp":0,"children":[{"key":"record_id","name":"system.record_id","names":null,"path":"system.record_id","selected":false},{"key":"company_key","name":"system.company_key","names":null,"path":"system.company_key","selected":false},{"key":"company_id","name":"system.company_id","names":null,"path":"system.company_id","selected":false},{"key":"application_key","name":"system.application_key","names":null,"path":"system.application_key","selected":false},{"key":"application_id","name":"system.application_id","names":null,"path":"system.application_id","selected":false},{"key":"screen_key","name":"system.screen_key","names":null,"path":"system.screen_key","selected":false},{"key":"screen_id","name":"system.screen_id","names":null,"path":"system.screen_id","selected":false},{"key":"button_key","name":"system.button_key","names":null,"path":"system.button_key","selected":false},{"key":"screen_flow_key","name":"system.screen_flow_key","names":null,"path":"system.screen_flow_key","selected":false},{"key":"screen_flow_id","name":"system.screen_flow_id","names":null,"path":"system.screen_flow_id","selected":false},{"key":"created_by","name":"system.created_by","names":null,"path":"system.created_by","selected":false},{"key":"edited_by","name":"system.edited_by","names":null,"path":"system.edited_by","selected":false},{"key":"owned_by","name":"system.owned_by","names":null,"path":"system.owned_by","selected":false},{"key":"created_by_role","name":"system.created_by_role","names":null,"path":"system.created_by_role","selected":false},{"key":"edited_by_role","name":"system.edited_by_role","names":null,"path":"system.edited_by_role","selected":false},{"key":"owned_by_role","name":"system.owned_by_role","names":null,"path":"system.owned_by_role","selected":false},{"key":"created_at","name":"system.created_at","names":null,"path":"system.created_at","selected":false},{"key":"updated_at","name":"system.updated_at","names":null,"path":"system.updated_at","selected":false},{"key":"assigned_at","name":"system.assigned_at","names":null,"path":"system.assigned_at","selected":false},{"key":"locked","name":"system.locked","names":null,"path":"system.locked","selected":false},{"key":"hidden","name":"system.hidden","names":null,"path":"system.hidden","selected":false},{"key":"current_parent","name":"system.current_parent","names":null,"path":"system.current_parent","selected":false},{"key":"words","name":"system.words","names":null,"path":"system.words","selected":false},{"key":"attachments_count","name":"system.attachments_count","names":null,"path":"system.attachments_count","selected":false}]},{"key":"var_string","name":"var_string","names":null,"path":"var_string","selected":false},{"key":"name","name":"name","names":null,"path":"name","selected":true}]'
    @extract = FactoryBot.create(:data_extract, :name => 'data', application: @application, field_list: @field.name, separator: ',', json: json)
    @extract.save!

    post '/'+@company.key+'/'+@application.key+'/records/data_extract.xml?auth_token=1234&key='+@extract.key, ''
    assert response.body.include?("1 record/s processed")
  end

  it 'should export data extract file (JSON format)' do
    @field = FactoryBot.create(:field, key: 'name', name: 'name', application: @application)

    #create record
    record = create_record(@application)
    record.name = "brandi"
    record.save!

    @env = FactoryBot.create(:environment, :name => 'test', :key => 'test', application: @application)

    #create data extract
    json = '[{"key":"system","path":"system","selected":false,"rows":2,"row_count":2,"show_index":true,"temp":0,"children":[{"key":"record_id","name":"system.record_id","names":null,"path":"system.record_id","selected":false},{"key":"company_key","name":"system.company_key","names":null,"path":"system.company_key","selected":false},{"key":"company_id","name":"system.company_id","names":null,"path":"system.company_id","selected":false},{"key":"application_key","name":"system.application_key","names":null,"path":"system.application_key","selected":false},{"key":"application_id","name":"system.application_id","names":null,"path":"system.application_id","selected":false},{"key":"screen_key","name":"system.screen_key","names":null,"path":"system.screen_key","selected":false},{"key":"screen_id","name":"system.screen_id","names":null,"path":"system.screen_id","selected":false},{"key":"button_key","name":"system.button_key","names":null,"path":"system.button_key","selected":false},{"key":"screen_flow_key","name":"system.screen_flow_key","names":null,"path":"system.screen_flow_key","selected":false},{"key":"screen_flow_id","name":"system.screen_flow_id","names":null,"path":"system.screen_flow_id","selected":false},{"key":"created_by","name":"system.created_by","names":null,"path":"system.created_by","selected":false},{"key":"edited_by","name":"system.edited_by","names":null,"path":"system.edited_by","selected":false},{"key":"owned_by","name":"system.owned_by","names":null,"path":"system.owned_by","selected":false},{"key":"created_by_role","name":"system.created_by_role","names":null,"path":"system.created_by_role","selected":false},{"key":"edited_by_role","name":"system.edited_by_role","names":null,"path":"system.edited_by_role","selected":false},{"key":"owned_by_role","name":"system.owned_by_role","names":null,"path":"system.owned_by_role","selected":false},{"key":"created_at","name":"system.created_at","names":null,"path":"system.created_at","selected":false},{"key":"updated_at","name":"system.updated_at","names":null,"path":"system.updated_at","selected":false},{"key":"assigned_at","name":"system.assigned_at","names":null,"path":"system.assigned_at","selected":false},{"key":"locked","name":"system.locked","names":null,"path":"system.locked","selected":false},{"key":"hidden","name":"system.hidden","names":null,"path":"system.hidden","selected":false},{"key":"current_parent","name":"system.current_parent","names":null,"path":"system.current_parent","selected":false},{"key":"words","name":"system.words","names":null,"path":"system.words","selected":false},{"key":"attachments_count","name":"system.attachments_count","names":null,"path":"system.attachments_count","selected":false}]},{"key":"var_string","name":"var_string","names":null,"path":"var_string","selected":false},{"key":"name","name":"name","names":null,"path":"name","selected":true}]'
    @extract = FactoryBot.create(:data_extract, :name => 'data', application: @application, field_list: @field.name, separator: ',', json: json)
    @extract.save!

    post '/'+@company.key+'/'+@application.key+'/records/data_extract.json?auth_token=1234&key='+@extract.key, ''
    assert response.body.include?('"status":"1 record/s processed"')
  end

  it 'should return an error if no extract matches the key' do
    post '/'+@company.key+'/'+@application.key+'/records/data_extract.json?auth_token=1234&key=', '', "CONTENT_TYPE" => "application/json"
    assert response.body.include?("No extract matches the key")
  end

  it 'should not work with no auth token (JSON format)' do
    post '/'+@company.key+'/'+@application.key+'/records/data_extract.json?auth_token=&key=', '', "CONTENT_TYPE" => "application/json"
    assert response.body.include?("Invalid user")
  end

  it 'should not work with no auth token (XML format)' do
    post '/'+@company.key+'/'+@application.key+'/records/data_extract.xml?auth_token=&key=', '', "CONTENT_TYPE" => "application/json"
    assert response.body.include?("Invalid user")
  end

  it 'should not work with invalid auth token (JSON format)' do
    post '/'+@company.key+'/'+@application.key+'/records/data_extract.json?auth_token=invalid&key=', '', "CONTENT_TYPE" => "application/json"
    assert response.body.include?("Invalid user")
  end

  it 'should not work with auth token belonging to a common user' do
    @user.is_admin = false
    @user.is_root = false
    post '/'+@company.key+'/'+@application.key+'/records/data_extract.json?auth_token=invalid&key=', '', "CONTENT_TYPE" => "application/json"
    assert response.body.include?("Invalid user")
  end

  it 'should not work with invalid auth token (XML format)' do
    post '/'+@company.key+'/'+@application.key+'/records/data_extract.xml?auth_token=invalid&key=', '', "CONTENT_TYPE" => "application/json"
    assert response.body.include?("Invalid user")
  end

  it 'should not work with auth token belonging to a common user (JSON format)' do
    @user.is_root = false
    post '/'+@company.key+'/'+@application.key+'/records/data_extract.json?auth_token=invalid&key=', '', "CONTENT_TYPE" => "application/json"
    assert response.body.include?("Invalid user")
  end

  it 'should not work with auth token belonging to a common user (XML format)' do
    @user.is_root = false
    post '/'+@company.key+'/'+@application.key+'/records/data_extract.xml?auth_token=invalid&key=', '', "CONTENT_TYPE" => "application/json"
    assert response.body.include?("Invalid user")
  end

  it 'should work with auth token belonging to an admin user (JSON format)' do
    @user.is_root = false
    @field = FactoryBot.create(:field, key: 'name', name: 'name', application: @application)

    #create record
    record = create_record(@application)
    record.name = "liza"
    record.save!

    @env = FactoryBot.create(:environment, :name => 'test', :key => 'test', application: @application)

    #create data extract
    json = '[{"key":"system","path":"system","selected":false,"rows":2,"row_count":2,"show_index":true,"temp":0,"children":[{"key":"record_id","name":"system.record_id","names":null,"path":"system.record_id","selected":false},{"key":"company_key","name":"system.company_key","names":null,"path":"system.company_key","selected":false},{"key":"company_id","name":"system.company_id","names":null,"path":"system.company_id","selected":false},{"key":"application_key","name":"system.application_key","names":null,"path":"system.application_key","selected":false},{"key":"application_id","name":"system.application_id","names":null,"path":"system.application_id","selected":false},{"key":"screen_key","name":"system.screen_key","names":null,"path":"system.screen_key","selected":false},{"key":"screen_id","name":"system.screen_id","names":null,"path":"system.screen_id","selected":false},{"key":"button_key","name":"system.button_key","names":null,"path":"system.button_key","selected":false},{"key":"screen_flow_key","name":"system.screen_flow_key","names":null,"path":"system.screen_flow_key","selected":false},{"key":"screen_flow_id","name":"system.screen_flow_id","names":null,"path":"system.screen_flow_id","selected":false},{"key":"created_by","name":"system.created_by","names":null,"path":"system.created_by","selected":false},{"key":"edited_by","name":"system.edited_by","names":null,"path":"system.edited_by","selected":false},{"key":"owned_by","name":"system.owned_by","names":null,"path":"system.owned_by","selected":false},{"key":"created_by_role","name":"system.created_by_role","names":null,"path":"system.created_by_role","selected":false},{"key":"edited_by_role","name":"system.edited_by_role","names":null,"path":"system.edited_by_role","selected":false},{"key":"owned_by_role","name":"system.owned_by_role","names":null,"path":"system.owned_by_role","selected":false},{"key":"created_at","name":"system.created_at","names":null,"path":"system.created_at","selected":false},{"key":"updated_at","name":"system.updated_at","names":null,"path":"system.updated_at","selected":false},{"key":"assigned_at","name":"system.assigned_at","names":null,"path":"system.assigned_at","selected":false},{"key":"locked","name":"system.locked","names":null,"path":"system.locked","selected":false},{"key":"hidden","name":"system.hidden","names":null,"path":"system.hidden","selected":false},{"key":"current_parent","name":"system.current_parent","names":null,"path":"system.current_parent","selected":false},{"key":"words","name":"system.words","names":null,"path":"system.words","selected":false},{"key":"attachments_count","name":"system.attachments_count","names":null,"path":"system.attachments_count","selected":false}]},{"key":"var_string","name":"var_string","names":null,"path":"var_string","selected":false},{"key":"name","name":"name","names":null,"path":"name","selected":true}]'
    @extract = FactoryBot.create(:data_extract, :name => 'data', application: @application, field_list: @field.name, separator: ',', json: json)
    @extract.save!

    post '/'+@company.key+'/'+@application.key+'/records/data_extract.json?auth_token=1234&key='+@extract.key, ''
    assert response.body.include?('"status":"1 record/s processed"')
  end

  it 'should work with auth token belonging to an admin user (XML format)' do
    @user.is_root = false
    @field = FactoryBot.create(:field, key: 'name', name: 'name', application: @application)

    #create records
    record = create_record(@application)
    record.name = "liza"
    record.save!

    @env = FactoryBot.create(:environment, :name => 'test', :key => 'test', application: @application)

    #create data extract
    json = '[{"key":"system","path":"system","selected":false,"rows":2,"row_count":2,"show_index":true,"temp":0,"children":[{"key":"record_id","name":"system.record_id","names":null,"path":"system.record_id","selected":false},{"key":"company_key","name":"system.company_key","names":null,"path":"system.company_key","selected":false},{"key":"company_id","name":"system.company_id","names":null,"path":"system.company_id","selected":false},{"key":"application_key","name":"system.application_key","names":null,"path":"system.application_key","selected":false},{"key":"application_id","name":"system.application_id","names":null,"path":"system.application_id","selected":false},{"key":"screen_key","name":"system.screen_key","names":null,"path":"system.screen_key","selected":false},{"key":"screen_id","name":"system.screen_id","names":null,"path":"system.screen_id","selected":false},{"key":"button_key","name":"system.button_key","names":null,"path":"system.button_key","selected":false},{"key":"screen_flow_key","name":"system.screen_flow_key","names":null,"path":"system.screen_flow_key","selected":false},{"key":"screen_flow_id","name":"system.screen_flow_id","names":null,"path":"system.screen_flow_id","selected":false},{"key":"created_by","name":"system.created_by","names":null,"path":"system.created_by","selected":false},{"key":"edited_by","name":"system.edited_by","names":null,"path":"system.edited_by","selected":false},{"key":"owned_by","name":"system.owned_by","names":null,"path":"system.owned_by","selected":false},{"key":"created_by_role","name":"system.created_by_role","names":null,"path":"system.created_by_role","selected":false},{"key":"edited_by_role","name":"system.edited_by_role","names":null,"path":"system.edited_by_role","selected":false},{"key":"owned_by_role","name":"system.owned_by_role","names":null,"path":"system.owned_by_role","selected":false},{"key":"created_at","name":"system.created_at","names":null,"path":"system.created_at","selected":false},{"key":"updated_at","name":"system.updated_at","names":null,"path":"system.updated_at","selected":false},{"key":"assigned_at","name":"system.assigned_at","names":null,"path":"system.assigned_at","selected":false},{"key":"locked","name":"system.locked","names":null,"path":"system.locked","selected":false},{"key":"hidden","name":"system.hidden","names":null,"path":"system.hidden","selected":false},{"key":"current_parent","name":"system.current_parent","names":null,"path":"system.current_parent","selected":false},{"key":"words","name":"system.words","names":null,"path":"system.words","selected":false},{"key":"attachments_count","name":"system.attachments_count","names":null,"path":"system.attachments_count","selected":false}]},{"key":"var_string","name":"var_string","names":null,"path":"var_string","selected":false},{"key":"name","name":"name","names":null,"path":"name","selected":true}]'
    @extract = FactoryBot.create(:data_extract, :name => 'data', application: @application, field_list: @field.name, separator: ',', json: json)
    @extract.save!

    post '/'+@company.key+'/'+@application.key+'/records/data_extract.xml?auth_token=1234&key='+@extract.key, ''
    assert response.body.include?("1 record/s processed")
  end

end