require 'spec_helper'
require 'factories'

describe 'Environment', type: :model do

  it 'is not valid when attributes are not defined' do
    env = Environment.new
    expect{env.save!}.to raise_exception(ActiveRecord::RecordInvalid, "Validation failed: Name can't be blank, Key can't be blank, Key should contain alpha numeric and underscore characters only")
  end

  it 'is not valid when name is empty' do
    env = Environment.new(:key => 'env')
    expect{env.save!}.to raise_exception(ActiveRecord::RecordInvalid, "Validation failed: Name can't be blank")
  end

  it 'is not valid when key is numeric' do
    env = Environment.new(:name => 'env', :key => '1')
    expect{env.save!}.to raise_exception(ActiveRecord::RecordInvalid, "Validation failed: Key should contain alpha numeric and underscore characters only")
  end

  it 'is only valid when name and key are defined' do
    env = Environment.new(:name => 'env', :key => 'env')
    expect(env).to be_valid
  end

  it 'is not valid when name has a duplicate' do
    @application = FactoryBot.create(:application)
    env = Environment.new(:name => 'env', :key => 'env', application: @application)
    env.save!
    env2 = Environment.new(:name => 'env', :key => 'env', application: @application)
    expect{env2.save!}.to raise_exception(ActiveRecord::RecordInvalid, "Validation failed: Name has already been taken, Key has already been taken. Note: key is generated by converting name to lowercase and symbols to underscores by default.")
  end


end