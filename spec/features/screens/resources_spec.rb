require 'rails_helper'
require 'factories'

def go_to_resources

  page.find(:css, 'div.model_name').click
  page.find(:xpath, "//*[@id='dd']/ul[1]/li[6]/a").hover
  click_link 'Resources'

  expect(page).to have_content("Asset")
end

feature 'Resources' do
  scenario 'Resources Add, Edit, Delete', :js => true do
    user_login
    add_application
    go_to_resources


    within ('div.ui-widget-header') do
      expect(page).to have_content("Select asset to edit")
    end

    find(:xpath, "/html").click
  end

end