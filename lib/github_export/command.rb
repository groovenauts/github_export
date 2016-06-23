# http://whatisthor.com/
# https://github.com/erikhuda/thor
require 'thor'

# https://github.com/octokit/octokit.rb
require 'octokit'

require 'uri'
require 'fileutils'

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
      assets
    end

    desc 'repository REPO', "Export repository itself"
    def repository(repo)
      result = client.repository(repo)
      output_to_file('repository.json', JSON.pretty_generate(result.to_attrs))
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

    ASSETS_LIST_FILENAME = 'assets.txt'.freeze

    desc 'assets', "Download assets of the repository"
    def assets
      files = Dir.glob(File.join(options[:output_dir], '**/*.json'))
      assets_list(*files)
      assets_download
      assets_check
    end

    ASSET_PATTERN = /\!\[[^\[\]]+\]\(([^\(\)]+)\)/.freeze
    desc 'assets_list FILES', "Scan asset urls to #{ASSETS_LIST_FILENAME}"
    def assets_list(*files)
      urls = files.map{|file|
        File.read(file).lines.map{|line| line.scan(ASSET_PATTERN)}.delete_if(&:empty?).flatten.uniq
      }.flatten.sort.uniq
      output_to_file(ASSETS_LIST_FILENAME, urls.join("\n"))
    end

    desc 'assets_download', "Download assets with #{ASSETS_LIST_FILENAME}"
    option :client_num, aliases: '-n', type: :numeric, default: 3, desc: "Number of clients to download"
    option :force     , aliases: '-f', type: :boolean            , desc: "Overwrite if the file exists"
    option :verbose   , aliases: '-V', type: :boolean            , desc: "Show more details"
    def assets_download
      num = [options[:client_num].to_i, 1].max
      lines = read_from_output_file(ASSETS_LIST_FILENAME).lines.map(&:strip)
      tasks = lines.group_by.with_index{|_, i| i % num}
      tasks.each do |idx, task_lines|
        fork do
          task_lines.each do |url|
            uri = URI.parse(url)
            dest = File.join(options[:output_dir], uri.path)
            if options[:force] || !File.exist?(dest)
              puts "\e[34mDL #{url}\e[0m" if options[:verbose]
              FileUtils.mkdir_p(File.dirname(dest))
              File.binwrite(dest, client.get(url))
            else
              puts "\e[33mSKIP #{url}\e[0m" if options[:verbose]
            end
          end
        end
        Process.waitall
      end
    end

    CHECK_MSG_OK = "\e[32mOK %s\e[0m".freeze
    CHECK_MSG_NG = "\e[31mNG %s\e[0m".freeze

    desc 'assets_check', "Check downloaded assets exist with #{ASSETS_LIST_FILENAME}"
    def assets_check
      read_from_output_file(ASSETS_LIST_FILENAME).lines.map(&:strip).each do |line|
        path = File.join(options[:output_dir], URI.parse(line).path)
        fmt = File.exist?(path) ? CHECK_MSG_OK : CHECK_MSG_NG
        puts fmt % path
      end
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
        output_to_file(filename, JSON.pretty_generate(results.map(&:to_attrs)))
      end

      def output_to_file(filename, content)
        open(File.join(options[:output_dir], filename), 'w') do |f|
          f.puts(content)
        end
      end

      def read_from_output_file(filename)
        File.read(File.join(options[:output_dir], filename))
      end

    end

  end
end
