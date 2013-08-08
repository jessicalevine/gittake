libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require "gittake/version"

require "grit"
require "colormath"
require "rainbow"

module Gittake
  class Blame
    def initialize(repopath, blamepath)
      @repo = ::Grit::Repo.new(repopath)
      @blame = ::Grit::Blame.new(@repo, blamepath, @repo.commits.first)
      @dates = @blame.lines.map(&:commit).map(&:committed_date)
      @most_recent = @dates.max
      @age = @dates.max - @dates.min
    end

    # Percent -- higher is newer
    def age_rating(date)
      since(date).to_f / @age.to_f
    end

    def since(date)
      # Invert, so closest gives highest number
      @most_recent - date
    end

    def rg_scale(rating)
      ::ColorMath::HSL.new(120 * rating, 1, 0.5)
    end

    def graph_blame
      pry = true
      @blame.lines.each do |line|
        date = line.commit.date
        cm = rg_scale(age_rating(date))
        puts line.line.color(cm.red * 255, cm.green * 255, cm.blue * 255)
      end
    end
  end
end

app = Gittake::Blame.new ARGV[0], ARGV[1]
app.graph_blame
