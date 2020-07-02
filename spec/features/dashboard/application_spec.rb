require 'rails_helper'
require 'factories'

def fill_in_fields (options = {})
  fill_in "application_name", with: options[:application_name] if options.has_key? :application_name
  fill_in "application_description", with: options[:application_description] if options.has_key? :application_description
  fill_in_filtering_select "application_default_queue_id_field", options[:application_default_queue_id_field] if options.has_key? :application_default_queue_id_field
  check "application_enable_audit_trail" if (options.has_key? :application_enable_audit_trail) && ([true, "true", 1].include? options[:application_enable_audit_trail])
  uncheck "application_enable_audit_trail" if (options.has_key? :application_enable_audit_trail) && ([false, "false", 0].include? options[:application_enable_audit_trail])
end

def get_application_model_instance options = {}
  ::Application.find_by(options.merge(company: @company))
end

feature 'Application' do

  before(:all) do |example|
    @company = FactoryBot.create(:company)
    @user = FactoryBot.create(:user, company: @company)
    set_module example.class.description
  end

  before(:each) do
    login_as(@user, :scope => :user)
    @application = ::Application.first
    visit "/admin"
  end

  after(:each) do |example|
    generate_screenshot example.description.parameterize
  end

  scenario 'Saving blank application form should return an error', :js => true do
    click_link "Add new Application"
    within ("#companyAndAppSelectors") do
      expect(page).to have_select('Company-scope', selected: "#{@company.name}", disabled: true)
    end
    expect(page).to have_content "New #{@module_info[:name]}"

    click_button "Save"
    within ('div.alert-danger') do
      expect(page).to have_content "#{@module_info[:name]} failed to be created"
      expect(page).to have_content "- Name can't be blank"
      expect(page).to have_content "- Key can't be blank"
      expect(page).to have_content "- Key should contain alpha numeric and underscore characters only"
    end

  end

  scenario 'Default queue should be empty when adding new application', :js => true do
    @queue = FactoryBot.create(:filter)
    click_link "Add new Application"
    within("#application_default_queue_id_field") do
      default_queue_options = find('#application_default_queue_id', visible: false).all('option').collect(&:text)
      expect(default_queue_options).not_to include(@queue.name)
    end
  end

  scenario 'Clicking Cancel button in Add Application Screen should not return anything', :js => true do
    click_link "Add new Application"
    fill_in_fields ({
        application_name: "Test Application",
        application_description: "Test Application Description"
    })
    click_button "Cancel"
    expect(page).to have_content "Site Administration"
    within ('div.alert-info') { expect(page).to have_content("No actions were taken") }
  end

  scenario 'Adding application with required fields should create new application and update application scope', :js => true do
    click_link "Add new Application"
    fill_in_fields ({
      application_name: "Test Application",
      application_description: "Test Application Description",
      application_enable_audit_trail: true
    })
    click_button "Save"
    expect(page).to have_content "Site Administration"
    within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
    within ("#companyAndAppSelectors") { expect(page).to have_css("#select2-Application-scope-container", text: "Test Application") }
    within ("ul.nav-tabs") { expect(page).to have_link('Dashboard') }
  end

  scenario 'Canceling Edit should not save any updates the user might have input', :js => true do
    within ("#companyAndAppSelectors") {
      expect(page).to have_css("#select2-Application-scope-container", text: @application.name)
      click_link "Edit Application"
    }
    expect(page).to have_content "Edit Application '#{@application.name}'"

    fill_in_fields ({
        application_name: "Test Application New Name",
        application_description: "Test Application New Description"
    })
    click_button "Cancel"
    within ('div.alert-info') { expect(page).to have_content("No actions were taken") }

    within ("#companyAndAppSelectors") {
      expect(page).to have_css("#select2-Application-scope-container", text: @application.name)
      click_link "Edit Application"
    }
    expect(page).to have_content "Edit Application '#{@application.name}'"
    expect(page).to have_field("application_name", with: @application.name)
    expect(page).to have_field("application_description", with: "#{@application.description}")
  end

  scenario 'Clicking Edit button should allow users to edit and save application information', :js => true do
    within ("#companyAndAppSelectors") {
      expect(page).to have_css("#select2-Application-scope-container", text: @application.name)
      click_link "Edit Application"
    }
    expect(page).to have_content "Edit Application '#{@application.name}'"

    fill_in_fields ({
        application_name: "Test Application New Name",
        application_description: "Test Application New Description"
    })
    click_button "Save and edit"
    @application.reload
    expect(page).to have_content "Edit Application '#{@application.name}'"
    within("div.alert-success") {expect(page).to have_content "Application successfully updated"}
    expect(page).to have_field("application_name", with: @application.name)
    expect(page).to have_field("application_description", with: "#{@application.description}")
  end

  scenario 'Application key should be read only by default' do
    within ("#companyAndAppSelectors") {
      expect(page).to have_css("#select2-Application-scope-container", text: @application.name)
      click_link "Edit Application"
    }
    expect(page).to have_content "Edit Application '#{@application.name}'"
    within "#application_key_field" do
      expect(page).to have_field "application_key", readonly: true
      expect(page).to have_unchecked_field "override_key"
    end

    check "override_key"
    within "#application_key_field" do
      expect(page).to have_field "application_key", readonly: false
      expect(page).to have_checked_field "override_key"
    end

    fill_in "application_key", with: "new_application_key"
    click_button "Save and edit"
    @application.reload
    expect(page).to have_field("application_key", with: @application.key)
  end

  scenario 'Delete Confirmation Page should display associated objects' do
    fields = FactoryBot.create_list(:field, 5, application: @application)
    tables = FactoryBot.create_list(:table, 5, application: @application)
    modifiers = FactoryBot.create_list(:modifier, 5, application: @application)
    visit "/admin"
    within "#scopeSelector li:nth-child(2)" do
      click_link "Delete Application"
    end
    expect(page).to have_content "Delete Application '#{@application.name}'"
    within ".list-group-flush" do
      fields.each do |field|
        expect(page).to have_selector "a", class: "pjax", text: /#{field.name}/
      end
      tables.each do |table|
        expect(page).to have_selector "a", class: "pjax", text: /#{table.name}/
      end
      modifiers.each do |modifier|
        expect(page).to have_selector "a", class: "pjax", text: /#{modifier.name}/
      end
    end
  end

  scenario 'Confirming Delete Application should remove application' do
    within "#scopeSelector li:nth-child(2)" do
      click_link "Delete Application"
    end
    expect(page).to have_content "Delete Application '#{@application.name}'"

    click_button "Yes, I'm sure"
    within (".alert-success") { expect(page).to have_content "#{@module_info[:name]} successfully deleted" }
  end

  scenario 'Changing Application Scope should display target application' do
    @applications = FactoryBot.create_list :application, 5, company: @company
    visit "/admin"
    change_application @applications[1].name
    change_application @applications[3].name
  end

end
