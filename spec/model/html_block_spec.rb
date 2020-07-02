require 'spec_helper'
require 'factories'

describe 'Html Block', type: :model do

  it 'is invalid when attributes are not defined' do
    html_block = HtmlBlock.new
    expect {html_block.save!}.to raise_exception(ActiveRecord::RecordInvalid, "Validation failed: Name can't be blank, Key can't be blank, Key should contain alpha numeric and underscore characters only")
  end

  it 'is valid when attributes are defined properly' do
    html_block = HtmlBlock.new(:name => 'Html Block')
    html_block.save!
    expect(HtmlBlock.count).to eq(1)
  end

  it 'it should have a pattern attribute' do
    @pattern = Pattern.new
    expect(@pattern).to respond_to(:html_block_id)
  end
end