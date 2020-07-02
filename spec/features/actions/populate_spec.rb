require 'rails_helper'
require 'factories'

def fill_in_fields (options = {})
  fill_in "populate_action_name", with: options[:populate_action_name] if options.has_key? :populate_action_name
  fill_in "populate_action_description", with: options[:populate_action_description] if options.has_key? :populate_action_description
  check "populate_action_populate_new" if (options.has_key? :populate_action_populate_new) && ([true, "true", 1].include? options[:populate_action_populate_new])
  uncheck "populate_action_populate_new" if (options.has_key? :populate_action_populate_new) && ([false, "false", 0].include? options[:populate_action_populate_new])
  check "populate_action_populate_existing" if (options.has_key? :populate_action_populate_existing) && ([true, "true", 1].include? options[:populate_action_populate_existing])
  uncheck "populate_action_populate_existing" if (options.has_key? :populate_action_populate_existing) && ([false, "false", 0].include? options[:populate_action_populate_existing])
  fill_in_multifiltering_select "add", "populate_action_table_ids", options[:populate_action_table_ids] if options.has_key? :populate_action_table_ids
  fill_in_multifiltering_select "add", "populate_action_field_ids", options[:populate_action_field_ids] if options.has_key? :populate_action_field_ids
end

feature 'Populate', type: :feature do

  before(:all) do |example|
    set_module example.class.description
  end

  before(:each) do |example|
    user_login
  end

  after(:each) do |example|
    generate_screenshot example.description.parameterize
  end


  scenario 'Saving blank Populate form should return an error', :js => true do
    add_new_module_item do
      click_button "Save"
      within ('div.alert-danger') do
        expect(page).to have_content "#{@module_info[:name]} failed to be created"
        expect(page).to have_content "- Name can't be blank"
        expect(page).to have_content "- Key can't be blank"
        expect(page).to have_content "- Key should contain alpha numeric and underscore characters only"
        expect(page).to have_content "One of the populate checkbox must be selected, either Populate new? or Populate existing? but not both"
      end
    end
  end

  scenario 'Cancelling add should return no actions were taken', :js => true do
    add_new_module_item do
      fill_in_fields ({
          populate_action_name: "Test Populate Action",
          populate_action_description: "Test Populate Action description"
      })
      click_button "Cancel"
      within ('div.alert-info') { expect(page).to have_content("No actions were taken") }
    end
  end

  scenario 'One of the populate checkbox must be selected, either Populate new? or Populate existing? but not both', :js => true do
    add_new_module_item do
      fill_in_fields ({
          populate_action_name: "Test Populate Action",
          populate_action_description: "Test Populate Action description",
          populate_action_populate_new: true,
          populate_action_populate_existing: true
      })
      click_button "Save"
      expect(page).to have_content "One of the populate checkbox must be selected, either Populate new? or Populate existing? but not both"
    end

    add_new_module_item do
      fill_in_fields ({
          populate_action_name: "Test Populate Action",
          populate_action_description: "Test Populate Action description",
          populate_action_populate_new: false,
          populate_action_populate_existing: false
      })
      click_button "Save"
      expect(page).to have_content "One of the populate checkbox must be selected, either Populate new? or Populate existing? but not both"
    end

    add_new_module_item do
      fill_in_fields ({
          populate_action_name: "Test Populate Action",
          populate_action_description: "Test Populate Action description",
          populate_action_populate_new: true,
          populate_action_populate_existing: false
      })
      click_button "Save"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
    end

  end

  scenario 'Adding Populate object with required fields should work', :js => true do
    fields = []
    tables = []
    5.times { tables << FactoryBot.create(:table, application: @application) }
    5.times { fields << FactoryBot.create(:field, application: @application) }
    add_new_module_item do
      fill_in_fields ({
          populate_action_name: "Test Populate Action",
          populate_action_description: "Test Populate Action description",
          populate_action_populate_new: true,
          populate_action_table_ids: [tables.last.name, tables.first.name],
          populate_action_fields_ids: [fields.last.name, fields.first.name]
      })
      click_button "Save"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
    end
  end

  scenario 'Save and Add another button should save Populate and remain in the form page', :js => true do
    add_new_module_item do
      fill_in_fields ({
          populate_action_name: "Test Populate Action",
          populate_action_description: "Test Populate Action description",
          populate_action_populate_new: true
      })
      click_button "Save and add another"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
      expect(page).to have_content "New #{@module_info[:name]}"
    end
  end

  scenario 'Save and Edit button should save Populate and remain in filled-up form page', :js => true do
    add_new_module_item do
      fill_in_fields ({
          populate_action_name: "Test Populate Action",
          populate_action_description: "Test Populate Action description",
          populate_action_populate_new: true
      })
      click_button "Save and edit"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
      expect(page).to have_content "Edit #{@module_info[:name]}"
    end
  end

  scenario 'Clicking Show should allow user to view Populate Action information', :js => true do
    populate_object = add_populate
    find_and_show populate_object.name
    expect(page).to have_content "Details for #{@module_info[:name]} '#{populate_object.name}'"
  end

  scenario 'Clicking Edit should allow user to update Populate Action information', :js => true do
    add_new_module_item do
      fill_in_fields ({
          populate_action_name: "Test Populate Action",
          populate_action_description: "Test Populate Action description",
          populate_action_populate_new: true
      })
      click_button "Save"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
    end

    find_and_edit "Test Populate Action"
    fill_in_fields ({
        populate_action_name: "Test Populate Action New Name",
        populate_action_description: "Test Populate Action new description",
        populate_action_populate_new: false,
    populate_action_populate_existing: true
    })
    click_button "Save and edit"
    expect(page).to have_content "#{@module_info[:name]} successfully updated"
    expect(page).to have_field "populate_action_name", text: "Test Populate Action New Name"
    expect(page).to have_field "populate_action_description", text: "Test Populate Action new description"

  end

  scenario 'Cancelling delete should not remove Populate Action record from list', :js => true do
    add_new_module_item do
      fill_in_fields ({
          populate_action_name: "Test Populate Action",
          populate_action_description: "Test Populate Action description",
          populate_action_populate_new: true
      })
      click_button "Save"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
    end

    find_and_edit "Test Populate Action"
    within ('ul.nav-tabs') { click_link 'Delete' }
    expect(page).to have_content "Delete #{@module_info[:name]} 'Test Populate Action'"

    click_button "Cancel"
    within ('div.alert-info') { expect(page).to have_content("No actions were taken") }
    expect(page).to have_content "Edit #{@module_info[:name]} 'Test Populate Action'"
  end

  scenario 'Deleting Populate Action object should remove data from list', :js => true do
    add_new_module_item do
      fill_in_fields ({
          populate_action_name: "Test Populate Action",
          populate_action_description: "Test Populate Action description",
          populate_action_populate_new: true
      })
      click_button "Save"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
    end

    find_and_edit "Test Populate Action"
    within ('ul.nav-tabs') { click_link 'Delete' }
    expect(page).to have_content "Delete #{@module_info[:name]} 'Test Populate Action'"

    click_button "Yes, I'm sure"
    within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully deleted") }
    expect(page).to have_content "Nothing to display"
  end

  #  Export Functionality

  scenario 'Export Populate Action data to csv', :js => true do
    add_populate
    export_from_dashboard do
      fill_in_filtering_select "csv_options_encoding_to", "UTF-8"
      fill_in_filtering_select "csv_options_generator_col_sep", ","
      expect(page).to have_button('Export to csv', disabled: false)
      click_button "Export to csv"
    end
  end

  scenario 'Export Populate Action data to json', :js => true do
    add_populate
    export_from_dashboard do
      fill_in_filtering_select "csv_options_encoding_to", "UTF-8"
      fill_in_filtering_select "csv_options_generator_col_sep", ","
      expect(page).to have_button('Export to json', disabled: false)
      click_button "Export to json"
    end
  end

  scenario 'Export Populate Action data to xml', :js => true do
    add_populate
    export_from_dashboard do
      fill_in_filtering_select "csv_options_encoding_to", "UTF-8"
      fill_in_filtering_select "csv_options_generator_col_sep", ","
      expect(page).to have_button('Export to csv', disabled: false)
      click_button "Export to xml"
    end
  end

  scenario 'Export buttons should be disabled if no field is selected' do
    add_populate
    export_from_dashboard do
      uncheck 'check_all'
      expect(page).to have_button('Export to csv', disabled: true)
      expect(page).to have_button('Export to json', disabled: true)
      expect(page).to have_button('Export to xml', disabled: true)
    end
  end

end