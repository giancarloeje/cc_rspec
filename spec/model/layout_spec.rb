require 'spec_helper'
require 'factories'

describe 'Layout', type: :model do

  it 'is invalid when attributes are not defined' do
    layout = Layout.new
    expect {layout.save!}.to raise_exception(ActiveRecord::RecordInvalid, "Validation failed: Name can't be blank")
  end

  it 'is valid when attributes are defined properly' do
    layout = Layout.new(:name => 'Layout')
    layout.save!
    expect(Layout.count).to eq(1)
  end
end