Gem::Specification.new do |s|
  s.name        = "rubiclifier"
  s.version     = File.read("VERSION").strip
  s.licenses    = ["MIT"]
  s.summary     = "Easily spin up new Ruby CLI applications with built-in backgrounding and data storage."
  s.authors     = ["Kyle Grinstead"]
  s.email       = "kyleag@hey.com"
  s.files       = Dir.glob("{lib}/**/*") + ["Gemfile"]
  s.homepage    = "https://rubygems.org/gems/rubiclifier"
  s.metadata    = { "source_code_uri" => "https://github.com/MrGrinst/rubiclifier" }
  s.require_path = "lib"
  s.platform    = Gem::Platform::RUBY
end
