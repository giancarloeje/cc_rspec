require 'rails_helper'
require 'factories'

def fill_in_fields (options = {})
  fill_in 'screen_flow_name', with: options[:screen_flow_name] if options.has_key? :screen_flow_name
  fill_in 'screen_flow_description', with: options[:screen_flow_description] if options.has_key? :screen_flow_description

  if options.has_key? :screen_flow_key
    within "#screen_flow_key_field" do
      expect(page).to have_field "override_key", type: 'checkbox'
      check "override_key"
      expect(page).to have_field "screen_flow_key", readonly: false
      fill_in 'screen_flow_key', with: options[:screen_flow_key]
    end
  end

  check "screen_flow_queue_only" if (options.has_key? :screen_flow_queue_only) && ([true, "true", 1].include? options[:screen_flow_queue_only])
  uncheck "screen_flow_queue_only" if (options.has_key? :screen_flow_queue_only) && ([false, "false", 0].include? options[:screen_flow_queue_only])

  check "screen_flow_client_required" if (options.has_key? :screen_flow_client_required) && ([true, "true", 1].include? options[:screen_flow_client_required])
  uncheck "screen_flow_client_required" if (options.has_key? :screen_flow_client_required) && ([false, "false", 0].include? options[:screen_flow_client_required])

  check "screen_flow_save_new_record" if (options.has_key? :screen_flow_save_new_record) && ([true, "true", 1].include? options[:screen_flow_save_new_record])
  uncheck "screen_flow_save_new_record" if (options.has_key? :screen_flow_save_new_record) && ([false, "false", 0].include? options[:screen_flow_save_new_record])

  check "screen_flow_save_child_record" if (options.has_key? :screen_flow_save_child_record) && ([true, "true", 1].include? options[:screen_flow_save_child_record])
  uncheck "screen_flow_save_child_record" if (options.has_key? :screen_flow_save_child_record) && ([false, "false", 0].include? options[:screen_flow_save_child_record])

  check "screen_flow_overwrite" if (options.has_key? :screen_flow_overwrite) && ([true, "true", 1].include? options[:screen_flow_overwrite])
  uncheck "screen_flow_overwrite" if (options.has_key? :screen_flow_overwrite) && ([false, "false", 0].include? options[:screen_flow_overwrite])

  check "screen_flow_safe_mode" if (options.has_key? :screen_flow_safe_mode) && ([true, "true", 1].include? options[:screen_flow_safe_mode])
  uncheck "screen_flow_safe_mode" if (options.has_key? :screen_flow_safe_mode) && ([false, "false", 0].include? options[:screen_flow_safe_mode])

end

