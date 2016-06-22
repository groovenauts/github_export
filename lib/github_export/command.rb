# http://whatisthor.com/
# https://github.com/erikhuda/thor
require 'thor'

# https://github.com/octokit/octokit.rb
require 'octokit'

module GithubExport
  class Command < Thor
    class_option :access_token, aliases: '-t', type: :string, desc: 'Personal Access Token'
    class_option :output_dir  , aliases: '-d', type: :string, desc: 'Output directory path', default: Dir.pwd

    desc 'all REPO', "Export all of the repository"
    def all(repo)
      repository(repo)
      milestones(repo)
      releases(repo)
      labels(repo)
      issues(repo)
      comments(repo)
      events(repo)
      issue_events(repo)
    end

    desc 'repository REPO', "Export repository itself"
    def repository(repo)
      result = client.repository(repo)
      open(File.join(options[:output_dir], 'repository.json'), 'w') do |f|
        f.puts(JSON.pretty_generate(result.to_attrs))
      end
    end

    desc 'milestones REPO', "Export milestones of the repository"
    def milestones(repo)
      call_repo_method(repo, :list_milestones, 'milestones.json')
    end

    desc 'releases REPO', "Export releases of the repository"
    def releases(repo)
      call_repo_method(repo, :releases, 'releases.json')
    end

    desc 'labels REPO', "Export labels of the repository"
    def labels(repo)
      call_repo_method(repo, :labels, 'labels.json')
    end

    desc 'issues REPO', "Export issues of the repository"
    def issues(repo)
      call_repo_method(repo, :list_issues, 'issues.json', state: 'all', sort: 'created', direction: 'asc')
    end

    desc 'comments REPO', "Export comments of the repository"
    def comments(repo)
      call_repo_method(repo, :issues_comments, 'comments.json', sort: 'created', direction: 'asc')
    end

    desc 'events REPO', "Export events of the repository"
    def events(repo)
      call_repo_method(repo, :repository_events, 'events.json', sort: 'created', direction: 'asc')
    end

    # desc 'network_events REPO', "Export network events of the repository"
    # def network_events(repo)
    #   call_repo_method(repo, :repository_network_events, 'network_events.json')
    # end

    desc 'issue_events REPO', "Export issue events of the repository"
    def issue_events(repo)
      call_repo_method(repo, :repository_issue_events, 'issue_events.json', sort: 'created', direction: 'asc')
    end

    no_commands do
      def client
        unless @client
          Octokit.auto_paginate = true
          access_token = options[:access_token]
          access_token ||= generate_access_token
          @client = Octokit::Client.new access_token: access_token
        end
        @client
      end

      def generate_access_token
        $stderr.print 'login: '   ; login = $stdin.gets
        $stderr.print 'password: '; pw = $stdin.gets
        $stderr.print 'two factor token(Optional): '; two_fa_token = $stdin.gets
        client = Octokit::Client.new login: login, password: pw
        opts = {:scopes => ["repo", "user"], :note => "Github Export"}
        unless two_fa_token.strip.empty?
          opts[:headers] = { "X-GitHub-OTP" => two_fa_token }
        end
        return client.create_authorization(opts)
      end

      def call_repo_method(repo, name, filename, api_opts = {})
        results = client.send(name, repo, api_opts)
        open(File.join(options[:output_dir], filename), 'w') do |f|
          f.puts(JSON.pretty_generate(results.map(&:to_attrs)))
        end
      end

    end

  end
end
