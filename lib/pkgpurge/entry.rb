module Pkgpurge
  class Entry
    def self.traverse_entry_with_path(entry, parent_path = nil, &block)
      if parent_path
        path = File.join(parent_path, entry.name)
      else
        path = entry.name
      end

      yield(entry, File.expand_path(path))

      entry.entries.each do |_, entry|
        traverse_entry_with_path(entry, path, &block)
      end
    end

    attr_reader :name, :mode, :uid, :gid, :size, :checksum, :mtime, :entries

    def initialize(name, mode, uid, gid, size, checksum, mtime)
      @name = name
      @mode = mode
      @uid = uid
      @gid = gid
      @size = size
      @checksum = checksum
      @mtime = mtime
      @entries = {}
    end

    # See `/usr/includde/sys/_types/_s_ifmt.h`
    S_IFMT  = 0170000
    S_IFDIR = 0040000
    S_IFLNK = 0120000

    def directory?
      (@mode & S_IFMT) == S_IFDIR
    end

    def symlink?
      (@mode & S_IFMT) == S_IFLNK
    end
  end
end
