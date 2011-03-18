#  Copyright 2011 Ryan J. Geyer
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.

include_recipe "rubygems::default"

%w{shapelib libshp-dev}.each do |p|
  package p
end

%w{right_aws shapelib}.each do |gem|
  gem_package gem
end

directory "/mnt/rg_shp2db"

git "/mnt/rg_shp2db" do
  repository "git://github.com/rgeyer/rs_shp2db.git"
  action :sync
end

template "/mnt/rg_shp2db/jobspec.yml" do
  source "jobspec.yml.erb"
end

mysql_database "Create rg_shp2db database" do
  host "localhost"
  username "root"
  database node[:rg_shp2db][:db_name]
  action :create_db
end

db_mysql_set_privileges "Create MySQL for grid workers" do
  preset "user"
  username node[:rg_shp2db][:db_user]
  password node[:rg_shp2db][:db_pass]
  db_name node[:rg_shp2db][:db_name]
end

bash "Populate MySQL DB Schema" do
  code <<-EOF
mysql -uroot #{node[:rg_shp2db][:db_name]} < /mnt/rg_shp2db/chef/cookbooks/rg_shp2db/files/default/rs_shp2db.sql
  EOF
end