require 'spec_helper'
require 'factories'
require 'rack'

def set_up
  @role1 = FactoryBot.create(:role, :application => @application)
  @role2 = FactoryBot.create(:role, :application => @application)
end

def auth_token(user)
  CGI.escape "#{Base64.urlsafe_encode64(user.email)}|#{user.authentication_token}"
end

describe 'Delete IDP mapping roles', type: :request do

  before(:each) do |example|
    p "Start of Test: #{example.description}"
    @company = FactoryBot.create(:company)
    @application = FactoryBot.create(:application, company: @company)
    define_record_factory(nil, @application)
    set_up
  end

  after :each do |example|
    p "End of Test: #{example.description}"
  end

  it 'should delete IDP roles from cc roles (xml) when auth token used belongs to a root user' do
    @root_user = FactoryBot.create(:user, authentication_token: Devise.friendly_token, :company => @company, :email => "root@domain.com")
    @root_user.is_root = true
    @role1.saml_idp_mapping = "QA, Sales, Maintenance"
    @role2.saml_idp_mapping = "QA, Sales, Maintenance"
    @role1.save!
    @role2.save!
    url = "/#{@company.key}/#{@application.key}/roles/delete_idp_mapping.xml?auth_token=#{auth_token(@root_user)}"
    post url, :roles => @role1.name + ", "+@role2.name, :idp_roles => %w[Sales Maintenance]
    p response.body
    assert response.body.include?('<status>2 role/s updated</status>')

    url = "/#{@company.key}/#{@application.key}/roles/list_idp_mapping.xml?auth_token=#{auth_token(@root_user)}"
    post url, :roles => @role1.name + ", "+@role2.name
    p response.body
    assert response.body.include?('<'+@role1.name+'>QA</'+@role1.name+'>')
    assert response.body.include?('<'+@role2.name+'>QA</'+@role2.name+'>')
  end

  it 'should delete IDP roles from cc roles (json) when auth token used belongs to a root user' do
    @root_user = FactoryBot.create(:user, authentication_token: Devise.friendly_token, :company => @company, :email => "root@domain.com")
    @root_user.is_root = true
    @role1.saml_idp_mapping = "QA, Sales, Maintenance"
    @role2.saml_idp_mapping = "QA, Sales, Maintenance"
    @role1.save!
    @role2.save!
    url = "/#{@company.key}/#{@application.key}/roles/delete_idp_mapping.json?auth_token=#{auth_token(@root_user)}"
    post url, :roles => @role1.name + ", "+@role2.name, :idp_roles => %w[Sales Maintenance]
    p response.body
    assert response.body.include?('{"response":{"status":"2 role/s updated"}}')

    url = "/#{@company.key}/#{@application.key}/roles/list_idp_mapping.json?auth_token=#{auth_token(@root_user)}"
    post url, :roles => @role1.name + ", "+@role2.name
    p response.body
    assert response.body.include?('{"roles":{"'+@role1.name+'":"QA","'+@role2.name+'":"QA"}}')
  end

  it 'should delete IDP roles from cc roles (xml) when auth token used belongs to an admin user' do
    @root_user = FactoryBot.create(:user, authentication_token: Devise.friendly_token, :company => @company, :email => "root@domain.com")
    @admin_user = FactoryBot.create(:user, authentication_token: '1234a', :company => @company, :email => "admin@domain.com")
    @admin_user.is_root = false
    @admin_user.is_admin = true
    @admin_user.save!
    @role1.saml_idp_mapping = "QA, Sales, Maintenance"
    @role2.saml_idp_mapping = "QA, Sales, Maintenance"
    @role1.save!
    @role2.save!
    url = "/#{@company.key}/#{@application.key}/roles/delete_idp_mapping.xml?auth_token=#{auth_token(@admin_user)}"
    post url, :roles => @role1.name + ", "+@role2.name, :idp_roles => %w[Sales Maintenance]
    p response.body
    assert response.body.include?('<status>2 role/s updated</status>')

    url = "/#{@company.key}/#{@application.key}/roles/list_idp_mapping.xml?auth_token=#{auth_token(@root_user)}"
    post url, :roles => @role1.name + ", "+@role2.name
    p response.body
    assert response.body.include?('<'+@role1.name+'>QA</'+@role1.name+'>')
    assert response.body.include?('<'+@role2.name+'>QA</'+@role2.name+'>')
  end

  it 'should delete IDP roles from cc roles (json) when auth token used belongs to an admin user' do
    @root_user = FactoryBot.create(:user, authentication_token: Devise.friendly_token, :company => @company, :email => "root@domain.com")
    @admin_user = FactoryBot.create(:user, authentication_token: '1234a', :company => @company, :email => "admin@domain.com")
    @admin_user.is_root = false
    @admin_user.is_admin = true
    @admin_user.save!
    @role1.saml_idp_mapping = "QA, Sales, Maintenance"
    @role2.saml_idp_mapping = "QA, Sales, Maintenance"
    @role1.save!
    @role2.save!
    url = "/#{@company.key}/#{@application.key}/roles/delete_idp_mapping.json?auth_token=#{auth_token(@admin_user)}"
    post url, :roles => @role1.name + ", "+@role2.name, :idp_roles => %w[Sales Maintenance]
    p response.body
    assert response.body.include?('{"response":{"status":"2 role/s updated"}}')

    url = "/#{@company.key}/#{@application.key}/roles/list_idp_mapping.json?auth_token=#{auth_token(@root_user)}"
    post url, :roles => @role1.name + ", "+@role2.name
    p response.body
    assert response.body.include?('{"roles":{"'+@role1.name+'":"QA","'+@role2.name+'":"QA"}}')
  end

  it 'should return an error message (xml) when auth token used belongs to a common user with no permissions' do
    @root_user = FactoryBot.create(:user, authentication_token: Devise.friendly_token, :company => @company, :email => "root@domain.com")
    @common_user = FactoryBot.create(:user, authentication_token: '1234ci', :company => @company, :email => "common@domain.com")
    @common_user.is_root = false
    @common_user.is_admin = false
    @common_user.save!
    @role1.saml_idp_mapping = "QA, Sales, Maintenance"
    @role2.saml_idp_mapping = "QA, Sales, Maintenance"
    @role1.save!
    @role2.save!
    url = "/#{@company.key}/#{@application.key}/roles/delete_idp_mapping.xml?auth_token=#{auth_token(@common_user)}"
    post url, :roles => @role1.name + ", "+@role2.name, :idp_roles => %w[Sales Maintenance]
    p response.body
    assert response.body.include?('<error>You are not allowed to use this API</error>')

    url = "/#{@company.key}/#{@application.key}/roles/list_idp_mapping.xml?auth_token=#{auth_token(@root_user)}"
    post url, :roles => @role1.name + ", "+@role2.name
    p response.body
    assert response.body.include?('<'+@role1.name+'>QA, Sales, Maintenance</'+@role1.name+'>')
    assert response.body.include?('<'+@role2.name+'>QA, Sales, Maintenance</'+@role2.name+'>')
  end

  it 'should return an error message (json) when auth token used belongs to a common user with no permissions' do
    @root_user = FactoryBot.create(:user, authentication_token: Devise.friendly_token, :company => @company, :email => "root@domain.com")
    @common_user = FactoryBot.create(:user, authentication_token: '1234ci', :company => @company, :email => "common@domain.com")
    @common_user.is_root = false
    @common_user.is_admin = false
    @common_user.save!
    @role1.saml_idp_mapping = "QA, Sales, Maintenance"
    @role2.saml_idp_mapping = "QA, Sales, Maintenance"
    @role1.save!
    @role2.save!
    url = "/#{@company.key}/#{@application.key}/roles/delete_idp_mapping.json?auth_token=#{auth_token(@common_user)}"
    post url, :roles => @role1.name + ", "+@role2.name, :idp_roles => %w[Sales Maintenance]
    p response.body
    assert response.body.include?('You are not allowed to use this API')

    url = "/#{@company.key}/#{@application.key}/roles/list_idp_mapping.json?auth_token=#{auth_token(@root_user)}"
    post url, :roles => @role1.name + ", "+@role2.name
    p response.body
    assert response.body.include?('{"roles":{"'+@role1.name+'":"QA, Sales, Maintenance","'+@role2.name+'":"QA, Sales, Maintenance"}}')
  end

  it 'should return an error message (xml) when auth token used is invalid' do
    @root_user = FactoryBot.create(:user, authentication_token: Devise.friendly_token, :company => @company, :email => "root@domain.com")
    @role1.saml_idp_mapping = "QA, Sales, Maintenance"
    @role2.saml_idp_mapping = "QA, Sales, Maintenance"
    @role1.save!
    @role2.save!
    url = "/#{@company.key}/#{@application.key}/roles/delete_idp_mapping.xml?auth_token=invalid"
    post url, :roles => @role1.name + ", "+@role2.name, :idp_roles => %w[Sales Maintenance]
    p response.body
    assert response.body.include?('<error>Invalid auth-token</error>')

    url = "/#{@company.key}/#{@application.key}/roles/list_idp_mapping.xml?auth_token=#{auth_token(@root_user)}"
    post url, :roles => @role1.name + ", "+@role2.name
    p response.body
    assert response.body.include?('<'+@role1.name+'>QA, Sales, Maintenance</'+@role1.name+'>')
    assert response.body.include?('<'+@role2.name+'>QA, Sales, Maintenance</'+@role2.name+'>')
  end

  it 'should return an error message (json) when auth token used is invalid' do
    @root_user = FactoryBot.create(:user, authentication_token: Devise.friendly_token, :company => @company, :email => "root@domain.com")
    @role1.saml_idp_mapping = "QA, Sales, Maintenance"
    @role2.saml_idp_mapping = "QA, Sales, Maintenance"
    @role1.save!
    @role2.save!
    url = "/#{@company.key}/#{@application.key}/roles/delete_idp_mapping.json?auth_token=invalid"
    post url, :roles => @role1.name + ", "+@role2.name, :idp_roles => %w[Sales Maintenance]
    p response.body
    assert response.body.include?('Invalid auth-token')

    url = "/#{@company.key}/#{@application.key}/roles/list_idp_mapping.json?auth_token=#{auth_token(@root_user)}"
    post url, :roles => @role1.name + ", "+@role2.name
    p response.body
    assert response.body.include?('{"roles":{"'+@role1.name+'":"QA, Sales, Maintenance","'+@role2.name+'":"QA, Sales, Maintenance"}}')
  end

  it 'should return an error message (xml) when roles parameter is missing in request' do
    @root_user = FactoryBot.create(:user, authentication_token: Devise.friendly_token, :company => @company, :email => "root@domain.com")
    url = "/#{@company.key}/#{@application.key}/roles/delete_idp_mapping.xml?auth_token=#{auth_token(@root_user)}"
    post url, :idp_roles => %w[Sales Maintenance]
    p response.body
    assert response.body.include?('<error>No roles parameter specified</error>')
  end

  it 'should return an error message (json) when roles parameter is missing in request' do
    @root_user = FactoryBot.create(:user, authentication_token: Devise.friendly_token, :company => @company, :email => "root@domain.com")
    url = "/#{@company.key}/#{@application.key}/roles/delete_idp_mapping.json?auth_token=#{auth_token(@root_user)}"
    post url, :idp_roles => %w[Sales Maintenance]
    p response.body
    assert response.body.include?('{"errors":["No roles parameter specified"]}')
  end

  it 'should return an error message (xml) when idp roles parameter is missing in request' do
    @root_user = FactoryBot.create(:user, authentication_token: Devise.friendly_token, :company => @company, :email => "root@domain.com")
    url = "/#{@company.key}/#{@application.key}/roles/delete_idp_mapping.xml?auth_token=#{auth_token(@root_user)}"
    post url, :roles => @role1.name + ", "+@role2.name
    p response.body
    assert response.body.include?('<error>No idp roles parameter specified</error>')
  end

  it 'should return an error message (json) when idp roles parameter is missing in request' do
    @root_user = FactoryBot.create(:user, authentication_token: Devise.friendly_token, :company => @company, :email => "root@domain.com")
    url = "/#{@company.key}/#{@application.key}/roles/delete_idp_mapping.json?auth_token=#{auth_token(@root_user)}"
    post url, :roles => @role1.name + ", "+@role2.name
    p response.body
    assert response.body.include?('{"errors":["No idp roles parameter specified"]}')
  end

  it 'should return zero roles updated (xml) when roles specified do not contain the IDP roles to be deleted ' do
    @root_user = FactoryBot.create(:user, authentication_token: Devise.friendly_token, :company => @company, :email => "root@domain.com")
    @role1.saml_idp_mapping = "QA, Sales, Maintenance"
    @role2.saml_idp_mapping = "QA, Sales, Maintenance"
    @role1.save!
    @role2.save!
    url = "/#{@company.key}/#{@application.key}/roles/delete_idp_mapping.xml?auth_token=#{auth_token(@root_user)}"
    post url, :roles => @role1.name + ", "+@role2.name, :idp_roles => %w[Admin QA_Special]
    p response.body
    assert response.body.include?('<status>0 role/s updated</status>')
  end

  it 'should return zero roles updated (json) when roles specified do not contain the IDP roles to be deleted ' do
    @root_user = FactoryBot.create(:user, authentication_token: Devise.friendly_token, :company => @company, :email => "root@domain.com")
    @role1.saml_idp_mapping = "QA, Sales, Maintenance"
    @role2.saml_idp_mapping = "QA, Sales, Maintenance"
    @role1.save!
    @role2.save!
    url = "/#{@company.key}/#{@application.key}/roles/delete_idp_mapping.json?auth_token=#{auth_token(@root_user)}"
    post url, :roles => @role1.name + ", "+@role2.name, :idp_roles => %w[Admin QA_Special]
    p response.body
    assert response.body.include?('{"response":{"status":"0 role/s updated"}}')
  end

  # API Permission

  it 'should show an error message when common user\'s role has no Role API permission (XML)' do
    @role_api = FactoryBot.create :role, API_role: false, application: @application
    @common_user = FactoryBot.create(:user, authentication_token: Devise.friendly_token, :company => @company, :email => "admin@gdslink.com", :is_root => false, :is_admin => false, :role_ids => [@role_api.id])

    @role1.saml_idp_mapping = "QA, Sales, Maintenance"
    @role2.saml_idp_mapping = "QA, Sales, Maintenance"
    @role1.save!
    @role2.save!
    url = "/#{@company.key}/#{@application.key}/roles/delete_idp_mapping.xml?auth_token=#{auth_token(@common_user)}"
    post url, :roles => @role1.name + ", "+@role2.name, :idp_roles => %w[Sales Maintenance]
    p response.body
    assert response.body.include?('You are not allowed to use this API')
  end

  it 'should show an error message when common user\'s role has no Role API permission (JSON)' do
    @role_api = FactoryBot.create :role, API_role: false, application: @application
    @common_user = FactoryBot.create(:user, authentication_token: Devise.friendly_token, :company => @company, :email => "admin@gdslink.com", :is_root => false, :is_admin => false, :role_ids => [@role_api.id])

    @role1.saml_idp_mapping = "QA, Sales, Maintenance"
    @role2.saml_idp_mapping = "QA, Sales, Maintenance"
    @role1.save!
    @role2.save!
    url = "/#{@company.key}/#{@application.key}/roles/delete_idp_mapping.json?auth_token=#{auth_token(@common_user)}"
    post url, :roles => @role1.name + ", "+@role2.name, :idp_roles => %w[Sales Maintenance]
    p response.body
    assert response.body.include?('You are not allowed to use this API')
  end

  it 'should delete IDP roles from user when common user\'s role has Role API permission (XML)' do
    @role_api = FactoryBot.create :role, API_role: true, application: @application
    @common_user = FactoryBot.create(:user, authentication_token: Devise.friendly_token, :company => @company, :email => "admin@gdslink.com", :is_root => false, :is_admin => false, :role_ids => [@role_api.id])

    @role1.saml_idp_mapping = "QA, Sales, Maintenance"
    @role2.saml_idp_mapping = "QA, Sales, Maintenance"
    @role1.save!
    @role2.save!
    url = "/#{@company.key}/#{@application.key}/roles/delete_idp_mapping.xml?auth_token=#{auth_token(@common_user)}"
    post url, :roles => @role1.name + ", "+@role2.name, :idp_roles => %w[Sales Maintenance]
    p response.body
    assert response.body.include?('<status>2 role/s updated</status>')

    url = "/#{@company.key}/#{@application.key}/roles/list_idp_mapping.xml?auth_token=#{auth_token(@common_user)}"
    post url, :roles => @role1.name + ", "+@role2.name
    p response.body
    assert response.body.include?('<'+@role1.name+'>QA</'+@role1.name+'>')
    assert response.body.include?('<'+@role2.name+'>QA</'+@role2.name+'>')
  end

  it 'should delete IDP roles from user when common user\'s role has Role API permission (JSON)' do
    @role_api = FactoryBot.create :role, API_role: true, application: @application
    @common_user = FactoryBot.create(:user, authentication_token: Devise.friendly_token, :company => @company, :email => "admin@gdslink.com", :is_root => false, :is_admin => false, :role_ids => [@role_api.id])

    @role1.saml_idp_mapping = "QA, Sales, Maintenance"
    @role2.saml_idp_mapping = "QA, Sales, Maintenance"
    @role1.save!
    @role2.save!
    url = "/#{@company.key}/#{@application.key}/roles/delete_idp_mapping.json?auth_token=#{auth_token(@common_user)}"
    post url, :roles => @role1.name + ", "+@role2.name, :idp_roles => %w[Sales Maintenance]
    p response.body
    assert response.body.include?('{"response":{"status":"2 role/s updated"}}')

    url = "/#{@company.key}/#{@application.key}/roles/list_idp_mapping.json?auth_token=#{auth_token(@common_user)}"
    post url, :roles => @role1.name + ", "+@role2.name
    p response.body
    assert response.body.include?('{"roles":{"'+@role1.name+'":"QA","'+@role2.name+'":"QA"}}')
  end

end