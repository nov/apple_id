Gem::Specification.new do |spec|
  spec.name          = 'apple_id'
  spec.version       = File.read('VERSION')
  spec.authors       = ['nov']
  spec.email         = ['nov@matake.jp']

  spec.summary       = %q{Sign-in with Apple Backend}
  spec.description   = %q{Sign-in with Apple backend library in Ruby.}
  spec.homepage      = 'https://github.com/nov/apple_id'
  spec.license       = 'MIT'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'rack-oauth2', '~> 1.19'
  spec.add_runtime_dependency 'openid_connect', '~> 1.3.0'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rspec-its'
  spec.add_development_dependency 'webmock'
  spec.add_development_dependency 'simplecov'
end
