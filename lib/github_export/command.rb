module GithubExport
  class Command < Thor
    class_option :access_token, type: :string
         
    desc 'export', "Export all"
    def export
    end
  end
end
