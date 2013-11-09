# capistrano-mysqldump

Capistrano extension to run mysqldump remotely, download, and import into your local Rails development database.

WARNING: This will blow away your development database (duh)

## Installation

```ruby
gem install capistrano-mysqldump
```

## Usage

* In your deploy file:

```ruby
require 'capistrano/mysqldump'
```

* Run:

```ruby
cap mysqldump
```

Or if you're using `capistrano-ext/multistage`, do

```ruby
cap production mysqldump
```

Or whatever environment you want to take the mysqldump from

## Configuration

Override these defaults in `deploy.rb` if necessary

* Location of the mysqldump binary

```ruby
set :mysqldump_bin, "/usr/local/mysql/bin/mysqldump"
```

* Where on the remote machine to dump the sql dump file

```ruby
set :mysqldump_remote_tmp_dir, "/tmp"
```

* Where on the local machine to download the sql dump file from the remote machine

```ruby
set :mysqldump_local_tmp_dir, "/tmp"
```

* Where to run the mysqldump command. If set to `:local`, mysqldump will use the `-h` parameter and run the dump locally. The default is set to `:local` if a host is specified, otherwise it is set to `:remote`

```ruby
set :mysqldump_location, :local
```

* The tables to ignore during the dump

```ruby
set :mysqldump_ignore_tables, %w(logs page_views)
```

* Arbitrary options to pass to mysql dump

```ruby
set :mysqldump_options, {'no-data' => true, 'port' => 3307 }}
```

Equivalent to running

    $ mysqldump --no-data --port=3308

## Contributing to capistrano-mysqldump

* Contributions welcome
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2011 Alex Farrill. See LICENSE.txt for
further details.
