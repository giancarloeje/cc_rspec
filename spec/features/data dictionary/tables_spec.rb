require 'rails_helper'
require 'factories'

def fill_in_fields (options = {})
  fill_in "table_name", with: options[:table_name] if options.has_key? :table_name
  fill_in "table_description", with: options[:table_description] if options.has_key? :table_description
  fill_in_filtering_select "table_update_logic", options[:table_update_logic] if options.has_key? :table_update_logic
  fill_in_multifiltering_select options[:table_child_ids][:operation], "table_child_ids", options[:table_child_ids][:values] if options.has_key? :table_child_ids
  fill_in_multifiltering_select options[:table_field_ids][:operation], "table_field_ids", options[:table_field_ids][:values] if options.has_key? :table_field_ids

end

feature 'Table' do

  before(:all) do |example|
    set_module example.class.description
    user_login
  end

  before(:each) do
    @tables = FactoryBot.create_list :table, 5, application: @application
    @fields = FactoryBot.create_list :field, 5, application: @application
    login_as(@user, :scope => :user)
  end

  after(:each) do |example|
    generate_screenshot example.description.parameterize
  end

  scenario 'Saving blank Table form should return an error', :js => true do
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
          table_name: "Test Table",
          table_description: "Test Table description",
      })
      click_button "Cancel"
      within ('div.alert-info') { expect(page).to have_content("No actions were taken") }
    end
  end

  scenario 'Adding Table with required fields should work', :js => true do
    add_new_module_item do
      fill_in_fields ({
          table_name: "Test Table",
          table_description: "Test Table description",
          table_update_logic: "replace",
          table_child_ids: {operation: "add", values: @tables.map(&:name)},
          table_field_ids: {operation: "add", values: @fields.map(&:name)}
      })
      click_button "Save"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
    end
  end

  scenario 'Save and Add another should save Table and remain in the Table form page', :js => true do
    add_new_module_item do
      fill_in_fields ({
          table_name: "Test Table",
          table_description: "Test Table description"
      })
      click_button "Save and add another"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
      expect(page).to have_content "New #{@module_info[:name]}"
    end
  end

  scenario 'Save and Edit button should save Table record and remain in filled-up form page', :js => true do
    add_new_module_item do
      fill_in_fields ({
          table_name: "Test Table",
          table_description: "Test Table description",
      })
      click_button "Save and edit"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
      expect(page).to have_content "Edit #{@module_info[:name]}"
    end
  end

  scenario 'Clicking Show should allow user to view Table information', :js => true do
    table = FactoryBot.create :table, application: @application
    find_and_show table.name
    expect(page).to have_content "Details for #{@module_info[:name]} '#{table.name}'"
  end

  scenario 'Clicking Edit should allow user to update Table information', :js => true do
    add_new_module_item do
      fill_in_fields ({
          table_name: "Test Table",
          table_description: "Test Table description",
          table_update_logic: "replace",
          table_child_ids: {operation: "add", values: @tables.map(&:name)},
          table_field_ids: {operation: "add", values: @fields.map(&:name)}
      })
      click_button "Save"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
    end

    find_and_edit "Test Table"
    fill_in_fields ({
        table_name: "Test Table new name",
        table_description: "Test Table new description",
        table_update_logic: "replace",
        table_child_ids: {operation: "remove", values: @tables.map(&:name)},
        table_field_ids: {operation: "remove", values: @fields.map(&:name)}
    })
    click_button "Save and edit"
    expect(page).to have_content "#{@module_info[:name]} successfully updated"
    expect(page).to have_field "table_name", with: "Test Table new name"
    expect(page).to have_field "table_description", with: "Test Table new description"
    children_tables = find("#table_child_ids_field div.ra-multiselect-left select").all("option").collect(&:text)
    children_fields = find("#table_field_ids_field div.ra-multiselect-left select").all("option").collect(&:text)
    expect(children_tables).not_to include @tables.map(&:name)
    expect(children_fields).not_to include @fields.map(&:name)
  end

  scenario 'Cancelling delete should not remove Table record from list', :js => true do
    table = FactoryBot.create :table, application: @application
    find_and_edit table.name
    within ('ul.nav-tabs') { click_link 'Delete' }
    expect(page).to have_content "Delete #{@module_info[:name]} '#{table.name}'"

    click_button "Cancel"
    within ('div.alert-info') { expect(page).to have_content("No actions were taken") }
    expect(page).to have_content "Edit #{@module_info[:name]} '#{table.name}'"
  end

  scenario 'Deleting Table object should remove data from list', :js => true do
    table = FactoryBot.create :table, application: @application
    find_and_edit table.name
    within ('ul.nav-tabs') { click_link 'Delete' }
    expect(page).to have_content "Delete #{@module_info[:name]} '#{table.name}'"

    click_button "Yes, I'm sure"
    within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully deleted") }
  end

  #  Export Functionality

  scenario 'Export Field data to csv', :js => true do
    FactoryBot.create_list :table, 10, application: @application
    export_from_dashboard do
      fill_in_filtering_select "csv_options_encoding_to", "UTF-8"
      fill_in_filtering_select "csv_options_generator_col_sep", ","
      expect(page).to have_button('Export to csv', disabled: false)
      click_button "Export to csv"
    end
  end

  scenario 'Export Field data to json', :js => true do
    FactoryBot.create_list :table, 10, application: @application
    export_from_dashboard do
      fill_in_filtering_select "csv_options_encoding_to", "UTF-8"
      fill_in_filtering_select "csv_options_generator_col_sep", ","
      expect(page).to have_button('Export to json', disabled: false)
      click_button "Export to json"
    end
  end

  scenario 'Export Field data to xml', :js => true do
    FactoryBot.create_list :table, 10, application: @application
    export_from_dashboard do
      fill_in_filtering_select "csv_options_encoding_to", "UTF-8"
      fill_in_filtering_select "csv_options_generator_col_sep", ","
      expect(page).to have_button('Export to csv', disabled: false)
      click_button "Export to xml"
    end
  end

  scenario 'Export buttons should be disabled if no field is selected' do
    FactoryBot.create_list :table, 10, application: @application
    export_from_dashboard do
      uncheck 'check_all'
      expect(page).to have_button('Export to csv', disabled: true)
      expect(page).to have_button('Export to json', disabled: true)
      expect(page).to have_button('Export to xml', disabled: true)
    end
  end

end