require 'rails_helper'
require 'factories'

describe XslSheet, type: :model do

  it 'is expected to be a Mongoid document' do
    is_expected.to be_mongoid_document
  end

  it 'is expected to have defined fields' do
    is_expected.to have_fields(:data_file_name, :aes_key).of_type(String)
    is_expected.to have_fields(:company_id).of_type(Integer)
    is_expected.to have_fields(:stylesheet_id).of_type(BSON::ObjectId)
  end

  #it 'is expected to validate presence of fields' do
    #is_expected.to validate_presence_of(:data_file_name)
  #end

  it 'is expected to validate uniqueness of data_file_name and stylesheet_id' do
    is_expected.to validate_uniqueness_of(:data_file_name).scoped_to(:company_id)
    is_expected.to validate_uniqueness_of(:stylesheet_id).scoped_to(:company_id)
  end
end
