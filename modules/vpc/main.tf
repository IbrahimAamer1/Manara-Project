# --- VPC Module --- #

# Create the VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr 
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-vpc"
    }
  )
}

# Create Public Subnets
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)  subnets/AZs
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true # Instances in public subnets get public IPs

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-public-subnet-${data.aws_availability_zones.available.names[count.index]}"
    }
  )
}

# Create Private Subnets for EC2 Application Instances
resource "aws_subnet" "private_app" {
  count             = length(var.private_app_subnet_cidrs) # Customizable: Adjust the number of private app subnets/AZs
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_app_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-private-app-subnet-${data.aws_availability_zones.available.names[count.index]}"
    }
  )
}

# Create Private Subnets for RDS Database (Optional, controlled by var.create_database)
resource "aws_subnet" "private_db" {
  count             = var.create_database ? length(var.private_db_subnet_cidrs) : 0 # Customizable: Adjust the number of private DB subnets/AZs
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_db_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-private-db-subnet-${data.aws_availability_zones.available.names[count.index]}"
    }
  )
}

# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-igw"
    }
  )
}

# Create Elastic IPs for NAT Gateways
resource "aws_eip" "nat" {
  count = length(var.public_subnet_cidrs) # One EIP per public subnet/AZ for NAT GW
  vpc   = true

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-nat-eip-${data.aws_availability_zones.available.names[count.index]}"
    }
  )
}

# Create NAT Gateways
resource "aws_nat_gateway" "nat" {
  count         = length(var.public_subnet_cidrs) # One NAT GW per public subnet/AZ
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-nat-gw-${data.aws_availability_zones.available.names[count.index]}"
    }
  )

  # Ensure Internet Gateway is created before NAT Gateways
  depends_on = [aws_internet_gateway.igw]
}

# Create Route Table for Public Subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0" # Route traffic to the internet
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-public-rt"
    }
  )
}

# Associate Public Route Table with Public Subnets
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Create Route Tables for Private Subnets (One per AZ)
resource "aws_route_table" "private" {
  count  = length(var.private_app_subnet_cidrs)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0" # Route traffic to the internet via NAT Gateway
    nat_gateway_id = aws_nat_gateway.nat[count.index].id
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-private-rt-${data.aws_availability_zones.available.names[count.index]}"
    }
  )
}

# Associate Private Route Tables with Private App Subnets
resource "aws_route_table_association" "private_app" {
  count          = length(var.private_app_subnet_cidrs)
  subnet_id      = aws_subnet.private_app[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# Associate Private Route Tables with Private DB Subnets (Optional)
resource "aws_route_table_association" "private_db" {
  count          = var.create_database ? length(var.private_db_subnet_cidrs) : 0
  subnet_id      = aws_subnet.private_db[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# Data source to get available AZs in the current region
data "aws_availability_zones" "available" {}

