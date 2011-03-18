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

require 'yaml'
require 'rubygems'
require 'right_aws'
require 'shapelib'

begin
  require 'RGShp2Db'
rescue
  puts "Attempted to load RGShp2Db but was unable to.. We're probably running on an EC2 job coordinator, otherwise some stuff is going to break soon!"
end

# This stores data in the bucket and key(path)
def upload_file(bucket, key, data)
  bucket.put(key, data)
end

def enqueue_work_unit(queue, work_unit, jobspec)
  if jobspec[:to_the_grid]
    queue.send_message(work_unit.to_yaml)
  else
    work_unit.merge!({:s3_in => jobspec[:shapefile_dir], :log_dir => '/tmp'})
    puts RGShp2Db.new().do_work(work_unit, nil).to_yaml
  end
end

# Log messages to the lof file and stdout
def log_message(log_msg_txt)
  `logger -t jobproducer #{log_msg_txt}`
  puts log_msg_txt
end

def create_job_serial(serial_hash)
  serial_hash[:index] += 1
  "#{serial_hash[:jobid]}_#{serial_hash[:index]}"
end

# Load jobspec
jobyaml = "jobspec.yml"
jobspec = YAML::load_file(jobyaml)
log_message("Job Yaml File: #{jobyaml}")

# Get S3
s3 = RightAws::S3.new(jobspec[:access_key_id], jobspec[:secret_access_key])
bucket = s3.bucket(jobspec[:bucket], false)
log_message("S3 Bucket: #{jobspec[:bucket]}")

# SQS Queues
sqs = RightAws::SqsGen2.new(jobspec[:access_key_id], jobspec[:secret_access_key])
inqueue = sqs.queue(jobspec[:inputqueue], false)
log_message("Input Queue: #{jobspec[:inputqueue]}")

serial_hash = {:jobid => $$, :index => 0}

Dir.glob(File.join(jobspec[:shapefile_dir], "*.shp")) do |filename|
  basename = File.basename(filename)
  upload_file(bucket, basename, File.open(filename))

  work_unit = {
	  :created_at => Time.now.utc.strftime('%Y-%m-%d %H:%M:%S %Z'),
    :s3_download => [File.join(jobspec[:bucket], basename)],
    :shapefile => basename,
    :db_type => jobspec[:db_type]
  }

  work_unit.merge!(jobspec)

  spfile = Shapelib::ShapeFile::open(filename, 'r')
  total_shapes = spfile.size
  if total_shapes > jobspec[:chunk_size]
    shape_idx = 0
    while (shape_idx < total_shapes)
      work_unit.merge!({:offset => shape_idx, :count => jobspec[:chunk_size], :serial => create_job_serial(serial_hash)})
      enqueue_work_unit(inqueue, work_unit, jobspec)
      shape_idx += jobspec[:chunk_size]
    end
  else
    work_unit.merge!({:serial => create_job_serial(serial_hash)})
    enqueue_work_unit(inqueue, work_unit, jobspec)
  end
  spfile.close
end