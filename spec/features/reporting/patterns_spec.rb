require 'rails_helper'
require 'factories'

def go_to_patterns
  user_login
  add_application
  page.find(:css, 'div.model_name').click
  page.find(:xpath, "//*[@id='dd']/ul[1]/li[8]/a").hover
  click_link 'Patterns'

  expect(page).to have_content("Patterns")
end

def create_pattern (name, description)
  fill_in 'pattern_name', with: name
  fill_in 'pattern_description', with: description
end

feature 'Patterns' do

  scenario 'Saving blank Patterns form should return an error', :js => true do
    go_to_patterns

    click_link 'Add new'

    within ('div.ui-widget-header') do
      expect(page).to have_content("Create pattern")
    end

    find(:css, 'li.save', :match => :first).click

    within ('div.ra-message') do
      expect(page).to have_content("Pattern failed to be created Name can't be blank Key can't be blank Key should contain alpha numeric characters only")
    end
  end

  scenario 'Cancelling add should return no actions were taken' do
    go_to_patterns
    click_link 'Add new'
    within ('div.ui-widget-header') do
      expect(page).to have_content("Create pattern")
    end

    find(:css, 'li.cancel', :match => :first).click

    within ('div.ra-message') do
      expect(page).to have_content("No actions were taken")
    end
  end

  scenario 'Adding pattern with name, description should work', :js => true do
    go_to_patterns
    click_link 'Add new'
    create_pattern 'Pattern Test', 'Pattern Test Description'

    find(:css, 'li.save', :match => :first).click

    within ('div.ra-message') do
      expect(page).to have_content("Pattern successfully created")
    end
  end

  scenario 'Save and Add another button should save Patterns record and remain in the form page', :js => true do
    go_to_patterns
    click_link 'Add new'

    create_pattern 'Pattern Test 2', 'Pattern Test 2 Description'

    find(:css, 'li.save.add', :match => :first).click

    within ('div.ra-message') do
      expect(page).to have_content("Pattern successfully created")
    end
  end

  scenario 'Save and Edit button should save Patterns record and remain in filled-up form page', :js => true do
    go_to_patterns
    click_link 'Add new'

    create_pattern 'Pattern Test 3', 'Pattern Test 3 Description'
    find(:css, 'li.save.edit', :match => :first).click

    within ('div.ui-widget-header') do
      expect(page).to have_content("Update pattern")
    end

    fill_in 'pattern_description', with: 'Edit Pattern Test 3 Description'
    find(:css, 'li.save', :match => :first).click

    within ('div.ra-message') do
      expect(page).to have_content("Pattern successfully updated")
    end
  end

  scenario 'Clicking Show should allow user to view Patterns Information', :js => true do
    go_to_patterns

    find(:css, 'td.action.show', :match => :first).click
    within ('div.ui-widget-header') do
      expect(page).to have_content ("Details for pattern")
    end

    within ('div.ra-message') do
      expect(page).to have_content ("You are in view mode. No change will be saved.")
    end

    visit '/admin/Pattern?Application=1&Company=1&locale=en'
  end

  scenario 'Cancelling Edit should not save any changes made', :js => true do
    go_to_patterns
    find(:css, 'td.action.edit', :match => :first).click
    within ('div.ui-widget-header') do
      expect(page).to have_content ("Update pattern")
    end

    fill_in 'pattern_description', with: 'Edit Link pattern description'
    find(:css, 'li.cancel', :match => :first).click

    within ('div.ra-message') do
      expect(page).to have_content("No actions were taken")
    end
  end

  scenario 'Clicking Edit should allow user to update Patterns information', :js => true do
    go_to_patterns
    find(:css, 'td.action.edit', :match => :first).click
    within ('div.ui-widget-header') do
      expect(page).to have_content ("Update pattern")
    end

    fill_in 'pattern_description', with: 'Edit Link pattern description'
    find(:css, 'li.save', :match => :first).click

    within ('div.ra-message') do
      expect(page).to have_content("Pattern successfully updated")
    end
  end

  scenario 'Cancelling delete should not remove Patterns record from list', :js => true do
    go_to_patterns
    find(:css, 'td.action.delete', :match => :first).click
    within ('div.ui-widget-header') do
      expect(page).to have_content ("Delete confirmation")
    end

    click_button 'Cancel'
    within ('div.ra-message') do
      expect(page).to have_content ("No actions were taken")
    end
  end

  scenario 'Deleting Patterns object should remove data from list', :js => true do
    go_to_patterns

    find(:css, 'td.action.delete', :match => :first).click
    within ('div.ui-widget-header') do
      expect(page).to have_content ("Delete confirmation")
    end

    click_button "Yes, I'm sure"
    within ('div.ra-message') do
      expect(page).to have_content ("Pattern successfully deleted")
    end

  end

  scenario 'Export Patterns data to csv', :js => true do
    go_to_patterns

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

  scenario 'Export Patterns data to json', :js => true do
    go_to_patterns

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

  scenario 'Export Patterns data to xml', :js => true do
    go_to_patterns

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

  scenario 'Display key field[CMOSD-1008]', :js => true do
    go_to_patterns

    within ('div.ra-block-content') do
      expect(page).to have_content("KEY")
    end

    find(:css, 'td.action.edit', :match => :first).click

    within ('div.ra-block-content') do
      expect(page).to have_content("Key")
    end

  end
=begin  scenario 'Searching for the word check in History should return 0 result', :js => true do
    go_to_patterns

    click_link 'History'

    within ('div.ui-widget-header') do
      expect(page).to have_content("History for Pattern")
    end

    fill_in 'query', with: 'check'
    click_button 'SEARCH'
  end
=end
end