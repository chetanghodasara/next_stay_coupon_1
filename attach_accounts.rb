require 'faraday'
require 'json'

case ARGV[0]
when 'local'
  coupon_id = 292
  url = "http://localhost:3001/v1/coupons/#{coupon_id}/accounts"
  data_file_location = 'data/account_ids_local.txt'
when 'dev'
  coupon_id = 49
  url = "https://private-internal.internal.dev.tabist.co.jp/v1/coupons/#{coupon_id}/accounts"
  data_file_location = 'data/account_ids_dev.txt'
when 'stg'
  coupon_id = 99
  url = "https://private-internal.internal.stg.tabist.co.jp/v1/coupons/#{coupon_id}/accounts"
  data_file_location = 'data/account_ids_stg.txt'
when 'prod'
  coupon_id = 99
  url = "https://private-internal.internal.prod.tabist.co.jp/v1/coupons/#{coupon_id}/accounts"
  data_file_location = 'data/account_ids_prod.txt'
else
  msgt = 'ERROR: invalid environment argument'
  puts msgt
  raise StandardError, msgt
end

# Assumption -- the account_ids are unique in the text file.
account_ids = File.readlines(data_file_location).map(&:strip)

conn = Faraday.new(url: url) do |faraday|
  faraday.adapter Faraday.default_adapter
end

puts "########## START #{ARGV[0]} env ##########"

account_ids.each do |account_id|
  payload = {
    'account_id' => account_id
  }

  puts "Attaching '#{account_id}' to coupon_id #{coupon_id}"
  response = conn.post do |req|
    req.url url
    req.headers['Content-Type'] = 'application/json'
    # req.headers['Authorization'] = "Bearer #{token}"
    req.body = JSON.generate(payload)
  end

  if response.success?
    puts "-- SUCCESS for '#{account_id}'. Response : #{response.body}"
  else
    puts "-- FAILURE for '#{account_id}' with error code #{response.status}: #{response.body}"
  end
end

puts "########## END #{ARGV[0]} env ##########"
