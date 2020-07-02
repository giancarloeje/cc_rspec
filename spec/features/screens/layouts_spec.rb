require 'rails_helper'
require 'factories'

def fill_in_fields (options = {})
  fill_in 'layout_name', with: options[:layout_name] if options.has_key? :layout_name
  fill_in 'layout_description', with: options[:layout_description] if options.has_key? :layout_description
  if options.has_key? :layout_key
    check "override_key"
    within "#layout_key_field" do
      expect(page).to have_field "layout_key", readonly: false
      expect(page).to have_checked_field "override_key"
    end
    fill_in 'layout_key', with: options[:layout_key]
  end
end

feature 'Layout' do
  before(:all) do |example|
    set_module example.class.description
  end

  before(:each) do |example|
    user_login
  end

  after(:each) do |example|
    generate_screenshot example.description.parameterize
  end


  scenario 'Saving blank layout should return an error', :js => true do
    add_new_module_item do
      click_button "Save"
      within ('div.alert-danger') do
        expect(page).to have_content "#{@module_info[:name]} failed to be created"
        expect(page).to have_content "- Name can't be blank"
      end
    end
  end

  scenario 'Cancelling add should return no actions were taken', :js => true do
    add_new_module_item do
      fill_in_fields ({
          layout_name: "Test layout",
          layout_description: "Test layout description"
      })
      click_button "Cancel"
      within ('div.alert-info') { expect(page).to have_content("No actions were taken") }
    end
  end

  scenario 'Adding required fields should work', :js => true do
    add_new_module_item do
      fill_in_fields ({
          layout_name: "Test layout",
          layout_description: "Test layout description"
      })
      click_button "Save and edit"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
    end
  end

  scenario 'Save and Add another button should save layout object and remain in the layout page', :js => true do
    add_new_module_item do
      fill_in_fields ({
          layout_name: "Test layout",
          layout_description: "Test layout description"
      })
      click_button "Save and add another"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
      expect(page).to have_content "New #{@module_info[:name]}"
    end
  end

  scenario 'Save and Edit button should save layout object and remain in filled-up layout page', :js => true do
    add_new_module_item do
      fill_in_fields ({
          layout_name: "Test layout",
          layout_description: "Test layout description"
      })
      click_button "Save and edit"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
      expect(page).to have_content "Edit #{@module_info[:name]}"
    end
  end

  scenario 'Clicking Show should allow user to view layout object in show mode', :js => true do
    add_new_module_item do
      fill_in_fields ({
          layout_name: "Test layout",
          layout_description: "Test layout description"
      })
      click_button "Save"
    end
    within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }

    find_and_show "Test layout"
    expect(page).to have_content "Details for #{@module_info[:name]} 'Test layout'"
  end

  scenario 'Clicking Edit should allow user to update layout object', :js => true do
    add_new_module_item do
      fill_in_fields ({
          layout_name: "Test layout",
          layout_description: "Test layout description"
      })
      click_button "Save"
    end
    within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }

    find_and_edit "Test layout"
    fill_in_fields ({
        layout_name: "Test layout new name",
        layout_description: "Test layout new description"
    })
    click_button "Save and edit"
    expect(page).to have_content "#{@module_info[:name]} successfully updated"
    expect(page).to have_field "layout_name", with: "Test layout new name"
    expect(page).to have_field "layout_description", with: "Test layout new description"
  end

  scenario 'Cancelling delete should not remove layout object from list', :js => true do
    add_new_module_item do
      fill_in_fields ({
          layout_name: "Test layout",
          layout_description: "Test layout description"
      })
      click_button "Save"
    end

    find_and_edit "Test layout"
    within ('ul.nav-tabs') { click_link 'Delete' }
    expect(page).to have_content "Delete #{@module_info[:name]} 'Test layout'"

    click_button "Cancel"
    within ('div.alert-info') { expect(page).to have_content("No actions were taken") }
    expect(page).to have_content "Edit #{@module_info[:name]} 'Test layout'"
  end

  scenario 'Deleting layout object should remove data from list', :js => true do
    add_new_module_item do
      fill_in_fields ({
          layout_name: "Test layout",
          layout_description: "Test layout description"
      })
      click_button "Save"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
    end

    find_and_edit "Test layout"
    within ('ul.nav-tabs') { click_link 'Delete' }
    expect(page).to have_content "Delete #{@module_info[:name]} 'Test layout'"

    click_button "Yes, I'm sure"
    within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully deleted") }
  end

  scenario 'Saving duplicate name should not work', :js => true do
    layout = FactoryBot.create :layout, application: @application
    layout2 = FactoryBot.create :layout, application: @application
    find_and_edit layout2.name
    fill_in_fields ({
        layout_name: layout.name,
        layout_description: "Test layout description"
    })
    click_button "Save and edit"
    within ('div.alert-danger') do
      expect(page).to have_content "#{@module_info[:name]} failed to be updated"
      expect(page).to have_content "- Name has already been taken"
    end

  end

end