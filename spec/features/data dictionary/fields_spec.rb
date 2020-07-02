require 'rails_helper'
require 'factories'

def fill_in_fields (options = {})
  fill_in "field_name", with: options[:field_name] if options.has_key? :field_name
  fill_in "field_description", with: options[:field_description] if options.has_key? :field_description
  fill_in_filtering_select "field_field_type", options[:field_field_type] if options.has_key? :field_field_type
  fill_in "field_default_value", with: options[:field_default_value] if options.has_key? :field_default_value
  fill_in_filtering_select "field_table_id", options[:field_table_id] if options.has_key? :field_table_id
  check "field_enable_index" if (options.has_key? :field_enable_index) && ([true, "true", 1].include? options[:field_enable_index])
  uncheck "field_enable_index" if (options.has_key? :field_enable_index) && ([false, "false", 0].include? options[:field_enable_index])
  check "field_is_protected" if (options.has_key? :field_is_protected) && ([true, "true", 1].include? options[:field_is_protected])
  uncheck "field_is_protected" if (options.has_key? :field_is_protected) && ([false, "false", 0].include? options[:field_is_protected])
  check "field_is_encrypted" if (options.has_key? :field_is_encrypted) && ([true, "true", 1].include? options[:field_is_encrypted])
  uncheck "field_is_encrypted" if (options.has_key? :field_is_encrypted) && ([false, "false", 0].include? options[:field_is_encrypted])

end

# Custom method for field type to cover alert when changing type on edit
def field_type_filtering_select field_type
  within(:xpath, "//select[@id='field_field_type']/ancestor::div[contains(@class, 'form-group')]") { find("span.input-group-btn").click }
  expect(page).to have_selector ".ui-autocomplete"
  accept_alert { within("ul.ui-autocomplete") { find("li", text: field_type).click } }
end