feature 'Screen flow' do

  before(:all) do |example|
    set_module example.class.description
  end

  before(:each) do |example|
    user_login
  end

  after(:each) do |example|
    generate_screenshot example.description.parameterize
  end

  scenario 'Saving blank Screen flow form should return an error', :js => true do
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
          screen_flow_name: "Test Screen flow",
          screen_flow_description: "Test Screen flow description",
      })
      click_button "Cancel"
      within ('div.alert-info') { expect(page).to have_content("No actions were taken") }
    end
  end

  scenario 'Adding Screen flow with required fields should work', :js => true do
    add_new_module_item do
      fill_in_fields ({
          screen_flow_name: "Test Screen flow",
          screen_flow_description: "Test Screen flow description",
          screen_flow_queue_only: true,
          screen_flow_client_required: true,
          screen_flow_save_new_record: true,
          screen_flow_overwrite: true,
          screen_flow_safe_mode: true
      })
      click_button "Save"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
    end
  end

  scenario 'Save and Add another should save Screen flow and remain in the Screen flow form page', :js => true do
    add_new_module_item do
      fill_in_fields ({
          screen_flow_name: "Test Screen flow",
          screen_flow_description: "Test Screen flow description"
      })
      click_button "Save and add another"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
      expect(page).to have_content "New #{@module_info[:name]}"
    end
  end

  scenario 'Save and Edit button should save Screen flow record and remain in filled-up form page', :js => true do
    add_new_module_item do
      fill_in_fields ({
          screen_flow_name: "Test Screen flow",
          screen_flow_description: "Test Screen flow description"
      })
      click_button "Save and edit"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
      expect(page).to have_content "Edit #{@module_info[:name]}"
    end
  end

  scenario 'Saving duplicate name and key should not work', :js => true do
    screen_flow = FactoryBot.create :screen_flow, application: @application
    add_new_module_item do
      fill_in_fields ({
          screen_flow_name: "Test Screen flow",
          screen_flow_description: "Test Screen flow description"
      })
      click_button "Save and edit"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
      expect(page).to have_field "screen_flow_name", with: "Test Screen flow"
      expect(page).to have_field "screen_flow_description", with: "Test Screen flow description"
      expect(page).to have_field "screen_flow_key", with: "test_screen_flow"
    end

    fill_in_fields ({
      screen_flow_name: screen_flow.name,
      screen_flow_key: screen_flow.key
    })
    click_button "Save and edit"
    within ('div.alert-danger') do
      expect(page).to have_content "#{@module_info[:name]} failed to be updated"
      expect(page).to have_content "- Name has already been taken"
      expect(page).to have_content "- Key has already been taken. Note: key is generated by converting name to lowercase and symbols to underscores by default."
    end

  end

  scenario 'Clicking Show should allow user to view Screen flow information', :js => true do
    screen_flow = FactoryBot.create :screen_flow, application: @application
    find_and_show screen_flow.name
    expect(page).to have_content "Details for #{@module_info[:name]} '#{screen_flow.name}'"
  end

  scenario 'Clicking Edit should allow user to update Screen flow information', :js => true do
    add_new_module_item do
      fill_in_fields ({
          screen_flow_name: "Test Screen flow",
          screen_flow_description: "Test Screen flow description"
      })
      click_button "Save"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
    end

    find_and_edit "Test Screen flow"
    fill_in_fields ({
        screen_flow_name: "Test Screen flow new name",
        screen_flow_description: "Test Screen flow new description"
    })
    click_button "Save and edit"
    expect(page).to have_content "#{@module_info[:name]} successfully updated"
    expect(page).to have_field "screen_flow_name", with: "Test Screen flow new name"
    expect(page).to have_field "screen_flow_description", with: "Test Screen flow new description"
  end

  scenario 'Cancelling delete should not remove Screen flow record from list', :js => true do
    add_new_module_item do
      fill_in_fields ({
          screen_flow_name: "Test Screen flow",
          screen_flow_description: "Test Screen flow description"
      })
      click_button "Save"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
    end

    find_and_edit "Test Screen flow"
    within ('ul.nav-tabs') { click_link 'Delete' }
    expect(page).to have_content "Delete #{@module_info[:name]} 'Test Screen flow'"

    click_button "Cancel"
    within ('div.alert-info') { expect(page).to have_content("No actions were taken") }
    expect(page).to have_content "Edit #{@module_info[:name]} 'Test Screen flow'"
  end

  scenario 'Deleting Screen flow object should remove data from list', :js => true do
    add_new_module_item do
      fill_in_fields ({
          screen_flow_name: "Test Screen flow",
          screen_flow_description: "Test Screen flow description"
      })
      click_button "Save"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
    end

    go_to_module_dashboard
    find_and_edit "Test Screen flow"
    within ('ul.nav-tabs') { click_link 'Delete' }
    expect(page).to have_content "Delete #{@module_info[:name]} 'Test Screen flow'"

    click_button "Yes, I'm sure"
    within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully deleted") }
  end

  scenario 'Either Save new record or Save child record but not both', :js => true do
    add_new_module_item do
      fill_in_fields ({
          screen_flow_name: "Test Screen flow",
          screen_flow_save_new_record: true,
          screen_flow_save_child_record: true
      })
      click_button "Save"
      within ('div.alert-danger') do
        expect(page).to have_content "#{@module_info[:name]} failed to be created"
        expect(page).to have_content "- Options under associations tab must have only one item selected"
      end
    end
  end

  # scenario 'Screens, Dataview360, Populate, Status flows, Modifiers, E-mails, and Screen flows modules should be available in Screen flow editor' do
  #   screen = FactoryBot.create :screen, application: @application
  #   dataview = FactoryBot.create :data_view_connector, application: @application
  #   populate = FactoryBot.create :populate_action, application: @application
  #   status_flow = FactoryBot.create :status_flow, application: @application
  #   modifier = FactoryBot.create :modifier, application: @application
  #   email = FactoryBot.create :email, application: @application
  #   screen_flow = FactoryBot.create :screen_flow, application: @application
  #
  #   visit "/admin"
  #   add_new_module_item do
  #     fill_in_fields ({
  #         screen_flow_name: "Test Screen flow",
  #         screen_flow_description: "Test Screen flow description"
  #     })
  #     click_button "Save and edit"
  #   end
  #
  #   within_frame('flowIframe') do
  #     within "#module-category-Screens" do
  #       expect(page).to have_content screen.name
  #     end
  #     within "#mmodule-category-Dataview360" do
  #       expect(page).to have_content dataview.name
  #     end
  #     within "#mmodule-category-Populate" do
  #       expect(page).to have_content populate.name
  #     end
  #     within "#mmodule-category-Status flows" do
  #       expect(page).to have_content status_flow.name
  #     end
  #     within "#mmodule-category-Modifiers" do
  #       expect(page).to have_content modifier.name
  #     end
  #     within "#module-category-E-mails" do
  #       expect(page).to have_content email.name
  #     end
  #     within "#module-category-Screen flows" do
  #       expect(page).to have_content screen_flow.name
  #     end
  #   end
  #
  # end


end