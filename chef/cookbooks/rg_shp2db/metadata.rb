maintainer       "Ryan J. Geyer"
maintainer_email "me@ryangeyer.com"
license          IO.read(File.join(File.dirname(__FILE__), '..', '..', '..', 'LICENSE'))
description      "Installs/Configures rg_shp2db"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.1"

recipe "rg_shp2db::coordinator", "Sets up a coordinator node which will host the MySQL database, and run the job producer and consumer scripts"
recipe "rg_shp2db::2010_census_tracts", "Downloads the 2010 US Census Tract shapefiles for all states"
recipe "rg_shp2db::run_jobproducer", "Enqueues jobs for the grid"

attribute "rg_shp2db/db_type",
  :display_name => "ActiveRecord database adapter type",
  :description => "The name of the ActiveRecord database adapter to use for storing the data",
  :recipes => ["rg_shp2db::coordinator"],
  :default => "mysql"

attribute "rg_shp2db/db_host",
  :display_name => "Database hostname",
  :description => "Hostname for the server which will recieve the results of the shapefile to database conversion",
  :recipes => ["rg_shp2db::coordinator"],
  :required => "required"

attribute "rg_shp2db/db_user",
  :display_name => "Database username",
  :description => "Administrator username for the server which will recieve the results of the shapefile to database conversion",
  :recipes => ["rg_shp2db::coordinator"],
  :required => "required"

attribute "rg_shp2db/db_pass",
  :display_name => "Database password",
  :description => "Administrator password for the server which will recieve the results of the shapefile to database conversion",
  :recipes => ["rg_shp2db::coordinator"],
  :required => "optional"

attribute "rg_shp2db/db_name",
  :display_name => "Database name",
  :description => "Name of the database which will recieve the results of the shapefile to database conversion",
  :recipes => ["rg_shp2db::coordinator"],
  :required => "required"

attribute "rg_shp2db/db_shape_table",
  :display_name => "Shape table name",
  :description => "The name of the table which will recieve the shapes from the shapefile to database conversion",
  :recipes => ["rg_shp2db::coordinator"],
  :default => "shapes"

attribute "rg_shp2db/db_point_table",
  :display_name => "Point table name",
  :description => "The name of the table which will recieve the points from the shapefile to database conversion",
  :recipes => ["rg_shp2db::coordinator"],
  :default => "points"

attribute "rg_shp2db/shapefile_dir",
  :display_name => "Source shapefile directory",
  :description => "The full or relative path to a directory containing the shapefiles to be converted.",
  :recipes => ["rg_shp2db::coordinator"],
  :required => "required"

attribute "rg_shp2db/chunk_size",
  :display_name => "Shapefile chunk size",
  :description => "The number of shapes that each instantiation of the grid worker will process.",
  :recipes => ["rg_shp2db::coordinator"],
  :default => "50"

attribute "rightgrid/aws_access_key_id",
  :display_name => "Access Key Id",
  :description => "This is an Amazon credential. Log in to your AWS account at aws.amazon.com to retrieve you access identifiers. Ex: 1JHQQ4KVEVM02KVEVM02",
  :recipes => ["rg_shp2db::coordinator"],
  :required => "required"

attribute "rightgrid/aws_secret_access_key",
  :display_name => "Secret Access Key",
  :description => "This is an Amazon credential. Log in to your AWS account at aws.amazon.com to retrieve your access identifiers. Ex: XVdxPgOM4auGcMlPz61IZGotpr9LzzI07tT8s2Ws",
  :recipes => ["rg_shp2db::coordinator"],
  :required => "required"

attribute "rightgrid/input_queue",
  :display_name => "Input Queue",
  :description => "The Amazon SQS queue used for input to RightGrid",
  :recipes => ["rg_shp2db::coordinator"],
  :required => "required"

attribute "rightgrid/output_queue",
  :display_name => "Output Queue",
  :description => "The Amazon SQS queue used for output from RightGrid",
  :recipes => ["rg_shp2db::coordinator"],
  :required => "required"

attribute "rightgrid/audit_queue",
  :display_name => "Audit Queue",
  :description => "The Amazon SQS queue used for audit info from RightGrid",
  :recipes => ["rg_shp2db::coordinator"],
  :required => "required"

attribute "rightgrid/s3_bucket",
  :display_name => "S3 Bucket",
  :description => "An S3 bucket where RightGrid will store it's input, output, and log files",
  :recipes => ["rg_shp2db::coordinator"],
  :required => "required"