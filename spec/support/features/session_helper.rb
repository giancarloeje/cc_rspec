require 'rails_helper'
require 'factories'

module Features

  module SessionHelpers

    # Use FactoryBot to create objects or use GUI?
    # Todo: Pending imeplementation
    USE_FACTORYBOT = true

    # This sets the module and other data required for navigation.
    # Make sure that the module you are testing is included in here.
    def set_module(mod)
      @module_info = case mod
                     when "DataView360"
                       {name: "DataView360", name_plural: "DataView360", url: "/admin/data_view_connector?locale=en", navbar_path: %w[Actions DataView360], via: "nav_path" }
                     when "E-mail"
                       {name: "E-mail", name_plural: "E-mails", url: "/admin/email?locale=en", navbar_path: %w[Actions E-mails], via: "nav_path" }
                     when "Modifier"
                       {name: "Modifier", name_plural: "Modifiers", url: "/admin/modifier?locale=en", navbar_path: %w[Actions Modifiers], via: "nav_path" }
                     when "Populate Action"
                       { name: "Populate Action", name_plural: "Populate Actions", url: "/admin/populate_action?locale=en", navbar_path: ["Actions", "Populate Actions"], via: "nav_path" }
                     when "Application"
                       { name: "Application", name_plural: "Applications", url: "/admin/Application/new?locale=en", via: "url" }
                     when "Company"
                       { name: "Company", name_plural: "Companies", url: "/admin/Company/new?locale=en", via: "url" }
                     when "Field"
                       { name: "Field", name_plural: "Fields", url: "/admin/data_view_connector?locale=en", navbar_path: ["Data dictionary", "Fields"], via: "nav_path" }
                     when "Status"
                       { name: "Status", name_plural: "Statuses", url: "/admin/status?locale=en", navbar_path: ["Data dictionary", "Statuses"], via: "nav_path" }
                     when "Table"
                       { name: "Table", name_plural: "Tables", url: "/admin/table?locale=en", navbar_path: ["Data dictionary", "Tables"], via: "nav_path" }
                     when "Environment property"
                       { name: "Environment property", name_plural: "Environment properties", url: "/admin/environment_property?locale=en", navbar_path: ["Environments", "Environment properties"], via: "nav_path" }
                     when "Environment"
                       {name: "Environment", name_plural: "Environments", url: "/admin/environment?locale=en", navbar_path: %w[Environments Environments], via: "nav_path" }
                     when "Schedule"
                       {name: "Schedule", name_plural: "Schedules", url: "/admin/schedule?locale=en", navbar_path: %w[Environments Schedules], via: "nav_path" }
                     when "Navigator"
                       { name: "Navigator", name_plural: "Navigators", url: "/admin/navigator?locale=en", navbar_path: ["Front-End UI", "Navigators"], via: "nav_path" }
                     when "Data Extract"
                       { name: "Data Extract", name_plural: "Data Extracts", url: "/admin/data_extract?locale=en", navbar_path: ["Reporting", "Data Extracts"], via: "nav_path" }
                     when "Patterns"
                       {name: "Pattern", name_plural: "Patterns", url: "/admin/pattern?locale=en", navbar_path: %w[Reporting Patterns], via: "nav_path" }
                     when "Screen flow"
                       { name: "Screen flow", name_plural: "Screen flows", url: "/admin/screen_flow?locale=en", navbar_path: ["Flows", "Screen flows"], via: "nav_path" }
                     when "Server flow"
                       { name: "Server flow", name_plural: "Server flows", url: "/admin/server_flow?locale=en", navbar_path: ["Flows", "Server flows"], via: "nav_path" }
                     when "Status flow"
                       { name: "Status flow", name_plural: "Status flows", url: "/admin/status_flow?locale=en", navbar_path: ["Flows", "Status flows"], via: "nav_path" }
                     when "Users"
                       { name: "User", name_plural: "Users", url: "/admin/user?locale=en", navbar_path: ["Users and roles", "Users"], via: "nav_path" }
                     when "Roles"
                       { name: "Role", name_plural: "Roles", url: "/admin/role?locale=en", navbar_path: ["Users and roles", "Roles"], via: "nav_path" }
                     when "User properties"
                       { name: "User property", name_plural: "User properties", url: "/admin/user_property?locale=en", navbar_path: ["Users and roles", "User properties"], via: "nav_path" }
                     when "Form"
                       {name: "Form", name_plural: "Forms", url: "/admin/form?locale=en", navbar_path: %w[Screens Forms], via: "nav_path" }
                     when "Html Block"
                       {name: "Html Block", name_plural: "Html Blocks", url: "/admin/html_block?locale=en", navbar_path: ["Screens", "Html Blocks"], via: "nav_path" }
                     when "Layout"
                       {name: "Layout", name_plural: "Layouts", url: "/admin/layout?locale=en", navbar_path: %w[Screens Layouts], via: "nav_path" }
                     when "Style"
                       {name: "Style", name_plural: "Styles", url: "/admin/style?locale=en", navbar_path: %w[Screens Styles], via: "nav_path" }
                     when "Screen"
                       {name: "Screen", name_plural: "Screens", url: "/admin/screen?locale=en", navbar_path: %w[Screens Screens], via: "nav_path" }
                     else
                       nil
                     end
      raise "Module #{mod} not found! Make sure configuration exists." if @module_info == nil
      @module_info.merge ({
          "screenshot" => lambda do |file_name|
            save_screenshot("Screenshots/features/#{@module_info[:name]}/#{filename}_#{DateTime.now.strftime('%s')}.png", full: true)
          end
      })

    end

    # Generate screenshot for each feature test
    def generate_screenshot filename
      save_screenshot("Screenshots/features/#{@module_info[:name]}/#{filename}_#{DateTime.now.strftime('%s')}.png", full: true)
    end

    def sign_up_with
      visit '/users/sign_in'
      user = FactoryBot.build(:user)
      fill_in 'Email', with: user.email
      fill_in 'Password', with: user.password
      click_button 'Sign up'
      expect(page).to have_content("Dashboard")
    end

    # This makes use of Devise test helper to bypass login page and speed up testing
    def user_login
      @company = FactoryBot.create(:company)
      @application = FactoryBot.create(:application, company: @company)
      @user = FactoryBot.create(:user, company: @company)
      #expect(page).to have_content("You need to sign in or sign up before continuing.")

      login_as(@user, :scope => :user)
      #visit "/admin"
      #fill_in 'user_email', with: user.email
      #fill_in 'user_password', with: user.password
      #click_button "Sign in"
      #expect(page).to have_content("Dashboard")
    end

    def client_login
      @company = FactoryBot.create(:company)
      @application = FactoryBot.create(:application, company: @company)
      user = FactoryBot.create(:user, company: @company)
      add_application
      visit '/client/new'
      fill_in 'user_email', with: user.email
      fill_in 'user_password', with: user.password
      click_button "Sign in"
    end

    def add_application
      # @client_permission = FactoryBot.build(:client_permission, application: @application)
      add_navigator
      add_role
      add_field
      add_table
      add_form
      add_layout
      add_screen
      add_screen_flow
      add_server_flow
      add_status_flow
      add_filter
      add_data_view_connector
      add_html_block
      add_style
      add_status
      add_email
      add_modifier
      add_populate
      #add_pattern
      add_data_extract
      add_environment
      add_environment_property
      add_schedule
      add_user_property
    end

    def add_object obj
      # TODO config option to use FactoryBot to create admin objects or use admin page
      # if user has no access to database or if tests will be executed on a remote host.
      obj = obj.to_sym if obj.is_a? String
      if USE_FACTORYBOT then

      else

      end
    end

    def add_navigator
      @navigator = FactoryBot.create(:navigator, name: 'Navi', application: @application)
    end

    def add_role
      @role = FactoryBot.create(:role, application: @application)
    end

    def add_field
      @field = FactoryBot.create(:field, application: @application)
    end

    def add_table
      @table = FactoryBot.create(:table, application: @application)
    end

    def add_form
      @form = FactoryBot.create(:form, application: @application)
    end

    def add_layout
      @layout = FactoryBot.create(:layout, application: @application)
    end

    def add_screen
      # @layout = FactoryBot.create(:layout, application: @application)
      @screen = FactoryBot.create(:screen, layout: @layout, application: @application)
    end

    def add_screen_flow
      @screen_flow = FactoryBot.create(:screen_flow, application: @application)
    end

    def add_server_flow
      @server_flow = FactoryBot.create(:server_flow, application: @application)
    end

    def add_filter
      @filter = FactoryBot.create(:filter, application: @application)
    end

    def add_data_view_connector
      @data_view_connector = FactoryBot.create(:data_view_connector, application: @application)
    end

    def add_html_block
      @html_block = FactoryBot.create(:html_block, application: @application)
    end

    def add_style
      @style = FactoryBot.create(:style, application: @application)
    end

    def add_status
      @status = FactoryBot.create(:status, application: @application)
    end

    def add_status_flow
      @status_flow = FactoryBot.create(:status_flow, application: @application)
    end

    def add_email
      # From and To fields are required.
      to = FactoryBot.create(:field, application: @application)
      from = FactoryBot.create(:field, application: @application)
      @email = FactoryBot.create(:email, from_field_id: from.id, to_field_id: to.id, application: @application)
      @email.reload
    end

    def add_modifier
      @modifier = FactoryBot.create(:modifier, application: @application)
    end

    def add_populate
      @populate_action = FactoryBot.create(:populate_action, application: @application)
    end

    def add_pattern
      @pattern = FactoryBot.create(:pattern, application: @application)
    end

    def add_environment
      @environment = FactoryBot.create(:environment, application: @application)
    end

    def add_environment_property
      @environment_property = FactoryBot.create(:environment_property, application: @application)
    end

    def add_schedule
      @schedule = FactoryBot.create(:schedule, application: @application)
    end

    def add_data_extract
      @data_extract = FactoryBot.create(:data_extract, application: @application)
    end

    def add_user_property
      @user_property = FactoryBot.create(:user_property, company: @company)
    end


    # Rails Admin Navigation helpers starts here...

    # There are times objects created with Factorybot do not appear, probably due to caching or because automation is too fast.
    # We then retry to locate the object up to three times.
    def go_to_module_dashboard
      raise "Unable to call module dashboard. Module Name not provided!" unless (@module_info.key? :name_plural)
      raise "Unable to call module dashboard. Module Navigation path not provided!" unless (@module_info.key? :navbar_path)
      begin
        retry_ctr ||= 0
        visit "/admin" if page.current_url.index("admin").nil?
        find("body > nav > div.toggleSideMenuButton.fa.fa-bars").click
        within("#accordion") do
          @module_info[:navbar_path].each_with_index do |path, index|
            find(".panel-heading a", text: path).click if index == 0
            find(".panel-body a", text: path).click if index == 1
          end
        end
        expect(page).to have_content("List of #{@module_info[:name_plural]}")
      rescue Capybara::ElementNotFound => e
        if (retries += 1) < 3
          retry
        else
          raise
        end
      end

      yield if block_given?

    end

    # There are times objects created with Factorybot do not appear, probably due to caching or because automation is too fast.
    # We then retry to locate the object up to three times.
    def find_and_edit(name)
      go_to_module_dashboard do

        begin
          retry_ctr ||= 0

          fill_in 'query', with: name
          click_button 'Refresh'
          expect(page).to have_selector('table.table tbody tr:first-child td:nth-child(2)', text: name)
          within 'table.table tr:first-child td.links' do
            click_link 'Edit'
          end
          expect(page).to have_content("Edit #{@module_info[:name]} '#{name}'")

        rescue Capybara::ElementNotFound => e
          if (retries += 1) < 3
            retry
          else
            raise
          end
        end


      end

    end

    # There are times objects created with Factorybot do not appear, probably due to caching or because automation is too fast.
    # We then retry to locate the object up to three times.
    def find_and_show(name)
      go_to_module_dashboard do
        begin
          retry_ctr ||= 0

          click_link "List"
          fill_in 'query', with: name
          click_button 'Refresh'

          expect(page).to have_selector('table.table tbody tr:first-child td:nth-child(2)', text: name)
          within 'table.table tr:first-child td.links' do
            click_link 'Show'
          end
          expect(page).to have_content("Details for #{@module_info[:name]} '#{name}'")

        rescue Capybara::ElementNotFound => e
          if (retries += 1) < 3
            retry
          else
            raise
          end
        end

      end

    end

    def fill_in_filtering_select (selector_id = "", str)
      within(:xpath, "//select[@id='#{selector_id}']/ancestor::div[contains(@class, 'form-group')]") do
        find("span.input-group-btn").click
        expect(page).to have_selector('input[type="text"].ra-filtering-select-input', visible: true)
        find('input[type="text"].ra-filtering-select-input').click.send_keys str, :down
      end

    end

    def fill_in_multifiltering_select (operation = "add", selector_id = "", values = [])
      within(:xpath, "//div[@id='#{selector_id}_field']") do
        if operation == "choose all"
          click_link "Choose all"
        elsif operation == "clear all"
          click_link "Clear all"
        elsif operation == "add"
          values.each do |value|
            find('div.ra-multiselect-header input[type="search"]').set("").send_keys value
            within('div.ra-multiselect-left') do
              find('select option', text: "#{value}").click
            end
            click_link "Add"
            within('div.ra-multiselect-right') do
              expect(page).to have_selector "select option", text: value
            end
          end
        elsif operation == "remove"
          values.each do |value|
            within('div.ra-multiselect-right') do
              expect(page).to have_selector "select option", text: value
              select_element = find("select")
              select_element.select value
            end
            click_link "Remove"
            within('div.ra-multiselect-left') do
              expect(page).to have_selector "select option", text: value
            end
          end
        end

      end
    end

    def add_new_module_item
      go_to_module_dashboard do
        click_link "Add new"
        expect(page).to have_content "New #{@module_info[:name]}"
        yield if block_given?
      end

    end

    def export_from_dashboard
      go_to_module_dashboard do
        within ('ul.nav-tabs') { click_link "Export" }
        expect(page).to have_content "Export #{@module_info[:name]}"
        yield if block_given?
      end

    end


    # Ace Editor From: https://www.eliotsykes.com/testing-ace-editor
    def fill_in_editor_field(code_editor_container, text)
      within(code_editor_container) { find_ace_editor_field.set text }
    end

    # Ace uses textarea.ace_text-input as
    # its input stream.
    def find_ace_editor_field
      input_field_locator = ".ace_text-input"
      is_input_field_visible = false
      find(input_field_locator, visible: is_input_field_visible)
    end

    # Ace uses div.ace_content as its
    # output stream to display the code
    # entered in the textarea.
    def have_editor_display(options)
      editor_display_locator = ".ace_content"
      have_css(editor_display_locator, options)
    end


    # Company and Application Scope
    def change_company company
      within "#scopeSelector ul li:nth-child(1)" do
        find(".select2-selection__arrow").click
      end
      expect(page).to have_selector :xpath, "/html/body/span[2]/span/span[1]/input" # this is not a very good selector, watch out
      page.find(:xpath, "/html/body/span[2]/span/span[1]/input").click.send_keys company, :enter
      expect(page).to have_content "Site Administration"
      within "#scopeSelector ul li:nth-child(1)" do
        expect(page).to have_selector("#select2-Company-scope-container", text: company)
      end
    end

    def change_application application
      within "#scopeSelector ul li:nth-child(2)" do
        find(".select2-selection__arrow").click
      end
      expect(page).to have_selector :xpath, "/html/body/span[2]/span/span[1]/input" # this is not a very good selector, watch out
      page.find(:xpath, "/html/body/span[2]/span/span[1]/input").click.send_keys application, :enter
      expect(page).to have_content "Site Administration"
      within "#scopeSelector ul li:nth-child(2)" do
        expect(page).to have_selector("#select2-Application-scope-container", text: application)
      end
    end


  end

end


