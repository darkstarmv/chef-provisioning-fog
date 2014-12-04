require 'chef/provisioning'
require 'chef/provisioning/fog_driver/driver'

# fog_key_pair 'my_bootstrap_key'

with_driver(
	'fog:Google', 
	compute_options: {
		google_project: node['fog']['google_project'],
		google_client_email: node['fog']['google_client_email'],
		google_key_location: node['fog']['google_key_location'],
		# zone_name: "us-central1-a" # not sure if this is really necessary
	}
)

with_machine_options({})

machine 'mario' do
  tag 'itsa_me'
  converge true
end

##
## Some other options one may pass to disk 
## in a future iteration:
## 
# with_machine_options(
# :bootstrap_options => {
# 	# disk_options does not take a name
#   disk_options: { 
# 	  source_image: 'chef-base-debian-7-wheezy-20141119',
# 	  size_gb: 10,
# 	  zone_name: 'us-central1-a',
# 	},
# 	# disks is an array of 
# 	disks: [
# 		# if `disks: []` is empty or non-existent 
# 		# create one boot_disk with disk_options and named for the instance itself
# 		# using default_disk_options if no disk_options specified
# 		boot_disk: {}, # boot_disk is shorthand for a boot-disk named for the instance itself
# 		special_data_disk: {}, # create or reattach 'special_data_disk' with disk_options
# 		log_disk: {
# 			size_gb: 100 # create or reattach with specifed options.
# 		}
# 	]
# } )
# 