require 'spec_helper'
require 'factories'
require 'rack'
require 'rack/test'

def test_file_path
  File.dirname(__FILE__) + '/../test_files/text_file.txt'
end

describe 'Records API', type: :request do

  before(:each) do
    @company = FactoryBot.create(:company)
    @application = FactoryBot.create(:application, company: @company)
    @user = FactoryBot.create(:user, authentication_token: '1234')
    define_record_factory(nil, @application)
  end


  it 'should create record with default values (XML format)' do
    post '/'+@company.key+'/'+@application.key+'/records/create.xml?auth_token=1234'
    assert response.body.include?("<record>")
  end

  it 'should create record with default values (JSON format)' do
    post '/'+@company.key+'/'+@application.key+'/records/create.json?auth_token=1234'
    assert response.body.include?("record")
  end

  it 'should create record based on the data specified in the request parameter (XML format)' do
    @field = FactoryBot.create(:field, key: 'name', name: 'name', application: @application)
    data = URI.encode('<record><name>bob</name></record>')
    url = '/'+@company.key+'/'+@application.key+'/records/create.xml?auth_token=1234&data='+data
    post url, '', "CONTENT-TYPE" => "text/xml"
    assert response.body.include?("<name>bob</name>")
  end

  it 'should create record based on the data specified in the request parameter (JSON format)' do
    @field = FactoryBot.create(:field, key: 'name', name: 'name', application: @application)
    data = URI.encode('{"record": { "name": "bob" }}')
    url = '/'+@company.key+'/'+@application.key+'/records/create.json?auth_token=1234&data='+data
    post url, '', "CONTENT-TYPE" => "application/json"
    assert response.body.include?('"name":"bob"')
  end

  it 'should retrieve on record based on a query (XML format)' do
    record = create_record(@application)
    record.save!
    query = URI.encode('{"system.record_id":"'+record.system.record_id+'"}')
    url = '/'+@company.key+'/'+@application.key+'/records/show.xml?auth_token=1234&query='+query
    post url
    assert response.body.include?('<record_id>'+record.system.record_id+'</record_id>')
  end

  it 'should retrieve on record based on a query (JSON format)' do
    record = create_record(@application)
    record.save!
    query = URI.encode('{"system.record_id":"'+record.system.record_id+'"}')
    url = '/'+@company.key+'/'+@application.key+'/records/show.json?auth_token=1234&query='+query
    post url, ''
    assert response.body.include?('"record_id":"'+record.system.record_id+'"')
  end

  it 'should return query returned no result if no such record exists (XML format)' do
    query = URI.encode('{"system.record_id":"1234"}')
    url = '/'+@company.key+'/'+@application.key+'/records/show.xml?auth_token=1234&query='+query
    post url
    assert response.body.include?('query returned no result')
  end

  it 'should return query returned no result if no such record exists (JSON format)' do
    query = URI.encode('{"system.record_id":"1234"}')
    url = '/'+@company.key+'/'+@application.key+'/records/show.json?auth_token=1234&query='+query
    post url, ''
    assert response.body.include?('query returned no result')
  end

  it 'should retrieve multiple records at once (XML format)' do
    @field = FactoryBot.create(:field, key: 'name', name: 'name', application: @application)
    record1 = create_record(@application)
    record2 = create_record(@application)
    record3 = create_record(@application)
    record1.name = "bob"
    record2.name = "liza"
    record3.name = "bob"
    record1.save!
    record2.save!
    record3.save!
    query = URI.encode('{"name": {"$in":["bob"]}}')
    url = '/'+@company.key+'/'+@application.key+'/records.xml?auth_token=1234&query='+query+'&limit=2'
    post url
    assert response.body.include?('<record_id>'+record1.system.record_id+'</record_id>')
    assert response.body.exclude?('<record_id>'+record2.system.record_id+'</record_id>')
    assert response.body.include?('<record_id>'+record3.system.record_id+'</record_id>')
  end

  it 'should retrieve multiple records at once (JSON format)' do
    @field = FactoryBot.create(:field, key: 'name', name: 'name', application: @application)
    record1 = create_record(@application)
    record2 = create_record(@application)
    record3 = create_record(@application)
    record1.name = "bob"
    record2.name = "liza"
    record3.name = "bob"
    record1.save!
    record2.save!
    record3.save!
    query = URI.encode('{"name": {"$in":["bob"]}}')
    url = '/'+@company.key+'/'+@application.key+'/records.json?auth_token=1234&query='+query+'&limit=2'
    post url
    assert response.body.include?('"record_id":"'+record1.system.record_id+'"')
    assert response.body.exclude?('"record_id":"'+record2.system.record_id+'"')
    assert response.body.include?('"record_id":"'+record3.system.record_id+'"')
  end

  it 'should return an error if query parameter is missing when retrieving multiple records at once (XML format)' do
    url = '/'+@company.key+'/'+@application.key+'/records.xml?auth_token=1234'
    post url
    assert response.body.include?('Invalid request. Missing query parameter.')
  end

  it 'should return an error if query parameter is missing when retrieving multiple records at once (JSON format)' do
    url = '/'+@company.key+'/'+@application.key+'/records.json?auth_token=1234'
    post url, ''
    assert response.body.include?('Invalid request. Missing query parameter.')
  end

  it 'should fetch a record based on a query and apply new data to it (XML format)' do
    @field = FactoryBot.create(:field, key: 'name', name: 'name', application: @application)
    record1 = create_record(@application)
    record1.name = "bob"
    record1.save!

    query = URI.encode('{"system.record_id": "'+record1.system.record_id+'"}')
    data = URI.encode('<record><name>maria</name></record>')
    url = '/'+@company.key+'/'+@application.key+'/records/update.xml?auth_token=1234&query='+query+'&data='+data
    post url
    assert response.body.include?('<name>maria</name>')
  end

  it 'should fetch a record based on a query and apply new data to it (JSON format)' do
    @field = FactoryBot.create(:field, key: 'name', name: 'name', application: @application)
    record1 = create_record(@application)
    record1.name = "bob"
    record1.save!

    query = URI.encode('{"system.record_id": "'+record1.system.record_id+'"}')
    data = URI.encode('{"record": { "name": "maria" }}')
    url = '/'+@company.key+'/'+@application.key+'/records/update.json?auth_token=1234&query='+query+'&data='+data
    post url
    assert response.body.include?('"name":"maria"')
  end

  it 'should return the number of record based on defined query (XML format)' do
    @field = FactoryBot.create(:field, key: 'name', name: 'name', application: @application)

    record1 = create_record(@application)
    record1.name = "bob"
    record2 = create_record(@application)
    record2.name = "liza"
    record3 = create_record(@application)
    record3.name = "bob"
    record1.save!
    record2.save!
    record3.save!

    query = URI.encode('{"name": {"$in":["bob"]}}')
    url = '/'+@company.key+'/'+@application.key+'/records/count.xml?auth_token=1234&query='+query
    post url, ''
    assert response.body.include?('<count type="integer">2</count>')
  end

  it 'should return the number of record based on defined query (JSON format)' do
    @field = FactoryBot.create(:field, key: 'name', name: 'name', application: @application)

    record1 = create_record(@application)
    record1.name = "bob"
    record2 = create_record(@application)
    record2.name = "liza"
    record3 = create_record(@application)
    record3.name = "bob"
    record1.save!
    record2.save!
    record3.save!

    query = URI.encode('{"name": {"$in":["bob"]}}')
    url = '/'+@company.key+'/'+@application.key+'/records/count.json?auth_token=1234&query='+query
    post url
    assert response.body.include?('"count":2')
  end

  it 'should hide from queue (XML format)' do
    record1 = create_record(@application)
    record2 = create_record(@application)
    record3 = create_record(@application)
    record1.save!
    record2.save!
    record3.save!

    url = '/'+@company.key+'/'+@application.key+'/records/hide.xml?auth_token=1234'
    post url, :ids => [record1.system.record_id, record2.system.record_id], "CONTENT_TYPE" => 'application/x-www-form-urlencoded'
    assert response.body.include?('<count type="integer">2</count>')

    query = URI.encode('{"system.record_id":"'+record1.system.record_id+'"}')
    url2 = '/'+@company.key+'/'+@application.key+'/records/show.xml?auth_token=1234&query='+query
    post url2
    assert response.body.include?('<hidden type="boolean">true</hidden>')
  end

  it 'should hide from queue (JSON format)' do
    record1 = create_record(@application)
    record2 = create_record(@application)
    record3 = create_record(@application)
    record1.save!
    record2.save!
    record3.save!

    url = '/'+@company.key+'/'+@application.key+'/records/hide.json?auth_token=1234'
    post url, :ids => [record1.system.record_id, record2.system.record_id], "CONTENT_TYPE" => 'application/x-www-form-urlencoded'
    assert response.body.include?('"count":2')

    query = URI.encode('{"system.record_id":"'+record1.system.record_id+'"}')
    url2 = '/'+@company.key+'/'+@application.key+'/records/show.json?auth_token=1234&query='+query
    post url2
    assert response.body.include?('"hidden":true')
  end

  it 'should unhide from queue (XML format)' do
    record1 = create_record(@application)
    record2 = create_record(@application)
    record3 = create_record(@application)
    record1.save!
    record2.save!
    record3.save!

    url = '/'+@company.key+'/'+@application.key+'/records/hide.xml?auth_token=1234'
    post url, :ids => [record1.system.record_id, record2.system.record_id], "CONTENT_TYPE" => 'application/x-www-form-urlencoded'

    url2 = '/'+@company.key+'/'+@application.key+'/records/unhide.xml?auth_token=1234'
    post url2, :ids => [record1.system.record_id, record2.system.record_id], "CONTENT_TYPE" => 'application/x-www-form-urlencoded'
    assert response.body.include?('<count type="integer">2</count>')

    query = URI.encode('{"system.record_id":"'+record1.system.record_id+'"}')
    post '/'+@company.key+'/'+@application.key+'/records/history.xml?auth_token=1234&query='+query, '',"CONTENT_TYPE" => "application/json"
    assert response.body.include?("<changes><field path='system.hidden'><old_val>true</old_val><new_val>false</new_val></field></changes>")
  end

  it 'should unhide from queue (JSON format)' do
    record1 = create_record(@application)
    record2 = create_record(@application)
    record3 = create_record(@application)
    record1.save!
    record2.save!
    record3.save!

    url = '/'+@company.key+'/'+@application.key+'/records/hide.json?auth_token=1234'
    post url, :ids => [record1.system.record_id, record2.system.record_id], "CONTENT_TYPE" => 'application/x-www-form-urlencoded'

    url2 = '/'+@company.key+'/'+@application.key+'/records/unhide.json?auth_token=1234'
    post url2, :ids => [record1.system.record_id, record2.system.record_id], "CONTENT_TYPE" => 'application/x-www-form-urlencoded'
    assert response.body.include?('"count":2')

    query = URI.encode('{"system.record_id":"'+record1.system.record_id+'"}')
    post '/'+@company.key+'/'+@application.key+'/records/history.json?auth_token=1234&query='+query, '',"CONTENT_TYPE" => "application/json"
    assert response.body.include?('[{"path":"system.hidden","old_value":"true","new_value":"false"}]')
  end

  #it 'should return the locked status of records and their ids (XML format) ' do
    #@field = FactoryBot.create(:field, key: 'name', name: 'name', application: @application)
    #record1 = create_record(@application)
    #record1.name = "bob"
    #record1.system.locked = false
    #record1.save!
    #query = URI.encode('{"system.record_id": "'+record1.system.record_id+'"}')
    #data = URI.encode('<record><name>maria</name></record>')
    #url = '/'+@company.key+'/'+@application.key+'/records/update.xml?auth_token=1234&query='+query+'&data='+data
    #post url

    #url2 = '/'+@company.key+'/'+@application.key+'/records/is_locked.xml?auth_token=1234'
   # post url2, :ids => [record1.system.record_id], "CONTENT_TYPE" => 'application/x-www-form-urlencoded'
    #assert response.body.include?('<lockStatus>&lt;?xml version="1.0" encoding="UTF-8"?&gt;&lt;record type="array"&gt;&lt;record&gt;&lt;id&gt;'+record1.system.record_id+'&lt;/id&gt;&lt;status type="boolean"&gt;false&lt;/status&gt;&lt;locked_by&gt;test@domain.com&lt;/locked_by&gt;&lt;/record&gt;&lt;/record&gt;</lockStatus>')
  #end

  it 'should return the locked status of records and their ids (JSON format)' do
    @field = FactoryBot.create(:field, key: 'name', name: 'name', application: @application)
    record1 = create_record(@application)
    record1.name = "bob"
    record1.system.locked = false
    record1.save!
    query = URI.encode('{"system.record_id": "'+record1.system.record_id+'"}')
    data = URI.encode('<record><name>maria</name></record>')
    url = '/'+@company.key+'/'+@application.key+'/records/update.xml?auth_token=1234&query='+query+'&data='+data
    post url, ''

    url2 = '/'+@company.key+'/'+@application.key+'/records/is_locked.json?auth_token=1234'
    post url2, :ids => [record1.system.record_id], "CONTENT_TYPE" => 'application/x-www-form-urlencoded'
    assert response.body.include?('{"lockStatus":[{"id":"'+record1.system.record_id+'","status":false,"locked_by":"test@domain.com"}]}')
  end

  it 'should create multiple records (XML format)' do
    @field = FactoryBot.create(:field, key: 'field1', name: 'field1', application: @application)
    data = URI.encode('<records><record><field1>First Record</field1></record><record><field1>Second Record</field1></record></records>')
    url = '/'+@company.key+'/'+@application.key+'/records/batch_create.xml?auth_token=1234&data='+data
    post url
    assert response.body.include?('<count type="integer">2</count>')
  end

  it 'should create multiple records (JSON format)' do
    @field = FactoryBot.create(:field, key: 'field1', name: 'field1', application: @application)
    data = URI.encode('{"records": {"record": [{ "field1": "First Record" },{ "field1": "Second Record" }]}}')
    url = '/'+@company.key+'/'+@application.key+'/records/batch_create.json?auth_token=1234&data='+data
    post url
    assert response.body.include?('{"record":{"count":2}}')
  end

  it 'should fetch multiple records based on a query and apply new data to it (XML format)' do
    @field1 = FactoryBot.create(:field, key: 'name', name: 'name', application: @application)
    @field2 = FactoryBot.create(:field, key: 'status', name: 'status', application: @application)

    record1 = create_record(@application)
    record1.name = "bob"
    record1.status = "no status"
    record2 = create_record(@application)
    record2.name = "liza"
    record2.status = "no status"
    record3 = create_record(@application)
    record3.name = "john"
    record3.status = "no status"

    record1.save!
    record2.save!
    record3.save!

    query = URI.encode('{"name": {"$in":["bob","john"]}}')
    data = URI.encode('<record><status>Approved</status></record>')

    url = '/'+@company.key+'/'+@application.key+'/records/batch_update.xml?auth_token=1234&query='+query+'&data='+data
    post url, ''
    assert response.body.include?('<count type="integer">2</count>')
  end

  it 'should fetch multiple records based on a query and apply new data to it (JSON format)' do
    @field1 = FactoryBot.create(:field, key: 'name', name: 'name', application: @application)
    @field2 = FactoryBot.create(:field, key: 'status', name: 'status', application: @application)

    record1 = create_record(@application)
    record1.name = "bob"
    record1.status = "no status"
    record2 = create_record(@application)
    record2.name = "liza"
    record2.status = "no status"
    record3 = create_record(@application)
    record3.name = "john"
    record3.status = "no status"

    record1.save!
    record2.save!
    record3.save!

    query = URI.encode('{"name": {"$in":["bob","john"]}}')
    data = URI.encode('{"record": { "status": "Approved" }}')

    url = '/'+@company.key+'/'+@application.key+'/records/batch_update.json?auth_token=1234&query='+query+'&data='+data
    post url
    assert response.body.include?('{"record":{"count":2}}')
  end

  it 'should create a new record if the query does not return any result (XML format)' do
    @field1 = FactoryBot.create(:field, key: 'name', name: 'name', application: @application)

    record1 = create_record(@application)
    record1.name = "bob"
    record1.save!

    query = URI.encode('{"system.record_id":"1234"}')
    data = URI.encode('<record><name>cynthia</name></record>')
    url = '/'+@company.key+'/'+@application.key+'/records/update_or_create.xml?auth_token=1234&query='+query+'&data='+data
    post url

    expect(xml.xpath('//created_at').text).to eq(xml.xpath('//updated_at').text)
  end

  it 'should create a new record if the query does not return any result (JSON format)' do
    @field1 = FactoryBot.create(:field, key: 'name', name: 'name', application: @application)

    record1 = create_record(@application)
    record1.name = "bob"
    record1.save!

    query = URI.encode('{"system.record_id":"1234"}')
    data = URI.encode('{"record": { "name": "cynthia" }}')
    url = '/'+@company.key+'/'+@application.key+'/records/update_or_create.json?auth_token=1234&query='+query+'&data='+data
    post url, ''
    assert_equal json['record']['system']['created_at'], json['record']['system']['updated_at']
  end

  it 'should update the records returned by the query (XML format)' do
    @field1 = FactoryBot.create(:field, key: 'name', name: 'name', application: @application)

    record1 = create_record(@application)
    record1.name = "bobby"
    record1.save!

    query = URI.encode('{"system.record_id":"'+record1.system.record_id+'"}')
    data = URI.encode('<record><name>clarisse</name></record>')
    url = '/'+@company.key+'/'+@application.key+'/records/update_or_create.xml?auth_token=1234&query='+query+'&data='+data
    post url, '', 'CONTENT_TYPE' => 'text/xml'
    #assert_not_equal json['record']['system']['created_at'], json['record']['system']['updated_at']
    assert response.body.include?('<name>clarisse</name>')
  end

  it 'should update the records returned by the query (JSON format) ' do
    @field1 = FactoryBot.create(:field, key: 'name', name: 'name', application: @application)

    record1 = create_record(@application)
    record1.name = "bobby"
    record1.save!

    query = URI.encode('{"system.record_id":"'+record1.system.record_id+'"}')
    data = URI.encode('{"record": { "name": "clarisse" }}')
    url = '/'+@company.key+'/'+@application.key+'/records/update_or_create.json?auth_token=1234&query='+query+'&data='+data
    post url, '', 'CONTENT_TYPE' => 'application/json'
    #assert_not_equal json['record']['system']['created_at'], json['record']['system']['updated_at']
    assert response.body.include?('"name":"clarisse"')
  end

  it 'should create a new record, if the record to be destroyed does not exist (XML format)' do
    @field1 = FactoryBot.create(:field, key: 'name', name: 'name', application: @application)

    record1 = create_record(@application)
    record1.name = "bob"
    record1.save!

    query = URI.encode('{"system.record_id":"'+record1.system.record_id+'"}')
    data = URI.encode('<record><name>cynthia</name></record>')
    url = '/'+@company.key+'/'+@application.key+'/records/drop_and_create.xml?auth_token=1234&query='+query+'&data='+data
    post url
    expect(xml.xpath('//created_at').text).to eq(xml.xpath('//updated_at').text)
    assert response.body.include?('<name>cynthia</name>')

    url2 = '/'+@company.key+'/'+@application.key+'/records/show.json?auth_token=1234&query='+query
    post url2
    assert response.body.include?('query returned no result')
  end

  it 'should create a new record, if the record to be destroyed does not exist (JSON format)' do
    @field1 = FactoryBot.create(:field, key: 'name', name: 'name', application: @application)

    record1 = create_record(@application)
    record1.name = "bob"
    record1.save!

    query = URI.encode('{"system.record_id":"'+record1.system.record_id+'"}')
    data = URI.encode('{"record": { "name": "cynthia" }}')
    url = '/'+@company.key+'/'+@application.key+'/records/drop_and_create.json?auth_token=1234&query='+query+'&data='+data
    post url, ''
    assert_equal json['record']['system']['created_at'], json['record']['system']['updated_at']
    assert response.body.include?('"name":"cynthia"')

    url2 = '/'+@company.key+'/'+@application.key+'/records/show.json?auth_token=1234&query='+query
    post url2
    assert response.body.include?('query returned no result')
  end

  it 'should delete the record returned by the query (XML format)' do
    @field1 = FactoryBot.create(:field, key: 'name', name: 'name', application: @application)

    record1 = create_record(@application)
    record1.name = "bob"
    record1.save!

    query = URI.encode('{"system.record_id":"'+record1.system.record_id+'"}')
    url = '/'+@company.key+'/'+@application.key+'/records/drop_and_create.xml?auth_token=1234&query='+query
    post url
    expect(xml.xpath('//created_at').text).to eq(xml.xpath('//updated_at').text)

    #check if the record still exists
    query2 = URI.encode('{"system.record_id":"'+record1.system.record_id+'"}')
    url2 = '/'+@company.key+'/'+@application.key+'/records/show.xml?auth_token=1234&query='+query2
    post url2
    assert response.body.include?('query returned no result')
  end

  it 'should delete the record returned by the query (JSON format)' do
    @field1 = FactoryBot.create(:field, key: 'name', name: 'name', application: @application)

    #create
    record1 = create_record(@application)
    record1.name = "bob"
    record1.save!

    query = URI.encode('{"system.record_id":"'+record1.system.record_id+'"}')
    url = '/'+@company.key+'/'+@application.key+'/records/drop_and_create.json?auth_token=1234&query='+query
    post url

    assert_equal json['record']['system']['created_at'], json['record']['system']['updated_at']

    #check if the record still exists
    query2 = URI.encode('{"system.record_id":"'+record1.system.record_id+'"}')
    url2 = '/'+@company.key+'/'+@application.key+'/records/show.json?auth_token=1234&query='+query2
    post url2, ''
    assert response.body.include?('query returned no result')
  end

  #report issue
  it 'should unlock records (XML format)' do
    record1 = create_record(@application)
    record1.system.locked = true
    record1.save!

    url = '/'+@company.key+'/'+@application.key+'/records/unlock.xml?auth_token=1234'
    post url, :ids => [record1.system.record_id], "CONTENT_TYPE" => 'application/x-www-form-urlencoded'
    assert response.body.include?('<count type="integer">1</count>')

    url2 = '/'+@company.key+'/'+@application.key+'/records/is_locked.xml?auth_token=1234'
    post url2, :ids => [record1.system.record_id], "CONTENT_TYPE" => 'application/x-www-form-urlencoded'
    #assert response.body.include?('{"lockStatus":[{"id":"'+record1.system.record_id+'","status":false,"locked_by":null}]}')
  end

  it 'should unlock records (JSON format)' do
    record1 = create_record(@application)
    record1.system.locked = true
    record1.save!

    url = '/'+@company.key+'/'+@application.key+'/records/unlock.json?auth_token=1234'
    post url, :ids => [record1.system.record_id], "CONTENT_TYPE" => 'application/x-www-form-urlencoded'
    assert response.body.include?('{"record":{"count":1}}')

    url2 = '/'+@company.key+'/'+@application.key+'/records/is_locked.json?auth_token=1234'
    post url2, :ids => [record1.system.record_id], "CONTENT_TYPE" => 'application/x-www-form-urlencoded'
    assert response.body.include?('{"lockStatus":[{"id":"'+record1.system.record_id+'","status":false,"locked_by":null}]}')
  end

  it 'change a record or set of records to a new owner or role depending on the defined user or role (XML format)' do
    @user_2 = FactoryBot.create(:user, email: 'test2@domain.com')
    @user_2.save!
    @role = FactoryBot.create(:role, :name => 'Role 1',:application => @application)
    #@user_2 = FactoryBot.create(:user)

    record1 = create_record(@application)
    record2 = create_record(@application)
    record1.save!
    record2.save!

    url = '/'+@company.key+'/'+@application.key+'/records/reassign.xml?auth_token=1234'
    post url, :ids => [record1.system.record_id, record2.system.record_id], :assign_to => ['user:'+@user_2.email,'role:'+@role.name]
    assert response.body.include?('<count type="integer">2</count>')

    query = URI.encode('{"system.record_id":"'+record1.system.record_id+'"}')
    url = '/'+@company.key+'/'+@application.key+'/records/show.xml?auth_token=1234&query='+query
    post url
    p response.body
    assert response.body.include?('<owned_by>test2@domain.com</owned_by>')
    assert response.body.include?('<owned_by_role>Role 1</owned_by_role>')
  end

  it 'change a record or set of records to a new owner or role depending on the defined user or role (JSON format)' do
    @user_2 = FactoryBot.create(:user, email: 'test2@domain.com')
    @user_2.save!
    @role = FactoryBot.create(:role, :application => @application)

    record1 = create_record(@application)
    record2 = create_record(@application)
    record1.save!
    record2.save!

    url = '/'+@company.key+'/'+@application.key+'/records/reassign.json?auth_token=1234'
    post url, :ids => [record1.system.record_id, record2.system.record_id], :assign_to => ['user:'+@user_2.email,'role:'+@role.name]
    assert response.body.include?('{"record":{"count":2}}')

    query = URI.encode('{"system.record_id":"'+record1.system.record_id+'"}')
    url = '/'+@company.key+'/'+@application.key+'/records/show.json?auth_token=1234&query='+query
    post url, ''
    assert response.body.include?('"owned_by":"test2@domain.com"')
    assert response.body.include?('"owned_by_role":["'+@role.name+'"]')
  end

  it 'should associate records (XML format)' do
    parent_rec = create_record(@application)
    child_rec1 = create_record(@application)
    child_rec2 = create_record(@application)

    url = '/'+@company.key+'/'+@application.key+'/records/associate.xml?auth_token=1234'
    post url, :ids => [child_rec1.system.record_id, child_rec2.system.record_id], :to => [parent_rec.system.record_id], "CONTENT_TYPE" => 'application/x-www-form-urlencoded'
    assert response.body.include?('<status type="symbol">ok</status>')
  end

  it 'should associate records (JSON format)' do
    parent_rec = create_record(@application)
    child_rec1 = create_record(@application)
    child_rec2 = create_record(@application)

    url = '/'+@company.key+'/'+@application.key+'/records/associate.json?auth_token=1234'
    post url, :ids => [child_rec1.system.record_id, child_rec2.system.record_id], :to => [parent_rec.system.record_id], "CONTENT_TYPE" => 'application/x-www-form-urlencoded'
    assert response.body.include?('{"record":{"status":"ok"}}')
  end

  it 'should release associations (XML format)' do
    parent_rec = create_record(@application)
    child_rec1 = create_record(@application)
    child_rec2 = create_record(@application)

    url = '/'+@company.key+'/'+@application.key+'/records/associate.xml?auth_token=1234'
    post url, :ids => [child_rec1.system.record_id, child_rec2.system.record_id], :to => [parent_rec.system.record_id], "CONTENT_TYPE" => 'application/x-www-form-urlencoded'
    assert response.body.include?('<status type="symbol">ok</status>')

    url = '/'+@company.key+'/'+@application.key+'/records/release_association.xml?auth_token=1234'
    post url, :ids => [child_rec1.system.record_id, child_rec2.system.record_id], "CONTENT_TYPE" => 'application/x-www-form-urlencoded'
    assert response.body.include?('<count type="integer">2</count>')
  end

  it 'should release associations (JSON format)' do
    parent_rec = create_record(@application)
    child_rec1 = create_record(@application)
    child_rec2 = create_record(@application)

    url = '/'+@company.key+'/'+@application.key+'/records/associate.json?auth_token=1234'
    post url, :ids => [child_rec1.system.record_id, child_rec2.system.record_id], :to => [parent_rec.system.record_id], "CONTENT_TYPE" => 'application/x-www-form-urlencoded'
    assert response.body.include?('{"record":{"status":"ok"}}')

    url = '/'+@company.key+'/'+@application.key+'/records/release_association.json?auth_token=1234'
    post url, :ids => [child_rec1.system.record_id, child_rec2.system.record_id], "CONTENT_TYPE" => 'application/x-www-form-urlencoded'
    assert response.body.include?('{"record":{"count":2}}')
  end

  it 'should replace existing parent-child relationship with a new one (XML format)' do
    parent_rec1 = create_record(@application)
    parent_rec2 = create_record(@application)
    child_rec1 = create_record(@application)
    child_rec2 = create_record(@application)

    url = '/'+@company.key+'/'+@application.key+'/records/associate.xml?auth_token=1234'
    post url, :ids => [child_rec1.system.record_id, child_rec2.system.record_id], :to => [parent_rec1.system.record_id], "CONTENT_TYPE" => 'application/x-www-form-urlencoded'
    assert response.body.include?('<status type="symbol">ok</status>')

    url = '/'+@company.key+'/'+@application.key+'/records/release_and_associate.xml?auth_token=1234'
    post url, :ids => [child_rec1.system.record_id, child_rec2.system.record_id], :to => [parent_rec2.system.record_id], "CONTENT_TYPE" => 'application/x-www-form-urlencoded'
    assert response.body.include?('<status type="symbol">ok</status>')
  end

  it 'should replace existing parent-child relationship with a new one (JSON format)' do
    parent_rec1 = create_record(@application)
    parent_rec2 = create_record(@application)
    child_rec1 = create_record(@application)
    child_rec2 = create_record(@application)

    url = '/'+@company.key+'/'+@application.key+'/records/associate.json?auth_token=1234'
    post url, :ids => [child_rec1.system.record_id, child_rec2.system.record_id], :to => [parent_rec1.system.record_id], "CONTENT_TYPE" => 'application/x-www-form-urlencoded'
    assert response.body.include?('{"record":{"status":"ok"}}')

    url = '/'+@company.key+'/'+@application.key+'/records/release_and_associate.json?auth_token=1234'
    post url, :ids => [child_rec1.system.record_id, child_rec2.system.record_id], :to => [parent_rec2.system.record_id], "CONTENT_TYPE" => 'application/x-www-form-urlencoded'
    assert response.body.include?('{"record":{"status":"ok"}}')
  end

  it 'should get records associated with the query (XML format)' do
    parent_rec = create_record(@application)
    child_rec1 = create_record(@application)
    child_rec2 = create_record(@application)

    url = '/'+@company.key+'/'+@application.key+'/records/associate.json?auth_token=1234'
    post url, :ids => [child_rec1.system.record_id, child_rec2.system.record_id], :to => [parent_rec.system.record_id], "CONTENT_TYPE" => 'application/x-www-form-urlencoded'

    query = URI.encode('{"system.record_id":"'+parent_rec.system.record_id+'"}')
    url = '/'+@company.key+'/'+@application.key+'/records/get_association.xml?auth_token=1234&query='+query
    post url,  :parents => false,"CONTENT_TYPE" => 'application/x-www-form-urlencoded'
    assert response.body.include?(' <_id>'+child_rec1.system.record_id+'</_id>
      <_lock_version type="integer">2</_lock_version>
      <child_ids type="array"/>
      <parent_ids type="array">
        <parent_id>'+parent_rec.system.record_id+'</parent_id>
      </parent_ids>')
    assert response.body.include?(' <_id>'+child_rec2.system.record_id+'</_id>
      <_lock_version type="integer">2</_lock_version>
      <child_ids type="array"/>
      <parent_ids type="array">
        <parent_id>'+parent_rec.system.record_id+'</parent_id>
      </parent_ids>')

    query = URI.encode('{"system.record_id":"'+child_rec1.system.record_id+'"}')
    url = '/'+@company.key+'/'+@application.key+'/records/get_association.xml?auth_token=1234&query='+query
    post url,  :parents => true,"CONTENT_TYPE" => 'application/x-www-form-urlencoded'
    assert response.body.include?('<_id>'+parent_rec.system.record_id+'</_id>')
  end

  it 'should get records associated with the query (JSON format)' do
    parent_rec = create_record(@application)
    child_rec1 = create_record(@application)
    child_rec2 = create_record(@application)

    url = '/'+@company.key+'/'+@application.key+'/records/associate.json?auth_token=1234'
    post url, :ids => [child_rec1.system.record_id, child_rec2.system.record_id], :to => [parent_rec.system.record_id], "CONTENT_TYPE" => 'application/x-www-form-urlencoded'

    query = URI.encode('{"system.record_id":"'+parent_rec.system.record_id+'"}')
    url = '/'+@company.key+'/'+@application.key+'/records/get_association.json?auth_token=1234&query='+query
    post url,  :parents => false,"CONTENT_TYPE" => 'application/x-www-form-urlencoded'
    assert response.body.include?('{"_id":"'+child_rec1.system.record_id+'","_lock_version":2,"child_ids":[],"parent_ids":["'+parent_rec.system.record_id+'"]')
    assert response.body.include?('{"_id":"'+child_rec2.system.record_id+'","_lock_version":2,"child_ids":[],"parent_ids":["'+parent_rec.system.record_id+'"]')

    query = URI.encode('{"system.record_id":"'+child_rec1.system.record_id+'"}')
    url = '/'+@company.key+'/'+@application.key+'/records/get_association.json?auth_token=1234&query='+query
    post url,  :parents => true,"CONTENT_TYPE" => 'application/x-www-form-urlencoded'
    assert response.body.include?('{"_id":"'+parent_rec.system.record_id)
  end

  it 'should return the number of records associated with the query (XML format)' do
    parent_rec = create_record(@application)
    child_rec1 = create_record(@application)
    child_rec2 = create_record(@application)

    url = '/'+@company.key+'/'+@application.key+'/records/associate.xml?auth_token=1234'
    post url, :ids => [child_rec1.system.record_id, child_rec2.system.record_id], :to => [parent_rec.system.record_id], "CONTENT_TYPE" => 'application/x-www-form-urlencoded'

    query = URI.encode('{"system.record_id":"'+parent_rec.system.record_id+'"}')
    url = '/'+@company.key+'/'+@application.key+'/records/get_association_count.xml?auth_token=1234&query='+query
    post url,  :parents => false,"CONTENT_TYPE" => 'application/x-www-form-urlencoded'
    assert response.body.include?('<count type="integer">2</count>')
  end

  it 'should return the number of records associated with the query (JSON format)' do
    parent_rec = create_record(@application)
    child_rec1 = create_record(@application)
    child_rec2 = create_record(@application)

    url = '/'+@company.key+'/'+@application.key+'/records/associate.json?auth_token=1234'
    post url, :ids => [child_rec1.system.record_id, child_rec2.system.record_id], :to => [parent_rec.system.record_id], "CONTENT_TYPE" => 'application/x-www-form-urlencoded'

    query = URI.encode('{"system.record_id":"'+parent_rec.system.record_id+'"}')
    url = '/'+@company.key+'/'+@application.key+'/records/get_association_count.json?auth_token=1234&query='+query
    post url,  :parents => false,"CONTENT_TYPE" => 'application/x-www-form-urlencoded'
    assert response.body.include?('"record":{"count":2}')
  end

  it 'should return attachment count' do
    record = create_record(@application)

    url = "/#{@company.key}/#{@application.key}/attachments_api/upload/#{record.system.record_id}/text_file.txt/1234.json"
    #request_body = Rack::Test::UploadedFile.new(test_file_path)
    request_body = Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/test_files/text_file.txt')))
    post "#{url}", request_body, 'CONTENT_TYPE' => 'application/octet-stream'

    #post "#{url}", :file => Rack::Test::UploadFile.new("C:/Users/User/case_center/spec/test_files/text_file.txt", "application/octet-stream")
    assert_response :success
    #p response.body
    record.save!
    url2 = '/'+@company.key+'/'+@application.key+'/records/attachments_count.json?auth_token=1234&id='+record.system.record_id
    post url2
    assert response.body.include?('"count":1')
  end

end