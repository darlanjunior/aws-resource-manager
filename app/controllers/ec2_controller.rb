class Ec2Controller < ApplicationController
	def index
	  aws_client = Aws::EC2::Client.new(region: 'sa-east-1')

	  @instances = instances aws_client
	end

	def volumes aws_client
		aws_client
			.describe_volumes
			.volumes
			.map do |v| 
				{
					id: v.volume_id, 
					size: v.size, 
					instances: v.attachments.map(&:instance_id) 
				} 
			end
	end

	def addresses aws_client
		aws_client
			.describe_addresses
			.addresses
			.map {|ip| {ip: ip.public_ip, instance: ip.instance_id}}
	end

	def instances aws_client
		aws_client
	  	.describe_instances
	  	.reservations
	  	.map(&:instances)
	  	.flatten 
	  	.map do |i| 
		  	{ 
		  		id: i.instance_id, 
		  		name: i.tags.find {|t| t.key == 'Name' }
		  		state: i.state.name, 
		  		ip: i.public_ip_address, 
		  		type: i.instance_type, 
		  		key: i.key_name,
		  		addresses: (addresses aws_client).select {|a| a.instance == i.instance_id},
		  		volumes: (volumes aws_client).select {|v| v.instances.include? i.instance_id}
		  	} 
		  end
	end

end