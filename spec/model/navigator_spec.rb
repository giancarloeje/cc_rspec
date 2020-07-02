require 'spec_helper'
require 'factories'

describe 'Navigator', type: :model do

  it 'is invalid when attributes are not defined' do
    navigator = Navigator.new
    expect{navigator.save!}.to raise_exception(ActiveRecord::RecordInvalid, "Validation failed: Name can't be blank")
  end

  it 'is valid when required attributes are defined' do
    navigator = Navigator.new(:name => 'Navi')
    navigator.save!
    expect(Navigator.count).to eq(1)
  end

  it 'should have a role attribute' do
    expect(Role.new).to respond_to(:navigator)
  end

end