require 'net/http'
require 'uri'
require 'json'

case ARGV[0]
when 'local'
  coupon_id = 292
  url = URI.parse("http://localhost:3001/v1/coupons/#{coupon_id}/accounts")
  data_file_location = 'data/account_ids_local.txt'
when 'dev'
  coupon_id = 49
  url = URI.parse("https://private-internal.internal.dev.tabist.co.jp/v1/coupons/#{coupon_id}/accounts")
  data_file_location = 'data/account_ids_dev.txt'
when 'stg'
  coupon_id = 99
  url = URI.parse("https://private-internal.internal.stg.tabist.co.jp/v1/coupons/#{coupon_id}/accounts")
  data_file_location = 'data/account_ids_stg.txt'
when 'prod'
  coupon_id = 99
  url = URI.parse("https://private-internal.internal.prod.tabist.co.jp/v1/coupons/#{coupon_id}/accounts")
  data_file_location = 'data/account_ids_prod.txt'
else
  msgt = 'ERROR: invalid environment argument'
  puts msgt
  raise StandardError, msgt
end

# Assumption -- the account_ids are unique in the text file.
account_ids = File.readlines(data_file_location).map(&:strip)

puts "########## START #{ARGV[0]} env ##########"
http = Net::HTTP.new(url.host, url.port)

account_ids.each do |account_id|
  payload = {
    'account_id' => account_id
  }

  request = Net::HTTP::Post.new(url)
  request['Content-Type'] = 'application/json'
  request.body = JSON.generate(payload)

  puts "Attaching '#{account_id}' to coupon_id #{coupon_id}"
  response = http.request(request)

  if response.code.to_i >= 200 && response.code.to_i < 300
    puts "-- SUCCESS for '#{account_id}'. Response : #{response.read_body}"
  else
    puts "-- FAILURE for '#{account_id}' with error code #{response.code}: #{response.read_body}"
  end
end

puts "########## END #{ARGV[0]} env ##########"
