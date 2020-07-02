require 'rails_helper'
require 'factories'

describe 'Field', type: :model do
  it 'should generate the same encrypted result (CMOSD-466)' do
    @company = FactoryBot.create(:company)
    @application = FactoryBot.create(:application, company: @company)
    @encrypted_field = FactoryBot.create(:field, key: 'encrypted_field', name: 'Encrypted Field', is_encrypted: true, application: @application)
    @application.generate_mongoid_model
    record = @application.get_mongoid_class.new
    record.encrypted_field = 'Hello World'
    record.add_system_record(nil, @application, @company)
    record.save!
    expect(record.encrypted_field.encrypted).to eq('XHgwMmB7fk1lRn59YFx4MDM=U2FsdGVkX19hbHNrbmQmaw80AwDwl3xkghidjs5i6Xs=')
  end

  it 'is invalid when attributes are not defined' do
    field = Field.new()
    expect{field.save!}.to raise_exception(ActiveRecord::RecordInvalid, "Validation failed: Name can't be blank, Key can't be blank, Key should start with alphabet or underscore followed by any alphanumeric character or underscore, Type can't be blank")
  end

  it 'is invalid when name is reserved name' do
    field = Field.new(:name => 'created_by', :field_type => "String")
    expect{field.save!}.to raise_exception(ActiveRecord::RecordInvalid, "Validation failed: Key is reserved and can't be used, Name is reserved and can't be used")
  end

  it 'is invalid when name is reserved name (test .downcase)' do
    field = Field.new(:name => 'CREATED_BY', :field_type => "String")
    expect{field.save!}.to raise_exception(ActiveRecord::RecordInvalid, "Validation failed: Key is reserved and can't be used, Name is reserved and can't be used")
  end

  it 'is invalid when key is numeric' do
    field = Field.new(:name => 'field', :key => '1', :field_type => "String")
    expect{field.save!}.to raise_exception(ActiveRecord::RecordInvalid, 'Validation failed: Key should start with alphabet or underscore followed by any alphanumeric character or underscore')
  end

  it 'is valid when attributes are defined properly' do
    field = Field.new(:name => 'field', :key => 'field', :field_type => "String")
    expect(field).to be_valid
  end

  it 'is valid when field type is String and default value is string' do
    field = Field.new(:key => 'field', :name => 'field', :field_type => 'String', :default_value => 'test')
    expect(field).to be_valid
  end

  it 'is valid when field type is String and default value is a number' do
    field = Field.new(:key => 'field', :name => 'field', :field_type => 'String', :default_value => '123')
    expect(field).to be_valid
  end

  it 'is valid when field type is String and default value is a character' do
    field = Field.new(:key => 'field', :name => 'field', :field_type => 'String', :default_value => '@!#$%^')
    expect(field).to be_valid
  end

  it 'is valid when a field type is String (Case Insensitive) and default value is a string ' do
    field = Field.new(:key => 'field', :name => 'field', :field_type => 'String (Case Insensitive)', :default_value => '@!#$%^')
    expect(field).to be_valid
  end

  it 'is invalid when field type is Integer and default value is string' do
    field = Field.new(:key => 'field', :name => 'field', :field_type => 'Integer', :default_value => 'test')
    expect{field.save!}.to raise_exception(ActiveRecord::RecordInvalid, 'Validation failed: Default value - invalid value for Integer(): "test"')
  end

  it 'is valid when field type and default value are both integers' do
    field = Field.new(:key => 'field', :name => 'field', :field_type => 'Integer', :default_value => '1')
    field.save!
    expect(Field.count).to equal(1)
  end

  it 'is invalid when field type is Float and default value is string' do
    field = Field.new(:key => 'field', :name => 'field', :field_type => 'Float', :default_value => 'test')
    expect{field.save!}.to raise_exception(ActiveRecord::RecordInvalid, 'Validation failed: Default value - invalid value for Float(): "test"')
  end

  it 'is valid when field type and default value are both float' do
    field = Field.new(:key => 'field', :name => 'field', :field_type => 'Float', :default_value => '123.0')
    field.save!
    expect(Field.count).to equal(1)
  end

  it 'is invalid when field type is Date and default value is in incorrect format' do
    field = Field.new(:key => 'field', :name => 'field', :field_type => 'Date', :default_value => '01/15/1991')
    expect{field.save!}.to raise_exception(ActiveRecord::RecordInvalid, 'Validation failed: Default value - Date format should be in dd/mm/yyyy format')
  end

  it 'is valid when field type is Date and default value is in correct format' do
    field = Field.new(:key => 'field', :name => 'field', :field_type => 'Date', :default_value => '15/01/1991')
    field.save!
    expect(Field.count).to equal(1)
  end

  it 'is invalid when field type is Money and default value is string' do
    field = Field.new(:key => 'field', :name => 'field', :field_type => 'Money', :default_value => 'test')
    expect{field.save!}.to raise_exception(ActiveRecord::RecordInvalid, 'Validation failed: Default value - invalid value for Money: test')
  end

  it 'is valid when field type is Money and default value is in correct format' do
    field = Field.new(:key => 'field', :name => 'field', :field_type => 'Money', :default_value => '100')
    field.save!
    expect(Field.count).to equal(1)
  end

  it 'is invalid when field type is Big Decimal and default value is string' do
    field = Field.new(:key => 'field', :name => 'field', :field_type => 'BigDecimal', :default_value => 'test')
    expect{field.save!}.to raise_exception(ActiveRecord::RecordInvalid, 'Validation failed: Default value - invalid value for BigDecimal: "test"')
  end

  it 'is valid when field type is BigDecimal and default value is in correct format' do
    field = Field.new(:key => 'field', :name => 'field', :field_type => 'BigDecimal', :default_value => '100')
    field.save!
    expect(Field.count).to equal(1)
  end

end


