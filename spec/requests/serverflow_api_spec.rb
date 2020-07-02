require 'spec_helper'
require 'factories'
require 'rack'

def setup_server_flow_test_env
  @user = FactoryBot.create(:user, is_root: true, authentication_token: 1234, company: @company)
  @env = FactoryBot.create(:environment, name: 'test', application: @app)
  @int = FactoryBot.create(:field, name:'int', key:'int', field_type:'Integer', default_value: '1',application: @app)
  @str = FactoryBot.create(:field, name:'str', key: 'str', field_type: 'String', default_value: 'testValue', application: @app)
  @status = FactoryBot.create(:field, name: 'status', key: 'status', field_type:'String', application: @app)
end

def create_queue(args={})
  @queue = FactoryBot.create(:filter, args)
end

describe 'Server Flow API', type: :request do

  before(:each) do
    @company = FactoryBot.create(:company)
    @app = FactoryBot.create(:application, company: @company)
    define_record_factory(nil, @app)
  end

  it 'should create a record and response should be in json format' do
    setup_server_flow_test_env

    @server_flow = FactoryBot.create(:server_flow, name:'server_flow', key:'server_flow', application: @app, data:'{"modules":[{"name":"Save","key":"Save","type":"save","value":{},"config":{"position":[142,149],"xtype":"WireIt.ImageContainer"}},
                  {"name":"Entry point","key":"Entry point","type":"entry_point","value":{},"config":{"position":[55,34],"xtype":"WireIt.ImageContainer"}},{"name":"End point","key":"End point","type":"end_point","value":{},"config":{"position":[165,279],"xtype":"WireIt.ImageContainer"}}],
                  "wires":[{"xtype":"WireIt.BezierWire","src":{"moduleId":1,"terminal":"ENTRY_POINT"},"tgt":{"moduleId":0,"terminal":"SAVE_INPUT"}},{"xtype":"WireIt.BezierWire","src":{"moduleId":0,"terminal":"SAVE_OUTPUT"},"tgt":{"moduleId":2,"terminal":"END_POINT"}}],"properties":{"name":"","description":""}}')

    post "/#{@company.key}/#{@app.key}/new/#{@server_flow.key}.json?auth_token=1234"

    expect(json['record']['_lock_version']).to eq(1)
    expect(json['record']['str']).to eq('testValue')
    expect(json['record']['int']).to eq(1)
    expect(json['record']['system']['created_by']).to eq('test@domain.com')
    #system.hidden should not be nil - CMOSD-1007
    expect(json['record']['system']['hidden']).to eq(false)
  end

  it 'should create a new record and response should be in xml format' do
    setup_server_flow_test_env

    @server_flow = FactoryBot.create(:server_flow, name:'server_flow', key:'server_flow', application: @app, data:'{"modules":[{"name":"Save","key":"Save","type":"save","value":{},"config":{"position":[142,149],"xtype":"WireIt.ImageContainer"}},
                  {"name":"Entry point","key":"Entry point","type":"entry_point","value":{},"config":{"position":[55,34],"xtype":"WireIt.ImageContainer"}},{"name":"End point","key":"End point","type":"end_point","value":{},"config":{"position":[165,279],"xtype":"WireIt.ImageContainer"}}],
                  "wires":[{"xtype":"WireIt.BezierWire","src":{"moduleId":1,"terminal":"ENTRY_POINT"},"tgt":{"moduleId":0,"terminal":"SAVE_INPUT"}},{"xtype":"WireIt.BezierWire","src":{"moduleId":0,"terminal":"SAVE_OUTPUT"},"tgt":{"moduleId":2,"terminal":"END_POINT"}}],"properties":{"name":"","description":""}}')

    post "/#{@company.key}/#{@app.key}/new/#{@server_flow.key}.xml?auth_token=1234"

    expect(xml.xpath('//_lock_version').text).to eq('1')
    expect(xml.xpath('//created_by').text).to eq('test@domain.com')
    expect(xml.xpath('//str').text).to eq('testValue')
    expect(xml.xpath('//int').text).to eq('1')
    expect(xml.xpath('//record_id').text).not_to be_nil
    #system.hidden should not be nil - CMOSD-1007
    expect(xml.xpath('//hidden').text).to eq('false')
  end

  it 'should create a new record based on the data defined' do
    setup_server_flow_test_env

    @server_flow = FactoryBot.create(:server_flow, name:'server_flow', key:'server_flow', application: @app, data:'{"modules":[{"name":"Save","key":"Save","type":"save","value":{},"config":{"position":[142,149],"xtype":"WireIt.ImageContainer"}},
                  {"name":"Entry point","key":"Entry point","type":"entry_point","value":{},"config":{"position":[55,34],"xtype":"WireIt.ImageContainer"}},{"name":"End point","key":"End point","type":"end_point","value":{},"config":{"position":[165,279],"xtype":"WireIt.ImageContainer"}}],
                  "wires":[{"xtype":"WireIt.BezierWire","src":{"moduleId":1,"terminal":"ENTRY_POINT"},"tgt":{"moduleId":0,"terminal":"SAVE_INPUT"}},{"xtype":"WireIt.BezierWire","src":{"moduleId":0,"terminal":"SAVE_OUTPUT"},"tgt":{"moduleId":2,"terminal":"END_POINT"}}],"properties":{"name":"","description":""}}')

    data = "<?xml version='1.0' encoding='UTF-8'?><record><str>newFieldValue</str><int>2</int></record>"
    post URI.encode("/#{@company.key}/#{@app.key}/new/#{@server_flow.key}.xml?auth_token=1234&data=" + data)

    expect(xml.xpath('//_lock_version').text).to eq('1')
    expect(xml.xpath('//created_by').text).to eq('test@domain.com')
    expect(xml.xpath('//str').text).to eq('newFieldValue')
    expect(xml.xpath('//int').text).to eq('2')
    expect(xml.xpath('//record_id').text).not_to be_nil
  end

  it 'should update existing record based on the data defined in params' do
    setup_server_flow_test_env
    record = create_record(@app)

    @server_flow = FactoryBot.create(:server_flow, name:'server_flow', key:'server_flow', application: @app, data:'{"modules":[{"name":"Save","key":"Save","type":"save","value":{},"config":{"position":[142,149],"xtype":"WireIt.ImageContainer"}},
                  {"name":"Entry point","key":"Entry point","type":"entry_point","value":{},"config":{"position":[55,34],"xtype":"WireIt.ImageContainer"}},{"name":"End point","key":"End point","type":"end_point","value":{},"config":{"position":[165,279],"xtype":"WireIt.ImageContainer"}}],
                  "wires":[{"xtype":"WireIt.BezierWire","src":{"moduleId":1,"terminal":"ENTRY_POINT"},"tgt":{"moduleId":0,"terminal":"SAVE_INPUT"}},{"xtype":"WireIt.BezierWire","src":{"moduleId":0,"terminal":"SAVE_OUTPUT"},"tgt":{"moduleId":2,"terminal":"END_POINT"}}],"properties":{"name":"","description":""}}')

    query = '{"system.record_id":"'+record.system.record_id+'"}'
    data = '{"record":{ "int": "10" }}'

    post URI.encode("/#{@company.key}/#{@app.key}/update/#{@server_flow.key}.json?auth_token=1234&query="+query+'&data='+data+'&lock=true')

    expect(json['record']['_lock_version']).to eq(2)
    expect(json['record']['int']).to eq(10)
    expect(json['record']['system']['edited_by']).to eq('test@domain.com')
  end

  it 'should fetch multiple records and update them based on the data defined' do
    setup_server_flow_test_env

    @server_flow = FactoryBot.create(:server_flow, name:'server_flow', key:'server_flow', application: @app, data:'{"modules":[{"name":"Save","key":"Save","type":"save","value":{},"config":{"position":[142,149],"xtype":"WireIt.ImageContainer"}},
                  {"name":"Entry point","key":"Entry point","type":"entry_point","value":{},"config":{"position":[55,34],"xtype":"WireIt.ImageContainer"}},{"name":"End point","key":"End point","type":"end_point","value":{},"config":{"position":[165,279],"xtype":"WireIt.ImageContainer"}}],
                  "wires":[{"xtype":"WireIt.BezierWire","src":{"moduleId":1,"terminal":"ENTRY_POINT"},"tgt":{"moduleId":0,"terminal":"SAVE_INPUT"}},{"xtype":"WireIt.BezierWire","src":{"moduleId":0,"terminal":"SAVE_OUTPUT"},"tgt":{"moduleId":2,"terminal":"END_POINT"}}],"properties":{"name":"","description":""}}')

    # create three records
    record1 = create_record(@app)
    record1.str = 'old'
    record1.save!

    record2 = create_record(@app)
    record2.str = 'new'
    record2.save!

    record3 = create_record(@app)
    record3.str = 'old'
    record3.save!

    query = '{"str": {"$in":["old"]}}'
    data = '{"record":{ "status": "Updated" }}'

    post URI.encode("/#{@company.key}/#{@app.key}/batch_update/#{@server_flow.key}.json?auth_token=1234&query="+query+'&data='+data+'&lock=true')

    expect(json['record']['count']).to eq(2)
  end

  it 'should create a new record when query does not return any results (update_or_create)' do
    setup_server_flow_test_env

    @server_flow = FactoryBot.create(:server_flow, name:'server_flow', key:'server_flow', application: @app, data:'{"modules":[{"name":"Save","key":"Save","type":"save","value":{},"config":{"position":[142,149],"xtype":"WireIt.ImageContainer"}},
                  {"name":"Entry point","key":"Entry point","type":"entry_point","value":{},"config":{"position":[55,34],"xtype":"WireIt.ImageContainer"}},{"name":"End point","key":"End point","type":"end_point","value":{},"config":{"position":[165,279],"xtype":"WireIt.ImageContainer"}}],
                  "wires":[{"xtype":"WireIt.BezierWire","src":{"moduleId":1,"terminal":"ENTRY_POINT"},"tgt":{"moduleId":0,"terminal":"SAVE_INPUT"}},{"xtype":"WireIt.BezierWire","src":{"moduleId":0,"terminal":"SAVE_OUTPUT"},"tgt":{"moduleId":2,"terminal":"END_POINT"}}],"properties":{"name":"","description":""}}')

    # create record
    record1 = create_record(@app)
    record1.str = 'old'
    record1.save!

    query = '{"str": {"$in":["new"]}}'
    data = '{"record":{ "status": "Updated" }}'

    post URI.encode("/#{@company.key}/#{@app.key}/update_or_create/#{@server_flow.key}.json?auth_token=1234&query="+query+'&data='+data+'&lock=true')

    expect(json['record']['_lock_version']).to eq(1)
    expect(json['record']['str']).to eq('testValue')
    expect(json['record']['status']).to eq('Updated')
  end

  it 'should update a record returned by query (update or create)' do
    setup_server_flow_test_env

    @server_flow = FactoryBot.create(:server_flow, name:'server_flow', key:'server_flow', application: @app, data:'{"modules":[{"name":"Save","key":"Save","type":"save","value":{},"config":{"position":[142,149],"xtype":"WireIt.ImageContainer"}},
                  {"name":"Entry point","key":"Entry point","type":"entry_point","value":{},"config":{"position":[55,34],"xtype":"WireIt.ImageContainer"}},{"name":"End point","key":"End point","type":"end_point","value":{},"config":{"position":[165,279],"xtype":"WireIt.ImageContainer"}}],
                  "wires":[{"xtype":"WireIt.BezierWire","src":{"moduleId":1,"terminal":"ENTRY_POINT"},"tgt":{"moduleId":0,"terminal":"SAVE_INPUT"}},{"xtype":"WireIt.BezierWire","src":{"moduleId":0,"terminal":"SAVE_OUTPUT"},"tgt":{"moduleId":2,"terminal":"END_POINT"}}],"properties":{"name":"","description":""}}')

    # create record
    record = create_record(@app)
    record.str = 'old'
    record.save!

    query = '{"str": {"$in":["old"]}}'
    data = '{"record":{ "status": "Updated" }}'

    post URI.encode("/#{@company.key}/#{@app.key}/update_or_create/#{@server_flow.key}.json?auth_token=1234&query="+query+'&data='+data+'&lock=false')

    expect(json['record']['_lock_version']).to eq(2)
    expect(json['record']['str']).to eq('old')
    expect(json['record']['status']).to eq('Updated')
  end

  it 'should update all records in queue' do
    setup_server_flow_test_env

    @modifier = FactoryBot.create(:modifier, name:'modifier', key:'modifier', code:'self.int = self.int + 1', application: @app)
    @queue = FactoryBot.create(:filter, name: 'queue', key: 'queue', application: @app, data:'{"columndata":[{"tableslot":"type=Integer&table=[NO TABLE]&field=int","table":"[NO TABLE]","field":"int","columnas":"int","columnhidden":false,"columnsort":false,"columnsearch":false,"columnadvancedsearch":false,"columnformat":false}],"sortdata":[],"groupdata":[],"wheredata":[]}')
    @server_flow = FactoryBot.create(:server_flow, name:'server_flow', key:'server_flow', filter_id: '1', application: @app, data:'{"modules":[{"name":"Entry point","key":"Entry point","type":"entry_point","value":{},"config":{"position":[184,67],"xtype":"WireIt.ImageContainer"}},{"name":"modifier","key":"modifier","type":"modifier","value":{},"config":{"position":[213,206],"xtype":"WireIt.ImageLabelContainer"}},{"name":"Save","key":"Save","type":"save","value":{},"config":{"position":[299,313],"xtype":"WireIt.ImageContainer"}},{"name":"End point","key":"End point","type":"end_point","value":{},"config":{"position":[417,352],"xtype":"WireIt.ImageContainer"}}],"wires":[{"xtype":"WireIt.BezierWire","src":{"moduleId":0,"terminal":"ENTRY_POINT"},"tgt":{"moduleId":1,"terminal":"MODIFIER_INPUT"}},{"xtype":"WireIt.BezierWire","src":{"moduleId":1,"terminal":"MODIFIER_OUTPUT"},"tgt":{"moduleId":2,"terminal":"SAVE_INPUT"}},{"xtype":"WireIt.BezierWire","src":{"moduleId":2,"terminal":"SAVE_OUTPUT"},"tgt":{"moduleId":3,"terminal":"END_POINT"}}],"properties":{"name":"","description":""}}')

    record1 = create_record(@app)
    record1.int = '1'
    record1.save!

    record2 = create_record(@app)
    record2.int = '9'
    record2.save!

    post URI.encode("/#{@company.key}/#{@app.key}/update_all_in_queue/#{@server_flow.key}.json?auth_token=1234")
    expect(json['record']['count']).to eq(2)
  end

  it 'should return 0 records since no record is in queue' do
    setup_server_flow_test_env

    @server_flow = FactoryBot.create(:server_flow, name:'server_flow', key:'server_flow', application: @app, data:'{"modules":[{"name":"Save","key":"Save","type":"save","value":{},"config":{"position":[142,149],"xtype":"WireIt.ImageContainer"}},
                  {"name":"Entry point","key":"Entry point","type":"entry_point","value":{},"config":{"position":[55,34],"xtype":"WireIt.ImageContainer"}},{"name":"End point","key":"End point","type":"end_point","value":{},"config":{"position":[165,279],"xtype":"WireIt.ImageContainer"}}],
                  "wires":[{"xtype":"WireIt.BezierWire","src":{"moduleId":1,"terminal":"ENTRY_POINT"},"tgt":{"moduleId":0,"terminal":"SAVE_INPUT"}},{"xtype":"WireIt.BezierWire","src":{"moduleId":0,"terminal":"SAVE_OUTPUT"},"tgt":{"moduleId":2,"terminal":"END_POINT"}}],"properties":{"name":"","description":""}}')

    query = '{"str": {"$in":["old"]}}'
    data = '{"record":{ "status": "Updated" }}'

    post URI.encode("/#{@company.key}/#{@app.key}/update_all_in_queue/#{@server_flow.key}.json?auth_token=1234&query="+query+'&data='+data+'&lock=false')

    expect(json['record']['count']).to eq(0)
  end

  it 'test server flow with modifier' do
    @field = FactoryBot.create(:field, name:'field', key:'field', field_type:'Integer', default_value:'1', application: @app)
    @filter = FactoryBot.create(:filter, name:'queue', key:'queue', data:'{"columndata":[{"tableslot":"type=Integer&table=[NO TABLE]&field=field", "table":"[NO TABLE]", "field":"field", "columnas":"field" ,
                "columnhidden":"undefined"}],"sortdata":[],"groupdata":[],"wheredata":[]}', application: @app)
    @modifier = FactoryBot.create(:modifier, name:'modifier', key:'modifier', code:'self.field = self.field + 1', application: @app)
    @server_flow = FactoryBot.create(:server_flow, name:'server', key:'server', filter_id: '1', application: @app, data:'{"modules":[{"name":"Entry point","key":"Entry point","type":"entry_point","value":{},"config":{"position":[70,32],"xtype":"WireIt.ImageContainer"}},{"name":"modifier","key":"modifier","type":"modifier","value":{},"config":{"position":[146,128],"xtype":"WireIt.ImageLabelContainer"}},{"name":"Save","key":"Save","type":
                "save","value":{},"config":{"position":[183,223],"xtype":"WireIt.ImageContainer"}},{"name":"End point","key":"End point","type":"end_point","value":{},"config":{"position":[220,325],"xtype":"WireIt.ImageContainer"}}],"wires":[{"xtype":"WireIt.BezierWire","src":{"moduleId":0,"terminal":"ENTRY_POINT"},"tgt":{"moduleId":1,"terminal":"MODIFIER_INPUT"}},{"xtype":"WireIt.BezierWire","src":{"moduleId":1,"terminal":"MODIFIER_OUTPUT"},
                "tgt":{"moduleId":2,"terminal":"SAVE_INPUT"}},{"xtype":"WireIt.BezierWire","src":{"moduleId":2,"terminal":"SAVE_OUTPUT"},"tgt":{"moduleId":3,"terminal":"END_POINT"}}],"properties":{"name":"","description":""}}')
    @record = create_record(@app)

    post URI.encode("/#{@company.key}/#{@app.key}/update_all_in_queue/#{@server_flow.key}.json?auth_token=124")

  end

  #Exceptions

  it 'should return an error when no auth token is provided' do
    @user = FactoryBot.create(:user, is_root: true, authentication_token: 1234, company: @company)
    @env = FactoryBot.create(:environment, name: 'test', application: @app)
    @server_flow = FactoryBot.create(:server_flow, name: 'server_flow', key: 'server_flow', application: @app)

    post "/#{@company.key}/#{@app.key}/new/#{@server_flow.key}.xml?"

    assert response.body.include?('Invalid User')
  end

  it 'should return an error when auth token provided is invalid' do
    @user = FactoryBot.create(:user, is_root: true, authentication_token: 1234, company: @company)
    @env = FactoryBot.create(:environment, name: 'test', application: @app)
    @server_flow = FactoryBot.create(:server_flow, name: 'server_flow', key: 'server_flow', application: @app)

    post "/#{@company.key}/#{@app.key}/new/#{@server_flow.key}.xml?auth_token=0"
    assert response.body.include?('Invalid user')
  end

  it 'should return an error when query parameter is missing' do
    @user = FactoryBot.create(:user, is_root: true, authentication_token: 1234, company: @company)
    @env = FactoryBot.create(:environment, name: 'test', application: @app)
    @server_flow = FactoryBot.create(:server_flow, name: 'server_flow', key: 'server_flow', application: @app)

    post "/#{@company.key}/#{@app.key}/update/#{@server_flow.key}.xml?auth_token=1234"

    assert response.body.include?('Invalid request. Missing query parameter.')
  end

end