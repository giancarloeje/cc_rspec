require 'rails_helper'
require 'factories'

def go_to_queues
  user_login
  add_application
  page.find(:css, 'div.model_name').click
  page.find(:xpath, "//*[@id='dd']/ul[1]/li[6]/a").hover
  click_link 'Queues'

  expect(page).to have_content("Queues")
end

def create_queue (name, description, max)
  fill_in 'filter_name', with: name
  fill_in 'filter_description', with: description
  fill_in 'filter_max_returned', with: max
end

feature 'Queues' do

  scenario 'Saving blank Queue form should return an error', :js => true do
    go_to_queues

    click_link 'Add new'

    within ('div.ui-widget-header') do
      expect(page).to have_content("Create queue")
    end

    create_queue '', '', ''
    find(:css, 'li.save', :match => :first).click

    within ('div.ra-message') do
      expect(page).to have_content("Queue failed to be created Name can't be blank Key can't be blank Key should contain alpha numeric characters only")
    end

    #find(:css, 'li.cancel', :match => :first).click

  end

  scenario 'Cancelling add should return no actions were taken', :js => true do
    go_to_queues

    click_link 'Add new'

    #the page is too long for the window to the footer appears mid page
    page.driver.resize_window(1920, 1080)

    create_queue 'Queues test', 'Queues test description', '200'
    check 'filter_is_hidden'
    check 'filter_show_deleted_records'
    check 'filter_show_root_only'
    check 'filter_show_parents'
    check 'filter_simple_grid'
    check 'filter_show_audit'

    find(:xpath, "//*[@id='new_filter']/fieldset[3]/div[3]/button").click
    #find(:xpath, "//*[@id='ui-id-10']").click
    find(:xpath, "//*[@id='new_filter']/fieldset[4]/div[4]/button").click
    find(:css, 'li.cancel', :match => :first).click

    within ('div.ra-message') do
      expect(page).to have_content("No actions were taken")
    end
  end

  scenario 'Adding Queue with name and description should work', :js => true do
    go_to_queues

    click_link 'Add new'

    #the page is too long for the window to the footer appears mid page
    page.driver.resize_window(1920, 1080)

    within ('div.ui-widget-header') do
      expect(page).to have_content("Create queue")
    end

    create_queue 'Queues Test', 'Queues Test Description', '200'
    check 'filter_is_hidden'
    check 'filter_show_deleted_records'
    check 'filter_show_root_only'
    check 'filter_show_parents'
    check 'filter_simple_grid'
    check 'filter_show_audit'

    find(:xpath, "//*[@id='new_filter']/fieldset[3]/div[3]/button").click
    #find(:xpath, "//*[@id='ui-id-10']").click
    find(:xpath, "//*[@id='new_filter']/fieldset[4]/div[4]/button").click


    find(:css, 'li.save', :match => :first).click

    within ('div.ra-message') do
      expect(page).to have_content("Queue successfully created")
    end
  end

  scenario 'Save and Add another button should save Queue record and remain in the form page', :js => true do
    go_to_queues

    click_link 'Add new'

    within ('div.ui-widget-header') do
      expect(page).to have_content("Create queue")
    end

    create_queue 'Queues Test 2', 'Queues Test 2 Description', '200'
    find(:css, 'li.save.add', :match => :first).click

    within ('div.ra-message') do
      expect(page).to have_content("Queue successfully created")
    end
  end

  scenario 'Save and Edit button should save Queue record and remain in filled-up form page', :js => true do
    go_to_queues

    click_link 'Add new'
    create_queue 'Queues Test 3', 'Queues Test 3 Description', '200'
    find(:css, 'li.save.edit', :match => :first).click

    within ('div.ra-message') do
      expect(page).to have_content("Queue successfully created")
    end

    within ('div.ui-widget-header') do
      expect(page).to have_content("Update queue")
    end

    fill_in 'filter_description', with: 'Edit Queues Test 3 Description'
    find(:css, 'li.save', :match => :first).click

    within ('div.ra-message') do
      expect(page).to have_content("Queue successfully updated")
    end
  end

  scenario 'Clicking Show should allow user to view Queue information', :js => true do
    go_to_queues

    find(:css, 'td.action.show', :match => :first).click
    within ('div.ui-widget-header') do
      expect(page).to have_content ("Details for queue")
    end

    within ('div.ra-message') do
      expect(page).to have_content ("You are in view mode. No change will be saved.")
    end

    visit '/admin/Queue?Application=1&Company=1&locale=en'

  end

  scenario 'Clicking Edit should allow user to update Queue information', :js => true do
    go_to_queues

    find(:css, 'td.action.edit', :match => :first).click
    within ('div.ui-widget-header') do
      expect(page).to have_content ("Update queue")
    end

    fill_in 'filter_description', with: 'Edit Link Queue description'
    find(:css, 'li.save', :match => :first).click

    within ('div.ra-message') do
      expect(page).to have_content("Queue successfully updated")
    end
  end

  scenario 'Cancelling delete should not remove Queue record from list', :js => true do
    go_to_queues

    find(:css, 'td.action.delete', :match => :first).click
    within ('div.ui-widget-header') do
      expect(page).to have_content ("Delete confirmation")
    end

    click_button 'Cancel'
    within ('div.ra-message') do
      expect(page).to have_content ("No actions were taken")
    end
  end

  scenario 'Deleting Queue object should remove data from list', :js => true do
    go_to_queues
    find(:css, 'td.action.delete', :match => :first).click
    within ('div.ui-widget-header') do
      expect(page).to have_content ("Delete confirmation")
    end

    click_button "Yes, I'm sure"
    within ('div.ra-message') do
      expect(page).to have_content ("Queue successfully deleted")
    end
  end

  scenario 'Export Queues data to csv', :js => true do
    go_to_queues

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

  scenario 'Export Queues data to json', :js => true do
    go_to_queues

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

  scenario 'Export Queues data to xml', :js => true do
    go_to_queues

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

  scenario 'Hidden option in Queue works[CMOSD-903]', :js => true do
    go_to_queues
    click_link 'Add new'

    within ('div#sqlbuild') do
      find(:xpath, "//*[@id='toggle-preview']").click
      click_link '[Click to add a new column]..'
      find(:xpath, "//*[@id='sqlmenulist'][1]/ul[1]/li[3]/span").hover
      find(:xpath, "//*[@id='sqlmenulist'][1]/ul[1]/li[3]/ul[1]/li[1]/a").click
      click_link 'assigned_at'
      click_link '[Click to add a new column]..'
      find(:xpath, "//*[@id='sqlmenulist'][1]/ul[1]/li[3]/span").hover
      find(:xpath, "//*[@id='sqlmenulist'][1]/ul[1]/li[3]/ul[1]/li[4]/a").click
    end

    within ('div#table') do
      expect(page).to have_content("assigned_at")
      expect(page).to have_content("created_at")
    end

    #click hide
    within ('div#sqlbuild') do
      find(:xpath, "//*[@id='state-0']").click
    end

    within ('div#table') do
      expect(page).not_to have_content("assigned_at")
      expect(page).to have_content("created_at")
    end

  end
=begin  scenario 'Searching for the word check in History should return 0 result', :js => true do
    go_to_queues

    click_link 'History'

    within ('div.ui-widget-header') do
      expect(page).to have_content("History for Queue")
    end

    fill_in 'query', with: 'check'
    click_button 'SEARCH'
  end
=end

end


