require 'rails_helper'
require 'factories'


def fill_in_fields (options = {})
  # Default values
  values = {
    data_view_connector_name: "",
    data_view_connector_description: "",
    data_view_connector_url: "http://domain.com/example_key/Dataview360.svc/Dataview360/transaction",
    data_view_connector_open_timeout: "30",
    data_view_connector_read_timeout: "30",
    data_view_connector_input_root_node: "",
    data_view_connector_output_root_node: "",
    data_view_connector_payload_format: "",
    data_view_connector_table_ids: [],
    data_view_connector_field_ids: [],
  }

  values = values.merge options

  fill_in "data_view_connector_name", with: values[:data_view_connector_name]
  fill_in "data_view_connector_description", with: values[:data_view_connector_description]
  fill_in "data_view_connector_url", with: values[:data_view_connector_url]
  fill_in "data_view_connector_open_timeout", with: values[:data_view_connector_open_timeout]
  fill_in "data_view_connector_read_timeout", with: values[:data_view_connector_read_timeout]
  fill_in "data_view_connector_input_root_node", with: values[:data_view_connector_input_root_node]
  fill_in "data_view_connector_output_root_node", with: values[:data_view_connector_output_root_node]
  fill_in_filtering_select "data_view_connector_payload_format", values[:data_view_connector_payload_format]
  fill_in_multifiltering_select "add", "data_view_connector_table_ids", values[:data_view_connector_table_ids]
  fill_in_multifiltering_select "add", "data_view_connector_field_ids", values[:data_view_connector_field_ids]
end

