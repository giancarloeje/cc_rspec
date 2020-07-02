require 'factory_bot'
require 'rails_helper'

FactoryBot.define do

  factory :user do
    sequence :email do |n|
      "test_user_#{n}@gdslink.com"
    end
    password { 'Password!01' }
    password_confirmation { |u| u.password }
    is_admin { false }
    is_root { true }
    association :company
  end

  factory :company do
    sequence :name do |n|
      "Company Test #{n}"
    end
    sequence :key do |n|
      "company_test#{n}"
    end
    sequence :description do |n|
      "Company Test Description#{n}"
    end
  end

  factory :application do
    sequence :name do |n|
      "Application Test #{n}"
    end
    sequence :key do |n|
      "Application_Test#{n}"
    end
    association :company
  end

  factory :role do
    sequence :name do |n|
      "Role #{n}"
    end
  end

  factory :field do
    after(:create) { |field, evaluator|
      evaluator.application.reload
      evaluator.application.generate_mongoid_model
    }
    sequence :name do |n|
      "Field #{n}"
    end
    sequence :key do |n|
      "Field#{n}"
    end
    is_protected { false }
    enable_index { false }
    is_encrypted { false }
    field_type { "String" }
    association :application
  end

  factory :table do
    after :create do |table, evaluator|
      evaluator.application.reload
      evaluator.application.generate_mongoid_model
    end
    sequence :name do |n|
      "Table #{n}"
    end
    sequence :key do |n|
      "Table#{n}"
    end
    update_logic { "replace" }
    association :application
  end

  factory :status do
    sequence :name do |n|
      "Status #{n}"
    end
    sequence :key do |n|
      "Status#{n}"
    end
  end

  factory :data_view_connector do
    sequence :name do |n|
      "Dataview360 #{n}"
    end
    sequence :key do |n|
      "Dataview360#{n}"
    end
    url { "http://localhost:8080/DataView360WS/DataView360Service?WSDL" }
    payload_format { "XML" }

    sequence :input_root_node do |n|
      "Input #{n}"
    end
    sequence :output_root_node do |n|
      "Output #{n}"
    end
  end

  factory :modifier do
    sequence :name do |n|
      "Modifier #{n}"
    end
    sequence :key do |n|
      "Modifier#{n}"
    end
    code { '# Insert code here' }
  end

  factory :filter do
    sequence :name do |n|
      "Queue #{n}"
    end
    sequence :key do |n|
      "Queue#{n}"
    end
  end

  factory :layout do
    sequence :name do |n|
      "Layout #{n}"
    end
  end

  factory :screen do
    sequence :name do |n|
      "Screen #{n}"
    end
    sequence :key do |n|
      "Screen#{n}"
    end
    association :layout
    layout_id { '1' }
  end

  factory :form do
    sequence :name do |n|
      "Form #{n}"
    end
    sequence :key do |n|
      "Form#{n}"
    end
  end

  factory :html_block do
    sequence :name do |n|
      "Html Block #{n}"
    end
    sequence :key do |n|
      "Html_Block#{n}"
    end
  end

  factory :style do
    sequence :name do |n|
      "Style #{n}"
    end
  end

  factory :status_flow do
    sequence :name do |n|
      "Status Flow #{n}"
    end
    sequence :key do |n|
      "Status_Flow#{n}"
    end
    sequence :field_id do |n|
      "Field#{n}"
    end
  end

  factory :server_flow do
    sequence :name do |n|
      "Server Flow #{n}"
    end
    sequence :key do |n|
      "Server_Flow#{n}"
    end
    #sequence :field_id do
    #  "Field#{n}"
    #end
  end

  factory :screen_flow do
    sequence :name do |n|
      "Screen Flow #{n}"
    end
    sequence :key do |n|
      "Screen_Flow#{n}"
    end

  end

  factory :navigator do
    sequence :name do |n|
      "Navigator #{n}"
    end
  end

  factory :populate_action do
    sequence :name do |n|
      "Populate #{n}"
    end
    sequence :key do |n|
      "Populate#{n}"
    end
    populate_new { '1' }
    populate_existing { '0' }
  end

  factory :email do
    sequence :name do |n|
      "Email #{n}"
    end
    sequence :key do |n|
      "Email#{n}"
    end
    email_subject { 'Email subject' }
    from_field_id { '1' }
    to_field_id { '1' }
    email_body { 'Test email' }
  end

  factory :pattern do
    sequence :name do |n|
      "Pattern #{n}"
    end
    pattern_type { 'csv' }
  end

  factory :data_extract do
    sequence :name do |n|
      "DataExtract #{n}"
    end
    sequence :key do |n|
      "DataExtract#{n}"
    end
    separator {","}
    storage_type {"S3 bucket"}
    file_path {"#{n}_file_path"}
  end

  factory :user_property do
    sequence :name do |n|
      "UserProp #{n}"
    end
    sequence :key do |n|
      "UserProp#{n}"
    end
  end

  factory :environment do
    sequence :name do |n|
      "Env #{n}"
    end
    sequence :key do |n|
      "Env#{n}"
    end
  end

  factory :environment_property do
    sequence :name do |n|
      "EnvProp #{n}"
    end
    sequence :key do |n|
      "EnvProp#{n}"
    end
  end

  factory :schedule do
    sequence :name do |n|
      "Schedule #{n}"
    end
    sequence :key do |n|
      "Schedule#{n}"
    end
  end

  factory :server_flow_job
  factory :report_job
end

def define_record_factory(user, app)
  app.generate_mongoid_model true, app
  clazz = app.get_mongoid_class
  FactoryBot.define do
    factory ("record_#{clazz.to_s}").to_sym, :class => clazz do
      transient do
        data { false }
      end

      before(:create) do |instance, evaluator|
        instance.update_with(clazz.record_layout, apply_update_logic: true)
        instance.update_with(evaluator.data, apply_update_logic: true) unless evaluator.data == false
        instance.add_system_record(user, app, app.company)
      end
    end
  end
end

def create_record(app, args = {})
  clazz = app.get_mongoid_class
  r = FactoryBot.create(("record_#{clazz.to_s}").to_sym, {:data => args})
end