require 'rails_helper'
require 'factories'

def fill_in_fields (options = {})
  # Default values
  values = {
      modifier_name: "",
      modifier_description: "",
      modifier_code: ""
  }

  values = values.merge options

  fill_in "modifier_name", with: values[:modifier_name] if values.has_key? :modifier_name
  fill_in "modifier_description", with: values[:modifier_description] if values.has_key? :modifier_description
  fill_in_editor_field "#modifier-code", values[:modifier_code] if values.has_key? :modifier_code
end

feature 'Modifier' do

  before(:all) do |example|
    set_module example.class.description
  end

  before(:each) do |example|
    user_login
  end

  after(:each) do |example|
    generate_screenshot example.description.parameterize
  end


  scenario 'Saving blank Modifier form should return an error', :js => true do
    add_new_module_item do
      click_button "Save"
    end
    within ('div.alert-danger') do
      expect(page).to have_content "Modifier failed to be created"
      expect(page).to have_content "- Name can't be blank"
      expect(page).to have_content "- Key can't be blank"
      expect(page).to have_content "- Key should contain alpha numeric and underscore characters only"
      expect(page).to have_content "- Code can't be blank"
    end
  end

  scenario 'Cancelling add should return no actions were taken', :js => true do
    add_new_module_item do
      fill_in_fields modifier_name: 'Modifier test', modifier_key: 'Modifier test description', modifier_description: '', modifier_code: "# Modifier code"
      click_button "Cancel"
      within ('div.alert-info') { expect(page).to have_content("No actions were taken") }
    end
  end

  scenario 'Adding Modifier with name, description, and code should work', :js => true do
    add_new_module_item do
      fill_in_fields modifier_name: 'Modifier test', modifier_key: 'modifier_test', modifier_description: '', modifier_code: "# Modifier code"
      click_button "Save"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
    end
  end

  scenario 'Save and Add another button should save Modifier and remain in the form page', :js => true do
    add_new_module_item
    fill_in_fields modifier_name: 'Modifier test', modifier_key: 'modifier_test', modifier_description: '', modifier_code: "# Modifier code"
    click_button "Save and add another"
    within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
    expect(page).to have_content "New #{@module_info[:name]}"
  end

  scenario 'Save and Edit button should save Modifier and remain in filled-up form page', :js => true do
    add_new_module_item do
      fill_in_fields modifier_name: 'Modifier test', modifier_key: 'modifier_test', modifier_description: '', modifier_code: "# Modifier code"
    end
    click_button "Save and edit"
    within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
    expect(page).to have_content "Edit #{@module_info[:name]} 'Modifier test'"
  end

  scenario 'Clicking Show should allow user to view Modifier information', :js => true do
    modifier_object = add_modifier
    go_to_module_dashboard
    go_to_module_dashboard
    find_and_show modifier_object.name
    expect(page).to have_content "Details for #{@module_info[:name]} '#{modifier_object.name}'"
  end

  scenario 'Clicking Edit should allow user to update Modifier information', :js => true do
    modifier_object = add_modifier
    go_to_module_dashboard
    find_and_edit modifier_object.name
    fill_in 'modifier_name', with: "New modifier name"
    fill_in 'modifier_description', with: "New modifier description"
    fill_in_editor_field "#modifier-code", "# New modifier code"
    click_button "Save"
    expect(page).to have_content "#{@module_info[:name]} successfully updated"
  end

  scenario 'Cancelling delete should not remove Modifier from list', :js => true do
    modifier_object = add_modifier
    go_to_module_dashboard
    find_and_edit modifier_object.name
    within ('ul.nav-tabs') { click_link 'Delete' }
    expect(page).to have_content "Delete #{@module_info[:name]} '#{modifier_object.name}'"

    click_button "Cancel"
    within ('div.alert-info') { expect(page).to have_content("No actions were taken") }
    expect(page).to have_content "Edit #{@module_info[:name]} '#{modifier_object.name}'"
  end

  scenario 'Deleting Modifier object should remove data from list', :js => true do
    modifier_object = add_modifier
    go_to_module_dashboard
    find_and_edit modifier_object.name
    within ('ul.nav-tabs') { click_link 'Delete' }
    expect(page).to have_content "Delete #{@module_info[:name]} '#{modifier_object.name}'"

    click_button "Yes, I'm sure"
    within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully deleted") }
    expect(page).to have_content "Nothing to display"
  end

  #  Export Functionality

  scenario 'Export Modifier data to csv', :js => true do
    add_modifier
    export_from_dashboard do
      fill_in_filtering_select "csv_options_encoding_to", "UTF-8"
      fill_in_filtering_select "csv_options_generator_col_sep", ","
      expect(page).to have_button('Export to csv', disabled: false)
      click_button "Export to csv"
    end
  end

  scenario 'Export Modifier data to json', :js => true do
    add_modifier
    export_from_dashboard do
      fill_in_filtering_select "csv_options_encoding_to", "UTF-8"
      fill_in_filtering_select "csv_options_generator_col_sep", ","
      expect(page).to have_button('Export to json', disabled: false)
      click_button "Export to json"
    end
  end

  scenario 'Export Modifier data to xml', :js => true do
    add_modifier
    export_from_dashboard do
      fill_in_filtering_select "csv_options_encoding_to", "UTF-8"
      fill_in_filtering_select "csv_options_generator_col_sep", ","
      expect(page).to have_button('Export to csv', disabled: false)
      click_button "Export to xml"
    end
  end

  scenario 'Export buttons should be disabled if no field is selected' do
    add_modifier
    export_from_dashboard do
      uncheck 'check_all'
      expect(page).to have_button('Export to csv', disabled: true)
      expect(page).to have_button('Export to json', disabled: true)
      expect(page).to have_button('Export to xml', disabled: true)
    end
  end

end