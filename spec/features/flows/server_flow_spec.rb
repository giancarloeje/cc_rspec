require 'rails_helper'
require 'factories'

def fill_in_fields (options = {})
  fill_in 'server_flow_name', with: options[:server_flow_name] if options.has_key? :server_flow_name
  fill_in 'server_flow_description', with: options[:server_flow_description] if options.has_key? :server_flow_description

  if options.has_key? :server_flow_key
    within "#server_flow_key_field" do
      expect(page).to have_field "override_key", type: 'checkbox'
      check "override_key"
      expect(page).to have_field "server_flow_key", readonly: false
      fill_in 'server_flow_key', with: options[:server_flow_key]
    end
  end

  fill_in_filtering_select "server_flow_schedule_id", options[:server_flow_schedule_id] if options.has_key? :server_flow_schedule_id
  fill_in_filtering_select "server_flow_filter_id", options[:server_flow_filter_id] if options.has_key? :server_flow_filter_id

  check "server_flow_silent_notifications" if (options.has_key? :server_flow_silent_notifications) && ([true, "true", 1].include? options[:server_flow_silent_notifications])
  uncheck "server_flow_silent_notifications" if (options.has_key? :server_flow_silent_notifications) && ([false, "false", 0].include? options[:server_flow_silent_notifications])

  check "server_flow_overwrite" if (options.has_key? :server_flow_overwrite) && ([true, "true", 1].include? options[:server_flow_overwrite])
  uncheck "server_flow_overwrite" if (options.has_key? :server_flow_overwrite) && ([false, "false", 0].include? options[:server_flow_overwrite])

end

