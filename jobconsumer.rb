###################################################################
#
#  Copyright Rightscale.inc 2007-2010, all rights reserved
#
#	JobConsumer Program
#	
#
####################################################################
require 'rubygems'
require 'yaml'
require 'right_aws'
require 'optparse'
require 'fileutils'
require 'active_record'

class Audit < ActiveRecord::Base
  has_many :errors, :class_name => 'Audit_Error'
end

class Audit_Error < ActiveRecord::Base

end

class Output < ActiveRecord::Base

end

class Error < ActiveRecord::Base

end

# Log messages to the lof file and stdout
def log_message(log_msg_txt)
  `logger -t jobproducer log_msg_txt`
  puts log_msg_txt
end

def download_result(bucket, key)
    bucket.get(key)
end

# this retrieves and deletes the next queued message
def dequeue_entry(queue)
   queue.pop
end
def enqueue_work_unit(queue, work_unit)
  queue.send_message(work_unit)
end

#def send_email(from, from_alias, to, to_alias, subject, message)
#	msg = <<END_OF_MESSAGE
#From: #{from_alias} <#{from}>
#To: #{to_alias} <#{to}>
#Subject: #{subject}
#Date: #{Time.now}
#
#
##{message}
#END_OF_MESSAGE
#
#	Net::SMTP.start('localhost') do |smtp|
#		smtp.send_message msg, from, to
#	end
#end

log_message("Program Started")

# Load jobspec
jobyaml = "jobspec.yml"
jobspec = YAML::load_file(jobyaml)
log_message("Job Yaml File : #{jobyaml}")

# Establish DB Connection
ActiveRecord::Base.establish_connection(
  :adapter  => jobspec[:db_type],
  :host     => jobspec[:db_host],
  :database => jobspec[:db_name],
  :username => jobspec[:db_user],
  :password => jobspec[:db_pass]
)

$audit_fields = Audit.new().attribute_names().collect { |it| it.downcase }
$output_fields = Output.new().attribute_names().collect { |it| it.downcase }

# Get S3 Buckets
@s3 = RightAws::S3.new(jobspec[:access_key_id], jobspec[:secret_access_key])
bucket = @s3.bucket(jobspec[:bucket], false)
log_message("S3 Bucket: #{jobspec[:bucket]}")

# Get SQS Handles
sqs = RightAws::SqsGen2.new(jobspec[:access_key_id], jobspec[:secret_access_key])
@i_queue = sqs.queue(jobspec[:inputqueue], false)
@o_queue = sqs.queue(jobspec[:outputqueue], false)
@a_queue = sqs.queue(jobspec[:auditqueue], false)
@e_queue = sqs.queue(jobspec[:errorqueue], false)

log_message("Input Queue : #{jobspec[:inputqueue]} size=#{@i_queue.size()}")
log_message("Output Queue: #{jobspec[:outputqueue]} size=#{@o_queue.size()}")
log_message("Audit Queue : #{jobspec[:auditqueue]} size=#{@a_queue.size()}")
log_message("Error Queue : #{jobspec[:errorqueue]} size=#{@e_queue.size()}")

# count the number of messages still to process
num_msg_to_process  = @i_queue.size() + @o_queue.size() + @a_queue.size() + @e_queue.size()
log_message("number of messages in queues is: #{num_msg_to_process}")
# Create output Dir
FileUtils.mkdir_p('output/')

@processed_files=0


def parse_output_queue(o_queue, sleeptime)
  while true do
  	while o_queue.size() > 0 do
	
  	  # Try to dequeue an output message	
  	  msg = dequeue_entry(o_queue)
  	  if msg != nil then
  			decodemsg = YAML.load(msg.body)

  			#log_message(decodemsg)
  			# 4. Some Debug Output
  			log_message("Output Processing: serial ID: #{decodemsg[:serial]} Msg ID: #{msg.id}")	
  			#log_message(msg)

        dbhash = decodemsg
        dbhash.merge!({
                        :jobid => decodemsg[:audit_info][:serial].split('_')[0],
                        :yaml => msg.body,
                        :audit_serial => decodemsg[:audit_info][:serial],
                        :audit_receive_timeout => decodemsg[:audit_info][:receive_message_timeout]
                      })
        dbhash.delete_if do |key,val|
          !$output_fields.include?(key.to_s.downcase)
        end

        Output.create(dbhash)

  			@processed_files += 1
  	  end
  	end
  	
  	sleep(sleeptime)
  	break if sleeptime == 0
  end
end

