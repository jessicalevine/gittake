libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require "gittake/version"

require "grit"
require "colormath"
require "rainbow"

module Gittake
  class Blame
    attr_accessor :most_recent, :age
    def initialize(blamepath)
      @repo = ::Grit::Repo.new(Dir.pwd)
      @blame = ::Grit::Blame.new(@repo, blamepath, @repo.commits.first)
      @dates = @blame.lines.map(&:commit).map(&:committed_date)
      @most_recent = @dates.max
      @age = @dates.max - @dates.min
    end

    def graph_blame
      block, blocks = nil, []
      @blame.lines.each do |line|
        if !block || (block.date != line.commit.date)
          block = Block.new(self, line.commit.date, line)
          blocks << block
        else
          block.addline(line)
        end
      end
      blocks.each(&:print)
      # @blame.lines.each do |line|
      #   date = line.commit.date
      #   cm = rg_scale(age_rating(date))
      #   puts line.line.color(cm.red * 255, cm.green * 255, cm.blue * 255)
      # end
    end
  end

  class Block
    attr_accessor :date

    def initialize(blame, date, line)
      @date = date
      @lines = []
      @blame = blame

      @lines << line if line
      @color = rg_scale(age_rating(date))
    end

    def addline(line)
      @lines << line
    end

    def print
      @lines.each_with_index do |line, ind|
        string = line.line
        if @@OPTS[:blocks]
          if @lines.size == 1
            string = string.prepend ".  "
          elsif ind == 0 || (ind == (@lines.size - 1))
            string = string.prepend "=- "
          else
            string = string.prepend "|  "
          end
        end
        put_color_line(string)
      end
    end

    private

    def put_color_line(string)
      puts string.color(cm.red * 255, cm.green * 255, cm.blue * 255)
    end

    def cm
      @color
    end

    def blame
      @blame
    end

    def age
      @blame.age
    end

    def most_recent
      @blame.most_recent
    end

    # Percent -- higher is newer
    def age_rating(date)
      since(date).to_f / age.to_f
    end

    def since(date)
      # Invert, so closest gives highest number
      most_recent - date
    end

    def rg_scale(rating)
      ::ColorMath::HSL.new(120 * rating, 1, 0.5)
    end
  end
end

@@OPTS = {
  :blocks => ARGV[1]
}

app = Gittake::Blame.new ARGV[0]
app.graph_blame
