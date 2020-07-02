require 'spec_helper'
require 'factories'

describe 'Modifier', type: :model do

  it 'is invalid when attributes are not defined' do
    modifier = Modifier.new
    expect{modifier.save!}.to raise_exception(ActiveRecord::RecordInvalid, "Validation failed: Name can't be blank, Key can't be blank, Key should contain alpha numeric and underscore characters only, Code can't be blank")
  end

  it 'is invalid when name is empty' do
    modifier = Modifier.new(:name => '', :key => 'modifier', :code => "#")
    expect{modifier.save!}.to raise_exception(ActiveRecord::RecordInvalid, "Validation failed: Name can't be blank")
  end

  it 'is invalid when key is numeric' do
    modifier = Modifier.new(:name => 'modifier', :key => '1', :code => "#")
    expect{modifier.save!}.to raise_exception(ActiveRecord::RecordInvalid, "Validation failed: Key should contain alpha numeric and underscore characters only")
  end

  it 'is invalid when code is blank' do
    modifier = Modifier.new(:name => 'modifier', :key => 'modifier')
    expect{modifier.save!}.to raise_exception(ActiveRecord::RecordInvalid, "Validation failed: Code can't be blank")
  end

  it 'is valid when required attributes are defined' do
    modifier = Modifier.new(:name => 'modifier', :key => 'modifier', :code => "#")
    modifier.save!
    expect(Modifier.count).to eq(1)
  end

end