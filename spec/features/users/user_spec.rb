require 'rails_helper'
require 'factories'

def go_to_users
  user_login
  add_application
  page.find(:css, 'div.model_name').click
  page.find(:xpath, "//*[@id='dd']/ul[1]/li[3]/a").hover
  find(:xpath, "//*[@id='Users_id']/li[1]/a").click
  expect(page).to have_content("Users")
end

def create_user (email, password, pw_confirmation)
    fill_in 'user_email', with: email
    fill_in 'user_password', with: password
    fill_in 'user_password_confirmation', with: pw_confirmation
end

feature 'Users' do
  scenario 'should show an alert when user does not belong to any company (CMOSD-415)' do
    user = FactoryBot.create(:user, email: 'usert@dom.com', password: 'User!01')
    visit '/client/new?locale='
    fill_in 'user_email', with: user.email
    fill_in 'user_password', with: user.password
    click_button "Sign in"
    expect(current_path).to eq('/client/new')
  end

  scenario 'Saving blank user form should return an error', :js => true do
    go_to_users
    click_link 'Add new'

    create_user '', '', ''
    find(:css, 'li.save', :match => :first).click

    within ('div.ra-message') do
      expect(page).to have_content("User failed to be created E-mail can't be blank Password can't be blank")
    end
  end

  scenario 'Cancelling add should return no actions were taken', :js => true do
    go_to_users
    within ('div.ui-widget-header') do
      expect(page).to have_content("Select user to edit")
    end

    click_link 'Add new'

    within('div.ui-widget-header') do
      expect(page).to have_content("Create user")
    end

    create_user 'user@domain.com', 'User!01', 'User!01'
    check 'user_is_admin'

    check 'user_enable_api'
    find(:css, 'li.cancel', :match => :first).click

    within('div.ra-message') do
      expect(page).to have_content("No actions were taken")
    end
  end

  scenario 'Invalid email and numeric password should return an error' do
    go_to_users
    click_link 'Add new'
    user2 = FactoryBot.build(:user, email: 'invalid_pw2', password: '123', password_confirmation: '123')
    fill_in 'user_email', with: user2.email
    fill_in 'user_password', with: user2.password
    fill_in 'user_password_confirmation', with: user2.password_confirmation
    find(:css, 'li.save', :match => :first).click
    within ('div.ra-message') do
    expect(page).to have_content("User failed to be created E-mail is invalid Password is too short (minimum is 6 characters)")
    end
  end

  scenario 'Invalid email and password should return an error' do
    go_to_users
    click_link 'Add new'
    user2 = FactoryBot.build(:user, email: 'a', password: 'a', password_confirmation: 'a')
    fill_in 'user_email', with: user2.email
    fill_in 'user_password', with: user2.password
    fill_in 'user_password_confirmation', with: user2.password_confirmation
    find(:css, 'li.save', :match => :first).click
    within ('div.ra-message') do
      expect(page).to have_content("User failed to be created E-mail is invalid Password is too short (minimum is 6 characters) Password must contain uppercase, lowercase letters and digits")
    end
  end

  scenario 'Add User should fail when password does not match' do
    go_to_users
    click_link 'Add new'

    create_user 'userqa@domain.com', 'User!01', 'User!02'
    find(:css, 'li.save', :match => :first).click

    within ('div.ra-message') do
      expect(page).to have_content("User failed to be created Password doesn't match confirmation")
    end
  end

  scenario 'Missing numeric character in password should return an error' do
    go_to_users
    click_link 'Add new'

    within('div.ui-widget-header') do
      expect(page).to have_content("Create user")
    end

    create_user 'user@domain.com', 'password', 'password'
    check 'user_is_admin'

    find(:css, 'li.save', :match => :first).click
    within ('div.ra-message') do
      expect(page).to have_content("User failed to be created Password must contain uppercase, lowercase letters and digits")
    end
  end

  scenario 'Using an existing email to add a new user should return an error', :js => true do
    go_to_users
    click_link 'Add new'
    user2 = FactoryBot.create(:user, email: 'existing@domain.com', password: 'Pass01', password_confirmation: 'Pass01')
    fill_in 'user_email', with: user2.email
    fill_in 'user_password', with: user2.password
    fill_in 'user_password_confirmation', with: user2.password_confirmation
    find(:css, 'li.save', :match => :first).click
    within ('div.ra-message') do
      expect(page).to have_content("User failed to be created E-mail has already been taken")
    end
  end

  scenario 'Adding user with name and password should work', :js => true do
    go_to_users
    click_link 'Add new'

    create_user 'userqa@domain.com', 'User!01', 'User!01'
    check 'user_is_admin'
    check 'user_enable_api'

    find(:css, 'li.save', :match => :first).click
    within ('div.ra-message') do
      expect(page).to have_content('User successfully created')
    end

  end

  scenario 'Save and Add another button should save user record and remain in the user form page', :js => true do
    go_to_users
    click_link 'Add new'

    within('div.ui-widget-header') do
      expect(page).to have_content("Create user")
    end

    create_user 'userqa2@domain.com', 'User!01', 'User!01'
    check 'user_is_admin'
    check 'user_enable_api'

    find(:css, 'li.save', :match => :first).click

    within ('div.ra-message') do
      expect(page).to have_content("User successfully created")
    end
  end

  scenario 'Save and Edit button should save user record and remain in filled-up for page', :js => true do
    go_to_users

    click_link 'Add new'
    create_user 'userqa3@domain.com', 'User!01', 'User!01'
    check 'user_is_admin'
    check 'user_enable_api'

    find(:css, 'li.save.edit', :match => :first).click

    within('div.ui-widget-header') do
      expect(page).to have_content("Update user")
    end

    fill_in 'user_email', with: 'userqa3edit@domain.com'
    find(:css, 'li.save', :match => :first).click

    within ('div.ra-message') do
      expect(page).to have_content("User successfully updated")
    end
  end

  scenario 'Clicking Show should allow user to view user information', :js => true do
    go_to_users

    find(:css, 'td.action.show', :match => :first).click
    within ('div.ui-widget-header') do
      expect(page).to have_content ("Details for user")
    end

    within ('div.ra-message') do
      expect(page).to have_content ("You are in view mode. No change will be saved.")
    end

    visit '/admin/User?Application=1&Company=1&locale=en'
  end

  scenario 'Clicking Edit should allow user to update user information', :js => true do
    go_to_users

    find(:css, 'td.action.edit', :match => :first).click
    within ('div.ui-widget-header') do
      expect(page).to have_content ("Update user")
    end

    check 'user_is_root'
    find(:css, 'li.save', :match => :first).click

    within ('div.ra-message') do
      expect(page).to have_content("User successfully updated")
    end
  end

  scenario 'Cancelling delete should not remove user record from list', :js => true do
    go_to_users
    find(:css, 'td.action.delete', :match => :first).click
    within ('div.ui-widget-header') do
      expect(page).to have_content ("Delete confirmation")
    end

    click_button 'Cancel'
    within ('div.ra-message') do
      expect(page).to have_content ("No actions were taken")
    end
  end

  scenario 'Deleting user object should remove data from list', :js => true do
    go_to_users
    click_link 'Add new'

    create_user 'userqa@domain.com', 'User!01', 'User!01'
    find(:css, 'li.save', :match => :first).click

    find(:css, 'td.action.delete', :match => :first).click
    within ('div.ui-widget-header') do
      expect(page).to have_content ("Delete confirmation")
    end

    page.find(:css, 'input[name="_delete"]').click()
    visit '/admin'
    page.find(:css, 'div.model_name').click
    page.find(:xpath, "//*[@id='dd']/ul[1]/li[3]/a").hover
    find(:xpath, "//*[@id='Users_id']/li[1]/a").click
    expect(page).to have_content("Users")
  end

  scenario 'Export user data to csv', :js => true do
    go_to_users
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

  scenario 'Export user data to json', :js => true do
    go_to_users

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

  scenario 'Export user data to xml', :js => true do
    go_to_users

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
    go_to_users

    click_link 'History'

    within ('div.ui-widget-header') do
      expect(page).to have_content("History for User")
    end

    fill_in 'query', with: 'check'
    click_button 'SEARCH'
  end
=end
end
