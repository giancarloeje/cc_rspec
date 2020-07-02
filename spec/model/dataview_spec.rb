require 'spec_helper'
require 'factories'

describe 'Data View Connector', type: :model do

  it 'is invalid if saved without any attributes' do
    dv = DataViewConnector.new
    expect { dv.save! }.to raise_exception(ActiveRecord::RecordInvalid, "Validation failed: Name can't be blank, Key can't be blank, Key should contain alpha numeric and underscore characters only, URL can't be blank, Input root node can't be blank, Output root node can't be blank, Payload Format can't be blank")
  end

  it 'is invalid if name is not supplied' do
    dv = DataViewConnector.new(:key => 'dv', :url => 'http://localhosts/DataviewService.asmx?wsdl', :input_root_node => 'input', :output_root_node => 'output', :open_timeout => '30', :read_timeout => '30', :payload_format => "json")
    expect { dv.save! }.to raise_exception(ActiveRecord::RecordInvalid, "Validation failed: Name can't be blank")
  end

  it 'is invalid if key is numeric' do
    dv = DataViewConnector.new(:name => 'dv', :key => '1', :url => 'http://localhosts/DataviewService.asmx?wsdl', :input_root_node => 'input', :output_root_node => 'output', :open_timeout => '30', :read_timeout => '30', :payload_format => "json")
    expect { dv.save! }.to raise_exception(ActiveRecord::RecordInvalid, "Validation failed: Key should contain alpha numeric and underscore characters only")
  end

  it 'is invalid if url is empty' do
    dv = DataViewConnector.new(:name => 'dv', :key => 'dv', :input_root_node => 'input', :output_root_node => 'output', :open_timeout => '30', :read_timeout => '30', :payload_format => "json")
    expect { dv.save! }.to raise_exception(ActiveRecord::RecordInvalid, "Validation failed: URL can't be blank")
  end

  it 'is invalid if payload format is empty' do
    dv = DataViewConnector.new(:name => 'dv', :key => 'dv', :url => 'http://localhosts/DataviewService.asmx?wsdl', :input_root_node => 'input', :output_root_node => 'output', :open_timeout => '30', :read_timeout => '30')
    expect { dv.save! }.to raise_exception(ActiveRecord::RecordInvalid, "Validation failed: Payload Format can't be blank")
  end

  it 'is invalid if input root node is empty' do
    dv = DataViewConnector.new(:name => 'dv', :key => 'dv', :url => 'http://localhost/DataviewService.asmx?wsdl', :input_root_node => '', :output_root_node => 'output', :open_timeout => '30', :read_timeout => '30', :payload_format => "json")
    expect { dv.save! }.to raise_exception(ActiveRecord::RecordInvalid, "Validation failed: Input root node can't be blank")
  end

  it 'is invalid if output root node is empty' do
    dv = DataViewConnector.new(:name => 'dv', :key => 'dv', :url => 'http://localhost/DataviewService.asmx?wsdl', :input_root_node => 'input', :output_root_node => '', :open_timeout => '30', :read_timeout => '30', :payload_format => "json")
    expect { dv.save! }.to raise_exception(ActiveRecord::RecordInvalid, "Validation failed: Output root node can't be blank")
  end

  it 'is invalid if open timeout is empty' do
    dv = DataViewConnector.new(:name => 'dv', :key => 'dv', :url => 'http://localhost/DataviewService.asmx?wsdl', :input_root_node => 'input', :output_root_node => 'output', :open_timeout => '', :read_timeout => '30', :payload_format => "json")
    expect { dv.save! }.to raise_exception(ActiveRecord::RecordInvalid, "Validation failed: Open timeout can't be blank")
  end

  it 'is invalid if read timeout is empty' do
    dv = DataViewConnector.new(:name => 'dv', :key => 'dv', :url => 'http://localhost/DataviewService.asmx?wsdl', :input_root_node => 'input', :output_root_node => 'output', :open_timeout => '30', :read_timeout => '', :payload_format => "json")
    expect { dv.save! }.to raise_exception(ActiveRecord::RecordInvalid, "Validation failed: Read timeout can't be blank")
  end

  it 'is valid if all attributes are valid' do
    dv = DataViewConnector.new(:name => 'dv', :key => 'dv', :url => 'http://localhost/DataviewService.asmx?wsdl', :input_root_node => 'input', :output_root_node => 'output', :open_timeout => '30', :read_timeout => '30', :payload_format => "json")
    expect(dv).to be_valid
  end
end