feature 'DataView360' do

  before(:all) do |example|
    set_module example.class.description
  end

  before(:each) do |example|
    user_login
  end

  after(:each) do |example|
    generate_screenshot example.description.parameterize
  end


  scenario 'Saving blank DV form should return an error', :js => true do
    add_new_module_item
    click_button "Save"
    within ('div.alert-danger') do
      expect(page).to have_content "DataView360 failed to be created"
      expect(page).to have_content "- Name can't be blank"
      expect(page).to have_content "- Key can't be blank"
      expect(page).to have_content "- Key should contain alpha numeric and underscore characters only"
      expect(page).to have_content "- Input root node can't be blank"
      expect(page).to have_content "- Output root node can't be blank"
      expect(page).to have_content "- Payload Format can't be blank"
    end

  end

  scenario 'Cancelling add should return no actions were taken', :js => true do
    add_new_module_item
    fill_in_fields data_view_connector_name: 'DV test', data_view_connector_description: 'DV test description', data_view_connector_payload_format: 'XML'
    click_button "Cancel"
    within ('div.alert-info') { expect(page).to have_content("No actions were taken") }
  end

  scenario 'Adding DV with name, description, format and URL should work', :js => true do
    add_new_module_item
    fill_in_fields({
      data_view_connector_name: 'DV test',
      data_view_connector_description: 'DV test description',
      data_view_connector_payload_format: "XML",
      data_view_connector_input_root_node: "record",
      data_view_connector_output_root_node: "record"
    })
    click_button "Save"
    within ('div.alert-success') do
      expect(page).to have_content("#{@module_info[:name]} successfully created")
    end
  end

  scenario 'Should be able to assign Tables and Fields' do
    tables = FactoryBot.create_list(:table, 10, application: @application)
    fields = FactoryBot.create_list(:field, 10, application: @application)
    add_new_module_item do
      fill_in_fields ({
          data_view_connector_name: 'DV test',
          data_view_connector_description: 'DV test description',
          data_view_connector_payload_format: 'XML',
          data_view_connector_input_root_node: "record",
          data_view_connector_output_root_node: "record",
          data_view_connector_table_ids: [tables.last.name, tables.first.name],
          data_view_connector_field_ids: [fields.last.name, fields.first.name],
      })
      click_button "Save and edit"
    end
  end

  scenario 'Save and Add another button should save DV record and remain in the DV form page', :js => true do
    add_new_module_item
    fill_in_fields({
       data_view_connector_name: 'DV test',
       data_view_connector_description: 'DV test description',
       data_view_connector_payload_format: "XML",
       data_view_connector_input_root_node: "record",
       data_view_connector_output_root_node: "record"
    })
    click_button "Save and add another"
    within ('div.alert-success') { expect(page).to have_content("DataView360 successfully created") }
    expect(page).to have_content "New #{@module_info[:name]}"
  end

  scenario 'Save and Edit button should save DV record and remain in filled-up form page', :js => true do
    add_new_module_item
    fill_in_fields({
      data_view_connector_name: 'DV test',
      data_view_connector_description: 'DV test description',
      data_view_connector_payload_format: "XML",
      data_view_connector_input_root_node: "record",
      data_view_connector_output_root_node: "record"
    })
    click_button "Save and edit"
    within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
    expect(page).to have_content "Edit #{@module_info[:name]} 'DV test'"
  end

  scenario 'Clicking Show should allow user to view DV information', :js => true do
    dv_object = add_data_view_connector
    visit "/admin"
    go_to_module_dashboard
    find_and_show dv_object.name
    expect(page).to have_content "Details for #{@module_info[:name]} '#{dv_object.name}'"
  end

  scenario 'Clicking Edit should allow user to update DV information', :js => true do
    dv_object = add_data_view_connector
    visit "/admin"
    go_to_module_dashboard
    find_and_edit dv_object.name
    fill_in 'data_view_connector_name', with: ""
    fill_in 'data_view_connector_name', with: "DV test 002"
    click_button "Save"
    expect(page).to have_content "DataView360 successfully updated"
  end

  scenario 'Cancelling delete should not remove DV record from list', :js => true do
    dv_object = add_data_view_connector
    visit "/admin"
    go_to_module_dashboard
    find_and_edit dv_object.name
    within 'ul.nav-tabs' do
      click_link 'Delete'
    end
    expect(page).to have_content "Delete #{@module_info[:name]} '#{dv_object.name}'"

    click_button "Cancel"
    within ('div.alert-info') do
      expect(page).to have_content("No actions were taken")
    end
    expect(page).to have_content "Edit #{@module_info[:name]} '#{dv_object.name}'"

  end

  scenario 'Deleting DV object should remove data from list', :js => true do
    dv_object = add_data_view_connector
    visit "/admin"
    go_to_module_dashboard
    find_and_edit dv_object.name
    within 'ul.nav-tabs' do
      click_link 'Delete'
    end
    expect(page).to have_content "Delete DataView360 '#{dv_object.name}'"

    click_button "Yes, I'm sure"
    within ('div.alert-success') do
      expect(page).to have_content("DataView360 successfully deleted")
    end
    expect(page).to have_content "Nothing to display"
  end

  #  Export Functionality

  scenario 'Export DV360 data to csv', :js => true do
    dv_object = add_data_view_connector
    export_from_dashboard do
      fill_in_filtering_select "csv_options_encoding_to", "UTF-8"
      fill_in_filtering_select "csv_options_generator_col_sep", ","
      expect(page).to have_button('Export to csv', disabled: false)
      click_button "Export to csv"
    end
  end

  scenario 'Export DV360 data to json', :js => true do
    dv_object = add_data_view_connector
    export_from_dashboard do
      fill_in_filtering_select "csv_options_encoding_to", "UTF-8"
      fill_in_filtering_select "csv_options_generator_col_sep", ","
      expect(page).to have_button('Export to json', disabled: false)
      click_button "Export to json"
    end
  end

  scenario 'Export DV360 data to xml', :js => true do
    dv_object = add_data_view_connector
    export_from_dashboard do
      fill_in_filtering_select "csv_options_encoding_to", "UTF-8"
      fill_in_filtering_select "csv_options_generator_col_sep", ","
      expect(page).to have_button('Export to csv', disabled: false)
      click_button "Export to xml"
    end
  end

  scenario 'Export buttons should be disabled if no field is selected' do
    dv_object = add_data_view_connector
    export_from_dashboard do
      uncheck 'check_all'
      expect(page).to have_button('Export to csv', disabled: true)
      expect(page).to have_button('Export to json', disabled: true)
      expect(page).to have_button('Export to xml', disabled: true)
    end
  end



end
