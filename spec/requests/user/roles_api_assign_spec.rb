require 'rails_helper'
require 'factories'
require 'rack'

def set_up_assign
  @user1 = FactoryBot.create(:user, authentication_token: Devise.friendly_token, :company => @company, :email => "user1@gdslink.com")
  @user2 = FactoryBot.create(:user, authentication_token: Devise.friendly_token, :company => @company, :email => "user2@gdslink.com")
  @role1 = FactoryBot.create(:role, :application => @application)
  @role2 = FactoryBot.create(:role, :application => @application)
  @role3 = FactoryBot.create(:role, :application => @application)
end

def auth_token(user)
  CGI.escape "#{Base64.urlsafe_encode64(user.email)}|#{user.authentication_token}"
end

describe 'Assign User API', type: :request  do

  before(:each) do |example|
    p "Start of Test: #{example.description}"
    @company = FactoryBot.create(:company)
    @application = FactoryBot.create(:application, company: @company)
    define_record_factory(nil, @application)
    set_up_assign
  end

  after :each do |example|
    p "End of Test: #{example.description}"
  end

  it 'should assign roles to user when authentication token used belongs to a root user (JSON)' do
    @root_user = FactoryBot.create(:user, authentication_token: Devise.friendly_token, :company => @company, :email => "root@gdslink.com")
    @root_user.is_root = true
    @root_user.save!
    url = "/#{@company.key}/#{@application.key}/roles/assign.json?auth_token=#{auth_token(@root_user)}"
    post url, :roles => [@role2.name, @role3.name], :users => [@user1.email, @user2.email]
    p response.body
    assert response.body.include?('"status":"2 user/s updated"')
  end

  it 'should assign roles to user when authentication token used belongs to a root user (XML)' do
    @root_user = FactoryBot.create(:user, authentication_token: Devise.friendly_token, :company => @company, :email => "root@gdslink.com")
    @root_user.is_root = true
    @root_user.save!
    url = "/#{@company.key}/#{@application.key}/roles/assign.xml?auth_token=#{auth_token(@root_user)}"
    post url, :roles => [@role2.name, @role3.name], :users => [@user1.email, @user2.email]
    p response.body
    assert response.body.include?('<status>2 user/s updated</status>')
  end

  it 'should assign roles to user when authentication token used belongs to an admin user (JSON)' do
    @admin_user = FactoryBot.create(:user, authentication_token: Devise.friendly_token, :company => @company, :email => "admin@gdslink.com")
    @admin_user.is_root = false
    @admin_user.is_admin = true
    @admin_user.save!
    url = "/#{@company.key}/#{@application.key}/roles/assign.json?auth_token=#{auth_token(@admin_user)}"
    post url, :roles => [@role2.name, @role3.name], :users => [@user1.email, @user2.email]
    p response.body
    assert response.body.include?('"status":"2 user/s updated"')
  end

  it 'should assign roles to user when authentication token used belongs to an admin user (XML)' do
    @admin_user = FactoryBot.create(:user, authentication_token: Devise.friendly_token, :company => @company, :email => "admin@gdslink.com")
    @admin_user.is_root = false
    @admin_user.is_admin = true
    @admin_user.save!
    url = "/#{@company.key}/#{@application.key}/roles/assign.xml?auth_token=#{auth_token(@admin_user)}"
    post url, :roles => [@role2.name, @role3.name], :users => [@user1.email, @user2.email]
    p response.body
    assert response.body.include?('<status>2 user/s updated</status>')
  end

  it 'should not be able to assign roles to user when authentication token used belongs to a common user (JSON)' do
    @common_user = FactoryBot.create(:user, authentication_token: Devise.friendly_token, :company => @company, :email => "common@gdslink.com")
    @common_user.is_root = false
    @common_user.is_admin = false
    @common_user.save!
    url = "/#{@company.key}/#{@application.key}/roles/assign.json?auth_token=#{auth_token(@common_user)}"
    post url, :roles => [@role2.name, @role3.name], :users => [@user1.email, @user2.email]
    p response.body
    assert response.body.include?("You are not allowed to use this API")
  end

  it 'should not be able to reassign roles to user when authentication token used belongs to a common user (XML)' do
    @common_user = FactoryBot.create(:user, authentication_token: Devise.friendly_token, :company => @company, :email => "admin@gdslink.com")
    @common_user.is_root = false
    @common_user.is_admin = false
    @common_user.save!
    url = "/#{@company.key}/#{@application.key}/roles/assign.json?auth_token=#{auth_token(@common_user)}"
    post url, :roles => [@role2.name, @role3.name], :users => [@user1.email, @user2.email]
    p response.body
    assert response.body.include?("You are not allowed to use this API")
  end

  it 'should not be able to assign roles to user when authentication token used is invalid (JSON)' do
    url = "/#{@company.key}/#{@application.key}/roles/assign.json?auth_token=invalid"
    post url, :roles => [@role2.name, @role3.name], :users => [@user1.email, @user2.email]
    p response.body
    assert response.body.include?("Invalid auth-token")
  end

  it 'should not be able to assign roles to user when authentication token used is invalid (XML)' do
    url = "/#{@company.key}/#{@application.key}/roles/assign.json?auth_token=invalid"
    post url, :roles => [@role2.name, @role3.name], :users => [@user1.email, @user2.email]
    p response.body
    assert response.body.include?("Invalid auth-token")
  end

  it 'should show an error message when request passed has no roles parameter specified (JSON)' do
    @admin_user = FactoryBot.create(:user, authentication_token: Devise.friendly_token, :company => @company, :email => "admin@gdslink.com")
    @admin_user.is_root = false
    @admin_user.is_admin = true
    @admin_user.save!
    url = "/#{@company.key}/#{@application.key}/roles/assign.json?auth_token=#{auth_token(@admin_user)}"
    post url, :users => [@user1.email, @user2.email]
    p response.body
    assert response.body.include?('No roles parameter specified')
  end

  it 'should show an error message when request passed has no roles parameter specified (XML)' do
    @admin_user = FactoryBot.create(:user, authentication_token: Devise.friendly_token, :company => @company, :email => "admin@gdslink.com")
    @admin_user.is_root = false
    @admin_user.is_admin = true
    @admin_user.save!
    url = "/#{@company.key}/#{@application.key}/roles/assign.json?auth_token=#{auth_token(@admin_user)}"
    post url, :users => [@user1.email, @user2.email]
    p response.body
    assert response.body.include?('No roles parameter specified')
  end

  it 'should show an error message when roles specified do not exist (JSON)' do
    @admin_user = FactoryBot.create(:user, authentication_token: Devise.friendly_token, :company => @company, :email => "admin@gdslink.com")
    @admin_user.is_root = false
    @admin_user.is_admin = true
    @admin_user.save!
    url = "/#{@company.key}/#{@application.key}/roles/assign.json?auth_token=#{auth_token(@admin_user)}"
    post url, :roles => %w[no_role1 no_role2], :users => [@user1.email, @user2.email]
    p response.body
    assert response.body.include?('no_role1, no_role2 role/s not found in '+@application.key+' application')
  end

  it 'should show an error message when roles specified do not exist (XML)' do
    @admin_user = FactoryBot.create(:user, authentication_token: Devise.friendly_token, :company => @company, :email => "admin@gdslink.com")
    @admin_user.is_root = false
    @admin_user.is_admin = true
    @admin_user.save!
    url = "/#{@company.key}/#{@application.key}/roles/assign.json?auth_token=#{auth_token(@admin_user)}"
    post url, :roles => %w[no_role1 no_role2], :users => [@user1.email, @user2.email]
    p response.body
    assert response.body.include?('no_role1, no_role2 role/s not found in '+@application.key+' application')
  end

  it 'should show an error message when no users parameter is specified (JSON)' do
    @admin_user = FactoryBot.create(:user, authentication_token: Devise.friendly_token, :company => @company, :email => "admin@gdslink.com")
    @admin_user.is_root = false
    @admin_user.is_admin = true
    @admin_user.save!
    url = "/#{@company.key}/#{@application.key}/roles/assign.json?auth_token=#{auth_token(@admin_user)}"
    post url, :roles => [@role1.name]
    p response.body
    assert response.body.include?('No users parameter specified')
  end

  it 'should show an error message when no users parameter is specified (XML)' do
    @admin_user = FactoryBot.create(:user, authentication_token: Devise.friendly_token, :company => @company, :email => "admin@gdslink.com")
    @admin_user.is_root = false
    @admin_user.is_admin = true
    @admin_user.save!
    url = "/#{@company.key}/#{@application.key}/roles/assign.json?auth_token=#{auth_token(@admin_user)}"
    post url, :roles => [@role1.name]
    p response.body
    assert response.body.include?('No users parameter specified')
  end

  it 'should show an error message when users specified in request do not exist (JSON)' do
    @admin_user = FactoryBot.create(:user, authentication_token: Devise.friendly_token, :company => @company, :email => "admin@gdslink.com")
    @admin_user.is_root = false
    @admin_user.is_admin = true
    @admin_user.save!
    url = "/#{@company.key}/#{@application.key}/roles/assign.json?auth_token=#{auth_token(@admin_user)}"
    post url, :roles => [@role1.name], :users => %w[no_user1@gdslink.com no_user2@gdslink.com]
    p response.body
    assert response.body.include?('no_user1@gdslink.com, no_user2@gdslink.com user/s not found in '+@company.key+' company')
  end

  it 'should show an error message when users specified in request do no exist (XML)' do
    @admin_user = FactoryBot.create(:user, authentication_token: Devise.friendly_token, :company => @company, :email => "admin@gdslink.com")
    @admin_user.is_root = false
    @admin_user.is_admin = true
    @admin_user.save!
    url = "/#{@company.key}/#{@application.key}/roles/assign.json?auth_token=#{auth_token(@admin_user)}"
    post url, :roles => [@role1.name], :users => %w[no_user1@gdslink.com no_user2@gdslink.com]
    p response.body
    assert response.body.include?('no_user1@gdslink.com, no_user2@gdslink.com user/s not found in '+@company.key+' company')
  end

  # API Permission

  it 'should show an error message when common user\'s role has no Role API permission (XML)' do
    @role_api = FactoryBot.create :role, API_role: false, application: @application
    @common_user = FactoryBot.create(:user, authentication_token: Devise.friendly_token, :company => @company, :email => "admin@gdslink.com", :is_root => false, :is_admin => false, :role_ids => [@role_api.id])
    url = "/#{@company.key}/#{@application.key}/roles/assign.xml?auth_token=#{auth_token(@common_user)}"
    post url, :roles => [@role2.name, @role3.name], :users => [@user1.email, @user2.email]
    p response.body
    assert response.body.include?('You are not allowed to use this API')
  end

  it 'should show an error message when common user\'s role has no Role API permission (JSON)' do
    @role_api = FactoryBot.create :role, API_role: false, application: @application
    @common_user = FactoryBot.create(:user, authentication_token: Devise.friendly_token, :company => @company, :email => "admin@gdslink.com", :is_root => false, :is_admin => false, :role_ids => [@role_api.id])
    url = "/#{@company.key}/#{@application.key}/roles/assign.json?auth_token=#{auth_token(@common_user)}"
    post url, :roles => [@role2.name, @role3.name], :users => [@user1.email, @user2.email]
    p response.body
    assert response.body.include?('You are not allowed to use this API')
  end

  it 'should assign roles to user when common user\'s role has Role API permission (XML)' do
    @role_api = FactoryBot.create :role, API_role: true, application: @application
    @common_user = FactoryBot.create(:user, authentication_token: Devise.friendly_token, :company => @company, :email => "admin@gdslink.com", :is_root => false, :is_admin => false, :role_ids => [@role_api.id])
    url = "/#{@company.key}/#{@application.key}/roles/assign.xml?auth_token=#{auth_token(@common_user)}"
    post url, :roles => [@role2.name, @role3.name], :users => [@user1.email, @user2.email]
    p response.body
    assert response.body.include?('<status>2 user/s updated</status>')
  end

  it 'should assign roles to user when common user\'s role has Role API permission (JSON)' do
    @role_api = FactoryBot.create :role, API_role: true, application: @application
    @common_user = FactoryBot.create(:user, authentication_token: Devise.friendly_token, :company => @company, :email => "admin@gdslink.com", :is_root => false, :is_admin => false, :role_ids => [@role_api.id])
    url = "/#{@company.key}/#{@application.key}/roles/assign.json?auth_token=#{auth_token(@common_user)}"
    post url, :roles => [@role2.name, @role3.name], :users => [@user1.email, @user2.email]
    p response.body
    assert response.body.include?('"status":"2 user/s updated"')
  end


end