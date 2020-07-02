require 'rails_helper'
require 'factories'

def fill_in_fields (options = {})
  fill_in 'data_extract_name', with: options[:data_extract_name] if options.has_key? :data_extract_name
  fill_in 'data_extract_description', with: options[:data_extract_description] if options.has_key? :data_extract_description

  fill_in_filtering_select "data_extract_separator", options[:data_extract_separator] if options.has_key? :data_extract_separator
  fill_in_filtering_select "data_extract_storage_type", options[:data_extract_storage_type] if options.has_key? :data_extract_storage_type
  fill_in 'data_extract_file_path', with: options[:data_extract_file_path] if options.has_key? :data_extract_file_path
  fill_in_filtering_select "data_extract_schedule_id", options[:data_extract_schedule_id] if options.has_key? :data_extract_schedule_id
  fill_in_filtering_select "data_extract_filter_id", options[:data_extract_filter_id] if options.has_key? :data_extract_filter_id

  check "data_extract_remove_newline" if (options.has_key? :data_extract_remove_newline) && ([true, "true", 1].include? options[:data_extract_remove_newline])
  uncheck "data_extract_remove_newline" if (options.has_key? :data_extract_remove_newline) && ([false, "false", 0].include? options[:data_extract_remove_newline])

  if (options.has_key? :fields)

  end

end

