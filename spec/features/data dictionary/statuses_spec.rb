require 'rails_helper'
require 'factories'

def fill_in_fields (options = {})
  fill_in "status_name", with: options[:status_name] if options.has_key? :status_name
  fill_in "status_description", with: options[:status_description] if options.has_key? :status_description
end

feature 'Status' do

  before(:all) do |example|
    set_module example.class.description
  end

  before(:each) do
    login_as(@user, :scope => :user)
  end

  after(:each) do|example|
    generate_screenshot example.description.parameterize
  end

  scenario 'Saving blank Status form should return an error', :js => true do
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
          status_name: "Test Status",
          status_description: "Test Status description",
      })
      click_button "Cancel"
      within ('div.alert-info') { expect(page).to have_content("No actions were taken") }
    end
  end

  scenario 'Adding Status with required fields should work', :js => true do
    add_new_module_item do
      fill_in_fields ({
          status_name: "Test Status",
          status_description: "Test Status description"
      })
      click_button "Save"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
    end
  end

  scenario 'Save and Add another should save Status and remain in the Status form page', :js => true do
    add_new_module_item do
      fill_in_fields ({
          status_name: "Test Status",
          status_description: "Test Status description"
      })
      click_button "Save and add another"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
      expect(page).to have_content "New #{@module_info[:name]}"
    end
  end

  scenario 'Save and Edit button should save Status record and remain in filled-up form page', :js => true do
    add_new_module_item do
      fill_in_fields ({
          status_name: "Test Status",
          status_description: "Test Status description"
      })
      click_button "Save and edit"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
      expect(page).to have_content "Edit #{@module_info[:name]}"
    end
  end

  scenario 'Clicking Show should allow user to view Status information', :js => true do
    status = FactoryBot.create :status, application: @application
    find_and_show status.name
    expect(page).to have_content "Details for #{@module_info[:name]} '#{status.name}'"
  end

  scenario 'Clicking Edit should allow user to update Status information', :js => true do
    add_new_module_item do
      fill_in_fields ({
          status_name: "Test Status",
          status_description: "Test Status description"
      })
      click_button "Save"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
    end

    find_and_edit "Test Status"
    fill_in_fields ({
        status_name: "Test Status new name",
        status_description: "Test Status new description"
    })
    click_button "Save and edit"
    expect(page).to have_content "#{@module_info[:name]} successfully updated"
    expect(page).to have_field "status_name", with: "Test Status new name"
    expect(page).to have_field "status_description", with: "Test Status new description"
  end

  scenario 'Cancelling delete should not remove Status record from list', :js => true do
    add_new_module_item do
      fill_in_fields ({
          status_name: "Test Status",
          status_description: "Test Status description"
      })
      click_button "Save"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
    end

    find_and_edit "Test Status"
    within ('ul.nav-tabs') { click_link 'Delete' }
    expect(page).to have_content "Delete #{@module_info[:name]} 'Test Status'"

    click_button "Cancel"
    within ('div.alert-info') { expect(page).to have_content("No actions were taken") }
    expect(page).to have_content "Edit #{@module_info[:name]} 'Test Status'"
  end

  scenario 'Deleting Status object should remove data from list', :js => true do
    add_new_module_item do
      fill_in_fields ({
          status_name: "Test Status",
          status_description: "Test Status description"
      })
      click_button "Save"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
    end

    find_and_edit "Test Status"
    within ('ul.nav-tabs') { click_link 'Delete' }
    expect(page).to have_content "Delete #{@module_info[:name]} 'Test Status'"

    click_button "Yes, I'm sure"
    within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully deleted") }
    expect(page).to have_content "Nothing to display"
  end

  #  Export Functionality

  scenario 'Export Field data to csv', :js => true do
    FactoryBot.create_list :status, 10, application: @application
    export_from_dashboard do
      fill_in_filtering_select "csv_options_encoding_to", "UTF-8"
      fill_in_filtering_select "csv_options_generator_col_sep", ","
      expect(page).to have_button('Export to csv', disabled: false)
      click_button "Export to csv"
    end
  end

  scenario 'Export Field data to json', :js => true do
    FactoryBot.create_list :status, 10, application: @application
    export_from_dashboard do
      fill_in_filtering_select "csv_options_encoding_to", "UTF-8"
      fill_in_filtering_select "csv_options_generator_col_sep", ","
      expect(page).to have_button('Export to json', disabled: false)
      click_button "Export to json"
    end
  end

  scenario 'Export Field data to xml', :js => true do
    FactoryBot.create_list :status, 10, application: @application
    export_from_dashboard do
      fill_in_filtering_select "csv_options_encoding_to", "UTF-8"
      fill_in_filtering_select "csv_options_generator_col_sep", ","
      expect(page).to have_button('Export to csv', disabled: false)
      click_button "Export to xml"
    end
  end

  scenario 'Export buttons should be disabled if no field is selected' do
    FactoryBot.create_list :status, 10, application: @application
    export_from_dashboard do
      uncheck 'check_all'
      expect(page).to have_button('Export to csv', disabled: true)
      expect(page).to have_button('Export to json', disabled: true)
      expect(page).to have_button('Export to xml', disabled: true)
    end
  end


end