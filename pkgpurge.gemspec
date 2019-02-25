lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name = "pkgpurge"
  spec.version = "0.1.0"
  spec.authors = ["Yoshimasa Niwa"]
  spec.email = ["niw@niw.at"]
  spec.summary = spec.description = "A simple helper tool to purge `intaller(8)` packages"
  spec.homepage = "https://github.com/niw/pkgpurge"

  spec.extra_rdoc_files = `git ls-files -z -- README* LICENSE`.split("\x0")
  executable_files = `git ls-files -z -- bin/*`.split("\x0")
  spec.files = `git ls-files -z -- lib/*`.split("\x0") + spec.extra_rdoc_files + executable_files

  spec.bindir = "bin"
  spec.executables = executable_files.map{|f| File.basename(f)}

  spec.require_paths = ["lib"]

  spec.add_dependency "thor"
  spec.add_dependency "plist"
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
end
