pkgpurge
========

NAME
----

`pkgpurge` -- A simple helper tool to purge `installer(8)` packages.

SYNOPSIS
--------

    pkgpurge COMMAND [OPTIONS...] [ARGS...]

DESCRIPTION
-----------

`pkgpurge` is a Ruby gem that provides a command line interface and a Ruby library
to purge `install(8)` packages.

`pkgpurge` command line interface takes next commands.

### `ls PATH`

List entries for given receipt plist at `PATH`.
Similar to `lsbom -pfmugsct PATH_TO_BOM_FILE`

### `verify PATH`

Verify entries for given receipt plist at `PATH`.
Print modified or missing entries.

* `--checksum`

    Verify checksum of each entry. Slow.
    Directories and symbolic links are ignored.
    This command executes `cksum(1)` on each regular file entry.

* `--mtime`

    Verify mtime of each entry. Directories are ignored.

### `ls-purge PATH`

List entries that can be purged for given receipt plist at PATH.
Entries are not modified and if it's a directory, must be empty before listed.

* `--checksum`

    Verify checksum of each entry. Slow.
    Directories and symbolic links are ignored.
    This command executes `cksum(1)` on each regular file entry.

* `--mtime`

    Verify mtime of each entry. Directories are ignored.
