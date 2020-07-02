require 'rails_helper'
require 'factories'

def fill_in_fields (options = {})
  fill_in 'style_name', with: options[:style_name] if options.has_key? :style_name
  fill_in 'style_description', with: options[:style_description] if options.has_key? :style_description
end

feature 'Style' do
  before(:all) do |example|
    set_module example.class.description
  end

  before(:each) do |example|
    user_login
  end

  after(:each) do |example|
    generate_screenshot example.description.parameterize
  end


  scenario 'Saving blank style should return an error', :js => true do
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
          style_name: "Test style",
          style_description: "Test style description"
      })
      click_button "Cancel"
      within ('div.alert-info') { expect(page).to have_content("No actions were taken") }
    end
  end

  scenario 'Adding required fields should work', :js => true do
    add_new_module_item do
      fill_in_fields ({
          style_name: "Test style",
          style_description: "Test style description"
      })
      click_button "Save and edit"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
    end
  end

  scenario 'Save and Add another button should save style object and remain in the style page', :js => true do
    add_new_module_item do
      fill_in_fields ({
          style_name: "Test style",
          style_description: "Test style description"
      })
      click_button "Save and add another"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
      expect(page).to have_content "New #{@module_info[:name]}"
    end
  end

  scenario 'Save and Edit button should save style object and remain in filled-up style page', :js => true do
    add_new_module_item do
      fill_in_fields ({
          style_name: "Test style",
          style_description: "Test style description"
      })
      click_button "Save and edit"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
      expect(page).to have_content "Edit #{@module_info[:name]}"
    end
  end

  scenario 'Clicking Show should allow user to view style object in show mode', :js => true do
    add_new_module_item do
      fill_in_fields ({
          style_name: "Test style",
          style_description: "Test style description"
      })
      click_button "Save"
    end
    within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }

    find_and_show "Test style"
    expect(page).to have_content "Details for #{@module_info[:name]} 'Test style'"
  end

  scenario 'Clicking Edit should allow user to update style object', :js => true do
    add_new_module_item do
      fill_in_fields ({
          style_name: "Test style",
          style_description: "Test style description"
      })
      click_button "Save"
    end
    within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }

    find_and_edit "Test style"
    fill_in_fields ({
        style_name: "Test style new name",
        style_description: "Test style new description"
    })
    click_button "Save and edit"
    expect(page).to have_content "#{@module_info[:name]} successfully updated"
    expect(page).to have_field "style_name", with: "Test style new name"
    expect(page).to have_field "style_description", with: "Test style new description"
  end

  scenario 'Cancelling delete should not remove style object from list', :js => true do
    add_new_module_item do
      fill_in_fields ({
          style_name: "Test style",
          style_description: "Test style description"
      })
      click_button "Save"
    end

    find_and_edit "Test style"
    within ('ul.nav-tabs') { click_link 'Delete' }
    expect(page).to have_content "Delete #{@module_info[:name]} 'Test style'"

    click_button "Cancel"
    within ('div.alert-info') { expect(page).to have_content("No actions were taken") }
    expect(page).to have_content "Edit #{@module_info[:name]} 'Test style'"
  end

  scenario 'Deleting style object should remove data from list', :js => true do
    add_new_module_item do
      fill_in_fields ({
          style_name: "Test style",
          style_description: "Test style description"
      })
      click_button "Save"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
    end

    find_and_edit "Test style"
    within ('ul.nav-tabs') { click_link 'Delete' }
    expect(page).to have_content "Delete #{@module_info[:name]} 'Test style'"

    click_button "Yes, I'm sure"
    within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully deleted") }
  end

  scenario 'Saving duplicate name and key should not work', :js => true do
    style = FactoryBot.create :style, application: @application
    style2 = FactoryBot.create :style, application: @application
    find_and_edit style2.name
    fill_in_fields ({
        style_name: style.name,
        style_description: "Test style description"
    })
    click_button "Save and edit"
    within ('div.alert-danger') do
      expect(page).to have_content "#{@module_info[:name]} failed to be updated"
      expect(page).to have_content "- Name has already been taken"
    end

  end

end