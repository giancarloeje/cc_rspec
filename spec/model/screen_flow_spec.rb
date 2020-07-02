require 'spec_helper'
require 'factories'

describe 'Screen Flow', type: :model do

  before(:each) do
    @application = FactoryBot.create(:application)
    define_record_factory(nil, @application)
  end

  it 'is invalid when attributes are not defined' do
    screen_flow = ScreenFlow.new
    expect{screen_flow.save!}.to raise_exception(ActiveRecord::RecordInvalid, "Validation failed: Name can't be blank, Key can't be blank, Key should contain alpha numeric and underscore characters only")
  end

  it 'is invalid when name is empty' do
    screen_flow = ScreenFlow.new(:name => '', :key => 'screenflow')
    expect{screen_flow.save!}.to raise_exception(ActiveRecord::RecordInvalid, "Validation failed: Name can't be blank")
  end

  it 'is invalid when key is empty' do
    screen_flow = ScreenFlow.new(:name => 'screenflow', :key => '1')
    expect{screen_flow.save!}.to raise_exception(ActiveRecord::RecordInvalid, "Validation failed: Key should contain alpha numeric and underscore characters only")
  end

  it 'is invalid when two association options are selected (CMOSD-783)' do
    screen_flow = ScreenFlow.new(:name => 'screenflow',  :key => 'screenflow', :save_child_record => '1', :save_new_record => '1')
    expect{screen_flow.save!}.to raise_exception(ActiveRecord::RecordInvalid, "Validation failed: Options under associations tab must have only one item selected")
  end

  it 'is valid to select one association option (CMOSD-783)' do
    screen_flow = FactoryBot.create(:screen_flow, name: 'screenflow', key: 'screenflow', save_child_record:'0', save_new_record:'1')
    expect(screen_flow).to be_valid
  end

  it 'should trigger create permission after save' do
    screen_flow = ScreenFlow.new(:name => 'screenflow', :key => 'screenflow')
    expect(screen_flow).to receive(:create_permissions)
    screen_flow.save!
  end

  it 'should get first screen' do
    @record = create_record(@application)
    @screen = FactoryBot.create(:screen, name: 'MainScreen', key: 'mainscreen', application: @application)
    @screen2 = FactoryBot.create(:screen, name: 'MainScreen2', key: 'mainscreen2', application: @application)
    @screen_flow = FactoryBot.create(:screen_flow, name: 'MainScreenFlow', key: 'mainscreenflow', data: '{"modules":[{"name":"Entry point","key":"Entry point","type":"entry_point","value":{},
                  "config":{"position":[81,48],"xtype":"WireIt.ImageContainer"}},{"name":"MainScreen","key":"mainscreen","type":"screen","value":{},"config":{"position":[164,151],"xtype":"WireIt.ImageLabelContainer"}},
                  {"name":"SubScreen","key":"subscreen","type":"screen_flow","value":{},"config":{"position":[265,258],"xtype":"WireIt.ImageLabelContainer"}},{"name":"MainScreen2","key":"mainscreen2","type":"screen",
                  "value":{},"config":{"position":[338,359],"xtype":"WireIt.ImageLabelContainer"}},{"name":"Save","key":"Save","type":"save","value":{},"config":{"position":[276,471],"xtype":"WireIt.ImageContainer"}},
                  {"name":"End point","key":"End point","type":"end_point","value":{},"config":{"position":[404,553],"xtype":"WireIt.ImageContainer"}}],"wires":[{"xtype":"WireIt.BezierWire","src":{"moduleId":0,
                  "terminal":"ENTRY_POINT"},"tgt":{"moduleId":1,"terminal":"SCREEN_INPUT"}},{"xtype":"WireIt.BezierWire","src":{"moduleId":1,"terminal":"SCREEN_OUTPUT"},"tgt":{"moduleId":2,"terminal":"SCREEN_FLOW_INPUT"}},
                  {"xtype":"WireIt.BezierWire","src":{"moduleId":2,"terminal":"SCREEN_FLOW_OUTPUT"},"tgt":{"moduleId":3,"terminal":"SCREEN_INPUT"}},{"xtype":"WireIt.BezierWire","src":{"moduleId":3,"terminal":"SCREEN_OUTPUT"},
                  "tgt":{"moduleId":4,"terminal":"SAVE_INPUT"}},{"xtype":"WireIt.BezierWire","src":{"moduleId":4,"terminal":"SAVE_OUTPUT"},"tgt":{"moduleId":5,"terminal":"END_POINT"}}],"properties":{"name":"","description":""}}', application: @application)

    screen1 = @screen_flow.get_first_screen(@record).name
    screen1 == 'MainScreen'
  end

  it 'should return true since first module is a screen' do
    @record = create_record(@application)
    @screen = FactoryBot.create(:screen, name: 'MainScreen', key: 'mainscreen', application: @application)
    @screen2 = FactoryBot.create(:screen, name: 'MainScreen2', key: 'mainscreen2', application: @application)
    @screen_flow = FactoryBot.create(:screen_flow, name: 'MainScreenFlow', key: 'mainscreenflow', data: '{"modules":[{"name":"Entry point","key":"Entry point","type":"entry_point","value":{},
                  "config":{"position":[81,48],"xtype":"WireIt.ImageContainer"}},{"name":"MainScreen","key":"mainscreen","type":"screen","value":{},"config":{"position":[164,151],"xtype":"WireIt.ImageLabelContainer"}},
                  {"name":"SubScreen","key":"subscreen","type":"screen_flow","value":{},"config":{"position":[265,258],"xtype":"WireIt.ImageLabelContainer"}},{"name":"MainScreen2","key":"mainscreen2","type":"screen",
                  "value":{},"config":{"position":[338,359],"xtype":"WireIt.ImageLabelContainer"}},{"name":"Save","key":"Save","type":"save","value":{},"config":{"position":[276,471],"xtype":"WireIt.ImageContainer"}},
                  {"name":"End point","key":"End point","type":"end_point","value":{},"config":{"position":[404,553],"xtype":"WireIt.ImageContainer"}}],"wires":[{"xtype":"WireIt.BezierWire","src":{"moduleId":0,
                  "terminal":"ENTRY_POINT"},"tgt":{"moduleId":1,"terminal":"SCREEN_INPUT"}},{"xtype":"WireIt.BezierWire","src":{"moduleId":1,"terminal":"SCREEN_OUTPUT"},"tgt":{"moduleId":2,"terminal":"SCREEN_FLOW_INPUT"}},
                  {"xtype":"WireIt.BezierWire","src":{"moduleId":2,"terminal":"SCREEN_FLOW_OUTPUT"},"tgt":{"moduleId":3,"terminal":"SCREEN_INPUT"}},{"xtype":"WireIt.BezierWire","src":{"moduleId":3,"terminal":"SCREEN_OUTPUT"},
                  "tgt":{"moduleId":4,"terminal":"SAVE_INPUT"}},{"xtype":"WireIt.BezierWire","src":{"moduleId":4,"terminal":"SAVE_OUTPUT"},"tgt":{"moduleId":5,"terminal":"END_POINT"}}],"properties":{"name":"","description":""}}', application: @application)

    i = @screen_flow.first_module_is_a_screen?
    expect(i).to eq(true)
  end

  it 'should return false since first module is not a screen' do
    @record = create_record(@application)
    @modifier = FactoryBot.create(:modifier, name: 'getAge', :code => "#", application: @application)
    @screen_flow = FactoryBot.create(:screen_flow, name: 'SubScreen', key: 'subscreen', data: '{"modules":[{"name":"Entry point","key":"Entry point","type":"entry_point","value":{},
                "config":{"position":[123,74],"xtype":"WireIt.ImageContainer"}},{"name":"getAge","key":"getage","type":"modifier","value":{},"config":{"position":[186,192],"xtype":"WireIt.ImageLabelContainer"}}],
                "wires":[{"xtype":"WireIt.BezierWire","src":{"moduleId":0,"terminal":"ENTRY_POINT"},"tgt":{"moduleId":1,"terminal":"MODIFIER_INPUT"}}],"properties":{"name":"","description":""}}', application: @application)

    i = @screen_flow.first_module_is_a_screen?
    expect(i).to eq(false)
  end

end