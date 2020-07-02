require 'active_support/concern'

module Screens

  module ScreenConcern
    extend ActiveSupport::Concern

    def get_fields_key_from_object(p_object, p_array)
      if p_object.is_a?(Hash)
        if (defined?(p_object['name']) && p_object['name'] != nil && p_object['name'].is_a?(String) && defined?(p_object['type']) && !%w[table list].include?(p_object['type'])) then
          f_key = (p_object['name'].split("@_@@_@")).last()
          p_array << f_key if f_key != nil
        end

        if (defined?(p_object['fields']) && p_object['fields'].is_a?(Array) && !p_object['fields'].empty?) then
          get_fields_key_from_object(p_object['fields'], p_array)
        end

        if (defined?(p_object['elementType']) && p_object['elementType'].is_a?(Hash) && !p_object['elementType'].empty?) then
          get_fields_key_from_object(p_object['elementType'], p_array)
        end

      elsif (p_object.is_a?(Array)) then
        p_object.each do |obj|
          get_fields_key_from_object(obj, p_array)
        end
      end

    end

  end


end
