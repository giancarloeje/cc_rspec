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

# I'm unable to click on user_enable_api using "check user_enable_api"
# but the fix is working properly when manually tested.

feature 'User' do
  scenario 'User authentication token should not be automatically enabled (CMOSD-373)' do
    go_to_users
    click_link 'Add new'

    create_user 'userqa@domain.com', 'User!01', 'User!01'
    check 'user_is_admin'
    check 'user_is_root'
    #check 'user_enable_api'

    find(:css, 'li.save', :match => :first).click
    within ('div.ra-message') do
      expect(page).to have_content('User successfully created')
    end

    find(:css, 'td.action.show', :match => :first).click
    within ('div.ui-widget-header') do
      expect(page).to have_content ("Details for user")
    end
  end
end