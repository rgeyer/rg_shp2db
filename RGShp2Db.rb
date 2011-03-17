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

# Requires 'shp2db' gem
# sudo gem install shp2db

# Also requires the gem for whichever DB is being populated by shp2db

class RGShp2Db
  def write_log(message, env)
    filepath = File.join(env[:log_dir], 'rg_shp2db.log')
    timestamp = Time.now.utc.strftime("%Y-%m-%d %H:%M:%S %Z")
    File.open(filepath,'a+') do |log|
      log.write("#{timestamp} - #{message}\n")
    end
    puts message
  end

  def do_work(message_env, message)
    starttime = Time.now

    cmd = "shp2db -f #{message_env[:s3_download]} -a #{message_env[:db_type]} -H #{message_env[:db_host]} -n #{message_env[:db_name]} -u #{message_env[:db_user]} -s #{message_env[:db_shape_table]} -P #{message_env[:db_point_table]}"
    cmd += " -p #{message_env[:db_pass]}" if message_env[:db_pass]
    cmd += " -O #{message_env[:offset]} -C #{message_env[:count]}" if message_env[:offset] && message_env[:count]
    write_log("Executing -- #{cmd}", message_env)
    cmd_result = `#{cmd}`

    finishtime = Time.now

    result = {
      :result => cmd_result,
      :audit_info => {
        :serial => message_env[:serial],
        :receive_message_timeout => message_env[:receive_message_timeout]
      },
      :serial => message_env[:serial],
      :starttime => starttime,
      :finishtime => finishtime
    }
  end
end