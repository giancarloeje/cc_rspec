require 'rails_helper'
require 'factories'

describe Pattern, type: :model do

  before(:each) do
    @application = FactoryBot.create(:application)
    define_record_factory(nil, @application)
  end

  it 'is expected to be a Mongoid document' do
    is_expected.to be_mongoid_document
  end

  it 'is expected to have defined fields' do
    is_expected.to have_fields(:name, :description, :pattern_file_name, :pattern_content_type, :pattern_type, :html_block_key, :aes_key).of_type(String)
    is_expected.to have_fields(:application_id, :pattern_file_size, :html_block_id).of_type(Integer)
    is_expected.to have_fields(:pattern_file_id).of_type(BSON::ObjectId)
  end

  it 'is expected to validate presence of fields' do
    is_expected.to validate_presence_of(:name)
    is_expected.to validate_presence_of(:pattern_type)
  end

  it 'is expected to validate uniqueness of name' do
    is_expected.to validate_uniqueness_of(:name).scoped_to(:application_id)
  end


  it 'is expected to be store in collection' do
    is_expected.to be_stored_in(collection: 'patterns')
  end

  it 'should return true if pattern type is pdf' do
    pattern = Pattern.new(:name => 'pattern', :pattern_type => 'pdf', :html_block_id => '1')
    result = pattern.is_pdf?
    expect(result).to eq(true)
  end

  it 'should return false if pattern type is pdf and htmlblock id is not present' do
    pattern = Pattern.new(:name => 'pattern', :pattern_type => 'pdf')
    result = pattern.is_pdf?
    expect(result).to eq(false)
  end

  it 'should return false if pattern type is csv' do
    pattern = Pattern.new(:name => 'pattern', :pattern_type => 'csv', :html_block_id => nil)
    result = pattern.is_pdf?
    expect(result).to eq(false)
  end

  it 'should use html block as PDF template and return PDF' do
    @html_block = FactoryBot.create(:html_block, key: 'htmlblock', name: 'htmlblock', code: "<p>TEST PDF</p>", application: @application)
    @pattern = FactoryBot.create(:pattern, name: 'pattern', pattern_type: 'pdf', html_block_id: '1', application_id: @application.id)
    record = create_record(@application)
    record = @application.get_mongoid_class.as_json
    pdf = @pattern.generate_pdf(record, @html_block.code)
    expect(pdf).to be_a String
  end

  it 'is invalid when attributes are not defined' do
    pattern = Pattern.new
    expect(pattern.valid?).to eq false
    expect(pattern.errors.full_messages).to eql ["Name can't be blank", "Pattern type can't be blank"]
  end

  it 'is invalid when name is empty' do
    html_block = FactoryBot.create(:html_block, key: 'htmlblock', name: 'htmlblock', code: "<p>TEST PDF</p>", application: @application)
    pattern = Pattern.new pattern_type: 'pdf', html_block_id: html_block.id, application_id: @application.id
    expect(pattern.valid?).to eql false
  end

  it 'should trigger create_permission on save' do
    html_block = FactoryBot.create(:html_block, key: 'htmlblock', name: 'htmlblock', code: "<p>TEST PDF</p>", application: @application)
    pattern = Pattern.new name: 'Pattern Test', pattern_type: 'pdf', html_block_id: html_block.id, application_id: @application.id
    expect(pattern).to receive(:create_permissions)
    pattern.save
  end

  it 'should trigger destroy_permission on destroy' do
    html_block = FactoryBot.create(:html_block, key: 'htmlblock', name: 'htmlblock', code: "<p>TEST PDF</p>", application: @application)
    pattern = Pattern.new name: 'Pattern Test', pattern_type: 'pdf', html_block_id: html_block.id, application_id: @application.id
    expect(pattern).to receive(:destroy_permissions)
    pattern.destroy
  end

  it 'should not trigger create_permission on destroy' do
    html_block = FactoryBot.create(:html_block, key: 'htmlblock', name: 'htmlblock', code: "<p>TEST PDF</p>", application: @application)
    pattern = Pattern.new name: 'Pattern Test', pattern_type: 'pdf', html_block_id: html_block.id, application_id: @application.id
    expect(pattern).not_to receive(:create_permissions)
    pattern.destroy
  end

  it 'should not trigger destroy_permission on save' do
    html_block = FactoryBot.create(:html_block, key: 'htmlblock', name: 'htmlblock', code: "<p>TEST PDF</p>", application: @application)
    pattern = Pattern.new name: 'Pattern Test', pattern_type: 'pdf', html_block_id: html_block.id, application_id: @application.id
    expect(pattern).not_to receive(:destroy_permissions)
    pattern.save
  end

end