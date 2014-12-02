require 'chef/provisioning'
require 'chef/provisioning/fog_driver/driver'

# fog_key_pair 'my_bootstrap_key'

with_driver(
	'fog:Google', 
	compute_options: {
		google_project: node['fog']['google_project'],
		google_client_email: node['fog']['google_client_email'],
		google_key_location: node['fog']['google_key_location']
	}
)

with_machine_options(:bootstrap_options => {
  disk_opts: { 
	  source_image: 'chef-base-debian-7-wheezy-20141119',
	  description: 'default source_image',
	  size_gb: 10,
	  name: 'new-resource-name',
	  zone_name: 'us-central1-a'
	},
	compute_options: {
		name: "test-1",
#		disks: [ boot_disk ],
		tags: ["tag1"],
		zone_name: "us-central1-a",
    machine_type: "n1-standard-1",
    network_name: "default",
		service_account_scopes: ["compute", "userinfo.email", "devstorage.full_control"],
		auto_restart: true,
		on_host_maintenance: "MIGRATE",
} } )

machine 'mario' do
  tag 'itsa_me'
  converge true
end
