resource "aws_vpc" "this" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_hostnames = true

  tags = local.vpc_final_tags
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = local.igw_final_tags
}
resource "aws_subnet" "public" {
    count = length(var.public_subnet_cidr)
    vpc_id     = aws_vpc.this.id
    cidr_block = var.public_subnet_cidr[count.index]
    availability_zone = local.az_names[count.index]
    map_public_ip_on_launch = true
    
    tags = merge(local.common_tags,
                                        {
                                            Name = "${var.project}-${var.environment}-public-${local.az_names[count.index]}"
                                        },
                                        var.public_subnets_tags)
  }

  
resource "aws_subnet" "private" {
    count = length(var.public_subnet_cidr)
    vpc_id     = aws_vpc.this.id
    cidr_block = var.private_subnet_cidr[count.index]
    availability_zone = local.az_names[count.index]

    tags = merge(local.common_tags,
                                        {
                                            Name = "${var.project}-${var.environment}-private-${local.az_names[count.index]}"
                                        },
                                        var.private_subnets_tags)
}


resource "aws_subnet" "database" {
    count = length(var.database_subnet_cidr)
    vpc_id     = aws_vpc.this.id
    cidr_block = var.database_subnet_cidr[count.index]
    availability_zone = local.az_names[count.index]
    
    tags = merge(local.common_tags,
                                        {
                                            Name = "${var.project}-${var.environment}-database-${local.az_names[count.index]}"
                                        },
                                        var.database_subnets_tags)
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
# roboshop-dev-public
  tags = merge(local.common_tags,
                                        {
                                            Name = "${var.project}-${var.environment}-public"
                                        },
                                        var.public_route_table_tags)
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id
# roboshop-dev-private
  tags = merge(local.common_tags,
                                        {
                                            Name = "${var.project}-${var.environment}-private"
                                        },
                                        var.private_route_table_tags)
}

resource "aws_route_table" "database" {
  vpc_id = aws_vpc.this.id
# roboshop-dev-database
  tags = merge(local.common_tags,
                                        {
                                            Name = "${var.project}-${var.environment}-database"
                                        },
                                        var.database_route_table_tags)
}

resource "aws_route" "public" {
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = "0.0.0.0/0" # this is routing to route 0.0.0.0/0 through internetgateway
  gateway_id = aws_internet_gateway.this.id
}

resource "aws_eip" "nat" {
  domain                    = "vpc"
  tags = merge(local.common_tags,
                                        {
                                            Name = "${var.project}-${var.environment}-nat"
                                        },
                                        var.eip_tags)
}
resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id # this is subnet of public us-east-1a

  tags = merge(local.common_tags,
                                        {
                                            Name = "${var.project}-${var.environment}"
                                        },
                                        var.nat_gateway_tags)

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.this]
}


resource "aws_route" "private" {
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = "0.0.0.0/0" # this is routing to route 0.0.0.0/0 through nat gateway
  nat_gateway_id = aws_nat_gateway.this.id
}
resource "aws_route" "database" {
  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = "0.0.0.0/0" # this is routing to route 0.0.0.0/0 through nat gateway
  nat_gateway_id = aws_nat_gateway.this.id
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidr)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidr)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "database" {
  count = length(var.database_subnet_cidr)
  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database.id
}