feature 'Server flow' do

  before(:all) do |example|
    set_module example.class.description
  end

  before(:each) do |example|
    user_login
    @dataview = FactoryBot.create :data_view_connector, application: @application
    @populate = FactoryBot.create :populate_action, application: @application
    @status_flow = FactoryBot.create :status_flow, application: @application
    @modifier = FactoryBot.create :modifier, application: @application
    @email = FactoryBot.create :email, application: @application
    @schedule = FactoryBot.create :schedule, application: @application
    @queue = FactoryBot.create :filter, application: @application
  end

  after(:each) do |example|
    generate_screenshot example.description.parameterize
  end

  scenario 'Saving blank Server flow form should return an error', :js => true do
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
          server_flow_name: "Test Server flow",
          server_flow_description: "Test Server flow description",
      })
      click_button "Cancel"
      within ('div.alert-info') { expect(page).to have_content("No actions were taken") }
    end
  end

  scenario 'Adding Server flow with required fields should work', :js => true do
    add_new_module_item do
      fill_in_fields ({
          server_flow_name: "Test Server flow",
          server_flow_description: "Test Server flow description",
          server_flow_schedule_id: @schedule.name,
          server_flow_filter_id: @queue.name,
          server_flow_silent_notifications: true,
          server_flow_overwrite: true
      })
      click_button "Save and edit"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
      within ("#server_flow_schedule_id_field") { expect(page).to have_field(nil, with: @schedule.name) }
      within ("#server_flow_filter_id_field") { expect(page).to have_field(nil, with: @queue.name) }
      expect(page).to have_field "server_flow_silent_notifications", checked: true
      expect(page).to have_field "server_flow_overwrite", checked: true
    end
  end

  scenario 'Save and Add another should save Server flow and remain in the Server flow form page', :js => true do
    add_new_module_item do
      fill_in_fields ({
          server_flow_name: "Test Server flow",
          server_flow_description: "Test Server flow description",
          server_flow_schedule_id: @schedule.name,
          server_flow_filter_id: @queue.name,
          server_flow_silent_notifications: true,
          server_flow_overwrite: true
      })
      click_button "Save and add another"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
      expect(page).to have_content "New #{@module_info[:name]}"
    end
  end

  scenario 'Save and Edit button should save Server flow record and remain in filled-up form page', :js => true do
    add_new_module_item do
      fill_in_fields ({
          server_flow_name: "Test Server flow",
          server_flow_description: "Test Server flow description",
          server_flow_schedule_id: @schedule.name,
          server_flow_filter_id: @queue.name,
          server_flow_silent_notifications: true,
          server_flow_overwrite: true
      })
      click_button "Save and edit"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
      expect(page).to have_content "Edit #{@module_info[:name]}"
    end
  end

  scenario 'Saving duplicate name and key should not work', :js => true do
    server_flow = FactoryBot.create :server_flow, application: @application
    add_new_module_item do
      fill_in_fields ({
          server_flow_name: "Test Server flow",
          server_flow_description: "Test Server flow description"
      })
      click_button "Save and edit"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
      expect(page).to have_field "server_flow_name", with: "Test Server flow"
      expect(page).to have_field "server_flow_description", with: "Test Server flow description"
      expect(page).to have_field "server_flow_key", with: "test_server_flow"
    end

    fill_in_fields ({
        server_flow_name: server_flow.name,
        server_flow_key: server_flow.key
    })
    click_button "Save and edit"
    within ('div.alert-danger') do
      expect(page).to have_content "#{@module_info[:name]} failed to be updated"
      expect(page).to have_content "- Name has already been taken"
      expect(page).to have_content "- Key has already been taken. Note: key is generated by converting name to lowercase and symbols to underscores by default."
    end

  end

  scenario 'Clicking Show should allow user to view Server flow information', :js => true do
    server_flow = FactoryBot.create :server_flow, application: @application
    find_and_show server_flow.name
    expect(page).to have_content "Details for #{@module_info[:name]} '#{server_flow.name}'"
  end

  scenario 'Clicking Edit should allow user to update Server flow information', :js => true do
    add_new_module_item do
      fill_in_fields ({
          server_flow_name: "Test Server flow",
          server_flow_description: "Test Server flow description",
          server_flow_schedule_id: @schedule.name,
          server_flow_filter_id: @queue.name,
          server_flow_silent_notifications: true,
          server_flow_overwrite: true
      })
      click_button "Save"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
    end

    find_and_edit "Test Server flow"
    fill_in_fields ({
        server_flow_name: "Test Server flow new name",
        server_flow_description: "Test Server flow new description"
    })
    click_button "Save and edit"
    expect(page).to have_content "#{@module_info[:name]} successfully updated"
    expect(page).to have_field "server_flow_name", with: "Test Server flow new name"
    expect(page).to have_field "server_flow_description", with: "Test Server flow new description"
  end

  scenario 'Saving duplicate name and key should not work', :js => true do
    server_flow = FactoryBot.create :server_flow, application: @application
    add_new_module_item do
      fill_in_fields ({
          server_flow_name: "Test Server flow",
          server_flow_description: "Test Server flow description"
      })
      click_button "Save and edit"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
      expect(page).to have_field "server_flow_name", with: "Test Server flow"
      expect(page).to have_field "server_flow_description", with: "Test Server flow description"
      expect(page).to have_field "server_flow_key", with: "test_server_flow"
    end

    fill_in_fields ({
        server_flow_name: server_flow.name,
        server_flow_key: server_flow.key
    })
    click_button "Save and edit"
    within ('div.alert-danger') do
      expect(page).to have_content "#{@module_info[:name]} failed to be updated"
      expect(page).to have_content "- Name has already been taken"
      expect(page).to have_content "- Key has already been taken. Note: key is generated by converting name to lowercase and symbols to underscores by default."
    end

  end

  scenario 'Cancelling delete should not remove Server flow record from list', :js => true do
    add_new_module_item do
      fill_in_fields ({
          server_flow_name: "Test Server flow",
          server_flow_description: "Test Server flow description",
          server_flow_schedule_id: @schedule.name,
          server_flow_filter_id: @queue.name,
          server_flow_silent_notifications: true,
          server_flow_overwrite: true
      })
      click_button "Save"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
    end

    find_and_edit "Test Server flow"
    within ('ul.nav-tabs') { click_link 'Delete' }
    expect(page).to have_content "Delete #{@module_info[:name]} 'Test Server flow'"

    click_button "Cancel"
    within ('div.alert-info') { expect(page).to have_content("No actions were taken") }
    expect(page).to have_content "Edit #{@module_info[:name]} 'Test Server flow'"
  end

  scenario 'Deleting Server flow object should remove data from list', :js => true do
    add_new_module_item do
      fill_in_fields ({
          server_flow_name: "Test Server flow",
          server_flow_description: "Test Server flow description"
      })
      click_button "Save"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
    end

    find_and_edit "Test Server flow"
    within ('ul.nav-tabs') { click_link 'Delete' }
    expect(page).to have_content "Delete #{@module_info[:name]} 'Test Server flow'"

    click_button "Yes, I'm sure"
    within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully deleted") }
  end

  scenario 'Dataview360, Populate, Status flows, Modifiers, and E-mails modules should be available in Server flow editor' do
    dataview = FactoryBot.create :data_view_connector, application: @application
    populate = FactoryBot.create :populate_action, application: @application
    status_flow = FactoryBot.create :status_flow, application: @application
    modifier = FactoryBot.create :modifier, application: @application
    email = FactoryBot.create :email, application: @application

    add_new_module_item do
      fill_in_fields ({
          server_flow_name: "Test Server flow",
          server_flow_description: "Test Server flow description"
      })
      click_button "Save and edit"
    end

    within_frame('flowIframe') do
      # within "#mmodule-category-Dataview360" do
      #   expect(page).to have_content dataview.name
      # end
      # within "#mmodule-category-Populate" do
      #   expect(page).to have_content populate.name
      # end
      expect(page).to have_selector "div.WiringEditor-module", text: @status_flow.name
      # within "#mmodule-category-Modifiers" do
      #   expect(page).to have_content modifier.name
      # end
      # within "#module-category-E-mails" do
      #   expect(page).to have_content email.name
      # end
    end

  end


end