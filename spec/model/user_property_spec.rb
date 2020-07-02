require 'spec_helper'
require 'factories'

describe 'User Property', type: :model do

 before(:each) do
    @company = FactoryBot.create(:company)
    @application = FactoryBot.create(:application, company: @company)
    define_record_factory(nil, @application)
  end

  it 'is not valid when no attributes are defined' do
    user_property = UserProperty.new()
    expect{user_property.save!}.to raise_exception(ActiveRecord::RecordInvalid, "Validation failed: Name can't be blank, Key should contain alpha numeric and underscore characters only")
  end

  it 'is valid when name is defined' do
    @user_property = UserProperty.new(:name => 'UserProp1').save!
    expect(UserProperty.count).to eq(1)
  end

  it 'returns user property not found exception' do
    record = create_record(@application)
    @testField = FactoryBot.create(:field, :name => 'testField', :key => 'testField', :application => @application )
    expect{UserProperty.set(record, 'invalid', @testField)}.to raise_exception('Property not found invalid')
  end

  it 'returns no current user found exception' do
    record = create_record(@application)
    @testField = FactoryBot.create(:field, :name => 'testField', :key => 'testField', field_type: 'String', :application => @application )
    @user_property = FactoryBot.create(:user_property, :name => 'testProp', :key => 'testProp', :company_id => @company.id)
    expect{UserProperty.set(record, @user_property.key, @testField)}.to raise_exception('User property - no current user found')
  end
end