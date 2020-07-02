require 'rails_helper'
require 'factories'

def fill_in_fields (options = {})
  fill_in 'navigator_name', with: options[:navigator_name] if options.has_key? :navigator_name
  fill_in 'navigator_description', with: options[:navigator_description] if options.has_key? :navigator_description

  fill_in 'label', with: options[:navigator_label] if options.has_key? :navigator_label
  fill_in_filtering_select "screen_flows", options[:navigator_screen_flow] if options.has_key? :navigator_screen_flow
  fill_in_filtering_select "queues", options[:navigator_queues] if options.has_key? :navigator_queues
  fill_in 'link', with: options[:navigator_link] if options.has_key? :navigator_link

end

feature 'Navigator' do

  before(:all) do |example|
    set_module example.class.description
  end

  before(:each) do |example|
    user_login
  end

  after(:each) do |example|
    generate_screenshot example.description.parameterize
  end

  scenario 'Saving blank Navigator form should return an error', :js => true do |example|
    add_new_module_item do
      click_button "Save"
      within ('div.alert-danger') do
        expect(page).to have_content "#{@module_info[:name]} failed to be created"
        expect(page).to have_content "- Name can't be blank"
        RSpec::ExampleGroups
      end
    end
  end

  scenario 'Cancelling add should return no actions were taken', :js => true do
    add_new_module_item do
      fill_in_fields ({
          navigator_name: "Test Navigator",
          navigator_description: "Test Navigator description"
      })
      click_button "Cancel"
      within ('div.alert-info') { expect(page).to have_content("No actions were taken") }
    end
  end

  scenario 'Adding Navigator with required fields should work', :js => true do
    add_new_module_item do
      fill_in_fields ({
          navigator_name: "Test Navigator",
          navigator_description: "Test Navigator description"
      })
      click_button "Save"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
    end
  end

  scenario 'Save and Add another should save Navigator and remain in the Navigator form page', :js => true do
    add_new_module_item do
      fill_in_fields ({
          navigator_name: "Test Navigator",
          navigator_description: "Test Navigator description"
      })
      click_button "Save and add another"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
      expect(page).to have_content "New #{@module_info[:name]}"
    end
  end

  scenario 'Save and Edit button should save Navigator record and remain in filled-up form page', :js => true do
    add_new_module_item do
      fill_in_fields ({
          navigator_name: "Test Navigator",
          navigator_description: "Test Navigator description"
      })
      click_button "Save and edit"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
      expect(page).to have_content "Edit #{@module_info[:name]}"
    end
  end

  scenario 'Clicking Show should allow user to view Navigator information', :js => true do
    navigator = FactoryBot.create :navigator, application: @application
    visit "/admin"
    go_to_module_dashboard
    find_and_show navigator.name
    expect(page).to have_content "Details for #{@module_info[:name]} '#{navigator.name}'"
  end

  scenario 'Clicking Edit should allow user to update Navigator information', :js => true do
    add_new_module_item do
      fill_in_fields ({
          navigator_name: "Test Navigator",
          navigator_description: "Test Navigator description"
      })
      click_button "Save"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
    end

    find_and_edit "Test Navigator"
    fill_in_fields ({
        navigator_name: "Test Navigator new name",
        navigator_description: "Test Navigator new description"
    })
    click_button "Save and edit"
    expect(page).to have_content "#{@module_info[:name]} successfully updated"
    expect(page).to have_field "navigator_name", with: "Test Navigator new name"
    expect(page).to have_field "navigator_description", with: "Test Navigator new description"
  end

  scenario 'Saving duplicate name should not work', :js => true do
    navigator = FactoryBot.create :navigator, application: @application
    add_new_module_item do
      fill_in_fields ({
          navigator_name: "Test Navigator",
          navigator_description: "Test Navigator description"
      })
      click_button "Save and edit"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
      expect(page).to have_field "navigator_name", with: "Test Navigator"
      expect(page).to have_field "navigator_description", with: "Test Navigator description"
    end

    fill_in_fields ({
        navigator_name: navigator.name
    })
    click_button "Save and edit"
    within ('div.alert-danger') do
      expect(page).to have_content "#{@module_info[:name]} failed to be updated"
      expect(page).to have_content "- Name has already been taken"
    end

  end

  scenario 'Cancelling delete should not remove Navigator record from list', :js => true do
    add_new_module_item do
      fill_in_fields ({
          navigator_name: "Test Navigator",
          navigator_description: "Test Navigator description"
      })
      click_button "Save"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
    end

    find_and_edit "Test Navigator"
    within ('ul.nav-tabs') { click_link 'Delete' }
    expect(page).to have_content "Delete #{@module_info[:name]} 'Test Navigator'"

    click_button "Cancel"
    within ('div.alert-info') { expect(page).to have_content("No actions were taken") }
    expect(page).to have_content "Edit #{@module_info[:name]} 'Test Navigator'"
  end

  scenario 'Deleting Navigator object should remove data from list', :js => true do
    add_new_module_item do
      fill_in_fields ({
          navigator_name: "Test Navigator",
          navigator_description: "Test Navigator description"
      })
      click_button "Save"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
    end

    go_to_module_dashboard
    find_and_edit "Test Navigator"
    within ('ul.nav-tabs') { click_link 'Delete' }
    expect(page).to have_content "Delete #{@module_info[:name]} 'Test Navigator'"

    click_button "Yes, I'm sure"
    within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully deleted") }
  end

  # scenario "Should be able to modify Navigation menu items" do
  #
  #   screen_flows = FactoryBot.create_list :screen_flow, 5, application: @application
  #   queues = FactoryBot.create_list :filter, 5, application: @application
  #
  #   add_new_module_item
  #
  #   # Test Add menu
  #   click_button "Add menu item"
  #   within "#new_navigator > fieldset:nth-child(5) > div.controls.col-sm-12.control-group > div:nth-child(1)" do
  #     expect(page).to have_selector "li"
  #     find("ol li div ", text: "Label").click
  #   end
  #   within "#add_navigator > fieldset:nth-child(6) > div:nth-child(2) > div.controls.col-sm-6.content-editor" do
  #     fill_in_fields ({
  #         navigator_label: "Test Navigator",
  #         navigator_screen_flow: screen_flows.first.name
  #     })
  #     find("#link").click
  #   end
  #   within "#new_navigator > fieldset:nth-child(6) > div:nth-child(2) > div:nth-child(1)" do
  #     expect(page).to have_css "ol > li > div", text: "Test Navigator"
  #   end
  #
  #   # Test Remove menu
  #   click_button "Remove menu item"
  #   within "#new_navigator > fieldset:nth-child(5) > div.controls.col-sm-12.control-group > div:nth-child(1)" do
  #     expect(page).to have_no_selector "li"
  #   end
  #
  # end


end