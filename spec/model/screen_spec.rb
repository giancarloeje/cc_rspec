require 'spec_helper'
require 'factories'

describe 'Screen', type: :model do

  before(:each) do
    @application = FactoryBot.create(:application)
    @layout = FactoryBot.create(:layout, name:'layout', application: @application)
  end

  it 'is not valid when key is numeric' do
    screen = Screen.new(key: '1', name: 'Screen', layout: @layout, application: @application)
    expect{screen.save!}.to raise_exception(ActiveRecord::RecordInvalid, "Validation failed: Key should contain alpha numeric and underscore characters only")
  end

  it 'should save screen with layout' do
    screen = Screen.new(key: 'screen', name: 'Screen', layout: @layout, application: @application)
    screen.save
    expect(Screen.count).to eq(1)
  end

  it 'should not save screen without layout' do
    screen = Screen.new(key: 'screen', name: 'Screen', layout: nil, application: @application)
    expect {screen.save!}.to raise_exception(ActiveRecord::RecordInvalid, "Validation failed: Layout can't be blank")
  end

end