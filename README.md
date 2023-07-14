# next_stay_coupons
This is a temporary repo, to do manual operations for Next_Stay_Coupons


# to attach account_ids to the coupon
- check data/account_ids_xxx.txt has correct account_ids
- make sure the coupon_id is correct in attach_accounts.rb
- run below command with correct env
- check logs

```
ruby attach_accounts.rb xxx
```

# to send emails
- check data/account_ids_xxx.txt has correct account_ids
- add latest tokent o tokens/token_xxx.txt
- run below command with correct env
- check logs

```
ruby send_emails.rb xxx
```