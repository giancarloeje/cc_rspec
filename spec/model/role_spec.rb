require 'spec_helper'
require 'factories'

describe 'Role', type: :model do

  it 'is invalid when attributes are not defined' do
    role = Role.new
    expect{role.save!}.to raise_exception(ActiveRecord::RecordInvalid, "Validation failed: Name can't be blank")
  end

  it 'is valid when name is defined' do
    role = Role.new(:name => 'role')
    role.save!
    expect(Role.count).to eq(1)
  end

  it 'should trigger update mfa after save' do
    role = Role.new(:name => 'role')
    expect(role).to receive(:update_mfa)
    role.save
  end
end