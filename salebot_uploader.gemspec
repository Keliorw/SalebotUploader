require File.expand_path('lib/salebot_uploader/version', __dir__)

Gem::Specification.new do |spec|
  spec.name                  = 'salebot_uploader'
  spec.version               = SalebotUploader::VERSION
  spec.authors               = ['Aleksey Gudkow']
  spec.email                 = ['alekseygudkou@gmail.com']
  spec.summary               = 'Library for uploader file.'
  spec.description           = 'Library for uploader file from Salebot.'
  spec.homepage              = 'https://github.com/Keliorw/salebot_uploader'
  spec.license               = 'MIT'
  spec.platform              = Gem::Platform::RUBY
  spec.required_ruby_version = '>= 2.7.5'

  spec.files = Dir['README.md', 'LICENSE',
                   'CHANGELOG.md', 'lib/**/*.rb',
                   'lib/**/*.rake',
                   'salebot_uploader.gemspec', '.github/*.md',
                   'Gemfile', 'Rakefile']
  spec.extra_rdoc_files = ['README.md']
  spec.require_paths    = ['lib']

  spec.add_dependency "image_processing", "~> 1.1"
  spec.add_dependency "marcel", "~> 1.0.0"
  spec.add_dependency "addressable", "~> 2.6"
  spec.add_dependency "ssrf_filter", "~> 1.0"
  spec.add_development_dependency "cucumber", "~> 2.3"
  spec.add_development_dependency "rspec", "~> 3.4"
  spec.add_development_dependency "rspec-retry"
  spec.add_development_dependency "rubocop", "~> 1.28"
  spec.add_development_dependency "webmock"
  spec.add_development_dependency "fog-aws"
  spec.add_development_dependency "fog-google", ["~> 1.7", "!= 1.12.1"]
  spec.add_development_dependency "fog-local"
  spec.add_development_dependency "fog-rackspace"
  spec.add_development_dependency "mini_magick", ">= 3.6.0"
  if RUBY_ENGINE != 'jruby'
    spec.add_development_dependency "rmagick", ">= 2.16"
  end
  spec.add_development_dependency "timecop"
  spec.add_development_dependency "generator_spec", ">= 0.9.1"
  spec.add_development_dependency "pry"
  if RUBY_ENGINE != 'jruby'
    spec.add_development_dependency "pry-byebug"
  end
  spec.add_development_dependency 'rubocop-performance', '~> 1.5'
  spec.add_development_dependency 'rubocop-rspec', '~> 1.37'
end