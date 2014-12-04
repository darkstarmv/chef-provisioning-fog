## ToDo:
##   - accept zone_name as a attribute for machine and disk
class Chef
module Provisioning
module FogDriver
  module Providers
    class Google < FogDriver::Driver

      Driver.register_provider_class('Google', FogDriver::Providers::Google)

      def creator
        compute_options[:google_client_email]
      end

      def self.default_disk_options()
        options = {
          source_image: 'debian-7-wheezy-v20141108',
          zone_name: 'us-central1-a',
          size_gb: 10,
          wait_for: false,
          boot: false,
          writable: true,
          auto_delete: true,
          timeout: 60,
          ignore_exists: true, # used locally, not a GCE/Fog thing
        }
      end
      
      def self.disk_options(options={})
        # options.merge(default_disk_options)
        default_disk_options().merge(options)
      end

      def self.default_bootstrap_options()
        options = {
          wait_for: false,
          zone_name: "us-central1-a",
          machine_type: "n1-standard-1",
          network_name: "default",
          service_account_scopes: ["compute", "userinfo.email", "devstorage.full_control"],
          auto_restart: true,
          on_host_maintenance: "MIGRATE",
          disks: [],
          disk_options: disk_options,
        }
      end

      def self.compute_options_for(provider, id, config)
        new_compute_options = {}
        new_compute_options[:provider] = provider
        new_config = { :driver_options => { :compute_options => new_compute_options }}
        bootstrap_options = default_bootstrap_options
        new_defaults = {
          :driver_options => { :compute_options => {} },
          :machine_options => { :bootstrap_options => bootstrap_options }
        }
        result = Cheffish::MergedConfig.new(new_config, config, new_defaults)

        new_compute_options[:google_project] = id if (id && id != '')
        credential = Fog.credentials

        new_compute_options[:google_project] ||= credential[:google_project]
        new_compute_options[:google_client_email] ||= credential[:google_client_email]
        new_compute_options[:google_key_location] ||= credential[:google_key_location]
    
        id = result[:driver_options][:compute_options][:google_project]
        binding.pry
        [result, id]
      end

      def create_disk(options)
        # determine how to search if disk exists.
        disk = compute.disks.get(options[:name]) || 
          compute.disks.create(options)
        disk.wait_for { disk.ready? } if options[:wait_for]
        disk.reload
      end

      def create_servers(action_handler, specs_and_options, parallelizer)
        # provision and associate disks
        specs_and_options.each do |machine_spec, machine_options|
          bootstrap_options = bootstrap_options_for(action_handler, machine_spec, machine_options)
          if bootstrap_options[:disks].empty? 
            disk_options = bootstrap_options[:disk_options].dup 
            disk_options[:boot] = true
            disk_options[:name] = machine_spec.node["name"]
            boot_disk = create_disk(disk_options)
            machine_options[:bootstrap_options][:disks] << boot_disk
          else
            raise ArgumentError, "disk array not supported yet"
          end
        end

        # can I do a server_for here?
        super(action_handler, specs_and_options, parallelizer) do |machine_spec, server|
          yield machine_spec, server if block_given?
          binding.pry
          machine_options = specs_and_options[machine_spec]
          bootstrap_options = symbolize_keys(machine_options[:bootstrap_options] || {})
        end
      end
    end
  end
end
end
end
