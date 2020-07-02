require 'rails_helper'
require 'factories'

def fill_in_fields (options = {})
  fill_in 'screen_name', with: options[:screen_name] if options.has_key? :screen_name
  fill_in 'screen_description', with: options[:screen_description] if options.has_key? :screen_description
  if options.has_key? :screen_key
    check "override_key"
    within "#screen_key_field" do
      expect(page).to have_field "screen_key", readonly: false
      expect(page).to have_checked_field "override_key"
    end
    fill_in 'screen_key', with: options[:screen_key]
  end

  if options.has_key? :layout
    within_frame('screenIframe') do
      select options[:layout], from: "layout-select"
    end
  end

  if options.has_key? :style
    within_frame('screenIframe') do
      select options[:style], from: "style-select"
    end
  end
end


feature 'Screen' do
  before(:all) do |example|
    set_module example.class.description
  end

  before(:each) do |example|
    user_login
    @layout = FactoryBot.create :layout, application: @application
    @style = FactoryBot.create :style, application: @application
  end

  after(:each) do |example|
    accept_alert { generate_screenshot example.description.parameterize }
  end


  scenario 'Saving blank screen should return an error', :js => true do
    add_new_module_item do
      click_button "Save"
      within ('div.alert-danger') do
        expect(page).to have_content "#{@module_info[:name]} failed to be created"
        expect(page).to have_content "- Name can't be blank"
        expect(page).to have_content "- Key can't be blank"
        expect(page).to have_content "- Key should contain alpha numeric and underscore characters only"
        expect(page).to have_content "- Layout can't be blank"
      end
    end
  end

  scenario 'Cancelling add should return no actions were taken', :js => true do
    add_new_module_item do
      fill_in_fields ({
          screen_name: "Test screen",
          screen_description: "Test screen description"
      })
      click_button "Cancel"
      within ('div.alert-info') { expect(page).to have_content("No actions were taken") }
    end
  end

  scenario 'Saving name with number only should generate _<key>', :js => true do
    add_new_module_item do
      fill_in_fields ({
          screen_name: "1",
          screen_description: "Test Field description",
          layout: @layout.name
      })
      click_button "Save and edit"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
      expect(page).to have_field "screen_key", with: "_1"
    end
  end

  scenario 'Adding required fields should work', :js => true do
    add_new_module_item do

      fill_in_fields ({
          screen_name: "Test screen",
          screen_description: "Test screen description",
          layout: @layout.name,
          style: @style.name
      })
      execute_script "setTimeout(function() {}, 4000);"
      click_button "Save and edit"
      accept_alert {}
      execute_script "setTimeout(function() {}, 4000);"

      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
    end
  end

  scenario 'Save and Add another button should save screen object and remain in the screen page', :js => true do
    add_new_module_item do
      fill_in_fields ({
          screen_name: "Test screen",
          screen_description: "Test screen description",
          layout: @layout.name,
          style: @style.name
      })
      click_button "Save and add another"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
      expect(page).to have_content "New #{@module_info[:name]}"
    end
  end

  scenario 'Save and Edit button should save screen object and remain in filled-up screen page', :js => true do
    add_new_module_item do
      fill_in_fields ({
          screen_name: "Test screen",
          screen_description: "Test screen description",
          layout: @layout.name,
          style: @style.name
      })
      click_button "Save and edit"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
      expect(page).to have_content "Edit #{@module_info[:name]}"
    end
  end

  scenario 'Clicking Show should allow user to view screen object information', :js => true do
    add_new_module_item do
      fill_in_fields ({
          screen_name: "Test screen",
          screen_description: "Test screen description",
          layout: @layout.name,
          style: @style.name
      })
      click_button "Save"
    end
    within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }

    find_and_show "Test screen"
    expect(page).to have_content "Details for #{@module_info[:name]} 'Test screen'"
  end

  scenario 'Clicking Edit should allow user to update screen information', :js => true do
    add_new_module_item do
      fill_in_fields ({
          screen_name: "Test screen",
          screen_description: "Test screen description",
          layout: @layout.name,
          style: @style.name
      })
      click_button "Save"
    end
    within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }

    find_and_edit "Test screen"
    fill_in_fields ({
        screen_name: "Test screen new name",
        screen_description: "Test screen new description",
        layout: @layout.name,
        style: @style.name
    })
    click_button "Save and edit"
    expect(page).to have_content "#{@module_info[:name]} successfully updated"
    expect(page).to have_field "screen_name", with: "Test screen new name"
    expect(page).to have_field "screen_description", with: "Test screen new description"
  end

  scenario 'Cancelling delete should not remove screen object from list', :js => true do
    add_new_module_item do
      fill_in_fields ({
          screen_name: "Test screen",
          screen_description: "Test screen description",
          layout: @layout.name,
          style: @style.name
      })
      click_button "Save"
    end

    find_and_edit "Test screen"
    within ('ul.nav-tabs') { click_link 'Delete' }
    expect(page).to have_content "Delete #{@module_info[:name]} 'Test screen'"

    click_button "Cancel"
    within ('div.alert-info') { expect(page).to have_content("No actions were taken") }
    expect(page).to have_content "Edit #{@module_info[:name]} 'Test screen'"
  end

  scenario 'Deleting screen object should remove data from list', :js => true do
    add_new_module_item do
      fill_in_fields ({
          screen_name: "Test screen",
          screen_description: "Test screen description",
          layout: @layout.name,
          style: @style.name
      })
      click_button "Save"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
    end

    find_and_edit "Test screen"
    within ('ul.nav-tabs') { click_link 'Delete' }
    expect(page).to have_content "Delete #{@module_info[:name]} 'Test screen'"

    click_button "Yes, I'm sure"
    within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully deleted") }
  end

  scenario 'Saving duplicate name and key should not work', :js => true do
    screen = FactoryBot.create :screen, application: @application
    screen2 = FactoryBot.create :screen, application: @application
    find_and_edit screen2.name
    fill_in_fields ({
        screen_name: screen.name,
        screen_description: "Test screen description",
        screen_key: screen.key,
        layout: @layout.name,
        style: @style.name
    })
    click_button "Save and edit"
    within ('div.alert-danger') do
      expect(page).to have_content "#{@module_info[:name]} failed to be updated"
      expect(page).to have_content "- Name has already been taken"
      expect(page).to have_content "- Key has already been taken. Note: key is generated by converting name to lowercase and symbols to underscores by default."
    end

  end

end