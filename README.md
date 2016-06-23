# github_export

`github_export` command exports your issues, pull requests, comments, labels, milestones and events to `.json` file.
And it downloads your files which was uploaded to the issues or the comments.

You can use the exported `.json` files and downloaded files for backup or migration to the other.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'github_export'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install github_export

## Usage

```bash
$ github_export all <org_or_user>/<repo> -d path/to/export
```

Or you can specify access token with `--access-token` options if you know the access token.

```bash
$ github_export all <org_or_user>/<repo> -d path/to/export -t <access token>
```

See help for more detail

```bash
$ github_export
Commands:
  github_export all REPO           # Export all of the repository
  github_export assets             # Download assets of the repository
  github_export assets_check       # Check downloaded assets exist with assets.txt
  github_export assets_download    # Download assets with assets.txt
  github_export assets_list FILES  # Scan asset urls to assets.txt
  github_export comments REPO      # Export comments of the repository
  github_export events REPO        # Export events of the repository
  github_export help [COMMAND]     # Describe available commands or one specific command
  github_export issue_events REPO  # Export issue events of the repository
  github_export issues REPO        # Export issues of the repository
  github_export labels REPO        # Export labels of the repository
  github_export milestones REPO    # Export milestones of the repository
  github_export releases REPO      # Export releases of the repository
  github_export repository REPO    # Export repository itself

Options:
  -t, [--access-token=ACCESS_TOKEN]  # Personal Access Token
  -d, [--output-dir=OUTPUT_DIR]      # Output directory path
                                     # Default: /Users/akima/groovenauts/github_export
  -V, [--verbose], [--no-verbose]    # Show more details
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/github_export. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

