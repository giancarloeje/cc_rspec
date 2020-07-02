require 'spec_helper'
require 'factories'
require 'rack'

def create_user(args={})
  @user = FactoryBot.create(:user, args)
end

def auth_token(user)
  CGI.escape "#{Base64.urlsafe_encode64(user.email)}|#{user.authentication_token}"
end

def set_up_release
  @role1 = FactoryBot.create(:role, :application => @application)
  @role2 = FactoryBot.create(:role, :application => @application)
  @user1 = create_user({is_root: false, is_admin: false, :roles => [@role1], email: 'qatest@gdslink.com', :company => @application.company})
  @user2 = create_user({is_root: false, is_admin: false, :roles => [@role2], email: 'qatest2@gdslink.com', :company => @application.company})
end

describe 'Release Roles API', type: :request do

  before(:each) do |example|
    p "Start of Test: #{example.description}"
    @company = FactoryBot.create(:company)
    @application = FactoryBot.create(:application, company: @company)
    define_record_factory(nil, @application)
    set_up_release
  end

  after :each do |example|
    p "End of Test: #{example.description}"
  end

  it 'should release roles from users when authentication token used belongs to a root user (JSON)' do
    @root_user = create_user({is_root: true, is_admin: false, email: 'root@gdslink.com', authentication_token: Devise.friendly_token, :company => @application.company})

    url = "/#{@company.key}/#{@application.key}/roles/release.json?auth_token=#{auth_token(@root_user)}"
    post url, :roles => [@role1.name, @role2.name], :users => [@user1.email, @user2.email]
    p response.body
    assert response.body.include?('2 user/s updated')
  end

  it 'should release roles from users when authentication token used belongs to a root user (XML)' do
    @root_user = create_user({is_root: true, is_admin: false, email: 'root@gdslink.com', authentication_token: Devise.friendly_token, :company => @application.company})

    url = "/#{@company.key}/#{@application.key}/roles/release.xml?auth_token=#{auth_token(@root_user)}"
    post url, :roles => [@role1.name, @role2.name], :users => [@user1.email, @user2.email]
    p response.body
    assert response.body.include?('<status>2 user/s updated</status>')
  end

  it 'should release roles from users when authentication token used belongs to an admin user (JSON)' do
    @admin_user = create_user({is_root: false, is_admin: true, email: 'admin@gdslink.com', authentication_token: Devise.friendly_token, :company => @application.company})

    url = "/#{@company.key}/#{@application.key}/roles/release.json?auth_token=#{auth_token(@admin_user)}"
    post url, :roles => [@role1.name, @role2.name], :users => [@user1.email, @user2.email]
    p response.body
    assert response.body.include?('"status":"2 user/s updated"')
  end

  it 'should release roles from users when authentication token used belongs to an admin user (XML)' do
    @admin_user = create_user({is_root: false, is_admin: true, email: 'admin@gdslink.com', authentication_token: Devise.friendly_token, :company => @application.company})

    url = "/#{@company.key}/#{@application.key}/roles/release.xml?auth_token=#{auth_token(@admin_user)}"
    post url, :roles => [@role1.name, @role2.name], :users => [@user1.email, @user2.email]
    p response.body
    assert response.body.include?('<status>2 user/s updated</status>')
  end

  it 'should not be able to release roles from users when authentication token used belongs to a common user (JSON)' do
    @common_user = create_user({is_root: false, is_admin: false, email: 'common@gdslink.com', authentication_token: Devise.friendly_token, :company => @application.company})

    url = "/#{@company.key}/#{@application.key}/roles/release.json?auth_token=#{auth_token(@common_user)}"
    post url, :roles => [@role1.name, @role2.name], :users => [@user1.email, @user2.email]
    p response.body
    assert response.body.include?("You are not allowed to use this API")
  end

  it 'should not be able to release roles from users when authentication token used belongs to a common user (XML)' do
    @common_user = create_user({is_root: false, is_admin: false, email: 'common@gdslink.com', authentication_token: Devise.friendly_token, :company => @application.company})

    url = "/#{@company.key}/#{@application.key}/roles/release.xml?auth_token=#{auth_token(@common_user)}"
    post url, :roles => [@role1.name, @role2.name], :users => [@user1.email, @user2.email]
    p response.body
    assert response.body.include?("You are not allowed to use this API")
  end

  it 'should not be able to release roles from user when authentication token used is invalid (JSON)' do
    url = "/#{@company.key}/#{@application.key}/roles/release.json?auth_token=invalid"
    post url, :roles => [@role1.name, @role2.name], :users => [@user1.email, @user2.email]
    p response.body
    assert response.body.include?("Invalid auth-token")
  end

  it 'should not be able to release roles from user when authentication token used is invalid (XML)' do
    url = "/#{@company.key}/#{@application.key}/roles/release.xml?auth_token=invalid"
    post url, :roles => [@role1.name, @role2.name], :users => [@user1.email, @user2.email]
    p response.body
    assert response.body.include?("Invalid auth-token")
  end

  it 'should show an error message when request passed has no roles parameter specified (JSON)' do
    @admin_user = create_user({is_root: false, is_admin: true, email: 'admin@gdslink.com', authentication_token: Devise.friendly_token, :company => @application.company})

    url = "/#{@company.key}/#{@application.key}/roles/release.json?auth_token=#{auth_token(@admin_user)}"
    post url, :users => [@user1.email, @user2.email]
    p response.body
    assert response.body.include?('No roles parameter specified')
  end

  it 'should show an error message when request passed has no roles parameter specified (XML)' do
    @admin_user = create_user({is_root: false, is_admin: true, email: 'admin@gdslink.com', authentication_token: Devise.friendly_token, :company => @application.company})

    url = "/#{@company.key}/#{@application.key}/roles/release.xml?auth_token=#{auth_token(@admin_user)}"
    post url, :users => [@user1.email, @user2.email]
    p response.body
    assert response.body.include?('No roles parameter specified')
  end

  it 'should show an error message when roles specified do not exist (JSON)' do
    @admin_user = create_user({is_root: false, is_admin: true, email: 'admin@gdslink.com', authentication_token: Devise.friendly_token, :company => @application.company})

    url = "/#{@company.key}/#{@application.key}/roles/release.json?auth_token=#{auth_token(@admin_user)}"
    post url, :roles => %w[no_role1 no_role2], :users => [@user1.email, @user2.email]
    p response.body
    assert response.body.include?('no_role1, no_role2 role/s not found in '+@application.key+' application')
  end

  it 'should show an error message when roles specified do not exist (XML)' do
    @admin_user = create_user({is_root: false, is_admin: true, email: 'admin@gdslink.com', authentication_token: Devise.friendly_token, :company => @application.company})

    url = "/#{@company.key}/#{@application.key}/roles/release.xml?auth_token=#{auth_token(@admin_user)}"
    post url, :roles => %w[no_role1 no_role2], :users => [@user1.email, @user2.email]
    p response.body
    assert response.body.include?('no_role1, no_role2 role/s not found in '+@application.key+' application')
  end

  it 'should show an error message when no users parameter is specified (JSON)' do
    @admin_user = create_user({is_root: false, is_admin: true, email: 'admin@gdslink.com', authentication_token: Devise.friendly_token, :company => @application.company})

    url = "/#{@company.key}/#{@application.key}/roles/release.json?auth_token=#{auth_token(@admin_user)}"
    post url, :roles => [@role1.name]
    p response.body
    assert response.body.include?('No users parameter specified')
  end

  it 'should show an error message when no users parameter is specified (XML)' do
    @admin_user = create_user({is_root: false, is_admin: true, email: 'admin@gdslink.com', authentication_token: Devise.friendly_token, :company => @application.company})

    url = "/#{@company.key}/#{@application.key}/roles/release.xml?auth_token=#{auth_token(@admin_user)}"
    post url, :roles => [@role1.name]
    p response.body
    assert response.body.include?('No users parameter specified')
  end

  it 'should show an error message when users specified in request do not exist (JSON)' do
    @admin_user = create_user({is_root: false, is_admin: true, email: 'admin@gdslink.com', authentication_token: Devise.friendly_token, :company => @application.company})

    url = "/#{@company.key}/#{@application.key}/roles/release.json?auth_token=#{auth_token(@admin_user)}"
    post url, :roles => [@role1.name], :users => %w[no_user1@gdslink.com no_user2@gdslink.com]
    p response.body
    assert response.body.include?('no_user1@gdslink.com, no_user2@gdslink.com user/s not found in '+@company.key+' company')
  end

  it 'should show an error message when users specified in request do no exist (XML)' do
    @admin_user = create_user({is_root: false, is_admin: true, email: 'admin@gdslink.com', authentication_token: Devise.friendly_token, :company => @application.company})

    url = "/#{@company.key}/#{@application.key}/roles/release.xml?auth_token=#{auth_token(@admin_user)}"
    post url, :roles => [@role1.name], :users => %w[no_user1@gdslink.com no_user2@gdslink.com]
    p response.body
    assert response.body.include?('no_user1@gdslink.com, no_user2@gdslink.com user/s not found in '+@company.key+' company')
  end

  # API Permission

  it 'should show an error message when common user\'s role has no Role API permission (XML)' do
    @role_api = FactoryBot.create :role, API_role: false, application: @application
    @common_user = FactoryBot.create(:user, authentication_token: Devise.friendly_token, :company => @company, :email => "admin@gdslink.com", :is_root => false, :is_admin => false, :role_ids => [@role_api.id])
    url = "/#{@company.key}/#{@application.key}/roles/release.xml?auth_token=#{auth_token(@common_user)}"
    post url, :roles => [@role1.name, @role2.name], :users => [@user1.email, @user2.email]
    p response.body
    assert response.body.include?('You are not allowed to use this API')
  end

  it 'should show an error message when common user\'s role has no Role API permission (JSON)' do
    @role_api = FactoryBot.create :role, API_role: false, application: @application
    @common_user = FactoryBot.create(:user, authentication_token: Devise.friendly_token, :company => @company, :email => "admin@gdslink.com", :is_root => false, :is_admin => false, :role_ids => [@role_api.id])
    url = "/#{@company.key}/#{@application.key}/roles/release.json?auth_token=#{auth_token(@common_user)}"
    post url, :roles => [@role1.name, @role2.name], :users => [@user1.email, @user2.email]
    p response.body
    assert response.body.include?('You are not allowed to use this API')
  end

  it 'should release roles from user when common user\'s role has Role API permission (XML)' do
    @role_api = FactoryBot.create :role, API_role: true, application: @application
    @common_user = FactoryBot.create(:user, authentication_token: Devise.friendly_token, :company => @company, :email => "admin@gdslink.com", :is_root => false, :is_admin => false, :role_ids => [@role_api.id])
    url = "/#{@company.key}/#{@application.key}/roles/release.xml?auth_token=#{auth_token(@common_user)}"
    post url, :roles => [@role1.name, @role1.name], :users => [@user1.email, @user2.email]
    p response.body
    assert response.body.include?('<status>2 user/s updated</status>')
  end

  it 'should release roles from user when common user\'s role has Role API permission (JSON)' do
    @role_api = FactoryBot.create :role, API_role: true, application: @application
    @common_user = FactoryBot.create(:user, authentication_token: Devise.friendly_token, :company => @company, :email => "admin@gdslink.com", :is_root => false, :is_admin => false, :role_ids => [@role_api.id])
    url = "/#{@company.key}/#{@application.key}/roles/release.json?auth_token=#{auth_token(@common_user)}"
    post url, :roles => [@role1.name, @role2.name], :users => [@user1.email, @user2.email]
    p response.body
    assert response.body.include?('"status":"2 user/s updated"')
  end

end