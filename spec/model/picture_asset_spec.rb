require 'rails_helper'
require 'factories'

describe PictureAsset, type: :model do

  before(:each) do
    @application = FactoryBot.create(:application)
    define_record_factory(nil, @application)
  end

  it 'is expected to be a Mongoid document' do
    is_expected.to be_mongoid_document
  end

  it 'is expected to have defined fields' do
    is_expected.to have_fields(:data_file_name, :data_content_type, :aes_key).of_type(String)
    is_expected.to have_fields(:data_file_size, :company_id).of_type(Integer)
    is_expected.to have_fields(:image_id, :thumb_image_id).of_type(BSON::ObjectId)
  end

  it 'is expected to be store in collection' do
    is_expected.to be_stored_in(collection: 'picture_assets')
  end

  it 'is expected to validate presence of fields' do
    is_expected.to validate_presence_of(:data_file_name)
    is_expected.to validate_presence_of(:data_content_type)
    is_expected.to validate_presence_of(:aes_key)
    is_expected.to validate_presence_of(:data_file_size)
    is_expected.to validate_presence_of(:company_id)
    is_expected.to validate_presence_of(:image_id)
    is_expected.to validate_presence_of(:thumb_image_id)
  end

  it 'is expected to validate uniqueness of data_file_name and image_id' do
    is_expected.to validate_uniqueness_of(:data_file_name).scoped_to(:company_id)
    is_expected.to validate_uniqueness_of(:image_id).scoped_to(:company_id)
  end

  it 'is expected to validate inclusion of data_content_type' do
    is_expected.to validate_inclusion_of(:data_content_type).to_allow("image/png", "image/jpeg", "image/jpg", "image/gif", "image/tiff")
  end

  it ' is invalid when attributes are empty' do
    pic_asset = PictureAsset.new
    expect(pic_asset.valid?).to equal(false)
    expect(pic_asset.errors[:data_file_name].first).to eq("can't be blank")
    expect(pic_asset.errors[:data_content_type].first).to eq("can't be blank")
    expect(pic_asset.errors[:data_file_size].first).to eq("can't be blank")
    expect(pic_asset.errors[:company_id].first).to eq("can't be blank")
    expect(pic_asset.errors[:image_id].first).to eq("can't be blank")
    expect(pic_asset.errors[:thumb_image_id].first).to eq("can't be blank")
    expect(pic_asset.errors[:aes_key].first).to eq("can't be blank")
  end

  it 'should only accept specific data_content_type' do
    pic_asset = PictureAsset.new data_content_type: "image/png"
    pic_asset.valid?
    expect(pic_asset.errors[:data_content_type].first).to eq(nil)

    pic_asset = PictureAsset.new data_content_type: "image/jpeg"
    pic_asset.valid?
    expect(pic_asset.errors[:data_content_type].first).to eq(nil)

    pic_asset = PictureAsset.new data_content_type: "image/jpg"
    pic_asset.valid?
    expect(pic_asset.errors[:data_content_type].first).to eq(nil)

    pic_asset = PictureAsset.new data_content_type: "image/gif"
    pic_asset.valid?
    expect(pic_asset.errors[:data_content_type].first).to eq(nil)

    pic_asset = PictureAsset.new data_content_type: "image/tiff"
    pic_asset.valid?
    expect(pic_asset.errors[:data_content_type].first).to eq(nil)

    pic_asset = PictureAsset.new data_content_type: "text/html"
    pic_asset.valid?
    expect(pic_asset.errors[:data_content_type].first).to eq("is not included in the list")
  end

end
