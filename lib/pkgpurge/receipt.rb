require "rubygems"
require "plist"
require "pathname"

module Pkgpurge
  class Receipt
    def initialize(path)
      @path = path
    end

    def root
      @root ||= parse!
    end

    private

    def parse!
      relative_install_prefix_path = Pathname.new(install_prefix_path).relative_path_from(Pathname.new("/")).to_s

      root = nil
      lsbom.lines.each do |line|
        # size and checksum are optional.
        path, mode, uid, gid, size, checksum, mtime = line.chomp.split("\t")
        mode = mode.to_i(8)
        uid = uid.to_i
        gid = gid.to_i
        size = size && size.to_i
        checksum = checksum && checksum.to_i
        mtime = mtime && Time.at(mtime.to_i)

        current = nil
        path.split("/").each do |path_component|
          if path_component == "."
            unless current
              if !root
                root = Entry.new(path_component, mode, uid, gid, size, checksum, mtime)
              end
              current = root
              next
            end
            raise "Unexpected path: #{path}"
          end

          entry = current.entries[path_component]
          unless entry
            entry = Entry.new(path_component, mode, uid, gid, size, checksum, mtime)
            current.entries[path_component] = entry
            break
          end

          current = entry
        end
      end

      root
    end

    LSBOM = "/usr/bin/lsbom".freeze
    PLIST_BUDDY = "/usr/libexec/PlistBuddy".freeze

    def lsbom
      @lsbom ||= begin
        bompath = "#{File.join(File.dirname(@path), File.basename(@path, ".plist"))}.bom"
        # file, mode, uid, gid, size, checksum, mtime
        Command.run(LSBOM, "-pfmugsct", bompath)
      end
    end

    def install_prefix_path
      plist["InstallPrefixPath"]
    end

    def plist
      @plist ||= begin
        plist_xml = Command.run(PLIST_BUDDY, "-x", "-c", "Print", @path)
        Plist.parse_xml(plist_xml)
      end
    end
  end
end
