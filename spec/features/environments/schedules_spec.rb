require 'rails_helper'
require 'factories'

def fill_in_fields (options = {})
  fill_in 'schedule_name', with: options[:schedule_name] if options.has_key? :schedule_name
  fill_in 'schedule_description', with: options[:schedule_description] if options.has_key? :schedule_description
  fill_in 'schedule_key', with: options[:schedule_key] if options.has_key? :schedule_key
end

feature 'Schedule' do

  before(:all) do |example|
    set_module example.class.description
  end

  before(:each) do |example|
    user_login
  end

  after(:each) do |example|
    generate_screenshot example.description.parameterize
  end

  scenario 'Saving blank Schedule form should return an error', :js => true do
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
          schedule_name: "Test Schedule",
          schedule_description: "Test Schedule description",
      })
      click_button "Cancel"
      within ('div.alert-info') { expect(page).to have_content("No actions were taken") }
    end
  end

  scenario 'Adding Schedule with required fields should work', :js => true do
    add_new_module_item do
      fill_in_fields ({
          schedule_name: "Test Schedule",
          schedule_description: "Test Schedule description"
      })
      click_button "Save"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
    end
  end

  scenario 'Save and Add another should save Schedule and remain in the Schedule form page', :js => true do
    add_new_module_item do
      fill_in_fields ({
          schedule_name: "Test Schedule",
          schedule_description: "Test Schedule description"
      })
      click_button "Save and add another"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
      expect(page).to have_content "New #{@module_info[:name]}"
    end
  end

  scenario 'Save and Edit button should save Schedule record and remain in filled-up form page', :js => true do
    add_new_module_item do
      fill_in_fields ({
          schedule_name: "Test Schedule",
          schedule_description: "Test Schedule description"
      })
      click_button "Save and edit"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
      expect(page).to have_content "Edit #{@module_info[:name]}"
    end
  end

  scenario 'Saving duplicate name and key should not work', :js => true do
    schedule = FactoryBot.create :schedule, application: @application
    add_new_module_item do
      fill_in_fields ({
          schedule_name: "Test Schedule",
          schedule_description: "Test Schedule description"
      })
      click_button "Save and edit"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
      expect(page).to have_field "schedule_name", with: "Test Schedule"
      expect(page).to have_field "schedule_description", with: "Test Schedule description"
      expect(page).to have_field "schedule_key", with: "test_schedule"
    end

    check "override_key"
    within "#schedule_key_field" do
      expect(page).to have_field "schedule_key", readonly: false
      expect(page).to have_checked_field "override_key"
    end
    fill_in_fields ({
        schedule_name: schedule.name,
        schedule_key: schedule.key
    })
    click_button "Save and edit"
    within ('div.alert-danger') do
      expect(page).to have_content "#{@module_info[:name]} failed to be updated"
      expect(page).to have_content "- Name has already been taken"
      expect(page).to have_content "- Key has already been taken. Note: key is generated by converting name to lowercase and symbols to underscores by default."
    end

  end

  scenario 'Clicking Show should allow user to view Schedule information', :js => true do
    schedule = FactoryBot.create :schedule, application: @application
    visit "/admin"
    go_to_module_dashboard
    find_and_show schedule.name
    expect(page).to have_content "Details for #{@module_info[:name]} '#{schedule.name}'"
  end

  scenario 'Clicking Edit should allow user to update Schedule information', :js => true do
    add_new_module_item do
      fill_in_fields ({
          schedule_name: "Test Schedule",
          schedule_description: "Test Schedule description"
      })
      click_button "Save"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
    end

    find_and_edit "Test Schedule"
    fill_in_fields ({
        schedule_name: "Test Schedule new name",
        schedule_description: "Test Schedule new description"
    })
    click_button "Save and edit"
    expect(page).to have_content "#{@module_info[:name]} successfully updated"
    expect(page).to have_field "schedule_name", with: "Test Schedule new name"
    expect(page).to have_field "schedule_description", with: "Test Schedule new description"
  end

  scenario 'Cancelling delete should not remove Schedule record from list', :js => true do
    add_new_module_item do
      fill_in_fields ({
          schedule_name: "Test Schedule",
          schedule_description: "Test Schedule description"
      })
      click_button "Save"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
    end

    find_and_edit "Test Schedule"
    within ('ul.nav-tabs') { click_link 'Delete' }
    expect(page).to have_content "Delete #{@module_info[:name]} 'Test Schedule'"

    click_button "Cancel"
    within ('div.alert-info') { expect(page).to have_content("No actions were taken") }
    expect(page).to have_content "Edit #{@module_info[:name]} 'Test Schedule'"
  end

  scenario 'Deleting Schedule object should remove data from list', :js => true do
    add_new_module_item do
      fill_in_fields ({
          schedule_name: "Test Schedule",
          schedule_description: "Test Schedule description"
      })
      click_button "Save"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
    end

    find_and_edit "Test Schedule"
    within ('ul.nav-tabs') { click_link 'Delete' }
    expect(page).to have_content "Delete #{@module_info[:name]} 'Test Schedule'"

    click_button "Yes, I'm sure"
    within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully deleted") }
  end

  scenario 'Schedule added should appear in environment objects', :js => true do
    add_new_module_item do
      fill_in_fields ({ schedule_name: "Test Schedule", schedule_description: "Test Schedule description" })
      click_button "Save and edit"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
      expect(page).to have_field "schedule_key", with: "test_schedule"
    end

    @module_info = { name: "Environment", name_plural: "Environments", url: "/admin/environment?locale=en", navbar_path: ["Environments", "Environments"], via: "nav_path" }
    environment = FactoryBot.create :environment, name: "test", key: "test", application: @application
    find_and_edit environment.name
    expect(page).to have_field "environment[schedule_list[test_schedule[start]]]"
  end

  scenario 'Schedule edited should also be updated in environment objects' do
    add_new_module_item do
      fill_in_fields ({ schedule_name: "Test Schedule", schedule_description: "Test Schedule description" })
      click_button "Save and edit"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
      expect(page).to have_field "schedule_key", with: "test_schedule"
    end

    @module_info = { name: "Environment", name_plural: "Environments", url: "/admin/environment?locale=en", navbar_path: ["Environments", "Environments"], via: "nav_path" }
    environment = FactoryBot.create :environment, name: "test", key: "test", application: @application
    find_and_edit environment.name
    expect(page).to have_field "environment[schedule_list[test_schedule[start]]]"

    @module_info = { name: "Schedule", name_plural: "Schedules", url: "/admin/schedule?locale=en", navbar_path: ["Environments", "Schedules"], via: "nav_path" }
    find_and_edit "Test Schedule"
    fill_in_fields ({ schedule_name: "Test updated Schedule" })
    check "override_key"
    within "#schedule_key_field" do
      expect(page).to have_field "schedule_key", readonly: false
      expect(page).to have_checked_field "override_key"
    end
    fill_in_fields ({ schedule_key: "test_schedule_new_key" })
    click_button "Save"
    within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully updated") }

    @module_info = { name: "Environment", name_plural: "Environments", url: "/admin/environment?locale=en", navbar_path: ["Environments", "Environments"], via: "nav_path" }
    find_and_edit environment.name
    expect(page).to have_field "environment[schedule_list[test_schedule_new_key[start]]]"
    @module_info = { name: "Schedule", name_plural: "Schedules", url: "/admin/schedule?locale=en", navbar_path: ["Environments", "Schedules"], via: "nav_path" } # This is for the screenshot path
  end

  scenario 'Schedule deleted should be removed from the list of Schedules in environment objects' do
    add_new_module_item do
      fill_in_fields ({ schedule_name: "Test Schedule", schedule_description: "Test Schedule description" })
      click_button "Save and edit"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
      expect(page).to have_field "schedule_key", with: "test_schedule"
    end

    @module_info = { name: "Environment", name_plural: "Environments", url: "/admin/environment?locale=en", navbar_path: ["Environments", "Environments"], via: "nav_path" }
    environment = FactoryBot.create :environment, name: "test", key: "test", application: @application
    find_and_edit environment.name
    expect(page).to have_field "environment[schedule_list[test_schedule[start]]]"

    @module_info = { name: "Schedule", name_plural: "Schedules", url: "/admin/schedule?locale=en", navbar_path: ["Environments", "Schedules"], via: "nav_path" }
    find_and_edit "Test Schedule"

    within ('ul.nav-tabs') { click_link 'Delete' }
    expect(page).to have_content "Delete #{@module_info[:name]} 'Test Schedule'"

    click_button "Yes, I'm sure"
    within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully deleted") }

    @module_info = { name: "Environment", name_plural: "Environments", url: "/admin/environment?locale=en", navbar_path: ["Environments", "Environments"], via: "nav_path" }
    find_and_edit environment.name
    expect(page).not_to have_field "environment[schedule_list[test_schedule[start]]]"

  end


end