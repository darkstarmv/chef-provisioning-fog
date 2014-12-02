# fog:Rackspace:https://identity.api.rackspacecloud.com/v2.0
class Chef
module Provisioning
module FogDriver
  module Providers
    class Google < FogDriver::Driver

      Driver.register_provider_class('Google', FogDriver::Providers::Google)

      def creator
        compute_options[:google_client_email]
      end

      def create_servers(action_handler, specs_and_options, parallelizer)

        specs_and_options.each do |machine_spec, machine_options|
          bootstrap_options = bootstrap_options_for(action_handler, machine_spec, machine_options)
          boot_disk = compute.disks.create(bootstrap_options[:disk_options])
          binding.pry
        end

        super(action_handler, specs_and_options, parallelizer) do |machine_spec, server|
          yield machine_spec, server if block_given?
          binding.pry
          machine_options = specs_and_options[machine_spec]
          bootstrap_options = symbolize_keys(machine_options[:bootstrap_options] || {})
        end
      end

      def self.compute_options_for(provider, id, config)
        new_compute_options = {}
        new_compute_options[:provider] = provider
        new_config = { :driver_options => { :compute_options => new_compute_options }}
        new_defaults = {
          :driver_options => { :compute_options => {} },
          :machine_options => { :bootstrap_options => {} }
        }
        result = Cheffish::MergedConfig.new(new_config, config, new_defaults)

        credential = Fog.credentials

        new_compute_options[:google_project] ||= credential[:google_project]
        new_compute_options[:google_client_email] ||= credential[:google_client_email]
        new_compute_options[:google_key_location] ||= credential[:google_key_location]

        id = "result[:driver_options][:compute_options][:google_project]:#{result[:driver_options][:compute_options][:zone_name]}"
        [result, id]
      end

    end
  end
end
end
end
