require 'rails_helper'
require 'factories'
require 'cancan/matchers'

describe 'Filter', type: :model do

  before(:each) do
    @application = FactoryBot.create(:application)
    define_record_factory(nil, @application)
  end

  it 'is invalid when no attributes are defined' do
    filter = Filter.new()
    expect{filter.save!}.to raise_exception(ActiveRecord::RecordInvalid, "Validation failed: Name can't be blank, Key can't be blank, Key should contain alpha numeric and underscore characters only")
  end

  it 'add support for months in queues (CMOSD-599)' do
    @field = FactoryBot.create(:field, name: 'Test Field', key: 'test_field', application: @application, field_type: 'String', default_value: 'test')

    @record = create_record(@application)
    @queue = FactoryBot.create(:filter, data:'{"columndata":[{"tableslot":"type=String&table=[NO TABLE]&field=test_field", "table":"[NO TABLE]", "field":"test_field", "columnas":"Test" , "columnhidden":"false"}],"sortdata":[],"groupdata":[],"wheredata":[{"tableslot":"type=Date&table=system&field=created_at", "table":"system", "field":"created_at","opslot":"8","op":"lt","chainslot":"0","chain":"and","columnvalue":"[1.months.ago]"}]}', application: @application)

    i = Q::Filter.new({:application => @application, :model => @application.get_mongoid_class, :query => @queue.data}).count
    expect(i).to eq(0)
  end

  it 'should display records based on the condition of updated_at (CMOSD-490, CMOSD-458)' do
    @field = FactoryBot.create(:field, name: 'Test Field', key: 'test_field', application: @application, field_type: 'String', default_value: 'test')

    @record = create_record(@application)
    @queue = FactoryBot.create(:filter, data:'{"columndata":[{"tableslot":"type=String&table=[NO TABLE]&field=test_field", "table":"[NO TABLE]", "field":"test_field", "columnas":"Test" , "columnhidden":"false"}],"sortdata":[],"groupdata":[],"wheredata":[{"tableslot":"type=Date&table=system&field=updated_at", "table":"system", "field":"updated_at","opslot":"8","op":"lt","chainslot":"0","chain":"and","columnvalue":"[1.days.from_now]"}]}', application: @application)

    i = Q::Filter.new({:application => @application, :model => @application.get_mongoid_class, :query => @queue.data}).count
    expect(i).to eq(1)
  end

  it 'should display record when created_by_role, edited_by_role and owned_by_role are added on queue column (CMOSD-430)' do
    @record = create_record(@application)
    @queue = FactoryBot.create(:filter, data:'{"columndata":[{"tableslot":"type=String&table=system&field=created_by_role", "table":"system", "field":"created_by_role", "columnas":"created_by_role" , "columnhidden":"false"},{"tableslot":"type=String&table=system&field=edited_by_role", "table":"system", "field":"edited_by_role", "columnas":"edited_by_role" , "columnhidden":"false"},{"tableslot":"type=String&table=system&field=owned_by_role", "table":"system", "field":"owned_by_role", "columnas":"owned_by_role" , "columnhidden":"false"}],"sortdata":[],"groupdata":[],"wheredata":[]}', application: @application)

    i = Q::Filter.new({:application => @application, :model => @application.get_mongoid_class, :query => @queue.data}).count
    expect(i).to eq(1)
  end

  # Use different field types as queue filter

  it 'should use CaseInsensitiveString as queue filter (CMOSD-576)' do
    @field = FactoryBot.create(:field, name: 'Test Field', key: 'test_field', application: @application, field_type: 'Mongoid::CaseInsensitiveString', default_value: 'TEST')

    @record = create_record(@application)
    @queue = FactoryBot.create(:filter, data:'{"columndata":[{"tableslot":"type=Mongoid::CaseInsensitiveString&table=[NO TABLE]&field=test_field", "table":"[NO TABLE]", "field":"test_field", "columnas":"Test Field" , "columnhidden":"false"}],"sortdata":[],"groupdata":[],"wheredata":[{"tableslot":"type=Mongoid::CaseInsensitiveString&table=[NO TABLE]&field=test_field", "table":"[NO TABLE]", "field":"test_field","opslot":"0","op":"eq","chainslot":"0","chain":"and","columnvalue":"TEST"}]}', application: @application)

    i = Q::Filter.new({:application => @application, :model => @application.get_mongoid_class, :query => @queue.data}).count
    expect(i).to eq(1)
  end

  it 'should use String field type as queue filter' do
    @field = FactoryBot.create(:field, name: 'Test Field', key: 'test_field', application: @application, field_type: 'String', default_value: 'test')

    @record = create_record(@application)
    @queue = FactoryBot.create(:filter, data:'{"columndata":[{"tableslot":"type=String&table=[NO TABLE]&field=test_field", "table":"[NO TABLE]", "field":"test_field", "columnas":"Test" , "columnhidden":"false"}],"sortdata":[],"groupdata":[],"wheredata":[{"tableslot":"type=String&table=[NO TABLE]&field=test_field", "table":"[NO TABLE]", "field":"test_field","opslot":"0","op":"eq","chainslot":"0","chain":"and","columnvalue":"test"}]}', application: @application)

    i = Q::Filter.new({:application => @application, :model => @application.get_mongoid_class, :query => @queue.data}).count
    expect(i).to eq(1)
  end

  it 'should use Integer field type as queue filter' do
    @field = FactoryBot.create(:field, name: 'Test Field', key: 'test_field', application: @application, field_type: 'Integer', default_value: '1')

    @record = create_record(@application)
    @queue = FactoryBot.create(:filter, data:'{"columndata":[{"tableslot":"type=Integer&table=[NO TABLE]&field=test_field", "table":"[NO TABLE]", "field":"test_field", "columnas":"Test" , "columnhidden":"false"}],"sortdata":[],"groupdata":[],"wheredata":[{"tableslot":"type=Integer&table=[NO TABLE]&field=test_field", "table":"[NO TABLE]", "field":"test_field","opslot":"0","op":"eq","chainslot":"0","chain":"and","columnvalue":"1"}]}', application: @application)

    i = Q::Filter.new({:application => @application, :model => @application.get_mongoid_class, :query => @queue.data}).count
    expect(i).to eq(1)
  end

  it 'should use Float field type as queue filter' do
    @field = FactoryBot.create(:field, name: 'Test Field', key: 'test_field', application: @application, field_type: 'Float', default_value: '1.234')

    @record = create_record(@application)
    @queue = FactoryBot.create(:filter, data:'{"columndata":[{"tableslot":"type=Float&table=[NO TABLE]&field=test_field", "table":"[NO TABLE]", "field":"test_field", "columnas":"Test" , "columnhidden":"false"}],"sortdata":[],"groupdata":[],"wheredata":[{"tableslot":"type=Float&table=[NO TABLE]&field=test_field", "table":"[NO TABLE]", "field":"test_field","opslot":"0","op":"eq","chainslot":"0","chain":"and","columnvalue":"1.234"}]}', application: @application)

    i = Q::Filter.new({:application => @application, :model => @application.get_mongoid_class, :query => @queue.data}).count
    expect(i).to eq(1)
  end

  it 'should use Big Decimal field type as queue filter' do
    @field = FactoryBot.create(:field, name: 'Test Field', key: 'test_field', application: @application, field_type: 'BigDecimal', default_value: '1000.2345')

    @record = create_record(@application)
    @queue = FactoryBot.create(:filter, data:'{"columndata":[{"tableslot":"type=BigDecimal&table=[NO TABLE]&field=test_field", "table":"[NO TABLE]", "field":"test_field", "columnas":"Test" , "columnhidden":"false"}],"sortdata":[],"groupdata":[],"wheredata":[{"tableslot":"type=BigDecimal&table=[NO TABLE]&field=test_field", "table":"[NO TABLE]", "field":"test_field","opslot":"0","op":"eq","chainslot":"0","chain":"and","columnvalue":"1000.2345"}]}', application: @application)

    i = Q::Filter.new({:application => @application, :model => @application.get_mongoid_class, :query => @queue.data}).count
    expect(i).to eq(1)
  end

  it 'should use Money field type as queue filter' do
    @field = FactoryBot.create(:field, name: 'Test Field', key: 'test_field', application: @application, field_type: 'Money', default_value: '1000')

    @record = create_record(@application)
    @queue = FactoryBot.create(:filter, data:'{"columndata":[{"tableslot":"type=Money&table=[NO TABLE]&field=test_field", "table":"[NO TABLE]", "field":"test_field", "columnas":"Test" , "columnhidden":"false"}],"sortdata":[],"groupdata":[],"wheredata":[{"tableslot":"type=Money&table=[NO TABLE]&field=test_field", "table":"[NO TABLE]", "field":"test_field","opslot":"0","op":"eq","chainslot":"0","chain":"and","columnvalue":"1000"}]}', application: @application)

    i = Q::Filter.new({:application => @application, :model => @application.get_mongoid_class, :query => @queue.data}).count
    expect(i).to eq(1)
  end

  it 'should use Date field type as queue filter' do
    @field = FactoryBot.create(:field, name: 'Test Field', key: 'test_field', application: @application, field_type: 'Date', default_value: '20/05/2015')

    @record = create_record(@application)
    @queue = FactoryBot.create(:filter, data:'{"columndata":[{"tableslot":"type=Date&table=[NO TABLE]&field=test_field", "table":"[NO TABLE]", "field":"test_field", "columnas":"Test" , "columnhidden":"false"}],"sortdata":[],"groupdata":[],"wheredata":[{"tableslot":"type=Date&table=[NO TABLE]&field=test_field", "table":"[NO TABLE]", "field":"test_field","opslot":"0","op":"eq","chainslot":"0","chain":"and","columnvalue":"2015-05-20"}]}', application: @application)

    i = Q::Filter.new({:application => @application, :model => @application.get_mongoid_class, :query => @queue.data}).count
    expect(i).to eq(1)
  end

  # Use different queue conditions on integer field type
  # equal, not equal, greater than, greater or equal, lower than, lower or equal,
  # exists?, not exists?, empty?

  it 'Should add record in queue (CMOSD-744)' do
    # should return record if Int is equal to 100
    table = FactoryBot.create(:table, name: 'Table', key: 'Table', application: @application)
    @field = FactoryBot.create(:field, name: 'Int', key: 'Int', table: table, application: @application, field_type: 'Integer', default_value: 100)

    @record = create_record(@application)
    @queue = FactoryBot.create(:filter, data:'{"columndata":[{"tableslot":"type=Integer&table=Table&field=Int", "table":"Table", "field":"Int", "columnas":"Int" , "columnhidden":"false"}],"sortdata":[],"groupdata":[],"wheredata":[{"tableslot":"type=Integer&table=Table&field=Int", "table":"Table", "field":"Int","opslot":"0","op":"gte","chainslot":"0","chain":"and","columnvalue":"100"}]}', application: @application)

    i = Q::Filter.new({:application => @application, :model => @application.get_mongoid_class, :query => @queue.data}).count
    expect(i).to eq(1)
  end

  it 'Should not add record in queue (CMOSD-744)' do
    # should return 0 if Int != 100
    table = FactoryBot.create(:table, name: 'Table', key: 'Table', application: @application)
    @field = FactoryBot.create(:field, name: 'Int', key: 'Int', table: table, application: @application, field_type: 'Integer', default_value: 10)

    @record = create_record(@application)
    @queue = FactoryBot.create(:filter, data:'{"columndata":[{"tableslot":"type=Integer&table=Table&field=Int", "table":"Table", "field":"Int", "columnas":"Int" , "columnhidden":"false"}],"sortdata":[],"groupdata":[],"wheredata":[{"tableslot":"type=Integer&table=Table&field=Int", "table":"Table", "field":"Int","opslot":"0","op":"gte","chainslot":"0","chain":"and","columnvalue":"100"}]}', application: @application)

    i = Q::Filter.new({:application => @application, :model => @application.get_mongoid_class, :query => @queue.data}).count
    expect(i).to eq(0)
  end

  it 'should return record since Int field is equal to 100 (queue uses eq)' do
    @field = FactoryBot.create(:field, name: 'Int', key: 'Int', application: @application, field_type: 'Integer', default_value: 100)

    @record = create_record(@application)
    @queue = FactoryBot.create(:filter, data:'{"columndata":[{"tableslot":"type=Integer&table=[NO TABLE]&field=Int", "table":"[NO TABLE]", "field":"Int", "columnas":"Int" , "columnhidden":"false"}],"sortdata":[],"groupdata":[],"wheredata":[{"tableslot":"type=Integer&table=[NO TABLE]&field=Int", "table":"[NO TABLE]", "field":"Int","opslot":"0","op":"eq","chainslot":"0","chain":"and","columnvalue":"100"}]}', application: @application)

    i = Q::Filter.new({:application => @application, :model => @application.get_mongoid_class, :query => @queue.data}).count
    expect(i).to eq(1)
  end

  it 'should not return record since Int field is not equal to 100 (queue uses ne)' do
    @field = FactoryBot.create(:field, name: 'Int', key: 'Int', application: @application, field_type: 'Integer', default_value: 100)

    @record = create_record(@application)
    @queue = FactoryBot.create(:filter, data:'{"columndata":[{"tableslot":"type=Integer&table=[NO TABLE]&field=Int", "table":"[NO TABLE]", "field":"Int", "columnas":"Int" , "columnhidden":"false"}],"sortdata":[],"groupdata":[],"wheredata":[{"tableslot":"type=Integer&table=[NO TABLE]&field=Int", "table":"[NO TABLE]", "field":"Int","opslot":"0","op":"ne","chainslot":"0","chain":"and","columnvalue":"100"}]}', application: @application)

    i = Q::Filter.new({:application => @application, :model => @application.get_mongoid_class, :query => @queue.data}).count
    expect(i).to eq(0)
  end

  it 'should return record since Int field is greater than 100 (queue uses gt)' do
    @field = FactoryBot.create(:field, name: 'Int', key: 'Int', application: @application, field_type: 'Integer', default_value: 101)

    @record = create_record(@application)
    @queue = FactoryBot.create(:filter, data:'{"columndata":[{"tableslot":"type=Integer&table=[NO TABLE]&field=Int", "table":"[NO TABLE]", "field":"Int", "columnas":"Int" , "columnhidden":"false"}],"sortdata":[],"groupdata":[],"wheredata":[{"tableslot":"type=Integer&table=[NO TABLE]&field=Int", "table":"[NO TABLE]", "field":"Int","opslot":"0","op":"gt","chainslot":"0","chain":"and","columnvalue":"100"}]}', application: @application)

    i = Q::Filter.new({:application => @application, :model => @application.get_mongoid_class, :query => @queue.data}).count
    expect(i).to eq(1)
  end

  it 'should not return record since Int is less than 100 (queue uses gt)' do
    @field = FactoryBot.create(:field, name: 'Int', key: 'Int', application: @application, field_type: 'Integer', default_value: 99)

    @record = create_record(@application)
    @queue = FactoryBot.create(:filter, data:'{"columndata":[{"tableslot":"type=Integer&table=[NO TABLE]&field=Int", "table":"[NO TABLE]", "field":"Int", "columnas":"Int" , "columnhidden":"false"}],"sortdata":[],"groupdata":[],"wheredata":[{"tableslot":"type=Integer&table=[NO TABLE]&field=Int", "table":"[NO TABLE]", "field":"Int","opslot":"0","op":"gt","chainslot":"0","chain":"and","columnvalue":"100"}]}', application: @application)

    i = Q::Filter.new({:application => @application, :model => @application.get_mongoid_class, :query => @queue.data}).count
    expect(i).to eq(0)
  end

  it 'should not return record since Int is equal to 100 (queue uses gt)' do
    @field = FactoryBot.create(:field, name: 'Int', key: 'Int', application: @application, field_type: 'Integer', default_value: 100)

    @record = create_record(@application)
    @queue = FactoryBot.create(:filter, data:'{"columndata":[{"tableslot":"type=Integer&table=[NO TABLE]&field=Int", "table":"[NO TABLE]", "field":"Int", "columnas":"Int" , "columnhidden":"false"}],"sortdata":[],"groupdata":[],"wheredata":[{"tableslot":"type=Integer&table=[NO TABLE]&field=Int", "table":"[NO TABLE]", "field":"Int","opslot":"0","op":"gt","chainslot":"0","chain":"and","columnvalue":"100"}]}', application: @application)

    i = Q::Filter.new({:application => @application, :model => @application.get_mongoid_class, :query => @queue.data}).count
    expect(i).to eq(0)
  end

  it 'should return record since Int is greater than 100 (queue uses gte)' do
    @field = FactoryBot.create(:field, name: 'Int', key: 'Int', application: @application, field_type: 'Integer', default_value: 101)

    @record = create_record(@application)
    @queue = FactoryBot.create(:filter, data:'{"columndata":[{"tableslot":"type=Integer&table=[NO TABLE]&field=Int", "table":"[NO TABLE]", "field":"Int", "columnas":"Int" , "columnhidden":"false"}],"sortdata":[],"groupdata":[],"wheredata":[{"tableslot":"type=Integer&table=[NO TABLE]&field=Int", "table":"[NO TABLE]", "field":"Int","opslot":"0","op":"gte","chainslot":"0","chain":"and","columnvalue":"100"}]}', application: @application)

    i = Q::Filter.new({:application => @application, :model => @application.get_mongoid_class, :query => @queue.data}).count
    expect(i).to eq(1)
  end

  it 'should return record since Int is equal to 100 (queue uses gte)' do
    @field = FactoryBot.create(:field, name: 'Int', key: 'Int', application: @application, field_type: 'Integer', default_value: 100)

    @record = create_record(@application)
    @queue = FactoryBot.create(:filter, data:'{"columndata":[{"tableslot":"type=Integer&table=[NO TABLE]&field=Int", "table":"[NO TABLE]", "field":"Int", "columnas":"Int" , "columnhidden":"false"}],"sortdata":[],"groupdata":[],"wheredata":[{"tableslot":"type=Integer&table=[NO TABLE]&field=Int", "table":"[NO TABLE]", "field":"Int","opslot":"0","op":"gte","chainslot":"0","chain":"and","columnvalue":"100"}]}', application: @application)

    i = Q::Filter.new({:application => @application, :model => @application.get_mongoid_class, :query => @queue.data}).count
    expect(i).to eq(1)
  end

  it 'should not return record since Int is less than 100 (queue uses gte)' do
    @field = FactoryBot.create(:field, name: 'Int', key: 'Int', application: @application, field_type: 'Integer', default_value: 99)

    @record = create_record(@application)
    @queue = FactoryBot.create(:filter, data:'{"columndata":[{"tableslot":"type=Integer&table=[NO TABLE]&field=Int", "table":"[NO TABLE]", "field":"Int", "columnas":"Int" , "columnhidden":"false"}],"sortdata":[],"groupdata":[],"wheredata":[{"tableslot":"type=Integer&table=[NO TABLE]&field=Int", "table":"[NO TABLE]", "field":"Int","opslot":"0","op":"gte","chainslot":"0","chain":"and","columnvalue":"100"}]}', application: @application)

    i = Q::Filter.new({:application => @application, :model => @application.get_mongoid_class, :query => @queue.data}).count
    expect(i).to eq(0)
  end
  #
  it 'should return record whose Int is lower than 100 (queue uses lt)' do
    @field = FactoryBot.create(:field, name: 'Int', key: 'Int', application: @application, field_type: 'Integer', default_value: 99)

    @record = create_record(@application)
    @queue = FactoryBot.create(:filter, data:'{"columndata":[{"tableslot":"type=Integer&table=[NO TABLE]&field=Int", "table":"[NO TABLE]", "field":"Int", "columnas":"Int" , "columnhidden":"false"}],"sortdata":[],"groupdata":[],"wheredata":[{"tableslot":"type=Integer&table=[NO TABLE]&field=Int", "table":"[NO TABLE]", "field":"Int","opslot":"0","op":"lt","chainslot":"0","chain":"and","columnvalue":"100"}]}', application: @application)

    i = Q::Filter.new({:application => @application, :model => @application.get_mongoid_class, :query => @queue.data}).count
    expect(i).to eq(1)
  end
  #
  it 'should not return record since Int is greater than 100 (queue uses lt)' do
    @field = FactoryBot.create(:field, name: 'Int', key: 'Int', application: @application, field_type: 'Integer', default_value: 100)

    @record = create_record(@application)
    @queue = FactoryBot.create(:filter, data:'{"columndata":[{"tableslot":"type=Integer&table=[NO TABLE]&field=Int", "table":"[NO TABLE]", "field":"Int", "columnas":"Int" , "columnhidden":"false"}],"sortdata":[],"groupdata":[],"wheredata":[{"tableslot":"type=Integer&table=[NO TABLE]&field=Int", "table":"[NO TABLE]", "field":"Int","opslot":"0","op":"lt","chainslot":"0","chain":"and","columnvalue":"100"}]}', application: @application)

    i = Q::Filter.new({:application => @application, :model => @application.get_mongoid_class, :query => @queue.data}).count
    expect(i).to eq(0)
  end

  it 'should return record since Int is lower than 100 (queue uses lte)' do
    @field = FactoryBot.create(:field, name: 'Int', key: 'Int', application: @application, field_type: 'Integer', default_value: 99)

    @record = create_record(@application)
    @queue = FactoryBot.create(:filter, data:'{"columndata":[{"tableslot":"type=Integer&table=[NO TABLE]&field=Int", "table":"[NO TABLE]", "field":"Int", "columnas":"Int" , "columnhidden":"false"}],"sortdata":[],"groupdata":[],"wheredata":[{"tableslot":"type=Integer&table=[NO TABLE]&field=Int", "table":"[NO TABLE]", "field":"Int","opslot":"0","op":"lte","chainslot":"0","chain":"and","columnvalue":"100"}]}', application: @application)

    i = Q::Filter.new({:application => @application, :model => @application.get_mongoid_class, :query => @queue.data}).count
    expect(i).to eq(1)
  end

  it 'should return record since Int is equal to 100 (queue uses lte)' do
    @field = FactoryBot.create(:field, name: 'Int', key: 'Int', application: @application, field_type: 'Integer', default_value: 100)

    @record = create_record(@application)
    @queue = FactoryBot.create(:filter, data:'{"columndata":[{"tableslot":"type=Integer&table=[NO TABLE]&field=Int", "table":"[NO TABLE]", "field":"Int", "columnas":"Int" , "columnhidden":"false"}],"sortdata":[],"groupdata":[],"wheredata":[{"tableslot":"type=Integer&table=[NO TABLE]&field=Int", "table":"[NO TABLE]", "field":"Int","opslot":"0","op":"lte","chainslot":"0","chain":"and","columnvalue":"100"}]}', application: @application)

    i = Q::Filter.new({:application => @application, :model => @application.get_mongoid_class, :query => @queue.data}).count
    expect(i).to eq(1)
  end

  it 'should not return record since Int is greater than 100 (queue uses lte)' do
    @field = FactoryBot.create(:field, name: 'Int', key: 'Int', application: @application, field_type: 'Integer', default_value: 101)

    @record = create_record(@application)
    @queue = FactoryBot.create(:filter, data:'{"columndata":[{"tableslot":"type=Integer&table=[NO TABLE]&field=Int", "table":"[NO TABLE]", "field":"Int", "columnas":"Int" , "columnhidden":"false"}],"sortdata":[],"groupdata":[],"wheredata":[{"tableslot":"type=Integer&table=[NO TABLE]&field=Int", "table":"[NO TABLE]", "field":"Int","opslot":"0","op":"lte","chainslot":"0","chain":"and","columnvalue":"100"}]}', application: @application)

    i = Q::Filter.new({:application => @application, :model => @application.get_mongoid_class, :query => @queue.data}).count
    expect(i).to eq(0)
  end

  it 'should not return record since it is not in between 100 and 150 (queue uses lte, gte) (CMOSD-776)' do
    @field = FactoryBot.create(:field, name: 'Int', key: 'Int', application: @application, field_type: 'Integer', default_value: 99)

    @record = create_record(@application)
    @queue = FactoryBot.create(:filter, application: @application, data:'{"columndata":[{"tableslot":"type=Integer&table=[NO TABLE]&field=Int", "table":"[NO TABLE]", "field":"Int", "columnas":"Int" , "columnhidden":"false"}],"sortdata":[],"groupdata":[],"wheredata":[{"tableslot":"type=Integer&table=[NO TABLE]&field=Int", "table":"[NO TABLE]", "field":"Int","opslot":"9","op":"lte","chainslot":"0","chain":"and","columnvalue":"150"},{"tableslot":"type=Integer&table=[NO TABLE]&field=Int", "table":"[NO TABLE]", "field":"Int","opslot":"7","op":"gte","chainslot":"0","chain":"and","columnvalue":"100"}]}')
    i = Q::Filter.new({:application => @application, :model => @application.get_mongoid_class, :query => @queue.data}).count
    expect(i).to eq(0)
  end

  it 'should return record since it is in between 100 and 150 (queue uses lte, gte) (CMOSD-776)' do
    @field = FactoryBot.create(:field, name: 'Int', key: 'Int', application: @application, field_type: 'Integer', default_value: 100)

    @record = create_record(@application)
    @queue = FactoryBot.create(:filter, application: @application, data:'{"columndata":[{"tableslot":"type=Integer&table=[NO TABLE]&field=Int", "table":"[NO TABLE]", "field":"Int", "columnas":"Int" , "columnhidden":"false"}],"sortdata":[],"groupdata":[],"wheredata":[{"tableslot":"type=Integer&table=[NO TABLE]&field=Int", "table":"[NO TABLE]", "field":"Int","opslot":"9","op":"lte","chainslot":"0","chain":"and","columnvalue":"150"},{"tableslot":"type=Integer&table=[NO TABLE]&field=Int", "table":"[NO TABLE]", "field":"Int","opslot":"7","op":"gte","chainslot":"0","chain":"and","columnvalue":"100"}]}')
    i = Q::Filter.new({:application => @application, :model => @application.get_mongoid_class, :query => @queue.data}).count
    expect(i).to eq(1)
  end

  it 'should return record if Int exists' do
    @field = FactoryBot.create(:field, name: 'Int', key: 'Int', application: @application, field_type: 'Integer', default_value: 100)

    @record = create_record(@application)
    @queue = FactoryBot.create(:filter, data:'{"columndata":[{"tableslot":"type=Integer&table=[NO TABLE]&field=Int", "table":"[NO TABLE]", "field":"Int", "columnas":"Int" , "columnhidden":"false"}],"sortdata":[],"groupdata":[],"wheredata":[{"tableslot":"type=Integer&table=[NO TABLE]&field=Int", "table":"[NO TABLE]", "field":"Int","opslot":"14","op":"exists","chainslot":"0","chain":"and","columnvalue":""}]}', application: @application)

    i = Q::Filter.new({:application => @application, :model => @application.get_mongoid_class, :query => @queue.data}).count
    expect(i).to eq(1)
  end

  it 'should not return record since Int does not exist' do
    @field = FactoryBot.create(:field, name: 'Int1', key: 'Int1', application: @application, field_type: 'Integer')

    @record = create_record(@application)
    @queue = FactoryBot.create(:filter, data:'{"columndata":[{"tableslot":"type=Integer&table=[NO TABLE]&field=Int", "table":"[NO TABLE]", "field":"Int", "columnas":"Int" , "columnhidden":"false"}],"sortdata":[],"groupdata":[],"wheredata":[{"tableslot":"type=Integer&table=[NO TABLE]&field=Int", "table":"[NO TABLE]", "field":"Int","opslot":"14","op":"exists","chainslot":"0","chain":"and","columnvalue":""}]}', application: @application)

    i = Q::Filter.new({:application => @application, :model => @application.get_mongoid_class, :query => @queue.data}).count
    expect(i).to eq(0)
  end

  it 'should not return record if Int is empty' do
    @field = FactoryBot.create(:field, name: 'Int1', key: 'Int1', application: @application, field_type: 'Integer')

    @record = create_record(@application)
    @queue = FactoryBot.create(:filter, data:'{"columndata":[{"tableslot":"type=Integer&table=[NO TABLE]&field=Int", "table":"[NO TABLE]", "field":"Int", "columnas":"Int" , "columnhidden":"false"}],"sortdata":[],"groupdata":[],"wheredata":[{"tableslot":"type=Integer&table=[NO TABLE]&field=Int", "table":"[NO TABLE]", "field":"Int","opslot":"16","op":"empty","chainslot":"0","chain":"and","columnvalue":""}]}', application: @application)

    i = Q::Filter.new({:application => @application, :model => @application.get_mongoid_class, :query => @queue.data}).count
    expect(i).to eq(0)
  end

  # Use different queue conditions on created_by_role, edited_by_role, owned_by_role
  # in, nin

end