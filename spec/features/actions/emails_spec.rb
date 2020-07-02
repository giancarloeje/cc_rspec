require 'rails_helper'
require 'factories'

def fill_in_fields (options = {})
  # Default values
  values = {
      email_name: "",
      email_description: "",
      email_from_field_id: "",
      email_to_field_id: "",
      email_cc_field_id: "",
      email_bcc_field_id:  "",
      email_email_subject: "",
      email_email_body: "",
      email_model_pattern_id: ""
  }

  values = values.merge options

  fill_in "email_name", with: options[:email_name]
  fill_in "email_description", with: options[:email_description]
  fill_in_filtering_select "email_from_field_id", options[:email_from_field_id]
  fill_in_filtering_select "email_to_field_id", options[:email_to_field_id]
  fill_in_filtering_select "email_cc_field_id", options[:email_cc_field_id]
  fill_in_filtering_select "email_bcc_field_id", options[:email_bcc_field_id]
  fill_in "email_email_subject", with: options[:email_email_subject]
  fill_in "email_email_body", with: options[:email_email_body]
  fill_in_filtering_select "email_model_pattern_id", options[:email_model_pattern_id]
end


feature 'E-mail' do

  before(:all) do |example|
    set_module example.class.description
  end

  before(:each) do |example|
    user_login
  end

  after(:each) do |example|
    generate_screenshot example.description.parameterize
  end


  scenario 'Saving blank Email form should return an error', :js => true do
    add_new_module_item do
      click_button "Save"
    end
    within ('div.alert-danger') do
      expect(page).to have_content "E-mail failed to be created"
      expect(page).to have_content "- Name can't be blank"
      expect(page).to have_content "- Key can't be blank"
      expect(page).to have_content "- Key should contain alpha numeric and underscore characters only"
      expect(page).to have_content "- From can't be blank"
      expect(page).to have_content "- To can't be blank"
      expect(page).to have_content "- Subject can't be blank"
      expect(page).to have_content "- Body can't be blank"
    end
  end

  scenario 'Cancelling add should return no actions were taken', :js => true do
    add_new_module_item do
      fill_in_fields email_name: 'E-mail test', email_description: 'E-mail test description', email_from_field_id: '', email_to_field_id: '', email_email_subject: '', email_email_body: '', email_model_pattern_id: ''
      click_button "Cancel"
      within ('div.alert-info') { expect(page).to have_content("No actions were taken") }
    end
  end

  scenario 'Add email with all required fields should work', :js => true do
    to = FactoryBot.create(:field, application: @application)
    from = FactoryBot.create(:field, application: @application)
    cc = FactoryBot.create(:field, application: @application)
    bcc = FactoryBot.create(:field, application: @application)
    add_new_module_item do
      fill_in_fields ({
          email_name: 'E-mail test',
          email_description: 'E-mail test description',
          email_from_field_id: from.name,
          email_to_field_id: to.name,
          email_cc_field_id: cc.name,
          email_bcc_field_id: bcc.name,
          email_email_subject: 'Lorem Ipsum',
          email_email_body: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur egestas leo quis urna posuere tempus.',
          email_model_pattern_id: ''
      })
      click_button "Save"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
    end
  end

  scenario 'Save and Add another button should save E-mail and remain in the E-mail form page', :js => true do
    to = FactoryBot.create(:field, application: @application)
    from = FactoryBot.create(:field, application: @application)
    cc = FactoryBot.create(:field, application: @application)
    bcc = FactoryBot.create(:field, application: @application)
    add_new_module_item
    fill_in_fields ({
        email_name: 'E-mail test',
        email_description: 'E-mail test description',
        email_from_field_id: from.name,
        email_to_field_id: to.name,
        email_cc_field_id: cc.name,
        email_bcc_field_id: bcc.name,
        email_email_subject: 'Lorem Ipsum',
        email_email_body: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur egestas leo quis urna posuere tempus.',
        email_model_pattern_id: ''
    })
    click_button "Save and add another"
    within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
    expect(page).to have_content "New #{@module_info[:name]}"
  end

  scenario 'Save and Edit button should save E-mail and remain in filled-up form page', :js => true do
    to = FactoryBot.create(:field, application: @application)
    from = FactoryBot.create(:field, application: @application)
    cc = FactoryBot.create(:field, application: @application)
    bcc = FactoryBot.create(:field, application: @application)
    sleep 3
    add_new_module_item do
      fill_in_fields ({
          email_name: 'E-mail test',
          email_description: 'E-mail test description',
          email_from_field_id: from.name,
          email_to_field_id: to.name,
          email_cc_field_id: cc.name,
          email_bcc_field_id: bcc.name,
          email_email_subject: 'Lorem Ipsum',
          email_email_body: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur egestas leo quis urna posuere tempus.',
          email_model_pattern_id: ''
      })
    end
    click_button "Save and edit"
    within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
    expect(page).to have_content "Edit #{@module_info[:name]} 'E-mail test'"
  end

  scenario 'Clicking Show should allow user to view E-mail information', :js => true do
    email_object = add_email
    find_and_show email_object.name
    expect(page).to have_content "Details for #{@module_info[:name]} '#{email_object.name}'"
  end

  scenario 'Clicking Edit should allow user to update E-mail information', :js => true do
    to = FactoryBot.create(:field, application: @application)
    from = FactoryBot.create(:field, application: @application)
    cc = FactoryBot.create(:field, application: @application)
    bcc = FactoryBot.create(:field, application: @application)
    add_new_module_item do
      fill_in_fields ({
          email_name: 'E-mail test',
          email_description: 'E-mail test description',
          email_from_field_id: from.name,
          email_to_field_id: to.name,
          email_cc_field_id: cc.name,
          email_bcc_field_id: bcc.name,
          email_email_subject: 'Lorem Ipsum',
          email_email_body: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur egestas leo quis urna posuere tempus.',
          email_model_pattern_id: ''
      })
      click_button "Save"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
    end

    find_and_edit "E-mail test"
    fill_in 'email_name', with: "New e-mail name"
    fill_in 'email_description', with: "New e-mail description"
    click_button "Save"
    expect(page).to have_content "#{@module_info[:name]} successfully updated"
  end

  scenario 'Cancelling delete should not remove E-mail from list', :js => true do
    to = FactoryBot.create(:field, application: @application)
    from = FactoryBot.create(:field, application: @application)
    cc = FactoryBot.create(:field, application: @application)
    bcc = FactoryBot.create(:field, application: @application)
    add_new_module_item do
      fill_in_fields ({
          email_name: 'E-mail test',
          email_description: 'E-mail test description',
          email_from_field_id: from.name,
          email_to_field_id: to.name,
          email_cc_field_id: cc.name,
          email_bcc_field_id: bcc.name,
          email_email_subject: 'Lorem Ipsum',
          email_email_body: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur egestas leo quis urna posuere tempus.',
          email_model_pattern_id: ''
      })
      click_button "Save"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
    end

    find_and_edit "E-mail test"
    within ('ul.nav-tabs') { click_link 'Delete' }
    expect(page).to have_content "Delete #{@module_info[:name]} 'E-mail test'"

    click_button "Cancel"
    within ('div.alert-info') { expect(page).to have_content("No actions were taken") }
    expect(page).to have_content "Edit #{@module_info[:name]} 'E-mail test'"

  end

  scenario 'Deleting E-mail object should remove data from list', :js => true do
    to = FactoryBot.create(:field, application: @application)
    from = FactoryBot.create(:field, application: @application)
    cc = FactoryBot.create(:field, application: @application)
    bcc = FactoryBot.create(:field, application: @application)
    add_new_module_item do
      fill_in_fields ({
          email_name: 'E-mail test',
          email_description: 'E-mail test description',
          email_from_field_id: from.name,
          email_to_field_id: to.name,
          email_cc_field_id: cc.name,
          email_bcc_field_id: bcc.name,
          email_email_subject: 'Lorem Ipsum',
          email_email_body: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur egestas leo quis urna posuere tempus.',
          email_model_pattern_id: ''
      })
      click_button "Save"
      within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully created") }
    end

    find_and_edit "E-mail test"
    within ('ul.nav-tabs') { click_link 'Delete' }
    expect(page).to have_content "Delete #{@module_info[:name]} 'E-mail test'"

    click_button "Yes, I'm sure"
    within ('div.alert-success') { expect(page).to have_content("#{@module_info[:name]} successfully deleted") }
    expect(page).to have_content "Nothing to display"

  end

  scenario 'Should not be saved when subject or body contain forbidden word: new', :js => true do
    to = FactoryBot.create(:field, application: @application)
    from = FactoryBot.create(:field, application: @application)
    add_new_module_item do
      fill_in_fields ({
          email_name: 'E-mail test',
          email_description: 'E-mail test description',
          email_from_field_id: from.name,
          email_to_field_id: to.name,
          email_email_subject: 'Lorem new Ipsum',
          email_email_body: 'Lorem new ipsum dolor sit amet, consectetur adipiscing elit. Curabitur egestas leo quis urna posuere tempus.',
          email_model_pattern_id: ''
      })
      click_button "Save"
      within ('div.alert-danger') {
        expect(page).to have_content("- Body contains forbidden content")
        expect(page).to have_content("- Subject contains forbidden content")
      }
    end
  end

  #  Export Functionality

  scenario 'Export E-mail data to csv', :js => true do
    add_email
    export_from_dashboard do
      fill_in_filtering_select "csv_options_encoding_to", "UTF-8"
      fill_in_filtering_select "csv_options_generator_col_sep", ","
      expect(page).to have_button('Export to csv', disabled: false)
      click_button "Export to csv"
    end
  end

  scenario 'Export E-mail data to json', :js => true do
    add_email
    export_from_dashboard do
      fill_in_filtering_select "csv_options_encoding_to", "UTF-8"
      fill_in_filtering_select "csv_options_generator_col_sep", ","
      expect(page).to have_button('Export to json', disabled: false)
      click_button "Export to json"
    end
  end

  scenario 'Export E-mail data to xml', :js => true do
    add_email
    export_from_dashboard do
      fill_in_filtering_select "csv_options_encoding_to", "UTF-8"
      fill_in_filtering_select "csv_options_generator_col_sep", ","
      expect(page).to have_button('Export to csv', disabled: false)
      click_button "Export to xml"
    end
  end

  scenario 'Export buttons should be disabled if no field is selected' do
    add_email
    export_from_dashboard do
      uncheck 'check_all'
      expect(page).to have_button('Export to csv', disabled: true)
      expect(page).to have_button('Export to json', disabled: true)
      expect(page).to have_button('Export to xml', disabled: true)
    end
  end

end