feature 'Data Extract' do

  before(:all) do |example|
    set_module example.class.description
  end

  before(:each) do |example|
    user_login
  end

  after(:each) do |example|
    generate_screenshot example.description.parameterize
  end


  scenario 'Saving blank Data Extract form should return an error', :js => true do
    add_new_module_item do
      click_button "Save"
      within ('div.alert-danger') do
        expect(page).to have_content "#{@module_info[:name]} failed to be created"
        expect(page).to have_content "- Name can't be blank"
        expect(page).to have_content "- Key can't be blank"
        expect(page).to have_content "- Key should contain alpha numeric and underscore characters only"
        expect(page).to have_content "- File path can't be blank"
      end
    end
  end

  scenario 'Cancelling add should return no actions were taken', :js => true do
    add_new_module_item do
      fill_in_fields ({
          data_extract_name: "Test Data Extract",
          data_extract_description: "Test Field description"
      })
      click_button "Cancel"
      within ('div.alert-info') { expect(page).to have_content("No actions were taken") }
    end
  end

  scenario 'Saving name with number only should not work', :js => true do
    add_new_module_item do
      fill_in_fields ({
          data_extract_name: "Test Data Extract",
          data_extract_description: "Test Field description",
          data_extract_separator: ",",
          data_extract_storage_type: "S3 bucket",
          data_extract_file_path: "test/path"
      })
      click_button "Save"
      within ('div.alert-danger') do
        expect(page).to have_content "- File path can't be blank"
        expect(page).to have_content "- Key should contain alpha numeric and underscore characters only"
      end
    end
  end

  scenario 'Adding required fields should work', :js => true do
    schedule = FactoryBot.create :schedule, application: @application
    filter = FactoryBot.create :filter, application: @application

    add_new_module_item do
      fill_in_fields ({
          data_extract_name: "Test Data Extract",
          data_extract_description: "Test Field description",
          data_extract_separator: ",",
          data_extract_storage_type: "S3 bucket",
          data_extract_file_path: "test/path",
          data_extract_schedule_id: schedule.name,
          data_extract_filter_id: filter.name,
          data_extract_remove_newline: true,
          data_extract_remove_newline: true
      })
      click_button "Save and edit"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
    end
  end

  scenario 'Save and Add another button should save data extract and remain in the form page', :js => true do
    add_new_module_item do
      fill_in_fields ({
          data_extract_name: "Test Data Extract",
          data_extract_description: "Test Field description",
          data_extract_separator: ",",
          data_extract_storage_type: "S3 bucket",
          data_extract_file_path: "test/path"
      })
      click_button "Save and add another"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
      expect(page).to have_content "New #{@module_info[:name]}"
    end
  end

  scenario 'Save and Edit button should save data extract and remain in filled-up form page', :js => true do
    add_new_module_item do
      fill_in_fields ({
          data_extract_name: "Test Data Extract",
          data_extract_description: "Test Field description",
          data_extract_separator: ",",
          data_extract_storage_type: "S3 bucket",
          data_extract_file_path: "test/path"
      })
      click_button "Save and edit"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
      expect(page).to have_content "Edit #{@module_info[:name]}"
    end
  end

  scenario 'Clicking Show should allow user to view Data Extract information', :js => true do
    add_new_module_item do
      fill_in_fields ({
          data_extract_name: "Test Data Extract",
          data_extract_description: "Test Field description",
          data_extract_separator: ",",
          data_extract_storage_type: "S3 bucket",
          data_extract_file_path: "test/path"
      })
      click_button "Save"
    end
    within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }

    find_and_show "Test Data Extract"
    expect(page).to have_content "Details for #{@module_info[:name]} 'Test Data Extract'"
  end

  scenario 'Clicking Edit should allow user to update Data Extract Information', :js => true do
    add_new_module_item do
      fill_in_fields ({
          data_extract_name: "Test Data Extract",
          data_extract_description: "Test Field description",
          data_extract_separator: ",",
          data_extract_storage_type: "S3 bucket",
          data_extract_file_path: "test/path"
      })
      click_button "Save"
    end
    within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }

    find_and_edit "Test Data Extract"
    fill_in_fields ({
        data_extract_name: "Data Extract new name",
        data_extract_description: "Data Extract new description"
    })
    click_button "Save and edit"
    expect(page).to have_content "#{@module_info[:name]} successfully updated"
    expect(page).to have_field "data_extract_name", with: "Data Extract new name"
    expect(page).to have_field "data_extract_description", with: "Data Extract new description"
  end

  scenario 'Cancelling delete should not remove Data Extract record from list', :js => true do
    add_new_module_item do
      fill_in_fields ({
          data_extract_name: "Test Data Extract",
          data_extract_description: "Test Field description",
          data_extract_separator: ",",
          data_extract_storage_type: "S3 bucket",
          data_extract_file_path: "test/path"
      })
      click_button "Save"
    end

    find_and_edit "Test Data Extract"
    within ('ul.nav-tabs') { click_link 'Delete' }
    expect(page).to have_content "Delete #{@module_info[:name]} 'Test Data Extract'"

    click_button "Cancel"
    within ('div.alert-info') { expect(page).to have_content("No actions were taken") }
    expect(page).to have_content "Edit #{@module_info[:name]} 'Test Data Extract'"
  end

  scenario 'Deleting Data Extract object should remove data from list', :js => true do
    add_new_module_item do
      fill_in_fields ({
          data_extract_name: "Test Data Extract",
          data_extract_description: "Test Field description",
          data_extract_separator: ",",
          data_extract_storage_type: "S3 bucket",
          data_extract_file_path: "test/path"
      })
      click_button "Save"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
    end

    find_and_edit "Test Data Extract"
    within ('ul.nav-tabs') { click_link 'Delete' }
    expect(page).to have_content "Delete #{@module_info[:name]} 'Test Data Extract'"

    click_button "Yes, I'm sure"
    within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully deleted") }
  end

  scenario 'Saving duplicate name and key should not work', :js => true do
    data_extract = FactoryBot.create :data_extract, application: @application
    add_new_module_item do
      fill_in_fields ({
          data_extract_name: data_extract.name,
          data_extract_description: "Test Field description",
          data_extract_separator: ",",
          data_extract_storage_type: "S3 bucket",
          data_extract_file_path: "test/path"
      })
      click_button "Save and edit"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
      expect(page).to have_field "schedule_name", with: "Test Schedule"
      expect(page).to have_field "schedule_description", with: "Test Schedule description"
      expect(page).to have_field "schedule_key", with: "test_schedule"
    end

    check "override_key"
    within "#data_extract_key_field" do
      expect(page).to have_field "data_extract_key", readonly: false
      expect(page).to have_checked_field "override_key"
    end
    fill_in_fields ({
        schedule_name: data_extract.name,
        schedule_key: data_extract.key
    })
    click_button "Save and edit"
    within ('div.alert-danger') do
      expect(page).to have_content "#{@module_info[:name]} failed to be updated"
      expect(page).to have_content "- Name has already been taken"
      expect(page).to have_content "- Key has already been taken. Note: key is generated by converting name to lowercase and symbols to underscores by default."
    end
  end

  scenario 'Update field selection' do
    table = FactoryBot.create :table, application: @application
    table_fields = FactoryBot.create_list :field, 20, application: @application, table: table
    root_fields = FactoryBot.create_list :field, 20, application: @application
    add_new_module_item do
      fill_in_fields ({
          data_extract_name: "Test Data Extract",
          data_extract_description: "Test Field description",
          data_extract_separator: ",",
          data_extract_storage_type: "S3 bucket",
          data_extract_file_path: "test/path"
      })
      within "#ol-container" do
        click_button "Select / Deselect All" # Default is selected but button need to be clicked twice to deselect all
        click_button "Select / Deselect All"

        within "li div[data-key='#{root_fields.first.key}']" do
          check
          find("span.de-show-name").click
          expect(page).to have_field(with: root_fields.first.key, type: "text")
          find("input[type='text']").set("#{root_fields.first.key} Field")
          find("span.de-show-name").click
        end

        within :xpath, "//div[@id='ol-container']//div[@data-key='#{table.key}']/parent::li" do
          within :xpath, "//div[@id='ol-container']//div[@data-key='#{table.key}']" do
            check
            find("span.disclose").click #open
          end
          expect(page).to have_xpath "//ol"

          within :xpath, "ol" do
            elems = find_all ("li > div:first-child")
            expect(elems.map{|elem| elem["data-key"]}.sort).to eq table_fields.map(&:key).sort #checks that all fields under table are correct
          end

        end

      end
      # click_button "Save and edit"
    end
  end


end