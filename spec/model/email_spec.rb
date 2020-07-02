require 'spec_helper'
require 'factories'

describe 'Email', type: :model do

  it 'is not valid when attributes are not defined' do
    e = Email.new
    expect{e.save!}.to raise_exception(ActiveRecord::RecordInvalid, "Validation failed: Name can't be blank, Key can't be blank, Key should contain alpha numeric and underscore characters only, From can't be blank, To can't be blank, Subject can't be blank, Body can't be blank")
  end

  it 'is not valid when name is empty' do
    e = Email.new(:key => 'email', :from_field_id => '1', :to_field_id => '1', :email_subject => 'E-mail subject', :email_body => 'email body')
    expect{e.save!}.to raise_exception(ActiveRecord::RecordInvalid, "Validation failed: Name can't be blank")
  end

  it 'is not valid when key is numeric' do
    e = Email.new(:name => 'email', :key => '1', :from_field_id => '1', :to_field_id => '1', :email_subject => 'E-mail subject', :email_body => 'email body')
    expect{e.save!}.to raise_exception(ActiveRecord::RecordInvalid, "Validation failed: Key should contain alpha numeric and underscore characters only")
  end

  it 'is not valid when from field is empty' do
    e = Email.new(:name => 'email', :key => 'email', :to_field_id => '1', :email_subject => 'E-mail subject', :email_body => 'email_body')
    expect{e.save!}.to raise_exception(ActiveRecord::RecordInvalid, "Validation failed: From can't be blank")
  end

  it 'is not valid when to field is empty' do
    e = Email.new(:name => 'email', :key => 'email', :from_field_id => '1', :email_subject => 'E-mail subject', :email_body => 'email_body')
    expect{e.save!}.to raise_exception(ActiveRecord::RecordInvalid, "Validation failed: To can't be blank")
  end

  it 'is not valid when to field is empty' do
    e = Email.new(:name => 'email', :key => 'email', :from_field_id => '1', :to_field_id => '1', :email_subject => 'E-mail subject', :email_body => '')
    expect{e.save!}.to raise_exception(ActiveRecord::RecordInvalid, "Validation failed: Body can't be blank")
  end

  it 'is valid when all attributes are defined' do
    e = Email.new(:name => 'email', :key => 'email', :from_field_id => '1', :to_field_id => '1', :email_subject => 'E-mail subject', :email_body => 'body')
    expect(e).to be_valid
  end
end