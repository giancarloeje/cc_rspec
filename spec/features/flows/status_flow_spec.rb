require 'rails_helper'
require 'factories'

def fill_in_fields (options = {})
  fill_in 'status_flow_name', with: options[:status_flow_name] if options.has_key? :status_flow_name
  fill_in 'status_flow_description', with: options[:status_flow_description] if options.has_key? :status_flow_description

  if options.has_key? :status_flow_key
    within "#status_flow_key_field" do
      expect(page).to have_field "override_key", type: 'checkbox'
      check "override_key"
      expect(page).to have_field "status_flow_key", readonly: false
      fill_in 'status_flow_key', with: options[:status_flow_key]
    end
  end

  fill_in_filtering_select "status_flow_field_id", options[:status_flow_field_id] if options.has_key? :status_flow_field_id

end

feature 'Status flow' do

  before(:all) do |example|
    set_module example.class.description
  end

  before(:each) do |example|
    user_login
    @statuses = FactoryBot.create_list :status, 5, application: @application
    @fields = FactoryBot.create_list :field, 5, application: @application
  end

  after(:each) do |example|
    generate_screenshot example.description.parameterize
  end

  scenario 'Saving blank Status flow form should return an error', :js => true do
    add_new_module_item do
      click_button "Save"
      within ('div.alert-danger') do
        expect(page).to have_content "#{@module_info[:name]} failed to be created"
        expect(page).to have_content "- Name can't be blank"
        expect(page).to have_content "- Key can't be blank"
        expect(page).to have_content "- Key should contain alpha numeric and underscore characters only"
      end
    end
  end

  scenario 'Cancelling add should return no actions were taken', :js => true do
    add_new_module_item do
      fill_in_fields ({
          status_flow_name: "Test Status flow",
          status_flow_description: "Test Status flow description",
          status_flow_field_id: @statuses.last.name
      })
      click_button "Cancel"
      within ('div.alert-info') { expect(page).to have_content("No actions were taken") }
    end
  end

  scenario 'Adding Status flow with required fields should work', :js => true do
    add_new_module_item do
      fill_in_fields ({
          status_flow_name: "Test Status flow",
          status_flow_description: "Test Status flow description",
          status_flow_field_id: @fields.last.name
      })
      click_button "Save"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
      within ("#status_flow_field_id") { expect(page).to have_field(nil, with: @fields.last.name) }
    end
  end

  scenario 'Save and Add another should save Status flow and remain in the Status flow form page', :js => true do
    add_new_module_item do
      fill_in_fields ({
          status_flow_name: "Test Status flow",
          status_flow_description: "Test Status flow description",
          status_flow_field_id: @statuses.last.name
      })
      click_button "Save and add another"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
      expect(page).to have_content "New #{@module_info[:name]}"
    end
  end

  scenario 'Save and Edit button should save Status flow record and remain in filled-up form page', :js => true do
    add_new_module_item do
      fill_in_fields ({
          status_flow_name: "Test Status flow",
          status_flow_description: "Test Status flow description",
          status_flow_field_id: @statuses.last.name
      })
      click_button "Save and edit"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
      expect(page).to have_content "Edit #{@module_info[:name]}"
    end
  end

  scenario 'Saving duplicate name and key should not work', :js => true do
    status_flow = FactoryBot.create :status_flow, application: @application
    add_new_module_item do
      fill_in_fields ({
          status_flow_name: "Test Status flow",
          status_flow_description: "Test Status flow description",
          status_flow_field_id: @fields.last.name
      })
      click_button "Save and edit"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
      expect(page).to have_field "status_flow_name", with: "Test Status flow"
      expect(page).to have_field "status_flow_description", with: "Test Status flow description"
      expect(page).to have_field "status_flow_key", with: "test_status_flow"
    end

    fill_in_fields ({
        status_flow_name: status_flow.name,
        status_flow_key: status_flow.key
    })
    click_button "Save and edit"
    within ('div.alert-danger') do
      expect(page).to have_content "#{@module_info[:name]} failed to be updated"
      expect(page).to have_content "- Name has already been taken"
      expect(page).to have_content "- Key has already been taken. Note: key is generated by converting name to lowercase and symbols to underscores by default."
    end

  end

  scenario 'Clicking Show should allow user to view Status flow information', :js => true do
    status_flow = FactoryBot.create :status_flow, application: @application
    find_and_show status_flow.name
    expect(page).to have_content "Details for #{@module_info[:name]} '#{status_flow.name}'"
  end

  scenario 'Clicking Edit should allow user to update Status flow information', :js => true do
    add_new_module_item do
      fill_in_fields ({
          status_flow_name: "Test Status flow",
          status_flow_description: "Test Status flow description",
          status_flow_field_id: @statuses.last.name
      })
      click_button "Save"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
    end

    find_and_edit "Test Status flow"
    fill_in_fields ({
        status_flow_name: "Test Status flow new name",
        status_flow_description: "Test Status flow new description"
    })
    click_button "Save and edit"
    expect(page).to have_content "#{@module_info[:name]} successfully updated"
    expect(page).to have_field "status_flow_name", with: "Test Status flow new name"
    expect(page).to have_field "status_flow_description", with: "Test Status flow new description"
  end

  scenario 'Canceling delete should not remove Status flow record from list', :js => true do
    add_new_module_item do
      fill_in_fields ({
          status_flow_name: "Test Status flow",
          status_flow_description: "Test Status flow description",
          status_flow_field_id: @fields.last.name
      })
      click_button "Save"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
    end

    find_and_edit "Test Status flow"
    within ('ul.nav-tabs') { click_link 'Delete' }
    expect(page).to have_content "Delete #{@module_info[:name]} 'Test Status flow'"

    click_button "Cancel"
    within ('div.alert-info') { expect(page).to have_content("No actions were taken") }
    expect(page).to have_content "Edit #{@module_info[:name]} 'Test Status flow'"
  end

  scenario 'Deleting Status flow object should remove data from list', :js => true do
    add_new_module_item do
      fill_in_fields ({
          status_flow_name: "Test Status flow",
          status_flow_description: "Test Status flow description",
          status_flow_field_id: @fields.last.name
      })
      click_button "Save"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
    end

    find_and_edit "Test Status flow"
    within ('ul.nav-tabs') { click_link 'Delete' }
    expect(page).to have_content "Delete #{@module_info[:name]} 'Test Status flow'"

    click_button "Yes, I'm sure"
    within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully deleted") }
  end

  scenario 'Status module should be available in Server flow editor' do

    add_new_module_item do
      fill_in_fields ({
          status_flow_name: "Test Status flow",
          status_flow_description: "Test Status flow description",
          status_flow_field_id: @fields.last.name
      })
      click_button "Save and edit"
    end

    within_frame('flowIframe') do
      within "#module-category-Statuses" do
        expect(page).to have_selector "div.WiringEditor-module", text: @statuses.first.name
      end

    end

  end


end