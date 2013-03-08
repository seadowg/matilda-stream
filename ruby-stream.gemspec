lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

Gem::Specification.new do |s|
  s.name = "ruby-stream"
  s.version = "0.1.0"
  s.platform = Gem::Platform::RUBY
  s.authors = ["Callum Stott"]
  s.email = ["callum.stott@me.com"]
  s.summary = "Lazy stream implementation for Ruby"

  s.require_paths = ['lib']
  s.files = `git ls-files`.split("\n")
end