def parse_audit_queue(a_queue, sleeptime)
  while true do
  	while a_queue.size() > 0 do
  	  # Try to dequeue an audit message
  	  a_msg = dequeue_entry(a_queue)
  	  if a_msg != nil then
    	  # Decode msg
    		decodemsg = YAML.load(a_msg.body)

        if(!decodemsg)
          log_message("Failed to decode message #{a_msg.inspect}")
          next
        end

        if(!decodemsg[:audit_info])
          log_message("Audit info is empty #{decodemsg.inspect}")
          next
        end
		 	 
    		log_message("Audit Queue Processing: Msg ID: #{a_msg.id}")

        job_id = "Unknown"
        serial = decodemsg[:audit_info][:serial]
        if(serial)
          serial_parts = serial.split('_')
          if(serial_parts && serial_parts[0])
            job_id = serial_parts[0]
          end
        end

        # Log audit information to database
        dbhash = decodemsg
        dbhash.merge!({
                        :jobid => job_id,
                        :yaml => a_msg.body,
                        :audit_serial => decodemsg[:audit_info][:serial],
                        :audit_receive_timeout => decodemsg[:audit_info][:receive_message_timeout]
                      })
        dbhash.delete_if do |key,val|
          !$audit_fields.include?(key.to_s.downcase)
        end

        audit_entry = Audit.create(dbhash)
        if(decodemsg[:errors])
          puts "Found errors yo..  #{decodemsg[:errors].to_yaml}"
          decodemsg[:errors].each do |err|
            Audit_Errors.create({:audit_id => audit_entry.id, :error => err.to_s})
          end
        end

    	  @processed_files += 1
  		end
  	end
  	
		sleep(sleeptime)
  	break if sleeptime == 0
  end
end

def parse_error_queue(e_queue, sleeptime)
  # TODO: Add a "retried" counter to this so we're not infinitely retrying the same doomed job.
  while true do
  	while e_queue.size() > 0 do 
  	  # Try to dequeue an error message	
  	  e_msg = dequeue_entry(e_queue)

  	  if e_msg != nil then
    		decodemsg = YAML.load(e_msg.body)
    		log_message("Error Queue Processing: serial ID: #{decodemsg[:serial]} Msg ID: #{e_msg.id}")
    		orig_msg=YAML.load(decodemsg["message"])
    	  orig_msg[:conversion_type]="sep"
    	  sndmsg = enqueue_work_unit(@i_queue, YAML.dump(orig_msg))
        Error.create({:yaml => e_msg.body, :jobid => orig_msg[:jobid]})
   	  end
  	end
  	
		sleep(sleeptime)
  	break if sleeptime == 0
  end
end

def parse_all_queues(options)
	parse_audit_queue(@a_queue,options[:sleeptime])
	parse_error_queue(@e_queue,options[:sleeptime])
	parse_output_queue(@o_queue,options[:sleeptime])
end
options = {}

optparse = OptionParser.new do |opts|
  # Set a banner, displayed at the top
  # of the help screen.
  opts.banner = "Usage: jobconsumer.rb -q queue_type(audit,error,output) -t sleeptime  -e email_address..."
  # Define the options, and what they do
  options[:queue_type] = 'all'
  opts.on( '-q', '--queue_type TYPE', 'Type of queue(audit,error,output)' ) do |type|
    options[:queue_type] = type.downcase.chomp
  end
  options[:sleeptime] = 0
  opts.on( '-t', '--sleeptime seconds', 'time between queue runs' ) do |time|
    options[:sleeptime] = time.to_i
  end
  options[:to_email] = 'root@localhost'
  opts.on( '-e', '--email email_address', 'Email Address to send report to' ) do |to_email|
    options[:to_email] = to_email.to_s
  end
  opts.on( '-h', '--help', 'Display this screen' ) do
    puts opts
    exit
  end
end

begin
	optparse.parse!
	rescue Exception => e
  STDERR.puts e 
  STDERR.puts optparse
  exit(-1) 
end

case options[:queue_type]
	when "audit"; parse_audit_queue(@a_queue,options[:sleeptime])
	when "error"; parse_error_queue(@e_queue,options[:sleeptime])
	when "output"; parse_output_queue(@o_queue,options[:sleeptime])
	else; parse_all_queues(options)
end

if @processed_files > 0 && options[:to_email]
	puts "Emailing Report to #{options[:to_email]}"
	email_msg = <<-EOF
	You can view your processed files at http://localhost/rightgrid
	EOF
	#send_email("root@#{ENV['EC2_PUBLIC_HOSTNAME']}", "root@#{ENV['EC2_PUBLIC_HOSTNAME']}", "#{options[:to_email]}", "#{options[:to_email]}", "Files Processed By RightGrid", email_msg)
  puts email_msg
end
