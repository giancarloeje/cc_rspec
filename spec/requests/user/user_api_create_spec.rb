require 'rails_helper'
require 'factories'
require 'rack'

describe 'User API', type: :request do

  before(:each) do |example|
    p "Start of Test: #{example.description}"
    @company = FactoryBot.create(:company)
    @application = FactoryBot.create(:application, company: @company)
    @role = FactoryBot.create :role, application: @application
    define_record_factory(nil, @application)
    @user = FactoryBot.create(:user, authentication_token: Devise.friendly_token, :company => @company)
    @auth_token = CGI.escape "#{Base64.urlsafe_encode64(@user.email)}|#{@user.authentication_token}"
    @user_property = FactoryBot.create :user_property, company: @company
  end

  after :each do |example|
    p "End of Test: #{example.description}"
  end

  # validity test
  it 'should create user with valid email and company key (XML format)' do
    email = "test@gdslink.com"
    request_body = <<~HEREDOC
      <user>
        <email>#{email}</email>
        <company>#{@company.key}</company>
      </user>
    HEREDOC
    post("/users.xml?auth_token=#{@auth_token}", request_body, {"CONTENT_TYPE": "text/xml"})
    p response.body
    assert response.body.include?("<email>#{email}</email>")
  end

  it 'should create user with valid email and company key (JSON format)' do
    email = "test@gdslink.com"
    request_body = <<~HEREDOC
      {  
          "user": {
              "company": "#{@company.key}",
              "email": "#{email}"
          }
      }
    HEREDOC
    post("/users.json?auth_token=#{@auth_token}", request_body, {"CONTENT_TYPE": "application/json"})
    p response.body
    assert response.body.include?('"email":"'+email+'"')
  end

  it 'should not be able to create user with invalid company key (XML format)' do
    email = "test@gdslink.com"
    company_key = "invalid_key"
    request_body = <<~HEREDOC
      <user>
        <email>#{email}</email>
        <company>#{company_key}</company>
      </user>
    HEREDOC
    post("/users.xml?auth_token=#{@auth_token}", request_body, {"CONTENT_TYPE": "text/xml"})
    p response.body
    assert response.body.include?("Unknown company key: #{company_key}")
  end

  it 'should not be able to create user with invalid company key (JSON format)' do
    email = "test@gdslink.com"
    company_key = "invalid_key"
    request_body = <<~HEREDOC
      {  
          "user": {
              "company": "#{company_key}",
              "email": "#{email}"
          }
      }
    HEREDOC
    post("/users.json?auth_token=#{@auth_token}", request_body, {"CONTENT_TYPE": "application/json"})
    p response.body
    assert response.body.include?("Unknown company key: #{company_key}")
  end

  it 'should not be able to create user with invalid email (XML format)' do
    email = "invalid_email"
    request_body = <<~HEREDOC
      <user>
        <email>#{email}</email>
        <company>#{@company.key}</company>
      </user>
    HEREDOC
    post("/users.xml?auth_token=#{@auth_token}", request_body, {"CONTENT_TYPE": "text/xml"})
    p response.body
    assert response.body.include?("E-mail is invalid")
  end

  it 'should not be able to create user with invalid email (JSON format)' do
    email = "invalid_email"
    request_body = <<~HEREDOC
      {  
          "user": {
              "company": "#{@company.key}",
              "email": "#{email}"
          }
      }
    HEREDOC
    post("/users.json?auth_token=#{@auth_token}", request_body, {"CONTENT_TYPE": "application/json"})
    p response.body
    assert response.body.include?("is invalid")
  end

  it 'should not be able to create user with no auth token (XML format)' do
    email = "test@gdslink.com"
    request_body = <<~HEREDOC
      <user>
        <email>#{email}</email>
        <company>#{@company.key}</company>
      </user>
    HEREDOC
    post("/users.xml?auth_token=", request_body, {"CONTENT_TYPE": "text/xml"})
    p response.body
    assert response.body.include?("Invalid auth-token")
  end

  it 'should not be able to create user with no auth token (JSON format)' do
    email = "test@gdslink.com"
    request_body = <<~HEREDOC
      {  
          "user": {
              "company": "#{@company.key}",
              "email": "#{email}"
          }
      }
    HEREDOC
    post("/users.json?auth_token=", request_body, {"CONTENT_TYPE": "application/json"})
    p response.body
    assert response.body.include?("Invalid auth-token")
  end

  it 'should not be able to create user with invalid auth token (XML format)' do
    email = "test@gdslink.com"
    auth_token = "invalid_auth_token"
    request_body = <<~HEREDOC
      <user>
        <email>#{email}</email>
        <company>#{@company.key}</company>
      </user>
    HEREDOC
    post("/users.xml?auth_token=#{auth_token}", request_body, {"CONTENT_TYPE": "text/xml"})
    p response.body
    assert response.body.include?("Invalid auth-token")
  end

  it 'should not be able to create user with invalid auth token (JSON format)' do
    email = "test@gdslink.com"
    auth_token = "invalid_auth_token"
    request_body = <<~HEREDOC
      {  
          "user": {
              "company": "#{@company.key}",
              "email": "#{email}"
          }
      }
    HEREDOC
    post("/users.json?auth_token=#{auth_token}", request_body, {"CONTENT_TYPE": "application/json"})
    p response.body
    assert response.body.include?("Invalid auth-token")
  end

  it 'should not be able to create user with auth token belonging to a common user (XML format)' do
    user2 = FactoryBot.create(:user, authentication_token: Devise.friendly_token, :company => @company, :email => "test2@gdslink.com")
    user2.is_root = false
    user2.is_admin = false
    user2.save!
    auth_token = CGI.escape "#{Base64.urlsafe_encode64(user2.email)}|#{user2.authentication_token}"
    email = "test@gdslink.com"
    request_body = <<~HEREDOC
      <user>
        <email>#{email}</email>
        <company>#{@company.key}</company>
      </user>
    HEREDOC
    post("/users.xml?auth_token=#{auth_token}", request_body, {"CONTENT_TYPE": "text/xml"})
    p response.body
    assert response.body.include?("You are not allowed to use this API")
  end

  it 'should not be able to create user with auth token belonging to a common user (JSON format)' do
    user2 = FactoryBot.create(:user, authentication_token: Devise.friendly_token, :company => @company, :email => "test2@gdslink.com")
    user2.is_root = false
    user2.is_admin = false
    user2.save!
    auth_token = CGI.escape "#{Base64.urlsafe_encode64(user2.email)}|#{user2.authentication_token}"
    email = "test@gdslink.com"
    request_body = <<~HEREDOC
      {  
          "user": {
              "company": "#{@company.key}",
              "email": "#{email}"
          }
      }
    HEREDOC
    post("/users.json?auth_token=#{auth_token}", request_body, {"CONTENT_TYPE": "application/json"})
    p response.body
    assert response.body.include?("You are not allowed to use this API")
  end

  it 'should be able to create user with auth token belonging to a root user (XML format)' do
    @user.is_root = true
    @user.save!
    email = "test@gdslink.com"
    request_body = <<~HEREDOC
      <user>
        <email>#{email}</email>
        <company>#{@company.key}</company>
      </user>
    HEREDOC
    post("/users.xml?auth_token=#{@auth_token}", request_body, {"CONTENT_TYPE": "text/xml"})
    p response.body
    assert response.body.include?("<email>#{email}</email>")
  end

  it 'should be able to create user with auth token belonging to a root user (JSON format)' do
    @user.is_root = true
    @user.save!
    email = "test@gdslink.com"
    request_body = <<~HEREDOC
      {  
          "user": {
              "company": "#{@company.key}",
              "email": "#{email}"
          }
      }
    HEREDOC
    post("/users.json?auth_token=#{@auth_token}", request_body, {"CONTENT_TYPE": "application/json"})
    p response.body
    assert response.body.include?('"email":"'+email+'"')
  end

  it 'should be able to create user with auth token belonging to an admin user (XML format)' do
    @user.is_root = false
    @user.is_admin = true
    @user.save!
    email = "test@gdslink.com"
    request_body = <<~HEREDOC
      <user>
        <email>#{email}</email>
        <company>#{@company.key}</company>
      </user>
    HEREDOC
    post("/users.xml?auth_token=#{@auth_token}", request_body, {"CONTENT_TYPE": "text/xml"})
    p response.body
    assert response.body.include?("<email>#{email}</email>")
  end

  it 'should be able to create user with auth token belonging to an admin user (JSON format)' do
    @user.is_root = false
    @user.is_admin = true
    email = "test@gdslink.com"
    request_body = <<~HEREDOC
      {  
          "user": {
              "company": "#{@company.key}",
              "email": "#{email}"
          }
      }
    HEREDOC
    post("/users.json?auth_token=#{@auth_token}", request_body, {"CONTENT_TYPE": "application/json"})
    p response.body
    assert response.body.include?('"email":"'+email+'"')
  end

  it 'should not be able to create a user if email is already taken and force create is false (XML format)' do
    email = "test@gdslink.com"
    request_body = <<~HEREDOC
      <user>
        <email>#{email}</email>
        <company>#{@company.key}</company>
        <force_create>0</force_create>
      </user>
    HEREDOC
    post("/users.xml?auth_token=#{@auth_token}", request_body, {"CONTENT_TYPE": "text/xml"})
    post("/users.xml?auth_token=#{@auth_token}", request_body, {"CONTENT_TYPE": "text/xml"})
    p response.body
    assert response.body.include?("E-mail has already been taken")
  end

  it 'should not be able to create a user if email is already taken and force create is false (JSON format)' do
    email = "test@gdslink.com"
    request_body = <<~HEREDOC
      {  
          "user": {
              "company": "#{@company.key}",
              "email": "#{email}"
          }
      }
    HEREDOC
    post("/users.json?auth_token=#{@auth_token}", request_body, {"CONTENT_TYPE": "application/json"})
    post("/users.json?auth_token=#{@auth_token}", request_body, {"CONTENT_TYPE": "application/json"})
    p response.body
    assert response.body.include?("has already been taken")
  end

  it 'should be able to create a user if force_create is set to true (XML format)' do
    email = "test@gdslink.com"
    request_body = <<~HEREDOC
      <user>
        <email>#{email}</email>
        <company>#{@company.key}</company>
        <force_create>1</force_create>
      </user>
    HEREDOC
    post("/users.xml?auth_token=#{@auth_token}", request_body, {"CONTENT_TYPE": "text/xml"})
    post("/users.xml?auth_token=#{@auth_token}", request_body, {"CONTENT_TYPE": "text/xml"})
    p response.body
    assert response.body.include?("<email>#{email}</email>")
  end

  it 'should be able to create a user if force_create is set to true (JSON format)' do
    email = "test@gdslink.com"
    request_body = <<~HEREDOC
      {  
          "user": {
              "company": "#{@company.key}",
              "email": "#{email}",
              "force_create": "1"
          }
      }
    HEREDOC
    post("/users.json?auth_token=#{@auth_token}", request_body, {"CONTENT_TYPE": "application/json"})
    post("/users.json?auth_token=#{@auth_token}", request_body, {"CONTENT_TYPE": "application/json"})
    p response.body
    assert response.body.include?('"email":"'+email+'"')
  end

  it 'should return an error if role indicated does not exist (XML format)' do
    email = "test@gdslink.com"
    role = "invalid_role"
    request_body = <<~HEREDOC
      <user>
        <email>#{email}</email>
        <company>#{@company.key}</company>
        <force_create>1</force_create>
        <roles>
            <role>
                <application>#{@application.key}</application>
                <name>#{role}</name>
            </role>
        </roles>
      </user>
    HEREDOC
    post("/users.xml?auth_token=#{@auth_token}", request_body, {"CONTENT_TYPE": "text/xml"})
    p response.body
    assert response.body.include?("Unknown role: #{role} for application #{@application.key}")
  end

  it 'should return an error if role indicated does not exist (JSON format)' do
    email = "test@gdslink.com"
    role = "invalid_role"
    request_body = <<~HEREDOC
      {  
          "user": {
              "company": "#{@company.key}",
              "email": "#{email}",
              "force_create": "1",
              "roles": {
                  "role": [{
                      "application": "#{@application.key}",
                      "name": "#{role}"
                  }]
              }
          }
      }
    HEREDOC
    post("/users.json?auth_token=#{@auth_token}", request_body, {"CONTENT_TYPE": "application/json"})
    p response.body
    assert response.body.include?("Unknown role: #{role} for application #{@application.key}")
  end

  it 'should create user if role indicated exist (XML format)' do
    email = "test@gdslink.com"
    request_body = <<~HEREDOC
      <user>
        <email>#{email}</email>
        <company>#{@company.key}</company>
        <roles>
            <role>
                <application>#{@application.key}</application>
                <name>#{@role.name}</name>
            </role>
        </roles>
      </user>
    HEREDOC
    post("/users.xml?auth_token=#{@auth_token}", request_body, {"CONTENT_TYPE": "text/xml"})
    p response.body
    assert response.body.include?("<name>#{@role.name}</name>")
  end

  it 'should create usr if role indicated exist (JSON format)' do
    email = "test@gdslink.com"
    request_body = <<~HEREDOC
      {  
          "user": {
              "company": "#{@company.key}",
              "email": "#{email}",
              "roles": {
                  "role": [{
                      "application": "#{@application.key}",
                      "name": "#{@role.name}"
                  }]
              }
          }
      }
    HEREDOC
    post("/users.json?auth_token=#{@auth_token}", request_body, {"CONTENT_TYPE": "application/json"})
    p response.body
    assert response.body.include?('"name":"'+@role.name+'"')
  end

  it 'should return an error if user property indicated does not exist (XML format)' do
    email = "test@gdslink.com"
    user_property_key = "invalid_user_property"
    request_body = <<~HEREDOC
      <user>
        <email>#{email}</email>
        <company>#{@company.key}</company>
        <user_properties>
            <#{user_property_key}>Property 1</#{user_property_key}>
        </user_properties>
      </user>
    HEREDOC
    post("/users.xml?auth_token=#{@auth_token}", request_body, {"CONTENT_TYPE": "text/xml"})
    p response.body
    assert response.body.include?("Unknown user property: #{user_property_key} for company #{@company.key}")
  end

  it 'should return an error if user property indicated does not exist (JSON format)' do
    email = "test@gdslink.com"
    user_property_key = "invalid_user_property"
    request_body = <<~HEREDOC
      {  
          "user": {
              "company": "#{@company.key}",
              "email": "#{email}",
              "user_properties": {
                "#{user_property_key}": "Property 1"
              }
          }
      }
    HEREDOC
    post("/users.json?auth_token=#{@auth_token}", request_body, {"CONTENT_TYPE": "application/json"})
    p response.body
    assert response.body.include?("Unknown user property: #{user_property_key} for company #{@company.key}")
  end

  it 'should create user with valid user property (XML format)' do
    email = "test@gdslink.com"
    user_property_value = "User Property"
    request_body = <<~HEREDOC
      <user>
        <email>#{email}</email>
        <company>#{@company.key}</company>
        <user_properties>
            <#{@user_property.key}>#{user_property_value}</#{@user_property.key}>
        </user_properties>
      </user>
    HEREDOC
    post("/users.xml?auth_token=#{@auth_token}", request_body, {"CONTENT_TYPE": "text/xml"})
    p response.body
    assert response.body.include?("<#{@user_property.key}>#{user_property_value}</#{@user_property.key}>")
  end

  it 'should create user with valid user property (JSON format)' do
    email = "test@gdslink.com"
    user_property_value = "User Property"
    request_body = <<~HEREDOC
      {  
          "user": {
              "company": "#{@company.key}",
              "email": "#{email}",
              "user_properties": {
                "#{@user_property.key}": "#{user_property_value}"
              }
          }
      }
    HEREDOC
    post("/users.json?auth_token=#{@auth_token}", request_body, {"CONTENT_TYPE": "application/json"})
    p response.body
    assert response.body.include?('"'+@user_property.key+'":"'+user_property_value+'"')
  end

  # API Permission

  it 'should show an error message when common user\'s role has no User API permission (XML)' do
    @role.API_user = false
    @role.save!
    @user.is_root = false
    @user.is_admin = false
    @user.role_ids = [@role.id]
    @user.save!
    email = "test@gdslink.com"
    request_body = <<~HEREDOC
      <user>
        <email>#{email}</email>
        <company>#{@company.key}</company>
      </user>
    HEREDOC
    post("/users.xml?auth_token=#{@auth_token}", request_body, {"CONTENT_TYPE": "text/xml"})
    p response.body
    assert response.body.include?('You are not allowed to use this API')
  end

  it 'should show an error message when common user\'s role has no User API permission (JSON)' do
    @role.API_user = false
    @role.save!
    @user.is_root = false
    @user.is_admin = false
    @user.role_ids = [@role.id]
    @user.save!
    email = "test@gdslink.com"
    request_body = <<~HEREDOC
      {  
          "user": {
              "company": "#{@company.key}",
              "email": "#{email}"
          }
      }
    HEREDOC
    post("/users.json?auth_token=#{@auth_token}", request_body, {"CONTENT_TYPE": "application/json"})
    p response.body
    assert response.body.include?('You are not allowed to use this API')
  end

  it 'should create user when common user\'s role has User API permission (XML format)' do
    @role.API_user = true
    @role.save!
    @user.is_root = false
    @user.is_admin = false
    @user.role_ids = [@role.id]
    @user.save!
    email = "test@gdslink.com"
    request_body = <<~HEREDOC
      <user>
        <email>#{email}</email>
        <company>#{@company.key}</company>
      </user>
    HEREDOC
    post("/users.xml?auth_token=#{@auth_token}", request_body, {"CONTENT_TYPE": "text/xml"})
    p response.body
    assert response.body.include?("<email>#{email}</email>")
  end

  it 'should create user when common user\'s role has User API permission (JSON format)' do
    @role.API_user = true
    @role.save!
    @user.is_root = false
    @user.is_admin = false
    @user.role_ids = [@role.id]
    @user.save!
    email = "test@gdslink.com"
    request_body = <<~HEREDOC
      {  
          "user": {
              "company": "#{@company.key}",
              "email": "#{email}"
          }
      }
    HEREDOC
    post("/users.json?auth_token=#{@auth_token}", request_body, {"CONTENT_TYPE": "application/json"})
    p response.body
    assert response.body.include?('"email":"'+email+'"')
  end

end