require 'spec_helper'
require 'factories'
require 'cancan/matchers'

describe 'ClientPermission', type: :model do

  before(:each) do
    @application = FactoryBot.create(:application)
    define_record_factory(nil, @application)
  end

  # Screen Flow Permission

  it 'should trigger create permission on Screen Flow save' do
    screen_flow = ScreenFlow.new(:name => 'Test Screen', :key => 'Test_Screen', :application => @application)
    screen_flow.save!

    create_cp = ClientPermission.find_by_action('create')
    expect(create_cp.object_class).to eq('ScreenFlow')
    expect(create_cp.name).to eq('Create Test Screen records')

    read_cp = ClientPermission.find_by_action('read')
    expect(read_cp.object_class).to eq('ScreenFlow')
    expect(read_cp.name).to eq('Read Test Screen records')

    update_cp = ClientPermission.find_by_action('update')
    expect(update_cp.object_class).to eq('ScreenFlow')
    expect(update_cp.name).to eq('Update Test Screen records')
  end

  it 'should trigger destroy permission on Screen Flow deletion' do
    screen_flow = ScreenFlow.new(:name => 'Test Screen', :key => 'Test_Screen', :application => @application)
    screen_flow.save!
    screen_flow.destroy

    cp = ClientPermission.find_by_object_class('ScreenFlow')
    expect(cp).to eq(nil)
  end

  it 'should not trigger destroy permission on Screen Flow save' do
    screen_flow = ScreenFlow.new(:name => 'Test Screen', :key => 'Test_Screen', :application => @application)
    expect(screen_flow).not_to receive(:destroy_permissions)
    screen_flow.save
  end

  it 'should not trigger create_permission on Screen Flow destroy' do
    screen_flow = ScreenFlow.new(:name => 'Test Screen', :key => 'Test_Screen', :application => @application)
    expect(screen_flow).not_to receive(:create_permissions)
    screen_flow.destroy
  end

  # Server Flow Permission

  it 'should trigger create permission on Server Flow save' do
    server_flow = ServerFlow.new(:name => 'Test Server', :key => 'Test_Server', :application => @application)
    server_flow.save!

    create_cp = ClientPermission.find_by_action('create')
    expect(create_cp.object_class).to eq('ServerFlow')
    expect(create_cp.name).to eq('Create Test Server records (server flow)')

    read_cp = ClientPermission.find_by_action('read')
    expect(read_cp.object_class).to eq('ServerFlow')
    expect(read_cp.name).to eq('Read Test Server records (server flow)')

    update_cp = ClientPermission.find_by_action('update')
    expect(update_cp.object_class).to eq('ServerFlow')
    expect(update_cp.name).to eq('Update Test Server records (server flow)')
  end

  it 'should trigger destroy permission on Server Flow deletion' do
    server_flow = ServerFlow.new(:name => 'Test Server', :key => 'Test_Server', :application => @application)
    server_flow.save!
    server_flow.destroy

    cp = ClientPermission.find_by_object_class('ServerFlow')
    expect(cp).to eq(nil)
  end

  it 'should not trigger destroy permission on Server Flow save' do
    server_flow = ServerFlow.new(:name =>'Test Server', :key => 'Test_Server', :application => @application)
    expect(server_flow).not_to receive(:destroy_permissions)
    server_flow.save
  end

  it 'should not trigger create_permission on Server Flow destroy' do
    server_flow = ServerFlow.new(:name =>'Test Server', :key => 'Test_Server', :application => @application)
    expect(server_flow).not_to receive(:create_permissions)
    server_flow.destroy
  end

  # Queue Client Permission

  it 'should trigger add read filter permission on save' do
    filter = Filter.new(:name => 'filter')
    filter.save!

    cp = ClientPermission.last
    expect(cp.object_class).to eq('Filter')
    expect(cp.action).to eq('read')
    expect(cp.name).to eq('Read filter queue')
  end

  it 'should trigger destroy_permission on filter destroy' do
    filter = Filter.new(:name => 'filter')
    filter.save!
    filter.destroy

    cp = ClientPermission.last
    expect(cp).to eq(nil)
  end

  it 'should not trigger destroy_permission on filter save' do
    filter = Filter.new(:name => 'filter')
    expect(filter).not_to receive(:destroy_permissions)
    filter.save
  end

  it 'should not trigger create_permission on filter destroy' do
    filter = Filter.new(:name => 'filter')
    expect(filter).not_to receive(:create_permissions)
    filter.destroy
  end

  # Pattern Permissions

  it 'should trigger create permission on pattern save' do
    html_block = FactoryBot.create(:html_block, key: 'htmlblock', name: 'htmlblock', code: "<p>TEST PDF</p>", application: @application)
    pattern = FactoryBot.create(:pattern, name: 'Pattern Test', pattern_type: 'pdf', html_block_id: '1', application_id: @application.id)
    pattern.save!

    create_cp = ClientPermission.find_by_action('create')
    expect(create_cp.object_class).to eq('Pattern')
    expect(create_cp.name).to eq('Create Pattern Test pattern')

    read_cp = ClientPermission.find_by_action('read')
    expect(read_cp.object_class).to eq('Pattern')
    expect(read_cp.name).to eq('Read Pattern Test pattern')

    update_cp = ClientPermission.find_by_action('update')
    expect(update_cp.object_class).to eq('Pattern')
    expect(update_cp.name).to eq('Update Pattern Test pattern')
  end

  it 'should trigger destroy_permission on pattern destroy' do
    html_block = FactoryBot.create :html_block
    pattern = Pattern.create(:name => 'patternTest', :pattern_type => 'pdf', :application_id => @application.id)
    pattern.destroy

    cp = ClientPermission.last
    expect(cp).to eq(nil)
  end

  it 'should not trigger destroy_permission on pattern save' do
    pattern = Pattern.new(:name => 'patternTest', :pattern_type => 'csv')
    expect(pattern).not_to receive(:destroy_permissions)
    pattern.save
  end

  it 'should not trigger create_permission on pattern destroy' do
    pattern = Pattern.new(:name => 'patternTest', :pattern_type => 'csv')
    expect(pattern).not_to receive(:create_permissions)
    pattern.destroy
  end

end