require 'factories'
require 'spec_helper'

describe 'Status Flow', type: :model do

  it 'should process status flow' do
    @company = FactoryBot.create(:company)
    @application = FactoryBot.create(:application, company: @company)
    @field = FactoryBot.create(:field, name:'field', key:'field', field_type:'String', application: @application)
    @status = FactoryBot.create(:status, name:'Status', key:'Status', application: @application)
    @statusflow = FactoryBot.create(:status_flow, name:'status_flow', key:'status_flow', data:'{"modules":[{"name":"Entry point","key":"Entry point","type":"entry_point","value":{},"config":{"position":[183,61],
                  "xtype":"WireIt.ImageContainer"}},{"name":"Status","key":"Status","type":"status","value":{},"config":{"position":[140,180],"xtype":"WireIt.ImageLabelContainer"}},{"name":"End point","key":
                  "End point","type":"end_point","value":{},"config":{"position":[172,304],"xtype":"WireIt.ImageContainer"}}],"wires":[{"xtype":"WireIt.BezierWire","src":{"moduleId":0,"terminal":"ENTRY_POINT"},
                  "tgt":{"moduleId":1,"terminal":"STATUS_INPUT"}},{"xtype":"WireIt.BezierWire","src":{"moduleId":1,"terminal":"STATUS_OUTPUT"},"tgt":{"moduleId":2,"terminal":"END_POINT"}}],"properties":{"name":"",
                  "description":""}}', field_id: '1',application: @application)

    @application.generate_mongoid_model
    record = @application.get_mongoid_class.new
    record.field = 'Test'
    record.add_system_record(nil, @application, @company)
    record.save!

    expect(record.field).to eq('Test')
    @statusflow.process_flow(@statusflow, record)
    expect(record.field).to eq('Status')
  end

  it 'should get first module id of status flow' do
    @company = FactoryBot.create(:company)
    @application = FactoryBot.create(:application, company: @company)
    @field = FactoryBot.create(:field, name:'field', key:'field', field_type:'String', application: @application)
    @status = FactoryBot.create(:status, name:'Status', key:'Status', application: @application)
    @statusflow = FactoryBot.create(:status_flow, name:'status_flow', key:'status_flow', data:'{"modules":[{"name":"Entry point","key":"Entry point","type":"entry_point","value":{},"config":{"position":[183,61],
                  "xtype":"WireIt.ImageContainer"}},{"name":"Status","key":"Status","type":"status","value":{},"config":{"position":[140,180],"xtype":"WireIt.ImageLabelContainer"}},{"name":"End point","key":
                  "End point","type":"end_point","value":{},"config":{"position":[172,304],"xtype":"WireIt.ImageContainer"}}],"wires":[{"xtype":"WireIt.BezierWire","src":{"moduleId":0,"terminal":"ENTRY_POINT"},
                  "tgt":{"moduleId":1,"terminal":"STATUS_INPUT"}},{"xtype":"WireIt.BezierWire","src":{"moduleId":1,"terminal":"STATUS_OUTPUT"},"tgt":{"moduleId":2,"terminal":"END_POINT"}}],"properties":{"name":"",
                  "description":""}}', field_id: '1',application: @application)

    @application.generate_mongoid_model
    record = @application.get_mongoid_class.new
    record.field = "Test"
    record.add_system_record(nil, @application, @company)
    record.save!

    i = @statusflow.get_first_module_id
    expect(i).to eq(0)
  end

  it 'should return first module of status flow' do
    @company = FactoryBot.create(:company)
    @application = FactoryBot.create(:application, company: @company)
    @field = FactoryBot.create(:field, name:'field', key:'field', field_type:'String', application: @application)
    @status = FactoryBot.create(:status, name:'Status', key:'Status', application: @application)
    @statusflow = FactoryBot.create(:status_flow, name:'status_flow', key:'status_flow', data:'{"modules":[{"name":"Entry point","key":"Entry point","type":"entry_point","value":{},"config":{"position":[183,61],
                  "xtype":"WireIt.ImageContainer"}},{"name":"Status","key":"Status","type":"status","value":{},"config":{"position":[140,180],"xtype":"WireIt.ImageLabelContainer"}},{"name":"End point","key":
                  "End point","type":"end_point","value":{},"config":{"position":[172,304],"xtype":"WireIt.ImageContainer"}}],"wires":[{"xtype":"WireIt.BezierWire","src":{"moduleId":0,"terminal":"ENTRY_POINT"},
                  "tgt":{"moduleId":1,"terminal":"STATUS_INPUT"}},{"xtype":"WireIt.BezierWire","src":{"moduleId":1,"terminal":"STATUS_OUTPUT"},"tgt":{"moduleId":2,"terminal":"END_POINT"}}],"properties":{"name":"",
                  "description":""}}', field_id: '1',application: @application)

    @application.generate_mongoid_model
    record = @application.get_mongoid_class.new
    record.field = "Test"
    record.add_system_record(nil, @application, @company)
    record.save!

    i = @statusflow.get_module(0)
    expect(i).to eq({"name"=>"Entry point", "key"=>"Entry point", "type"=>"entry_point", "value"=>{}, "config"=>{"position"=>[183, 61], "xtype"=>"WireIt.ImageContainer"}})
  end

  it 'should return next module id of status flow' do
    @company = FactoryBot.create(:company)
    @application = FactoryBot.create(:application, company: @company)
    @field = FactoryBot.create(:field, name:'field', key:'field', field_type:'String', application: @application)
    @status = FactoryBot.create(:status, name:'Status', key:'Status', application: @application)
    @statusflow = FactoryBot.create(:status_flow, name:'status_flow', key:'status_flow', data:'{"modules":[{"name":"Entry point","key":"Entry point","type":"entry_point","value":{},"config":{"position":[183,61],
                  "xtype":"WireIt.ImageContainer"}},{"name":"Status","key":"Status","type":"status","value":{},"config":{"position":[140,180],"xtype":"WireIt.ImageLabelContainer"}},{"name":"End point","key":
                  "End point","type":"end_point","value":{},"config":{"position":[172,304],"xtype":"WireIt.ImageContainer"}}],"wires":[{"xtype":"WireIt.BezierWire","src":{"moduleId":0,"terminal":"ENTRY_POINT"},
                  "tgt":{"moduleId":1,"terminal":"STATUS_INPUT"}},{"xtype":"WireIt.BezierWire","src":{"moduleId":1,"terminal":"STATUS_OUTPUT"},"tgt":{"moduleId":2,"terminal":"END_POINT"}}],"properties":{"name":"",
                  "description":""}}', field_id: '1',application: @application)

    @application.generate_mongoid_model
    record = @application.get_mongoid_class.new
    record.field = "Test"
    record.add_system_record(nil, @application, @company)
    record.save!

    i = @statusflow.get_next_module_id(@status_flow, 0, record)
    expect(i).to eq(1)
  end

  it 'should return second module of status flow' do
    @company = FactoryBot.create(:company)
    @application = FactoryBot.create(:application, company: @company)
    @field = FactoryBot.create(:field, name:'field', key:'field', field_type:'String', application: @application)
    @status = FactoryBot.create(:status, name:'Status', key:'Status', application: @application)
    @statusflow = FactoryBot.create(:status_flow, name:'status_flow', key:'status_flow', data:'{"modules":[{"name":"Entry point","key":"Entry point","type":"entry_point","value":{},"config":{"position":[183,61],
                  "xtype":"WireIt.ImageContainer"}},{"name":"Status","key":"Status","type":"status","value":{},"config":{"position":[140,180],"xtype":"WireIt.ImageLabelContainer"}},{"name":"End point","key":
                  "End point","type":"end_point","value":{},"config":{"position":[172,304],"xtype":"WireIt.ImageContainer"}}],"wires":[{"xtype":"WireIt.BezierWire","src":{"moduleId":0,"terminal":"ENTRY_POINT"},
                  "tgt":{"moduleId":1,"terminal":"STATUS_INPUT"}},{"xtype":"WireIt.BezierWire","src":{"moduleId":1,"terminal":"STATUS_OUTPUT"},"tgt":{"moduleId":2,"terminal":"END_POINT"}}],"properties":{"name":"",
                  "description":""}}', field_id: '1',application: @application)

    @application.generate_mongoid_model
    record = @application.get_mongoid_class.new
    record.field = "Test"
    record.add_system_record(nil, @application, @company)
    record.save!

    i = @statusflow.get_module(1)
    expect(i).to eq({"name"=>"Status", "key"=>"Status", "type"=>"status", "value"=>{}, "config"=>{"position"=>[140, 180], "xtype"=>"WireIt.ImageLabelContainer"}})
  end

  it 'should return nil when flow is not defined' do
    @company = FactoryBot.create(:company)
    @application = FactoryBot.create(:application, company: @company)
    @field = FactoryBot.create(:field, name:'field', key:'field', field_type:'String', application: @application)
    @statusflow = FactoryBot.create(:status_flow, name:'status_flow', key:'status_flow', data:'{"modules":[],"wires":[],"properties":{"name":"","description":""}}', field_id: '1', application: @application)

    @application.generate_mongoid_model
    record = @application.get_mongoid_class.new
    record.field = "Test"
    record.add_system_record(nil, @application, @company)
    record.save!

    i = @statusflow.get_first_module_id
    expect(i).to eq(nil)
  end

  it 'should return nil when next module is not defined' do
    @company = FactoryBot.create(:company)
    @application = FactoryBot.create(:application, company: @company)
    @field = FactoryBot.create(:field, name:'field', key:'field', field_type:'String', application: @application)
    @statusflow = FactoryBot.create(:status_flow, name:'status_flow', key:'status_flow', data:'{"modules":[],"wires":[],"properties":{"name":"","description":""}}', field_id: '1', application: @application)

    @application.generate_mongoid_model
    record = @application.get_mongoid_class.new
    record.field = "Test"
    record.add_system_record(nil, @application, @company)
    record.save!

    i = @statusflow.get_next_module_id(@status_flow, 0, record)
    expect(i).to eq(nil)
  end

  it 'should return nil when get module is used on an empty flow' do
    @company = FactoryBot.create(:company)
    @application = FactoryBot.create(:application, company: @company)
    @field = FactoryBot.create(:field, name:'field', key:'field', field_type:'String', application: @application)
    @statusflow = FactoryBot.create(:status_flow, name:'status_flow', key:'status_flow', data:'{"modules":[],"wires":[],"properties":{"name":"","description":""}}', field_id: '1', application: @application)

    @application.generate_mongoid_model
    record = @application.get_mongoid_class.new
    record.field = "Test"
    record.add_system_record(nil, @application, @company)
    record.save!

    i = @statusflow.get_module(0)
    expect(i).to eq(nil)
  end

end