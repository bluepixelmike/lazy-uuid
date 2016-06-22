Lazy UUID
=========

[![Travis CI](https://travis-ci.org/bluepixelmike/lazy-uuid.svg)](https://travis-ci.org/bluepixelmike/lazy-uuid)
[![Code Climate](https://codeclimate.com/github/bluepixelmike/lazy-uuid/badges/gpa.svg)](https://codeclimate.com/github/bluepixelmike/lazy-uuid)
[![Test Coverage](https://codeclimate.com/github/bluepixelmike/lazy-uuid/badges/coverage.svg)](https://codeclimate.com/github/bluepixelmike/lazy-uuid/coverage)
[![Issue Count](https://codeclimate.com/github/bluepixelmike/lazy-uuid/badges/issue_count.svg)](https://codeclimate.com/github/bluepixelmike/lazy-uuid)
[![Documentation](https://inch-ci.org/github/bluepixelmike/lazy-uuid.svg?branch=master)](http://www.rubydoc.info/github/bluepixelmike/lazy-uuid/master)

Small gem for creating and using UUIDs (universally unique identifier).
It has no external dependencies.

Installation
------------

Add this line to your application's Gemfile:

```ruby
gem 'lazy-uuid'
```

Or to your gemspec:

```ruby
spec.add_dependency 'lazy-uuid'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install lazy-uuid

Usage
-----

### Script Usage

Include the `Uuid` class by doing:

```ruby
require 'lazy-uuid'
```

To generate a new UUID:

```ruby
uuid = Uuid.generate
```

To create a new UUID from a value:

```ruby
value = "\xde\x30\x5d\x54\x75\xb4\x43\x1b\xad\xb2\xeb\x6b\x9e\x54\x60\x14"
uuid = Uuid.new(value)
```

To parse an existing UUID string:
```ruby
str = 'de305d54-75b4-431b-adb2-eb6b9e546014'
uuid = Uuid.parse(str)
```

Use `#to_s` to generate a human-readable representation of the UUID.

Development
-----------

After checking out the repo, run `bin/setup` to install developer dependencies.
Then, run `bundle exec rake test` to run the tests.
It's recommended that you run `bundle exec rake inspect` to run inspections.
You can also run `bin/console` for an interactive prompt that will allow you to experiment.
`bundle exec rake doc` will generate documentation.

To install this gem onto your local machine, run `bundle exec rake install`.
To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`.
This will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

Contributing
------------

Bug reports and pull requests are welcome on [GitHub](https://github.com/bluepixelmike/lazy-uuid).
