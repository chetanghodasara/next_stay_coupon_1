require 'faraday'
require 'json'

case ARGV[0]
when 'local'
  coupon_code = 'TABIX230315'
  url = 'http://localhost:3000/v1/admin/notifications'
  token_file_location = 'tokens/token_local.txt'
  data_file_location = 'data/account_ids_local.txt'
when 'dev'
  coupon_code = 'TABIX230315'
  url = 'https://booking.internal.dev.tabist.co.jp/v1/admin/notifications'
  token_file_location = 'tokens/token_dev.txt'
  data_file_location = 'data/account_ids_dev.txt'
when 'stg'
  coupon_code = 'TABIX230315'
  url = 'https://booking.internal.stg.tabist.co.jp/v1/admin/notifications'
  token_file_location = 'tokens/token_stg.txt'
  data_file_location = 'data/account_ids_stg.txt'
when 'prod'
  coupon_code = 'TABIX230315'
  url = 'https://booking.internal.prod.tabist.co.jp/v1/admin/notifications'
  token_file_location = 'tokens/token_prod.txt'
  data_file_location = 'data/account_ids_prod.txt'
else
  msgt = 'ERROR: invalid environment argument'
  puts msgt
  raise StandardError, msgt
end

# Assumption -- the account_ids are unique in the text file.
account_ids = File.readlines(data_file_location).map(&:strip)
token = "Bearer #{File.readlines(token_file_location)[0]}"

conn = Faraday.new(url: url) do |faraday|
  faraday.adapter Faraday.default_adapter
end

puts "########## START Sending Emails #{ARGV[0]} env ##########"

account_ids.each do |account_id|
  payload = {
    'topic' => 'next_stay_coupon',
    'params' => {
      'account_id' => account_id,
      'coupon_codes' => [
        coupon_code
      ]
    }
  }

  puts "Sending email to '#{account_id}' for coupon_code #{coupon_code}. DateTime #{Time.now.getlocal('+09:00')} JST"
  response = conn.post do |req|
    req.url url
    req.headers['Content-Type'] = 'application/json'
    req.headers['Authorization'] = token
    req.body = JSON.generate(payload)
  end

  if response.success?
    puts "-- SUCCESS email for '#{account_id}'. Response : #{response.body}"
  else
    puts "-- FAILURE email for '#{account_id}' with error code #{response.status}: #{response.body}"
  end
end

puts "########## END Sending Emails #{ARGV[0]} env ##########"
