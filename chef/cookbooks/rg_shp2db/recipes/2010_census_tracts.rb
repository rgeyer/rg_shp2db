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

states = [
  "01","02","04","05","06","08","09","10","11","12","13","15","16","17","18","19","20","21","22","23","24","25","26",
  "27","28","29","30","31","32","33","34","35","36","37","38","39","40","41","42","44","45","46","47","48","49","50",
  "51","53","54","55","56"
]

directory node[:rg_shp2db][:shapefile_dir] do
  recursive true
  action :create
end

states.each do |fips_code|
  filename = "tl_2010_#{fips_code}_tract10.zip"
  filepath = ::File.join(node[:rg_shp2db][:shapefile_dir], filename)
#  remote_file filepath do
#    source "http://www2.census.gov/geo/tiger/TIGER2010/TRACT/2010/#{filename}"
#  end

  bash "Unzip tract file" do
    code <<-EOF
wget -q -O #{filename} http://www2.census.gov/geo/tiger/TIGER2010/TRACT/2010/#{filename}
unzip #{filepath} -d #{node[:rg_shp2db][:shapefile_dir]}
    EOF
  end
end