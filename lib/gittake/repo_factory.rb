module Gittake
  class RepoFactory
    def self.from_exec_dir
      ::Grit::Repo.new(Dir.pwd)
    end
  end
end