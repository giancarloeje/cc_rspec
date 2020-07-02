require 'rails_helper'
require 'factories'

def fill_in_fields (options = {})
  fill_in 'html_block_name', with: options[:html_block_name] if options.has_key? :html_block_name
  fill_in 'html_block_description', with: options[:html_block_description] if options.has_key? :html_block_description
  if options.has_key? :html_block_key
    check "override_key"
    within "#html_block_key_field" do
      expect(page).to have_field "html_block_key", readonly: false
      expect(page).to have_checked_field "override_key"
    end
    fill_in 'html_block_key', with: options[:html_block_key]
  end
end

feature 'Html Block' do
  before(:all) do |example|
    set_module example.class.description
  end

  before(:each) do |example|
    user_login
  end

  after(:each) do |example|
    generate_screenshot example.description.parameterize
  end


  scenario 'Saving blank Data Extract html_block should return an error', :js => true do
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
          html_block_name: "Test html_block",
          html_block_description: "Test html_block description"
      })
      click_button "Cancel"
      within ('div.alert-info') { expect(page).to have_content("No actions were taken") }
    end
  end

  scenario 'Saving name with number only should generate _<key>', :js => true do
    add_new_module_item do
      fill_in_fields ({
          html_block_name: "1",
          html_block_description: "Test Field description"
      })
      click_button "Save and edit"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
      expect(page).to have_field "html_block_key", with: "_1"
    end
  end

  scenario 'Adding required fields should work', :js => true do
    add_new_module_item do
      fill_in_fields ({
          html_block_name: "Test html_block",
          html_block_description: "Test html_block description"
      })
      click_button "Save and edit"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
    end
  end

  scenario 'Save and Add another button should save html_block object and remain in the html_block page', :js => true do
    add_new_module_item do
      fill_in_fields ({
          html_block_name: "Test html_block",
          html_block_description: "Test html_block description"
      })
      click_button "Save and add another"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
      expect(page).to have_content "New #{@module_info[:name]}"
    end
  end

  scenario 'Save and Edit button should save html_block object and remain in filled-up html_block page', :js => true do
    add_new_module_item do
      fill_in_fields ({
          html_block_name: "Test html_block",
          html_block_description: "Test html_block description"
      })
      click_button "Save and edit"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
      expect(page).to have_content "Edit #{@module_info[:name]}"
    end
  end

  scenario 'Clicking Show should allow user to view html_block object in show mode', :js => true do
    add_new_module_item do
      fill_in_fields ({
          html_block_name: "Test html_block",
          html_block_description: "Test html_block description"
      })
      click_button "Save"
    end
    within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }

    find_and_show "Test html_block"
    expect(page).to have_content "Details for #{@module_info[:name]} 'Test html_block'"
  end

  scenario 'Clicking Edit should allow user to update html_block Inhtml_blockation', :js => true do
    add_new_module_item do
      fill_in_fields ({
          html_block_name: "Test html_block",
          html_block_description: "Test html_block description"
      })
      click_button "Save"
    end
    within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }

    find_and_edit "Test html_block"
    fill_in_fields ({
        html_block_name: "Test html_block new name",
        html_block_description: "Test html_block new description"
    })
    click_button "Save and edit"
    expect(page).to have_content "#{@module_info[:name]} successfully updated"
    expect(page).to have_field "html_block_name", with: "Test html_block new name"
    expect(page).to have_field "html_block_description", with: "Test html_block new description"
  end

  scenario 'Cancelling delete should not remove html_block object from list', :js => true do
    add_new_module_item do
      fill_in_fields ({
          html_block_name: "Test html_block",
          html_block_description: "Test html_block description"
      })
      click_button "Save"
    end

    find_and_edit "Test html_block"
    within ('ul.nav-tabs') { click_link 'Delete' }
    expect(page).to have_content "Delete #{@module_info[:name]} 'Test html_block'"

    click_button "Cancel"
    within ('div.alert-info') { expect(page).to have_content("No actions were taken") }
    expect(page).to have_content "Edit #{@module_info[:name]} 'Test html_block'"
  end

  scenario 'Deleting html_block object should remove data from list', :js => true do
    add_new_module_item do
      fill_in_fields ({
          html_block_name: "Test html_block",
          html_block_description: "Test html_block description"
      })
      click_button "Save"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
    end

    find_and_edit "Test html_block"
    within ('ul.nav-tabs') { click_link 'Delete' }
    expect(page).to have_content "Delete #{@module_info[:name]} 'Test html_block'"

    click_button "Yes, I'm sure"
    within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully deleted") }
  end

  scenario 'Saving duplicate name and key should not work', :js => true do
    html_block = FactoryBot.create :html_block, application: @application
    html_block2 = FactoryBot.create :html_block, application: @application
    find_and_edit html_block2.name
    fill_in_fields ({
        html_block_name: html_block.name,
        html_block_description: "Test html_block description",
        html_block_key: html_block.key
    })
    click_button "Save and edit"
    within ('div.alert-danger') do
      expect(page).to have_content "#{@module_info[:name]} failed to be updated"
      expect(page).to have_content "- Name has already been taken"
      expect(page).to have_content "- Key has already been taken. Note: key is generated by converting name to lowercase and symbols to underscores by default."
    end

  end

end