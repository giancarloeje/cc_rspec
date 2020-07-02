require 'spec_helper'
require 'factories'
require 'rack'

def test_file_path
  "#{Rails.root}/spec/test_files/text_file.txt"
end

def invalid_file_path
  "#{Rails.root}/spec/test_files/script_file.rb"
end

def create_user(args={})
  @user = FactoryBot.create(:user, args)
end

def auth_token(user)
  CGI.escape "#{Base64.urlsafe_encode64(user.email)}|#{user.authentication_token}"
end

def upload_attachment
  record = create_record(@application)
  url = "/#{@company.key}/#{@application.key}/attachments_api/upload/#{record.system.record_id}/Upload.txt/#{auth_token(@user)}.json"
  request_body = fixture_file_upload(test_file_path, :binary)
  post "#{url}", request_body, 'CONTENT_TYPE' => 'application/octet-stream'
end

describe 'Attachments API', type: :request do

  before(:each) do |example|
    p "Start of Test: #{example.description}"
    @company = FactoryBot.create(:company)
    @application = FactoryBot.create(:application, company: @company)
    define_record_factory(nil, @application)
  end

  after :each do |example|
    p "End of Test: #{example.description}"
  end

  # Attachment API: upload, list, download, delete

  it 'should upload a text file' do
    @user = FactoryBot.create(:user, is_root: true, authentication_token: Devise.friendly_token, company: @company)
    record = create_record(@application)

    url = "/#{@company.key}/#{@application.key}/attachments_api/upload/#{record.system.record_id}/uploadapi.txt/#{auth_token(@user)}.json"
    request_body = fixture_file_upload(test_file_path, :binary)

    post "#{url}", request_body, 'CONTENT_TYPE' => 'application/octet-stream'

    expect(json["id"]).to_not be_nil
    expect(json['aes_key']).to be_nil
    expect(json['company_id']).to be_nil
    expect(json["record_id"]).to eq(record.system.record_id)
    expect(json['data_file_name']).to eq('uploadapi.txt')
    expect(json['user']).to eq(@user.email)

  end

  it 'should return a list of attachments' do
    @user = FactoryBot.create(:user, is_root: true, authentication_token: Devise.friendly_token, company: @company)

    upload_attachment
    record_id = json["record_id"]

    # get list
    url2 = "/#{@company.key}/#{@application.key}/attachments_api/list/#{record_id}/#{auth_token(@user)}.json"
    post "#{url2}"

    expect(json[0]["id"]).to_not be_nil
    expect(json[0]['aes_key']).to be_nil
    expect(json[0]['company_id']).to be_nil
    expect(json[0]["record_id"]).to eq(record_id)
    expect(json[0]['data_file_name']).to eq('Upload.txt')
    expect(json[0]['user']).to eq(@user.email)
  end

  it 'should download attachment' do
    @user = FactoryBot.create(:user, is_root: true, authentication_token: Devise.friendly_token, company: @company)

    upload_attachment
    unique_id = json["id"]
    record_id = json["record_id"]

    # download
    post "/#{@company.key}/#{@application.key}/attachments_api/download/#{record_id}/#{unique_id}/#{auth_token(@user)}.json"
    assert_response :success
  end

  it 'should download attachment as zipped file' do
    @user = FactoryBot.create(:user, is_root: true, authentication_token: Devise.friendly_token, company: @company)
    upload_attachment
    unique_id = json["id"]
    record_id = json["record_id"]

    # download as zipped file
    post "/#{@company.key}/#{@application.key}/attachments_api/downloadAsZip/#{record_id}/#{auth_token(@user)}.json"
    expect(response.content_type).to eq "application/zip"
  end

  it 'should delete attachment' do
    @user = FactoryBot.create(:user, is_root: true, authentication_token: Devise.friendly_token, company: @company)

    upload_attachment
    unique_id = json["id"]
    record_id = json["record_id"]

    # delete
    post "/#{@company.key}/#{@application.key}/attachments_api/delete/#{record_id}/#{unique_id}/#{auth_token(@user)}.json"
    response.body.include?('{"success":true}')
  end

  # Exceptions

  it 'should return an exception when record id is undefined during upload' do
    @user = FactoryBot.create(:user, is_root: true, authentication_token: Devise.friendly_token, company: @company)
    @record = create_record(@application)

    url = "/#{@company.key}/#{@application.key}/attachments_api/upload/undefined/test_file.txt/#{auth_token(@user)}.json"
    request_body = fixture_file_upload(test_file_path)
    post "#{url}", request_body, 'CONTENT_TYPE' => 'application/octet-stream'

    assert response.body.include?('Record does not exist')
  end

  it 'should return an exception when auth token is not provided' do
    @user = FactoryBot.create(:user, is_root: true, authentication_token: Devise.friendly_token, company: @company)
    record = create_record(@application)

    url = "/#{@company.key}/#{@application.key}/attachments_api/upload/#{record.system.record_id}/test_file.txt"
    request_body = fixture_file_upload(test_file_path)
    post "#{url}", request_body, 'CONTENT_TYPE' => 'application/octet-stream'

    assert response.body.include?('Invalid or missing authenticity token.')
  end

  it 'should return an exception when user deletes a non existent file' do
    @user = FactoryBot.create(:user, is_root: true, authentication_token: Devise.friendly_token, company: @company)
    record = create_record(@application)
    unique_id = 123456-12321-312-312

    post "/#{@company.key}/#{@application.key}/attachments_api/delete/#{record.system.record_id}/#{unique_id}/#{auth_token(@user)}.json"
    assert response.body.include?('{"errors":["error: attachment not found"]}')
  end

  it 'should return an exception when a unsupported file type is uploaded' do
    @user = FactoryBot.create(:user, is_root: true, authentication_token: Devise.friendly_token, company: @company)
    record = create_record(@application)

    url = "/#{@company.key}/#{@application.key}/attachments_api/upload/#{record.system.record_id}/invalid_file.rb/#{auth_token(@user)}.json"
    request_body = fixture_file_upload(invalid_file_path)
    post "#{url}", request_body, 'CONTENT_TYPE' => 'application/octet-stream'

    assert response.body.include?('{"errors":["file type not allowed : text/x-ruby"]}')
  end

  it 'should return an exception when user downloads a non existent file' do
    @user = FactoryBot.create(:user, is_root: true, authentication_token: Devise.friendly_token, company: @company)

    upload_attachment
    unique_id = 'invalid'
    record_id = json['record_id']

    # download
    post "/#{@company.key}/#{@application.key}/attachments_api/download/#{record_id}/#{unique_id}/#{auth_token(@user)}.json"
    assert response.body.include?('{"errors":["error: attachment not found"]}')
  end

  # Permission Test

  it 'should return an exception when auth token used is invalid' do
    @user = FactoryBot.create(:user, is_root: true, authentication_token: Devise.friendly_token, company: @company)
    record = create_record(@application)

    url = "/#{@company.key}/#{@application.key}/attachments_api/upload/#{record.system.record_id}/test_file.txt/invalid.json"
    request_body = fixture_file_upload(test_file_path)
    post "#{url}", request_body, 'CONTENT_TYPE' => 'application/octet-stream'

    assert response.body.include?('{"errors":["Invalid auth-token"]}')
  end

  it 'should not allow non-root/non-admin user without API_attachment ability to list, upload, download, delete, and download as zip files' do
    @user = FactoryBot.create(:user, is_root: true, authentication_token: Devise.friendly_token, company: @company)
    record = create_record(@application)
    upload_attachment
    unique_id = json['id']
    record_id = json['record_id']

    attachment_role = FactoryBot.create(:role, API_attachment: 0, application: @application)
    @user1 = create_user({is_root: false, is_admin: false, :roles => [attachment_role], authentication_token: Devise.friendly_token, :company => @application.company})

    # list
    url = "/#{@company.key}/#{@application.key}/attachments_api/list/#{record_id}/#{auth_token(@user1)}.json"
    post "#{url}"
    assert response.body.include?('You are not allowed to use this API')

    # upload
    url = "/#{@company.key}/#{@application.key}/attachments_api/upload/#{record_id}/uploadapi.txt/#{auth_token(@user1)}.json"
    request_body = fixture_file_upload(test_file_path, :binary)
    post "#{url}", request_body, 'CONTENT_TYPE' => 'application/octet-stream'
    assert response.body.include?('You are not allowed to use this API')

    # download
    post "/#{@company.key}/#{@application.key}/attachments_api/download/#{record_id}/#{unique_id}/#{auth_token(@user1)}.json"
    assert response.body.include?('You are not allowed to use this API')

    # delete
    post "/#{@company.key}/#{@application.key}/attachments_api/delete/#{record_id}/#{unique_id}/#{auth_token(@user1)}.json"
    assert response.body.include?('You are not allowed to use this API')

    # download as zipped
    post "/#{@company.key}/#{@application.key}/attachments_api/downloadAsZip/#{record_id}/#{auth_token(@user1)}.json"
    assert response.body.include?('You are not allowed to use this API')

  end

  it 'should allow non-root/non-admin user with API_attachment ability to list, upload, download, delete, and download as zip files' do
    @user = FactoryBot.create(:user, is_root: true, authentication_token: Devise.friendly_token, company: @company)
    record = create_record(@application)
    upload_attachment
    unique_id = json['id']
    record_id = json['record_id']

    attachment_role = FactoryBot.create(:role, API_attachment: 1, application: @application)
    @user1 = create_user({is_root: false, is_admin: false, :roles => [attachment_role], authentication_token: Devise.friendly_token, :company => @application.company})

    # list
    url = "/#{@company.key}/#{@application.key}/attachments_api/list/#{record_id}/#{auth_token(@user1)}.json"
    post "#{url}"
    assert_response :success

    # upload
    url = "/#{@company.key}/#{@application.key}/attachments_api/upload/#{record_id}/uploadapi.txt/#{auth_token(@user1)}.json"
    request_body = fixture_file_upload(test_file_path, :binary)
    post "#{url}", request_body, 'CONTENT_TYPE' => 'application/octet-stream'
    assert_response :success

    # download
    post "/#{@company.key}/#{@application.key}/attachments_api/download/#{record_id}/#{unique_id}/#{auth_token(@user1)}.json"
    assert_response :success

    # delete
    post "/#{@company.key}/#{@application.key}/attachments_api/delete/#{record_id}/#{unique_id}/#{auth_token(@user1)}.json"
    assert_response :success

    # download as zipped
    post "/#{@company.key}/#{@application.key}/attachments_api/downloadAsZip/#{record_id}/#{auth_token(@user1)}.json"
    assert_response :success

  end

  it 'should allow an admin user to upload, download and delete file' do
    attachment_role = FactoryBot.create(:role, {has_upload: 0, has_download: 0, has_delete_attachments: 0, application: @application})
    @user = create_user({is_root: false, is_admin: true, :roles => [attachment_role], authentication_token: Devise.friendly_token, :company => @application.company})

    # upload
    upload_attachment
    unique_id = json["id"]
    record_id = json["record_id"]

    # download
    post "/#{@company.key}/#{@application.key}/attachments_api/download/#{record_id}/#{unique_id}/#{auth_token(@user)}.json"
    assert_equal 'text/plain', response.content_type

    # delete
    post "/#{@company.key}/#{@application.key}/attachments_api/delete/#{record_id}/#{unique_id}/#{auth_token(@user)}.json"
    response_body = response.body
    assert response_body.include?('{"success":true}')
  end

  # File name

  it 'should allow dash line in file name during upload (CMOSD-1093)' do
    @user = FactoryBot.create(:user, is_root: true, authentication_token: Devise.friendly_token, company: @company)
    record = create_record(@application)

    url = "/#{@company.key}/#{@application.key}/attachments_api/upload/#{record.system.record_id}/upload-api.txt/#{auth_token(@user)}.json"
    request_body = fixture_file_upload(test_file_path)

    post "#{url}", request_body, 'CONTENT_TYPE' => 'application/octet-stream'

    expect(json['data_file_name']).to eq('upload-api.txt')
    expect(json['user']).to eq(@user.email)
    expect(json["id"]).to_not be_nil
  end

end