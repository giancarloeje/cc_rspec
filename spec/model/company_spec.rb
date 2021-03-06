require 'spec_helper'
require 'factories'

describe 'Company', type: :model do

  it 'is not valid if name and key is empty' do
    company = Company.new
    expect{company.save!}.to raise_exception(ActiveRecord::RecordInvalid, "Validation failed: Name can't be blank, Key should contain alpha numeric and underscore characters only")
  end

  it 'is not valid if key is numeric only' do
    company = Company.new(:name => 'com', :key => 123)
    expect{company.save!}.to raise_exception(ActiveRecord::RecordInvalid, "Validation failed: Key should contain alpha numeric and underscore characters only")
  end

  it 'is not valid if name and key is a duplicate' do
    company = Company.new(:name => 'com', :key => 'com')
    company.save!
    company = Company.new(:name => 'com', :key => 'com')
    expect{company.save!}.to raise_exception(ActiveRecord::RecordInvalid, "Validation failed: Name has already been taken, Key has already been taken. Note: key is generated by converting name to lowercase and symbols to underscores by default.")
  end

  it 'is valid with valid attributes' do
    company = Company.new(:name => 'com', :key => 'com')
    expect(company).to be_valid
  end

  it 'converts name that begins with numeric value to underscore for its key value' do
    company = Company.new(:name => '888com')
    company.save!
    expect(company.key).to eq('_com')
  end

  it 'converts name with any non-word character to underscore for its key value' do
    company = Company.new(:name => 'case center+v1.6.4*')
    company.save!
    expect(company.key).to eq('case_center_v1_6_4_')
  end

  it 'able to create company with spaces in between [CMOSD-989]' do
    company = Company.new(:name => 'CaseCenter v1_6_4')
    expect(company).to be_valid
  end
end