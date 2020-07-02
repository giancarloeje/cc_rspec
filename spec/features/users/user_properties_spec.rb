require 'rails_helper'
require 'factories'

def go_to_user_properties
  user_login
  add_application
  page.find(:css, 'div.model_name').click
  page.find(:xpath, ".//*[@id='dd']/ul[1]/li[3]/a").hover
  click_link 'User properties'
  expect(page).to have_content("User properties")
end

def create_user_property(name, description)
  fill_in 'user_property_name', with: name
  fill_in 'user_property_description', with: description
end

feature 'User Property' do

  scenario 'Saving blank User Property form should return an error', :js => true do

    go_to_user_properties
    click_link 'Add new'

    within('div.ui-widget-header') do
      expect(page).to have_content 'Create user property'
    end

    #find(:css, 'li.save', :match => :first).click
    page.find(:xpath, ".//*[@id='submit-buttons']/ul[1]/li[1]/input").click

    within('div.ra-message') do
      expect(page).to have_content 'User property failed to be created Name can\'t be blank Key should contain alpha numeric characters only'
    end

  end

  scenario 'Cancelling add should return no actions were taken', :js => true do

    go_to_user_properties
    click_link 'Add new'
    create_user_property 'user property name', 'user property description'
    #find(:css, 'li.cancel', :match => :first).click
    page.find(:xpath, ".//*[@id='submit-buttons']/ul[1]/li[4]/input").click
    within('div.ra-message') do
      expect(page).to have_content 'No actions were taken'
    end

  end

  scenario 'Saving name with number only should not work', :js => true do
    go_to_user_properties
    click_link 'Add new'
    create_user_property '1', 'user property description'

    # within ('#submit-buttons') do
    #  find(:css, 'li.save', :match => :first).click
    #end
    page.find(:xpath, ".//*[@id='submit-buttons']/ul[1]/li[1]/input").click

    within ('div.ra-message') do
      expect(page).to have_content 'User property failed to be created Key should contain alpha numeric characters only'
    end

  end

  scenario 'Adding user property with name and description should work', :js => true do
    go_to_user_properties
    click_link 'Add new'

    within ('div.ui-widget-header') do
      expect(page).to have_content("Create user property")
    end

    create_user_property 'user property', 'user property description'

    #find(:css, 'li.save', :match => :first).click
    page.find(:xpath, ".//*[@id='submit-buttons']/ul[1]/li[1]/input").click

    within ('div.ra-message') do
      expect(page).to have_content("User property successfully created")
    end
  end

  scenario 'Save and Add another button should save user property and remain in the form page', :js => true do
    go_to_user_properties
    click_link 'Add new'

    within ('div.ui-widget-header') do
      expect(page).to have_content("Create user property")
    end

    create_user_property 'user property', 'user property description'

    #find(:css, 'li.save.add', :match => :first).click
    page.find(:xpath, ".//*[@id='submit-buttons']/ul[1]/li[2]/input").click

    within ('div.ra-message') do
      expect(page).to have_content("User property successfully created")
    end

    within ('div.ui-widget-header') do
      expect(page).to have_content("Create user property")
    end

  end

  scenario 'Save and Edit button should save user property and remain in filled-up form page', :js => true do
    go_to_user_properties
    click_link 'Add new'

    within ('div.ui-widget-header') do
      expect(page).to have_content("Create user property")
    end

    create_user_property 'user property', 'user property description'
    #find(:css, 'li.save.edit', :match => :first).click
    page.find(:xpath, ".//*[@id='submit-buttons']/ul[1]/li[3]/input").click

    within ('div.ra-message') do
      expect(page).to have_content("User property successfully created")
    end

    within ('div.ui-widget-header') do
      expect(page).to have_content("Update user property")
    end

    fill_in 'user_property_description', with: 'edited user property description'

    #find(:css, 'li.save', :match => :first).click
    page.find(:xpath, ".//*[@id='submit-buttons']/ul[1]/li[1]/input").click

    within ('div.ra-message') do
      expect(page).to have_content("User property successfully updated")
    end
  end

  scenario 'Clicking Show should allow user to view User property information', :js => true do
    go_to_user_properties
    find(:css, 'td.action.show', :match => :first).click


    within ('div.ui-widget-header') do
      expect(page).to have_content("Details for user property")
    end

    within ('div.ra-message') do
      expect(page).to have_content ("You are in view mode. No change will be saved.")
    end
  end

  scenario 'Clicking Edit should allow user to update User property Information', :js => true do
    go_to_user_properties
    find(:css, 'td.action.edit', :match => :first).click
    within ('div.ui-widget-header') do
      expect(page).to have_content("Update user property")
    end

    fill_in 'user_property_description', with: 'Edited user property description'
    #find(:css, 'li.save', :match => :first).click
    page.find(:xpath, ".//*[@id='submit-buttons']/ul[1]/li[1]/input").click

    within ('div.ra-message') do
      expect(page).to have_content("User property successfully updated")
    end
  end

  scenario 'Cancelling delete should not remove user property record from list', :js => true do
    go_to_user_properties
    find(:css, 'td.action.delete', :match => :first).click
    within ('div.ui-widget-header') do
      expect(page).to have_content ("Delete confirmation")
    end

    click_button 'Cancel'
    within ('div.ra-message') do
      expect(page).to have_content ("No actions were taken")
    end
  end

  scenario 'Deleting user property object should remove it from list', :js => true do
    go_to_user_properties
    find(:css, 'td.action.delete', :match => :first).click
    within ('div.ui-widget-header') do
      expect(page).to have_content ("Delete confirmation")
    end

    click_button "Yes, I'm sure"
    within ('div.ra-message') do
      expect(page).to have_content ("User property successfully deleted")
      #check if removed from the list
    end

  end

  scenario 'Saving duplicate name and key should not work', :js => true do
    go_to_user_properties
    click_link 'Add new'
    create_user_property 'user property test', 'user property description'
    #find(:css, 'li.add', :match => :first).click
    page.find(:xpath, ".//*[@id='submit-buttons']/ul[1]/li[2]/input").click

    create_user_property 'user property test', 'user property description'
    #find(:css, 'li.save', :match => :first).click
    page.find(:xpath, ".//*[@id='submit-buttons']/ul[1]/li[1]/input").click
    within ('div.ra-message') do
      expect(page).to have_content ("User property failed to be created Name has already been taken")
    end
  end

  scenario 'User property added should appear in user object', :js => true do
    go_to_user_properties

    # Add user property
    click_link 'Add new'
    create_user_property 'userproptest', 'user property description'
    page.find(:xpath, ".//*[@id='submit-buttons']/ul[1]/li[1]/input").click

    # Go to Users
    page.find(:css, 'div.model_name').click
    page.find(:xpath, ".//*[@id='dd']/ul[1]/li[3]/a").hover
    page.find(:xpath, ".//*[@id='Users_id']/li[1]/a[1]").click

    # Edit User
    find(:css, 'td.action.edit', :match => :first).click
    within(:xpath, ".//*[@id='edit_user_1']/fieldset[4]/legend") do
      expect(page).to have_content('USER PROPERTIES')
    end
    expect(page).to have_content ("userproptest")
  end

  scenario 'User property edited should also be updated in user object' do
    go_to_user_properties

    # Edit user property
    find(:css, 'td.action.edit', :match => :first).click
    fill_in 'user_property_name', with: 'Edited user prop'
    page.find(:xpath, ".//*[@id='submit-buttons']/ul[1]/li[1]/input").click

    # Go to Users
    page.find(:css, 'div.model_name').click
    page.find(:xpath, ".//*[@id='dd']/ul[1]/li[3]/a").hover
    page.find(:xpath, ".//*[@id='Users_id']/li[1]/a[1]").click

    # Edit User
    find(:css, 'td.action.edit', :match => :first).click

    within(:xpath, ".//*[@id='edit_user_1']/fieldset[4]/legend") do
      expect(page).to have_content('USER PROPERTIES')
    end

    expect(page).to have_content ("Edited user prop")
  end

  scenario 'User property deleted should be removed from the list of user properties in user object' do
    go_to_user_properties
    find(:css, 'td.action.delete', :match => :first).click
    within ('div.ui-widget-header') do
      expect(page).to have_content ("Delete confirmation")
    end

    click_button "Yes, I'm sure"
    page.find(:css, 'div.model_name').click
    page.find(:xpath, ".//*[@id='dd']/ul[1]/li[3]/a").hover
    page.find(:xpath, ".//*[@id='Users_id']/li[1]/a[1]").click
    find(:css, 'td.action.edit', :match => :first).click

    expect(page).to have_content ("No user properties defined")
  end

 end