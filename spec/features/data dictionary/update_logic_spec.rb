require 'rails_helper'
require 'factories'

feature 'Update Logic' do

scenario 'Append update logic adds null field after save (CMOSD-605)' do

  # Test

    pending("TODO update_logic_spec")

    @company = FactoryBot.create(:company)
    @application = FactoryBot.create(:application, company: @company)

    table = Table.new(:name => 'table', :key => 'table', :update_logic => 'append', application: @application)

    table.fields.build(:name => 'field1', :key => 'field1', :field_type => 'String')
    table.fields.build(:name => 'field2', :key => 'field2', :field_type => 'String')
    record = @application.get_mongoid_class.new
    record.add_system_record(nil, @application, @company)
    record.save!


    f = [{:field1 => "One", :field2 => "Two"}]
    record.write_attributes(:table => f)

    f = [{:field1 => "AAA", :field2 => "BBB"}]
    record.write_attributes(:table[1] => f)

    p record.table[0].inspect

    #record.table[0].attributes.merge!(f)

    #This needs to be completed
    expect(0).to eq(1)

  end

end