libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require "gittake/version"
require "gittake/repo_factory"
require "gittake/cli"

require "grit"

module Gittake
end
