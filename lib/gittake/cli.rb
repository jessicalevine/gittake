require "thor"

module Gittake
  class CLI < Thor
    desc "analyze FILEPATH", "Analyze a git blame"
    def analyze(filepath)
      repo = RepoFactory.from_exec_dir
      blame = ::Grit::Blame.new(repo, filepath, repo.commits.first)
      puts blame.lines.inspect
    end
  end
end