require 'rails_helper'
require 'factories'


feature 'User signs in' do

  def go_to_login(username, password)
    visit '/admin'
    expect(current_path).to eq('/users/sign_in')
    expect(page).to have_content("You need to sign in or sign up before continuing.")
    fill_in 'user_email', with: username
    fill_in 'user_password', with: password
  end

  scenario 'with valid email and password' do
    @company = FactoryBot.create(:company)
    user = FactoryBot.create(:user, company: @company)
    login_as(user, :scope => :user)
    visit '/admin'
    expect(page).to have_content ("Site Administration")
    save_screenshot('Screenshots/features/login/001.png', full: true)
    logout(:user)
  end

  scenario 'with invalid email' do
    @company = FactoryBot.create(:company)
    user = FactoryBot.create(:user, company: @company)
    go_to_login 'invalid_email@dom', user.password
    click_button 'Sign in'
    expect(page).to have_content ("Invalid E-mail or password.")
    save_screenshot('Screenshots/features/login/002.png', full: true)
  end

  scenario 'with invalid password' do
    @company = FactoryBot.create(:company)
    user = FactoryBot.create(:user, company: @company)
    go_to_login user.email, '1234'
    click_button 'Sign in'
    expect(page).to have_content ("Invalid email or password.")
    save_screenshot('Screenshots/features/login/003.png', full: true)
  end

  scenario 'with blank password' do
    @company = FactoryBot.create(:company)
    user = FactoryBot.create(:user, company: @company)
    go_to_login user.email, ''
    click_button 'Sign in'
    expect(page).to have_content ("Invalid E-mail or password.")
    save_screenshot('Screenshots/features/login/004.png', full: true)
  end

  scenario 'sign in from forgot password page' do
    @company = FactoryBot.create(:company)
    user = FactoryBot.create(:user, company: @company)
    visit '/admin'
    click_link 'Forgot your password?'
    expect(current_path).to eq('/users/password/new')

    fill_in 'user_email', with: user.email
    click_button 'Send me reset password instructions'
    expect(page).to have_content ("You will receive an email with instructions about how to reset your password in a few minutes.")
    save_screenshot('Screenshots/features/login/005.png', full: true)
  end

  scenario 'sign in from resend unlock instructions page' do
    @company = FactoryBot.create(:company)
    user = FactoryBot.create(:user, company: @company)
    visit '/admin'
    expect(current_path).to eq('/users/sign_in')
    click_link ("Didn't receive unlock instructions?")
    expect(current_path).to eq('/users/unlock/new')
    click_link 'Sign in'

    expect(current_path).to eq('/users/sign_in')
    expect(page).to have_link("Forgot your password?", href: '/users/password/new?locale=en')
    expect(page).to have_link("Didn't receive unlock instructions?", href: '/users/unlock/new?locale=en')
    save_screenshot('Screenshots/features/login/006.png', full: true)
  end

end
