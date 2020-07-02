require 'rails_helper'
require 'factories'

def go_to_login
  visit "/admin"
  expect(page).to have_content("You need to sign in or sign up before continuing.")
end

feature 'Password Reset' do

  scenario 'should email password reset url' do
    user = FactoryBot.create(:user)
    go_to_login

    click_link 'Forgot your password?'
    expect(current_path).to eq('/users/password/new')
    fill_in 'user_email', with: user.email
    click_button "Send me reset password instructions"
    expect(page).to have_content ("You will receive an email with instructions about how to reset your password in a few minutes.")

    expect(last_email.to).to include(user.email)
    expect(last_email.subject).to eq('Reset password instructions')
    save_screenshot('Screenshots/features/password_reset/001.png', full: true)
  end

  scenario 'should not send password reset link to an invalid email' do
    go_to_login
    click_link 'Forgot your password?'
    expect(current_path).to eq('/users/password/new')
    fill_in 'user_email', with: 'invalid_email@dom'
    click_button "Send me reset password instructions"

    expect(page).to have_content ("E-mail not found")
    save_screenshot('Screenshots/features/password_reset/002.png', full: true)
  end

  scenario 'should send password reset instructions from resend unlock instructions page' do
    user = FactoryBot.create(:user)
    go_to_login
    click_link ("Didn't receive unlock instructions?")
    expect(current_path).to eq('/users/unlock/new')
    click_link 'Forgot your password'

    expect(current_path).to eq('/users/password/new')
    fill_in 'user_email', with: user.email
    click_button "Send me reset password instructions"

    expect(last_email.to).to include(user.email)
    expect(last_email.subject).to eq('Reset password instructions')
    save_screenshot('Screenshots/features/password_reset/003.png', full: true)
  end

  scenario 'should return an error message when email is blank' do
    @user = FactoryBot.create(:user)
    go_to_login
    click_link ("Didn't receive unlock instructions?")
    expect(current_path).to eq('/users/unlock/new')
    click_link 'Forgot your password'

    expect(current_path).to eq('/users/password/new')
    fill_in 'user_email', with: ''
    click_button "Send me reset password instructions"

    expect(page).to have_content ("E-mail can't be blank")
    save_screenshot('Screenshots/features/password_reset/004.png', full: true)
  end

end