require "rubygems"
require "thor"

module Pkgpurge
  class CLI < Thor
    desc "ls PATH", "List entries for given receipt plist at PATH"
    def ls(path)
      root = Receipt.new(path).root

      Entry.traverse_entry_with_path(root, "/") do |entry, path|
        report path, "%o" % entry.mode, entry.uid, entry.gid, entry.size, entry.checksum
      end
    end

    desc "verify PATH", "Verify entries for given receipt plist at PATH"
    option :checksum, type: :boolean, banner: "Verify checksum of each entry. Slow."
    option :mtime, type: :boolean, banner: "Verify mtime of each entry."
    def verify(path)
      root = Receipt.new(path).root

      Entry.traverse_entry_with_path(root, "/") do |entry, path|
        verify_entry(entry, path, options).each do |modification|
          report path, *modification
        end
      end
    end

    desc "ls-purge PATH", "List entries that can be purged for given receipt plist at PATH"
    option :checksum, type: :boolean, banner: "Verify checksum of each entry. Slow."
    option :mtime, type: :boolean, banner: "Verify mtime of each entry."
    def ls_purge(path)
      root = Receipt.new(path).root

      traverse_purge_entry_with_path(root, "/") do |entry, path|
        if verify_entry(entry, path, options).empty?
          puts path
          true
        else
          false
        end
      end
    end

    private

    def traverse_purge_entry_with_path(entry, parent_path, &block)
      path = File.expand_path(File.join(parent_path, entry.name))
      unless File.exists?(path)
        return true
      end

      children = if !File.symlink?(path) && File.directory?(path)
        Dir.children(path)
      else
        []
      end

      empty_children = []
      entry.entries.each do |_, entry|
        if traverse_purge_entry_with_path(entry, path, &block)
          empty_children << entry.name
        end
      end

      if children.sort == empty_children.sort
        # All children are empty, so we can purge this path
        yield(entry, path)
      else
        false
      end
    end

    def verify_entry(entry, path, options = {})
      modifications = []

      unless File.exists?(path)
        modifications << ["missing"]
        return modifications
      end

      stat = File.lstat(path)
      unless stat.mode == entry.mode
        modifications << ["mode", "%o" % entry.mode, "%o" % stat.mode]
      end
      unless stat.uid == entry.uid
        modifications << ["uid", entry.uid, stat.uid]
      end
      unless stat.gid == entry.gid
        modifications << ["gid", entry.gid, stat.gid]
      end

      if entry.size
        unless stat.size == entry.size
          modifications << ["size", entry.size, stat.size]
        end
      end

      if options[:checksum] && entry.checksum && !entry.symlink?
        checksum = cksum(path)
        if checksum != entry.checksum
          modifications << ["checksum", entry.checksum, checksum]
        end
      end

      if options[:mtime] && entry.mtime
        unless stat.mtime == entry.mtime
          modifications << ["mtime", entry.mtime, stat.mtime]
        end
      end

      modifications
    end

    CKSUM = "/usr/bin/cksum".freeze

    def cksum(path)
      Command.run(CKSUM, path).split(/\s/).first.to_i
    end

    def report(*messages)
      puts messages.join("\t")
    end
  end
end
