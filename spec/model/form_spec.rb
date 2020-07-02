require 'spec_helper'
require 'factories'

describe 'Form', type: :model do

  it 'is not valid when attributes are not defined' do
    f = Form.new
    expect{f.save!}.to raise_exception(ActiveRecord::RecordInvalid, "Validation failed: Name can't be blank, Key can't be blank, Key should contain alpha numeric and underscore characters only")
  end

  it 'is not valid when name is empty' do
    f = Form.new(:name => '', :key => 'form')
    expect{f.save!}.to raise_exception(ActiveRecord::RecordInvalid, "Validation failed: Name can't be blank")
  end

  it 'is valid when attributes are defined' do
    f = Form.new(:name => 'form', :key => 'form')
    expect(f).to be_valid
  end
end