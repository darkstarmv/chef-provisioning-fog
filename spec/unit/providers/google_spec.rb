require 'spec_helper'
require 'chef/provisioning/fog_driver/providers/google'

describe Chef::Provisioning::FogDriver::Providers::Google do
  subject { Chef::Provisioning::FogDriver::Driver.from_provider(
  	'Google',{
  		driver_options: {
  			compute_options: {
	  		  google_project: 'none',
          google_client_email: 'example@developer.gserviceaccount.com',
          google_key_location: '/file/path/to/key.p12'
	  		}
	  	}
		}) }

  it "returns the correct driver" do
    expect(subject).to be_an_instance_of Chef::Provisioning::FogDriver::Providers::Google end

  it "has a fog backend" do
    pending unless Fog.mock?
    expect(subject.compute).to be_an_instance_of Fog::Compute::Google::Mock
  end

end
