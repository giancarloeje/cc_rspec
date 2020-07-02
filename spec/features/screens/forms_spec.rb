require 'rails_helper'
require 'factories'

def fill_in_fields (options = {})
  fill_in 'form_name', with: options[:form_name] if options.has_key? :form_name
  fill_in 'form_description', with: options[:form_description] if options.has_key? :form_description
  if options.has_key? :form_key
    check "override_key"
    within "#form_key_field" do
      expect(page).to have_field "form_key", readonly: false
      expect(page).to have_checked_field "override_key"
    end
    fill_in 'form_key', with: options[:form_key]
  end
end

feature 'Form' do
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
      end
    end
  end

  scenario 'Cancelling add should return no actions were taken', :js => true do
    add_new_module_item do
      fill_in_fields ({
          form_name: "Test Form",
          form_description: "Test Form description"
      })
      click_button "Cancel"
      within ('div.alert-info') { expect(page).to have_content("No actions were taken") }
    end
  end

  scenario 'Saving name with number only should generate _<key>', :js => true do
    add_new_module_item do
      fill_in_fields ({
          form_name: "1",
          form_description: "Test Field description"
      })
      click_button "Save and edit"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
      expect(page).to have_field "form_key", with: "_1"
    end
  end

  scenario 'Adding required fields should work', :js => true do
    add_new_module_item do
      fill_in_fields ({
          form_name: "Test Form",
          form_description: "Test Form description"
      })
      click_button "Save and edit"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
    end
  end

  scenario 'Save and Add another button should save form object and remain in the form page', :js => true do
    add_new_module_item do
      fill_in_fields ({
          form_name: "Test Form",
          form_description: "Test Form description"
      })
      click_button "Save and add another"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
      expect(page).to have_content "New #{@module_info[:name]}"
    end
  end

  scenario 'Save and Edit button should save form object and remain in filled-up form page', :js => true do
    add_new_module_item do
      fill_in_fields ({
          form_name: "Test Form",
          form_description: "Test Form description"
      })
      click_button "Save and edit"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
      expect(page).to have_content "Edit #{@module_info[:name]}"
    end
  end

  scenario 'Clicking Show should allow user to view Form object information', :js => true do
    add_new_module_item do
      fill_in_fields ({
          form_name: "Test Form",
          form_description: "Test Form description"
      })
      click_button "Save"
    end
    within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }

    find_and_show "Test Form"
    expect(page).to have_content "Details for #{@module_info[:name]} 'Test Form'"
  end

  scenario 'Clicking Edit should allow user to update Form Information', :js => true do
    add_new_module_item do
      fill_in_fields ({
          form_name: "Test Form",
          form_description: "Test Form description"
      })
      click_button "Save"
    end
    within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }

    find_and_edit "Test Form"
    fill_in_fields ({
        form_name: "Test Form new name",
        form_description: "Test Form new description"
    })
    click_button "Save and edit"
    expect(page).to have_content "#{@module_info[:name]} successfully updated"
    expect(page).to have_field "form_name", with: "Test Form new name"
    expect(page).to have_field "form_description", with: "Test Form new description"
  end

  scenario 'Cancelling delete should not remove Form object from list', :js => true do
    add_new_module_item do
      fill_in_fields ({
          form_name: "Test Form",
          form_description: "Test Form description"
      })
      click_button "Save"
    end

    find_and_edit "Test Form"
    within ('ul.nav-tabs') { click_link 'Delete' }
    expect(page).to have_content "Delete #{@module_info[:name]} 'Test Form'"

    click_button "Cancel"
    within ('div.alert-info') { expect(page).to have_content("No actions were taken") }
    expect(page).to have_content "Edit #{@module_info[:name]} 'Test Form'"
  end

  scenario 'Deleting Form object should remove data from list', :js => true do
    add_new_module_item do
      fill_in_fields ({
          form_name: "Test Form",
          form_description: "Test Form description"
      })
      click_button "Save"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
    end

    find_and_edit "Test Form"
    within ('ul.nav-tabs') { click_link 'Delete' }
    expect(page).to have_content "Delete #{@module_info[:name]} 'Test Form'"

    click_button "Yes, I'm sure"
    within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully deleted") }
  end

  scenario 'Saving duplicate name and key should not work', :js => true do
    form = FactoryBot.create :form, application: @application
    form2 = FactoryBot.create :form, application: @application
    find_and_edit form2.name
    fill_in_fields ({
        form_name: form.name,
        form_description: "Test Form description",
        form_key: form.key
    })
    click_button "Save and edit"
    within ('div.alert-danger') do
      expect(page).to have_content "#{@module_info[:name]} failed to be updated"
      expect(page).to have_content "- Name has already been taken"
      expect(page).to have_content "- Key has already been taken. Note: key is generated by converting name to lowercase and symbols to underscores by default."
    end

  end

end