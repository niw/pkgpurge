module Pkgpurge
  module Command
    def self.run(*command)
      IO.popen(command){|io| io.read}
    end
  end
end
