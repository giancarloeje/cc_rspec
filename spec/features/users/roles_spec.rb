require 'rails_helper'
require 'factories'

def go_to_roles
  user_login
  add_application
  page.find(:css, 'div.model_name').click
  page.find(:xpath, "//*[@id='dd']/ul[1]/li[3]/a").hover
  click_link 'Roles'
  expect(page).to have_content("Roles")
end

def create_role (name, desc)
    fill_in 'role_name', with: name
    fill_in 'role_description', with: desc
end

feature 'Roles' do

  scenario 'Saving blank Role form should return an error', :js => true do
    go_to_roles
    click_link 'Add new'
    expect(current_path).to eq('/admin/roles/new')

    create_role '', ''
    find(:css, 'li.save', :match => :first).click

    within ('div.ra-message') do
      expect(page).to have_content("Role failed to be created Name can't be blank")
    end
  end

  scenario 'Cancelling add should return no actions were taken', :js => true do
    go_to_roles

    click_link 'Add new'
    expect(current_path).to eq('/admin/roles/new')

    within ('div.ui-widget-header') do
      expect(page).to have_content ('Create role')
    end

    fill_in 'role_name', with: 'Test Role'
    fill_in 'role_description', with: 'Test Role Description'

    # Admin Permissions
    within ('div#role_admin_permission_ids_field') do
      #find("option[value='94']").click
      #find("option[value='93']").click
      find(:xpath, "//*[@id='role_admin_permission_ids_field']/div/div[3]/a[1]").click
    end

    # Client Permissions
    check 'role_has_audit'
    check 'role_has_delete'
    check 'role_has_undelete'
    check 'role_has_reassociation'
    check 'role_has_export'
    check 'role_has_messaging'
    check 'role_unlock_all'
    check 'role_has_download'
    check 'role_has_delete_attachments'
    check 'role_has_upload'
    check 'role_has_change_owner'
    check 'role_has_real_time_notifications'
    #check 'role_has_change_role'

    find(:xpath, "//*[@id='new_role']/fieldset[5]/div[1]/button").click

    find(:css, 'li.cancel', :match => :first).click

    within ('div.ra-message') do
      expect(page).to have_content('No actions were taken')
    end
  end

  scenario 'Adding Role with name and description should work', :js => true do
    go_to_roles
    click_link 'Add new'
    expect(current_path).to eq('/admin/roles/new')

    within ('div.ui-widget-header') do
      expect(page).to have_content ('Create role')
    end

    create_role 'Test Role', 'Test Role Description'

    # Admin Permissions
    within ('div#role_admin_permission_ids_field') do
      #find("option[value='90']").click
      #find("option[value='89']").click
      #find("option[value='75']").click
      find(:xpath, "//*[@id='role_admin_permission_ids_field']/div/div[3]/a[1]").click
    end

    # Client Permissions
    check 'role_has_audit'
    check 'role_has_messaging'
    check 'role_unlock_all'
    check 'role_has_change_owner'
    #check 'role_has_change_role'

    find(:css, 'li.save', :match => :first).click

    within ('div.ra-message') do
      expect(page).to have_content('Role successfully created')
    end
  end

  scenario 'Save and Add another button should save role record and remain in the form page', :js => true do
    go_to_roles

    click_link 'Add new'
    expect(current_path).to eq('/admin/roles/new')

    within ('div.ui-widget-header') do
      expect(page).to have_content ('Create role')
    end

    create_role 'Test Role 2', 'Test Role Description 2'

    # Admin Permissions
    within ('div#role_admin_permission_ids_field') do

      #page.execute_script('$("ui-icon.ui-icon-circle-triangle-e.ra-multiselect-item-add").click()')
    end

    # Client Permissions
    check 'role_has_audit'
    check 'role_has_messaging'

    find(:css, 'li.save.add', :match => :first).click
  end

  scenario 'Save and Edit button should save DV record and remain in filled-up form page', :js => true do
    go_to_roles
    click_link 'Add new'
    create_role 'Test Role 3', 'Edit Test Role Description 3'

    # Admin Permissions


    within ('div#role_admin_permission_ids_field') do
    #  encoding_selector = find(:css, 'select#ra-multiselect-collection')

      #find("option[value='65']").click
      #find("option[value='35']").click
      #find("option[value='92']").click
      #find("option[value='15']").click
      #find("option[value='34']").click
      #find("option[value='1']").click
      #find("option[value='2']").click
      #find("option[value='3']").click
     # find(:xpath, "//*[@id='role_admin_permission_ids_field']/div/div[3]/a[1]").click
    end

    # Client Permissions
    check 'role_has_audit'
    check 'role_has_messaging'
    check 'role_unlock_all'
    check 'role_has_change_owner'
    #check 'role_has_change_role'

    find(:css, 'li.save.edit', :match => :first).click

    within ('div#role_admin_permission_ids_field') do
      #find("option[value='1']").click
     # find("option[value='2']").click
     # find("option[value='3']").click
      find(:xpath, "//*[@id='role_admin_permission_ids_field']/div/div[3]/a[2]").click
    end

    find(:css, 'li.save', :match => :first).click
  end

  scenario 'Clicking Show should allow user to view Role information', :js => true do
    go_to_roles
    find(:css, 'td.action.show', :match => :first).click
    within ('div.ui-widget-header') do
      expect(page).to have_content ("Details for role")
    end

    within ('div.ra-message') do
      expect(page).to have_content ("You are in view mode. No change will be saved.")
    end
  end

  scenario 'Clicking Edit should allow user to update Role information', :js => true do
    go_to_roles
    find(:css, 'td.action.edit', :match => :first).click
    within ('div.ui-widget-header') do
      expect(page).to have_content ("Update role")
    end

    fill_in 'role_name', with: 'Role Test Edit 2'
    find(:css, 'li.save', :match => :first).click

    within ('div.ra-message') do
      expect(page).to have_content("Role successfully updated")
    end
  end

  scenario 'Cancelling delete should not remove Role record from list', :js => true do
    go_to_roles
    find(:css, 'td.action.delete', :match => :first).click
    within ('div.ui-widget-header') do
      expect(page).to have_content ("Delete confirmation")
    end

    click_button 'Cancel'
    within ('div.ra-message') do
      expect(page).to have_content ("No actions were taken")
    end
  end

  scenario 'Deleting Role object should remove data from list', :js => true do
    go_to_roles
    find(:css, 'td.action.delete', :match => :first).click

    within ('div.ui-widget-header') do
      expect(page).to have_content ("Delete confirmation")
    end

    click_button "Yes, I'm sure"
    within ('div.ra-message') do
      expect(page).to have_content ("Role successfully deleted")
    end
  end

  scenario 'Export DV360 data to csv', :js => true do
    go_to_roles

    click_link 'Export current view'

    within ('div.ui-widget-header') do
      expect(page).to have_content("Select fields to export")
    end

    # drop down menu with encoding options
    encoding_selector = find(:xpath, ".//select[@id='csv_options_encoding_to']")
    encoding_selector.find(:xpath, ".//option[@value='UTF-8']").select_option

    click_button 'Export to csv'
    click_button 'Cancel'
  end

  scenario 'Export DV360 data to json', :js => true do
    go_to_roles

    click_link 'Export current view'

    within ('div.ui-widget-header') do
      expect(page).to have_content("Select fields to export")
    end

    # drop down menu with encoding options
    encoding_selector = find(:xpath, ".//select[@id='csv_options_encoding_to']")
    encoding_selector.find(:xpath, ".//option[@value='UTF-8']").select_option

    click_button 'Export to json'
    click_button 'Cancel'
  end

  scenario 'Export DV360 data to xml', :js => true do
    go_to_roles
    click_link 'Export current view'

    within ('div.ui-widget-header') do
      expect(page).to have_content("Select fields to export")
    end

    # drop down menu with encoding options
    encoding_selector = find(:xpath, ".//select[@id='csv_options_encoding_to']")
    encoding_selector.find(:xpath, ".//option[@value='UTF-8']").select_option

    click_button 'Export to xml'
    click_button 'Cancel'
  end

=begin  scenario 'Searching for the word check in History should return 0 result', :js => true do
    go_to_roles

    click_link 'History'

    within ('div.ui-widget-header') do
      expect(page).to have_content("History for Role")
    end

    fill_in 'query', with: 'check'
    click_button 'SEARCH'
  end
=end
end
