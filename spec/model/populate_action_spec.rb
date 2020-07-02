require 'spec_helper'
require 'factories'

describe 'Populate Action', type: :model do

  before(:each) do
    @populate_action = PopulateAction.new(:name => 'Populate')
    @populate_action.run_callbacks(:save)


  end

  it 'is invalid when attributes are not defined' do
    populate = PopulateAction.new
    expect{populate.save!}.to raise_exception(ActiveRecord::RecordInvalid, "Validation failed: Name can't be blank, Key can't be blank, Key should contain alpha numeric and underscore characters only, One of the populate checkbox must be selected, either Populate new? or Populate existing? but not both")
  end

  it 'is invalid when name is empty' do
    populate = PopulateAction.new(:name => '', :key =>'populate', :populate_new => '1', :populate_existing => '0')
    expect{populate.save!}.to raise_exception(ActiveRecord::RecordInvalid, "Validation failed: Name can't be blank")
  end

  it 'is invalid when key is numeric' do
    populate = PopulateAction.new(:name => 'populate', :key =>'1', :populate_new => '1', :populate_existing => '0')
    expect{populate.save!}.to raise_exception(ActiveRecord::RecordInvalid, "Validation failed: Key should contain alpha numeric and underscore characters only")
  end

  it 'is invalid when populate action type is not selected' do
    populate = PopulateAction.new(:name => 'populate', :key =>'populate', :populate_new => '', :populate_existing => '')
    expect{populate.save!}.to raise_exception(ActiveRecord::RecordInvalid, "Validation failed: One of the populate checkbox must be selected, either Populate new? or Populate existing? but not both")
  end

  it 'is valid when required attributes are defined' do
    populate = PopulateAction.new(:name => 'populate', :key =>'populate', :populate_new => '1', :populate_existing => '0')
    populate.save!

    expect(PopulateAction.count).to eq(1)
  end

end