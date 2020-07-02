require 'rails_helper'
require 'factories'

def go_to_login
  visit '/admin'
  expect(page).to have_content("You need to sign in or sign up before continuing.")
end

feature 'Unlock account' do

  scenario 'When an invalid email requests for reset token, an error should appear' do
    visit '/admin'
    expect(current_path).to eq('/users/sign_in')
    click_link ("Didn't receive unlock instructions?")
    expect(current_path).to eq('/users/unlock/new')
    expect(page).to have_content ("E-mail")

    fill_in 'user_email', with: 'invalid_email@dom'
    click_button "Resend unlock instructions"

    within 'div#flash-alert' do
       expect(page).to have_content ("E-mail not found")
    end
    save_screenshot('Screenshots/features/unlock_account/001.png', full: true)

  end

  scenario 'When an unlocked account requests for reset token, an error should appear' do
    user = FactoryBot.create(:user, company: @company)
    visit '/admin'
    expect(current_path).to eq('/users/sign_in')
    click_link ("Didn't receive unlock instructions?")
    expect(current_path).to eq('/users/unlock/new')
    expect(page).to have_content ("E-mail")

    fill_in 'user_email', with: user.email
    click_button "Resend unlock instructions"
    within 'div#flash-alert' do
      expect(page).to have_content("E-mail was not locked")
    end
    save_screenshot('Screenshots/features/unlock_account/002.png', full: true)
  end

  scenario 'Resend unlock instructions to a locked account' do
    user = FactoryBot.create(:user, company: @company)

    go_to_login

    fill_in 'user_email', with: user.email
    fill_in 'user_password', with: '1234'
    click_button 'Sign in'
    expect(page).to have_content ("Invalid email or password.")

    fill_in 'user_email', with: user.email
    fill_in 'user_password', with: '1234a'
    click_button 'Sign in'
    expect(page).to have_content ("You have one more attempt before your account is locked.")

    fill_in 'user_email', with: user.email
    fill_in 'user_password', with: '1234abcd'
    click_button 'Sign in'
    expect(page).to have_content ("Your account is locked.")

    click_link ("Didn't receive unlock instructions?")
    expect(current_path).to eq('/users/unlock/new')
    expect(page).to have_content ("E-mail")

    fill_in 'user_email', with: user.email
    sleep 2
    find('input[name="commit"]').click
    expect(page).to have_content("You will receive an email with instructions about how to unlock your account in a few minutes.")
    expect(last_email.to).to include(user.email)
    expect(last_email.subject).to eq('Unlock Instructions')
    save_screenshot('Screenshots/features/unlock_account/003.png', full: true)
  end

  scenario 'Resend unlock instructions from forgot password page' do
    user = FactoryBot.create(:user, company: @company)
    visit '/admin'

    fill_in 'user_email', with: user.email
    fill_in 'user_password', with: '1234'
    click_button 'Sign in'
    expect(page).to have_content ("Invalid email or password.")

    fill_in 'user_email', with: user.email
    fill_in 'user_password', with: '1234a'
    click_button 'Sign in'
    expect(page).to have_content ("You have one more attempt before your account is locked.")

    fill_in 'user_email', with: user.email
    fill_in 'user_password', with: '1234abcd'
    click_button 'Sign in'
    expect(page).to have_content ("Your account is locked.")
    expect(current_path).to eq('/users/sign_in')

    click_link ("Didn't receive unlock instructions?")
    expect(current_path).to eq('/users/unlock/new')
    expect(page).to have_content ("E-mail")

    fill_in 'user_email', with: user.email
    find('input[name="commit"]').click
    expect(page).to have_content("You will receive an email with instructions about how to unlock your account in a few minutes.")
    expect(last_email.to).to include(user.email)
    expect(last_email.subject).to eq('Unlock Instructions')
    save_screenshot('Screenshots/features/unlock_account/004.png', full: true)
  end

  scenario 'email user unlock instructions' do
    user = FactoryBot.create(:user, company: @company)

    go_to_login
    fill_in 'user_email', with: user.email
    fill_in 'user_password', with: '1234'
    click_button 'Sign in'
    expect(page).to have_content ("Invalid email or password.")

    fill_in 'user_email', with: user.email
    fill_in 'user_password', with: '1234a'
    click_button 'Sign in'
    expect(page).to have_content ("You have one more attempt before your account is locked.")

    fill_in 'user_email', with: user.email
    fill_in 'user_password', with: '1234abcd'
    click_button 'Sign in'
    expect(page).to have_content ("Your account is locked.")

    expect(last_email.to).to include(user.email)
    expect(last_email.subject).to eq('Unlock Instructions')
    save_screenshot('Screenshots/features/unlock_account/005.png', full: true)
  end
end