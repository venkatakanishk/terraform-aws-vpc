## This module creates VPC
 This module creates the following resources
 1. Aws_VPC
 2. Internet gateway association with vpc
 3. aws subnets >> pulic, private, database
 4. aws route tables >> pulic, private, database
 5. aws routes >> pulic, private, database
 6. Elastic IP 
 7. Natgateway with Elastic IP allocation.
 8. Route table associations
 9. vpc perring with default
 10. route table entries with peering
## inputs

* project = Required string type, users must provide the name of the project.
* Environment = Required string type, users must provide the name of the Environment.
* VPC_CIDR = Optional string type, default is "10.0.0.0/16" users can override.
* public_subnet_cidr = Optional list type, default is  ["10.0.1.0/24", "10.0.2.0/24"] users can override.
* private_subnet_cidr = Optional list type, default is  ["10.0.11.0/24", "10.0.12.0/24"] users can override.
* database_subnet_cidr = Optional list type, default is  ["10.0.21.0/24", "10.0.22.0/24"] users can override.
* public_subnets_tags = Optional map type, users can provide the details what ever they want.
* private_subnets_tags = Optional map type, users can provide the details what ever they want.
* databse_subnets_tags = Optional map type, users can provide the details what ever they want.
* vpc_tags = Optional map type, users can provide the details what ever they want.
* igw_tags = Optional map type, users can provide the details what ever they want.
* public_route_table_tags = Optional map type, users can provide the details what ever they want.
* private_route_table_tags = Optional map type, users can provide the details what ever they want.
* datbase_route_table_tags = Optional map type, users can provide the details what ever they want.
* eip_tags = Optional map type, users can provide the details what ever they want.
* nat_gateway_tags = Optional map type, users can provide the details what ever they want.
* is_peering_required = 