# AppleID

"Sign-in with Apple" is an implementation of OpenID Connect with small custom features.

This gem handles such custom features.

Basically, this gem is based on my [OpenID Connect gem](https://github.com/nov/openid_connect) and [OAuth2 gem](https://github.com/nov/rack-oauth2), so the usage is almost same with them.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'apple_id'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install apple_id

## Usage

There is [a sample rails app](https://github.com/nov/signin-with-apple) running at [signin-with-apple.herokuapp.com](https://signin-with-apple.herokuapp.com).

If you run script in your terminal only, do like below.

```ruby
require 'apple_id'

# NOTE: in debugging mode, you can see all HTTPS request & response in the log.
# AppleID.debug!

pem = <<-PEM
-----BEGIN PRIVATE KEY-----
  :
  :
-----END PRIVATE KEY-----
PEM
private_key = OpenSSL::PKey::EC.new pem

client = AppleID::Client.new(
  identifier: '<YOUR-CLIENT-ID>',
  team_id: '<YOUR-TEAM-ID>',
  key_id: '<YOUR-KEY-ID>',
  private_key: private_key,
  redirect_uri: '<YOUR-REDIRECT-URI>'
)

authorization_uri = client.authorization_uri(scope: [:email, :name])
puts authorization_uri
`open "#{authorization_uri}"`

print 'code: ' and STDOUT.flush
code = gets.chop

client.authorization_code = code
response = client.access_token!

response.id_token.verify!(
  client,
  access_token: response.access_token,
  verify_signature: false # NOTE: when verifying signature, one http request to Apple's JWKs are required.
)
puts response.id_token.sub # => OpenID Connect Subject Identifier (= Apple User ID)
puts response.id_token.original_jwt.pretty_generate
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/apple_id. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the AppleID project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/apple_id/blob/master/CODE_OF_CONDUCT.md).
