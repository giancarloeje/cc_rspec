require 'rails_helper'
require 'factories'

def fill_in_fields (options = {})
  fill_in "company_name", with: options[:company_name] if options.has_key? :company_name
  fill_in "company_description", with: options[:company_description] if options.has_key? :company_description
  attach_file("picture", options[:picture]) if options.has_key? :picture
  fill_in_multifiltering_select options[:company_user_ids][:operation], "company_user_ids", options[:company_user_ids][:values] if options.has_key? :company_user_ids
end


feature 'Company' do

  before :all do |example|
    @users = FactoryBot.create_list(:user, 10)
    @user = @users.first
    @company = nil
    set_module example.class.description
  end

  before :each do
    login_as(@user, :scope => :user)
    @company = Company.first
    visit "/admin"
  end

  after :each do |example|
    generate_screenshot example.description.parameterize
  end

  scenario 'Saving a blank company form should return an error', :js => true do
    click_link "Add new Company"
    expect(page).to have_content "New #{@module_info[:name]}"

    click_button "Save"
    within ('div.alert-danger') do
      expect(page).to have_content "#{@module_info[:name]} failed to be created"
      expect(page).to have_content "- Name can't be blank"
      expect(page).to have_content "- Key should contain alpha numeric and underscore characters only"
    end
  end

  scenario 'Canceling add new company should return no actions were taken', :js => true do
    click_link "Add new Company"
    fill_in_fields ({
        company_name: "Test Application",
        company_description: "Test Application Description"
    })
    click_button "Cancel"
    expect(page).to have_content "Site Administration"
    within ('div.alert-info') { expect(page).to have_content("No actions were taken") }
  end

  scenario 'Adding a company with required fields should work', :js => true do
    click_link "Add new Company"
    fill_in_fields ({
        company_name: "Test Company",
        company_description: "Test Company Description",
        company_user_ids: {operation: "add", values: @users.map(&:email)}
    })
    click_button "Save"
    expect(page).to have_content "Site Administration"
    within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
    within ("#companyAndAppSelectors") { expect(page).to have_css("#select2-Company-scope-container", text: "Test Company") }
  end

  scenario 'Canceling Edit should not save any updates the user might have input', :js => true do
    within ("#companyAndAppSelectors") {
      expect(page).to have_css("#select2-Company-scope-container", text: @company.name)
      click_link "Edit #{@module_info[:name]}"
    }
    expect(page).to have_content "Edit #{@module_info[:name]} '#{@company.name}'"

    fill_in_fields ({
        application_name: "Test Company New Name",
        application_description: "Test Company New Description"
    })
    click_button "Cancel"
    within ('div.alert-info') { expect(page).to have_content("No actions were taken") }

    within ("#companyAndAppSelectors") {
      expect(page).to have_css("#select2-Company-scope-container", text: @company.name)
      click_link "Edit #{@module_info[:name]}"
    }
    expect(page).to have_content "Edit #{@module_info[:name]} '#{@company.name}'"
    expect(page).to have_field("company_name", with: @company.name)
    expect(page).to have_field("company_description", with: "#{@company.description}")
  end

  scenario 'Clicking Edit should allow user to update company information', :js => true do
    within ("#companyAndAppSelectors") {
      expect(page).to have_css("#select2-Company-scope-container", text: @company.name)
      click_link "Edit #{@module_info[:name]}"
    }
    expect(page).to have_content "Edit #{@module_info[:name]} '#{@company.name}'"

    fill_in_fields ({
        company_name: "Test Company updated name",
        company_description: "Test Company updated description",
        #picture: "#{Rails.root}/spec/fixtures/images/logo.png"
    })
    click_button "Save and edit"
    @company.reload
    expect(page).to have_content "Edit #{@module_info[:name]} '#{@company.name}'"
    within("div.alert-success") {expect(page).to have_content "#{@module_info[:name]} successfully updated"}
    expect(page).to have_field("company_name", with: @company.name)
    expect(page).to have_field("company_description", with: "#{@company.description}")
  end

  scenario 'Delete Confirmation Page should display associated applications' do
    applications = FactoryBot.create_list :application, 5, company: @company
    visit "/admin"
    within "#scopeSelector li:nth-child(1)" do
      click_link "Delete Company"
    end
    expect(page).to have_content "Delete #{@module_info[:name]} '#{@company.name}'"
    within ".list-group-flush" do
      applications.each do |application|
        expect(page).to have_selector "a", class: "pjax", text: /#{application.name}/
      end
    end
  end

  scenario 'Confirming Delete Company should remove Company', :js => true do
    within "#scopeSelector li:nth-child(1)" do
      click_link "Delete #{@module_info[:name]}"
    end
    expect(page).to have_content "Delete #{@module_info[:name]} '#{@company.name}'"

    click_button "Yes, I'm sure"
    within (".alert-success") { expect(page).to have_content "#{@module_info[:name]} successfully deleted" }
  end

  scenario 'Changing Company Scope should display target company' do
    companies = FactoryBot.create_list :company, 5
    visit "/admin"
    change_company companies[1].name
    change_company companies[3].name
  end

  scenario 'Import Attachments' do

  end

  scenario 'Import Assets' do

  end

end
