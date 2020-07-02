require 'rails_helper'
require 'factories'
require 'rack'

def create_users
  @user1 = FactoryBot.create(:user, authentication_token: Devise.friendly_token, :company => @company, :email => "user1@gdslink.com")
  @user2 = FactoryBot.create(:user, authentication_token: Devise.friendly_token, :company => @company, :email => "user2@gdslink.com")
end

def auth_token(user)
  CGI.escape "#{Base64.urlsafe_encode64(user.email)}|#{user.authentication_token}"
end

def create_user(args={})
  @user = FactoryBot.create(:user, args)
end

describe 'Delete User API', type: :request do

  before(:each) do
    @company = FactoryBot.create(:company)
    @application = FactoryBot.create(:application, company: @company)
    define_record_factory(nil, @application)
    create_users
  end

  it 'should delete user when authentication token used belongs to a root user (JSON)' do
    @root_user = FactoryBot.create(:user, authentication_token: Devise.friendly_token, :company => @company, :email => "root@domain.com")
    @root_user.is_root = true
    @root_user.save!
    request_body = <<~HEREDOC
      {
        "users": {
          "email": [
            "user1@gdslink.com",
            "user2@gdslink.com"
          ]
        }
      }
    HEREDOC
    delete "/users.json?auth_token=#{auth_token(@root_user)}", request_body, "CONTENT_TYPE" => "application/json"
    assert response.body.include?('"status":"2 user/s deleted"')
  end

  it 'should delete user when authentication token used belongs to a root user (XML)' do
    @root_user = FactoryBot.create(:user, authentication_token: Devise.friendly_token, :company => @company, :email => "root@domain.com")
    @root_user.is_root = true
    @root_user.save!
    request_body = <<~HEREDOC
      <users>
        <email>user1@gdslink.com</email>
        <email>user2@gdslink.com</email>
      </users>
    HEREDOC
    delete "/users.xml?auth_token=#{auth_token(@root_user)}", request_body, "CONTENT_TYPE" => "application/xml"
    assert response.body.include?('<status>2 user/s deleted</status>')
  end

  it 'should delete user when authentication token used belongs to a admin user (JSON)' do
    @admin_user = FactoryBot.create(:user, authentication_token: Devise.friendly_token, :company => @company, :email => "admin@domain.com")
    @admin_user.is_root = false
    @admin_user.is_admin = true
    @admin_user.save!
    request_body = <<~HEREDOC
      {
        "users": {
          "email": [
            "user1@gdslink.com",
            "user2@gdslink.com"
          ]
        }
      }
    HEREDOC
    delete "/users.json?auth_token=#{auth_token(@admin_user)}", request_body, "CONTENT_TYPE" => "application/json"
    assert response.body.include?('"status":"2 user/s deleted"')
  end

  it 'should delete user when authentication token used belongs to a admin user (XML)' do
    @admin_user = FactoryBot.create(:user, authentication_token: Devise.friendly_token, :company => @company, :email => "admin@domain.com")
    @admin_user.is_root = false
    @admin_user.is_admin = true
    @admin_user.save!
    request_body = <<~HEREDOC
      <users>
        <email>user1@gdslink.com</email>
        <email>user2@gdslink.com</email>
      </users>
    HEREDOC
    delete "/users.xml?auth_token=#{auth_token(@admin_user)}", request_body, "CONTENT_TYPE" => "application/xml"
    assert response.body.include?('<status>2 user/s deleted</status>')
  end

  it 'should not be able to delete user when authentication token used is invalid (JSON)' do
    request_body = <<~HEREDOC
      {
        "users": {
          "email": [
            "user1@gdslink.com",
            "user2@gdslink.com"
          ]
        }
      }
    HEREDOC
    delete "/users.json?auth_token=1234", request_body, "CONTENT_TYPE" => "application/json"
    assert response.body.include?('Invalid auth-token')
  end

  it 'should not be able to delete user when authentication token used is invalid (XML)' do
    request_body = <<~HEREDOC
      <users>
        <email>user1@domain.com</email>
        <email>user2@domain.com</email>
      </users>
    HEREDOC
    delete "/users.xml?auth_token=1234", request_body, "CONTENT_TYPE" => "application/xml"
    assert response.body.include?('Invalid auth-token')
  end

  it 'should not be able to delete user when authentication token used belongs to a common user (JSON)' do
    @common_user = create_user({is_root: false, is_admin: false, email: 'common@domain.com', authentication_token: Devise.friendly_token, :company => @application.company})
    request_body = <<~HEREDOC
      {
        "users": {
          "email": [
            "user1@gdslink.com",
            "user2@gdslink.com"
          ]
        }
      }
    HEREDOC
    delete "/users.json?auth_token=#{auth_token(@common_user)}", request_body, "CONTENT_TYPE" => "application/json"
    assert response.body.include?('You are not allowed to use this API')
  end

  it 'should not be able to delete user when authentication token used belongs to a common user (XML)' do
    @common_user = create_user({is_root: false, is_admin: false, email: 'common@domain.com', authentication_token: Devise.friendly_token, :company => @application.company})
    request_body = <<~HEREDOC
      <users>
        <email>user1@gdslink.com</email>
        <email>user2@gdslink.com</email>
      </users>
    HEREDOC
    delete "/users.xml?auth_token=#{auth_token(@common_user)}", request_body, "CONTENT_TYPE" => "application/xml"
    assert response.body.include?('You are not allowed to use this API')
  end

  it 'should show an error message when users indicated in request do not exist (JSON)' do
    @admin_user = FactoryBot.create(:user, authentication_token: Devise.friendly_token, :company => @company, :email => "admin@domain.com")
    @admin_user.is_root = false
    @admin_user.is_admin = true
    @admin_user.save!
    request_body = <<~HEREDOC
      {
        "users": {
          "email": [
            "invalid_user1@gdslink.com",
            "invalid_user2@gdslink.com"
          ]
        }
      }
    HEREDOC
    delete "/users.json?auth_token=#{auth_token(@admin_user)}", request_body, "CONTENT_TYPE" => "application/json"
    assert response.body.include?('"error":"User/s not found. Nothing to delete."')
  end

  it 'should show an error message when users indicated in request do not exist (XML)' do
    @admin_user = FactoryBot.create(:user, authentication_token: Devise.friendly_token, :company => @company, :email => "admin@domain.com")
    @admin_user.is_root = false
    @admin_user.is_admin = true
    @admin_user.save!
    request_body = <<~HEREDOC
      <users>
        <email>invalid_user1@gdslink.com</email>
        <email>invalid_user2@gdslink.com</email>
      </users>
    HEREDOC
    delete "/users.xml?auth_token=#{auth_token(@admin_user)}", request_body, "CONTENT_TYPE" => "application/xml"
    assert response.body.include?('User/s not found. Nothing to delete.')
  end

  it 'should show an error message when users is missing (JSON)' do
    @admin_user = FactoryBot.create(:user, authentication_token: Devise.friendly_token, :company => @company, :email => "admin@domain.com")
    @admin_user.is_root = false
    @admin_user.is_admin = true
    @admin_user.save!
    delete "/users.json?auth_token=#{auth_token(@admin_user)}", "CONTENT_TYPE" => "application/json"
    assert response.body.include?('No users specified')
  end

  it 'should show an error message when users is missing (XML)' do
    @admin_user = FactoryBot.create(:user, authentication_token: Devise.friendly_token, :company => @company, :email => "admin@domain.com")
    @admin_user.is_root = false
    @admin_user.is_admin = true
    @admin_user.save!
    delete "/users.xml?auth_token=#{auth_token(@admin_user)}", "CONTENT_TYPE" => "application/xml"
    assert response.body.include?('No users specified')
  end

  it 'should show an error message when emails is is blank or missing (JSON)' do
    @admin_user = FactoryBot.create(:user, authentication_token: Devise.friendly_token, :company => @company, :email => "admin@domain.com")
    @admin_user.is_root = false
    @admin_user.is_admin = true
    @admin_user.save!
    request_body = <<~HEREDOC
      {
        "users": { "tag": "user@gdslink.com" }
      }
    HEREDOC
    delete "/users.json?auth_token=#{auth_token(@admin_user)}", request_body, "CONTENT_TYPE" => "application/json"
    assert response.body.include?('No email/s specified')
  end

  it 'should show an error message when emails is is blank or missing (XML)' do
    @admin_user = FactoryBot.create(:user, authentication_token: Devise.friendly_token, :company => @company, :email => "admin@domain.com")
    @admin_user.is_root = false
    @admin_user.is_admin = true
    @admin_user.save!
    request_body = <<~HEREDOC
      <users>
        <tag>user@gdslink.com</tag>
      </users>
    HEREDOC
    delete "/users.xml?auth_token=#{auth_token(@admin_user)}", request_body, "CONTENT_TYPE" => "application/xml"
    assert response.body.include?('No email/s specified')
  end

  # API Permission

  it 'should not delete user when when common user\'s role has no Role API permission (XML)' do
    @role_api = FactoryBot.create :role, API_role: false, application: @application
    @common_user = FactoryBot.create(:user, authentication_token: Devise.friendly_token, :company => @company, :email => "admin@gdslink.com", :is_root => false, :is_admin => false, :role_ids => [@role_api.id])
    request_body = <<~HEREDOC
      <users>
        <email>user1@gdslink.com</email>
        <email>user2@gdslink.com</email>
      </users>
    HEREDOC
    delete "/users.xml?auth_token=#{auth_token(@root_user)}", request_body, "CONTENT_TYPE" => "application/xml"
    p response.body
    assert response.body.include?('You are not allowed to use this API')
  end

  it 'should not delete user when when common user\'s role has no Role API permission (JSON)' do
    @role_api = FactoryBot.create :role, API_role: false, application: @application
    @common_user = FactoryBot.create(:user, authentication_token: Devise.friendly_token, :company => @company, :email => "admin@gdslink.com", :is_root => false, :is_admin => false, :role_ids => [@role_api.id])
    request_body = <<~HEREDOC
      {
        "users": {
          "email": [
            "user1@gdslink.com",
            "user2@gdslink.com"
          ]
        }
      }
    HEREDOC
    delete "/users.json?auth_token=#{auth_token(@common_user)}", request_body, "CONTENT_TYPE" => "application/json"
    p response.body
    assert response.body.include?('You are not allowed to use this API')
  end

  it 'should delete user when when common user\'s role has Role API permission (XML)' do
    @role_api = FactoryBot.create :role, API_role: true, application: @application
    @common_user = FactoryBot.create(:user, authentication_token: Devise.friendly_token, :company => @company, :email => "admin@gdslink.com", :is_root => false, :is_admin => false, :role_ids => [@role_api.id])
    request_body = <<~HEREDOC
      <users>
        <email>user1@gdslink.com</email>
        <email>user2@gdslink.com</email>
      </users>
    HEREDOC
    delete "/users.xml?auth_token=#{auth_token(@root_user)}", request_body, "CONTENT_TYPE" => "application/xml"
    p response.body
    assert response.body.include?('<status>2 user/s deleted</status>')
  end

  it 'should delete user when when common user\'s role has Role API permission (JSON)' do
    @role_api = FactoryBot.create :role, API_role: true, application: @application
    @common_user = FactoryBot.create(:user, authentication_token: Devise.friendly_token, :company => @company, :email => "admin@gdslink.com", :is_root => false, :is_admin => false, :role_ids => [@role_api.id])
    request_body = <<~HEREDOC
      {
        "users": {
          "email": [
            "user1@gdslink.com",
            "user2@gdslink.com"
          ]
        }
      }
    HEREDOC
    delete "/users.json?auth_token=#{auth_token(@common_user)}", request_body, "CONTENT_TYPE" => "application/json"
    p response.body
    assert response.body.include?('"status":"2 user/s deleted"')
  end

end