feature 'Fields' do

  before(:all) do
    user_login
    @tables = FactoryBot.create_list :table, 5, application: @application
    set_module "Field"
    @count = 1
  end

  before(:each) do
    login_as(@user, :scope => :user)
    visit "/admin"
    go_to_module_dashboard
  end

  after(:each) do
    save_screenshot("Screenshots/features/actions/#{@module_info[:name]}/#{@count}_#{DateTime.now.strftime('%s')}.png", full: true)
    @count = @count + 1
  end

  scenario 'Field Type field should have correct options', :js => true do
    add_new_module_item
    within("#field_field_type_field") {
      find("label[title='Show All Items']").click
    }
    field_types = find("#ui-id-1").all("li a").collect(&:text)
    expect(field_types).to match_array(["String", "String (Case Insensitive)", "Integer", "Float", "BigDecimal", "Money", "Date", "File"])
  end

  scenario 'Saving blank Field form should return an error', :js => true do
    add_new_module_item do
      click_button "Save"
      within ('div.alert-danger') do
        expect(page).to have_content "#{@module_info[:name]} failed to be created"
        expect(page).to have_content "- Name can't be blank"
        expect(page).to have_content "- Key can't be blank"
        expect(page).to have_content "- Key should start with alphabet or underscore followed by any alphanumeric character or underscore"
      end
    end
  end

  scenario 'Cancelling add should return no actions were taken', :js => true do
    add_new_module_item do
      fill_in_fields ({
          field_name: "Test Field name",
          field_description: "Test Field description",
          field_field_type: "String",
          field_default_value: "Hello",
          field_table_id: @tables.first.name,
          field_enable_index: true,
          field_is_protected: false,
          field_is_encrypted: false
      })
      click_button "Cancel"
      within ('div.alert-info') { expect(page).to have_content("No actions were taken") }
    end
  end

  scenario 'When an invalid default value is entered it should return an error', :js => true do
    add_new_module_item
    fill_in_fields ({
        field_name: "Test Field name",
        field_description: "Test Field description",
        field_field_type: "String",
        field_default_value: "String",
    })
    click_button "Save and edit"
    within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }

    # BigDecimal
    field_type_filtering_select "BigDecimal"
    fill_in_fields  field_default_value: "string value"
    click_button "Save and edit"
    within ('div.alert-danger.alert-dismissible') { expect(page).to have_content '- Default value - invalid value for BigDecimal: "string value"' }

    fill_in_fields  field_default_value: "123.45"
    click_button "Save and edit"
    within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully updated") }

    # Integer
    field_type_filtering_select "Integer"
    fill_in_fields  field_default_value: "string value"
    click_button "Save and edit"
    within ('div.alert-danger.alert-dismissible') { expect(page).to have_content '- Default value - invalid value for Integer: "string value"' }

    fill_in_fields  field_default_value: "123.45"
    click_button "Save and edit"
    within ('div.alert-danger.alert-dismissible') { expect(page).to have_content '- Default value - invalid value for Integer: "123.45"' }

    fill_in_fields  field_default_value: "123"
    click_button "Save and edit"
    within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully updated") }

    # Float
    field_type_filtering_select "Float"
    fill_in_fields  field_default_value: "string value"
    click_button "Save and edit"
    within ('div.alert-danger.alert-dismissible') { expect(page).to have_content '- Default value - invalid value for Float: "string value"' }

    fill_in_fields  field_default_value: "123"
    click_button "Save and edit"
    within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully updated") }

    fill_in_fields  field_default_value: "123.45"
    click_button "Save and edit"
    within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully updated") }

    # Money
    field_type_filtering_select "Money"
    fill_in_fields  field_default_value: "string value"
    click_button "Save and edit"
    within ('div.alert-danger.alert-dismissible') { expect(page).to have_content '- Default value - invalid value for BigDecimal: "string value"' }

    fill_in_fields  field_default_value: "123.45"
    click_button "Save and edit"
    within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully updated") }

    # Date
    field_type_filtering_select "Date"
    fill_in_fields  field_default_value: "string value"
    click_button "Save and edit"
    within ('div.alert-danger.alert-dismissible') { expect(page).to have_content '- Default value - invalid value for Date: "string value"' }

    fill_in_fields  field_default_value: "32/01/2020"
    click_button "Save and edit"
    within ('div.alert-danger.alert-dismissible') { expect(page).to have_content '- Default value - invalid value for Date: "32/01/2020"' }

    fill_in_fields  field_default_value: "01/01/2020"
    click_button "Save and edit"
    within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully updated") }
  end

  scenario 'Adding Field with required fields should work', :js => true do
    add_new_module_item do
      fill_in_fields ({
          field_name: "Test Field name",
          field_description: "Test Field description",
          field_field_type: "String",
          field_default_value: "Hello",
          field_table_id: @tables.first.name,
          field_enable_index: true,
          field_is_protected: false,
          field_is_encrypted: false
      })
      click_button "Save"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
    end
  end

  scenario 'Save and Add Another should save Field record and remain in the form page', :js => true do
    add_new_module_item do
      fill_in_fields ({
          field_name: "Test Field name",
          field_description: "Test Field description",
          field_field_type: "String"
      })
      click_button "Save and add another"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
      expect(page).to have_content "New #{@module_info[:name]}"
    end
  end

  scenario 'Save and Edit should save Field record and remain in filled-up form page', :js => true do
    add_new_module_item do
      fill_in_fields ({
          field_name: "Test Field name",
          field_description: "Test Field description",
          field_field_type: "String"
      })
      click_button "Save and edit"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
      expect(page).to have_content "Edit #{@module_info[:name]}"
    end
  end

  scenario 'Clicking Show should allow user to view Field information', :js => true do
    field = FactoryBot.create :field, application: @application
    visit "/admin"
    go_to_module_dashboard
    find_and_show field.name
    expect(page).to have_content "Details for #{@module_info[:name]} '#{field.name}'"
  end

  scenario 'Clicking Edit should allow user to update Field information', :js => true do
    add_new_module_item do
      fill_in_fields ({
          field_name: "Test Field name",
          field_description: "Test Field description",
          field_field_type: "String"
      })
      click_button "Save"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
    end

    visit "/admin"
    go_to_module_dashboard
    find_and_edit "Test Field name"
    fill_in_fields ({
        field_name: "Test Field new name",
        field_description: "Test Field new description"
    })
    click_button "Save and edit"
    expect(page).to have_content "#{@module_info[:name]} successfully updated"
    expect(page).to have_field "field_name", with: "Test Field new name"
    expect(page).to have_field "field_description", with: "Test Field new description"
  end

  scenario 'Cancelling delete should not remove Field record from list', :js => true do
    add_new_module_item do
      fill_in_fields ({
          field_name: "Test Field",
          field_description: "Test Field description"
      })
      click_button "Save"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
    end

    visit "/admin"
    go_to_module_dashboard
    find_and_edit "Test Field"
    within ('ul.nav-tabs') { click_link 'Delete' }
    expect(page).to have_content "Delete #{@module_info[:name]} 'Test Field'"

    click_button "Cancel"
    within ('div.alert-info') { expect(page).to have_content("No actions were taken") }
    expect(page).to have_content "Edit #{@module_info[:name]} 'Test Field'"
  end

  scenario 'Deleting Field object should remove data from list', :js => true do
    add_new_module_item do
      fill_in_fields ({
          field_name: "Test Field",
          field_description: "Test Field description"
      })
      click_button "Save"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
    end

    go_to_module_dashboard
    find_and_edit "Test Field"
    within ('ul.nav-tabs') { click_link 'Delete' }
    expect(page).to have_content "Delete #{@module_info[:name]} 'Test Field'"

    click_button "Yes, I'm sure"
    within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully deleted") }
    expect(page).to have_content "Nothing to display"
  end

  #  Export Functionality

  scenario 'Export Field data to csv', :js => true do
    FactoryBot.create_list :field, 10, application: @application
    export_from_dashboard do
      fill_in_filtering_select "csv_options_encoding_to", "UTF-8"
      fill_in_filtering_select "csv_options_generator_col_sep", ","
      expect(page).to have_button('Export to csv', disabled: false)
      click_button "Export to csv"
    end
  end

  scenario 'Export Field data to json', :js => true do
    FactoryBot.create_list :field, 10, application: @application
    export_from_dashboard do
      fill_in_filtering_select "csv_options_encoding_to", "UTF-8"
      fill_in_filtering_select "csv_options_generator_col_sep", ","
      expect(page).to have_button('Export to json', disabled: false)
      click_button "Export to json"
    end
  end

  scenario 'Export Field data to xml', :js => true do
    FactoryBot.create_list :field, 10, application: @application
    export_from_dashboard do
      fill_in_filtering_select "csv_options_encoding_to", "UTF-8"
      fill_in_filtering_select "csv_options_generator_col_sep", ","
      expect(page).to have_button('Export to csv', disabled: false)
      click_button "Export to xml"
    end
  end

  scenario 'Export buttons should be disabled if no field is selected' do
    FactoryBot.create_list :field, 10, application: @application
    export_from_dashboard do
      uncheck 'check_all'
      expect(page).to have_button('Export to csv', disabled: true)
      expect(page).to have_button('Export to json', disabled: true)
      expect(page).to have_button('Export to xml', disabled: true)
    end
  end

end