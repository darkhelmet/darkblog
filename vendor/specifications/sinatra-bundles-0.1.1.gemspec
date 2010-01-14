# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{sinatra-bundles}
  s.version = "0.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Daniel Huckstep"]
  s.date = %q{2010-01-13}
  s.description = %q{Bundle CSS and Javascript assets to a single file, compress, and cache them for snappier web experiences.}
  s.email = %q{darkhelmet@darkhelmetlive.com}
  s.extra_rdoc_files = ["LICENSE", "README.md"]
  s.files = [".document", ".gitignore", "LICENSE", "README.md", "Rakefile", "VERSION", "lib/sinatra/bundles.rb", "sinatra-bundles.gemspec", "spec/app.rb", "spec/production_app.rb", "spec/public/javascripts/test1.js", "spec/public/javascripts/test2.js", "spec/public/stylesheets/test1.css", "spec/public/stylesheets/test2.css", "spec/sinatra-bundles_spec.rb", "spec/spec.opts", "spec/spec_helper.rb", "vendor/cache/sinatra-0.10.1.gem", "vendor/gems/sinatra-0.10.1/AUTHORS", "vendor/gems/sinatra-0.10.1/CHANGES", "vendor/gems/sinatra-0.10.1/LICENSE", "vendor/gems/sinatra-0.10.1/README.jp.rdoc", "vendor/gems/sinatra-0.10.1/README.rdoc", "vendor/gems/sinatra-0.10.1/Rakefile", "vendor/gems/sinatra-0.10.1/lib/sinatra.rb", "vendor/gems/sinatra-0.10.1/lib/sinatra/base.rb", "vendor/gems/sinatra-0.10.1/lib/sinatra/images/404.png", "vendor/gems/sinatra-0.10.1/lib/sinatra/images/500.png", "vendor/gems/sinatra-0.10.1/lib/sinatra/main.rb", "vendor/gems/sinatra-0.10.1/lib/sinatra/showexceptions.rb", "vendor/gems/sinatra-0.10.1/lib/sinatra/tilt.rb", "vendor/gems/sinatra-0.10.1/sinatra.gemspec", "vendor/gems/sinatra-0.10.1/test/base_test.rb", "vendor/gems/sinatra-0.10.1/test/builder_test.rb", "vendor/gems/sinatra-0.10.1/test/contest.rb", "vendor/gems/sinatra-0.10.1/test/erb_test.rb", "vendor/gems/sinatra-0.10.1/test/erubis_test.rb", "vendor/gems/sinatra-0.10.1/test/extensions_test.rb", "vendor/gems/sinatra-0.10.1/test/filter_test.rb", "vendor/gems/sinatra-0.10.1/test/haml_test.rb", "vendor/gems/sinatra-0.10.1/test/helper.rb", "vendor/gems/sinatra-0.10.1/test/helpers_test.rb", "vendor/gems/sinatra-0.10.1/test/mapped_error_test.rb", "vendor/gems/sinatra-0.10.1/test/middleware_test.rb", "vendor/gems/sinatra-0.10.1/test/request_test.rb", "vendor/gems/sinatra-0.10.1/test/response_test.rb", "vendor/gems/sinatra-0.10.1/test/result_test.rb", "vendor/gems/sinatra-0.10.1/test/route_added_hook_test.rb", "vendor/gems/sinatra-0.10.1/test/routing_test.rb", "vendor/gems/sinatra-0.10.1/test/sass_test.rb", "vendor/gems/sinatra-0.10.1/test/server_test.rb", "vendor/gems/sinatra-0.10.1/test/sinatra_test.rb", "vendor/gems/sinatra-0.10.1/test/static_test.rb", "vendor/gems/sinatra-0.10.1/test/templates_test.rb", "vendor/gems/sinatra-0.10.1/test/views/error.builder", "vendor/gems/sinatra-0.10.1/test/views/error.erb", "vendor/gems/sinatra-0.10.1/test/views/error.erubis", "vendor/gems/sinatra-0.10.1/test/views/error.haml", "vendor/gems/sinatra-0.10.1/test/views/error.sass", "vendor/gems/sinatra-0.10.1/test/views/foo/hello.test", "vendor/gems/sinatra-0.10.1/test/views/hello.builder", "vendor/gems/sinatra-0.10.1/test/views/hello.erb", "vendor/gems/sinatra-0.10.1/test/views/hello.erubis", "vendor/gems/sinatra-0.10.1/test/views/hello.haml", "vendor/gems/sinatra-0.10.1/test/views/hello.sass", "vendor/gems/sinatra-0.10.1/test/views/hello.test", "vendor/gems/sinatra-0.10.1/test/views/layout2.builder", "vendor/gems/sinatra-0.10.1/test/views/layout2.erb", "vendor/gems/sinatra-0.10.1/test/views/layout2.erubis", "vendor/gems/sinatra-0.10.1/test/views/layout2.haml", "vendor/gems/sinatra-0.10.1/test/views/layout2.test", "vendor/specifications/sinatra-0.10.1.gemspec"]
  s.homepage = %q{http://github.com/darkhelmet/sinatra-bundles}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Easy asset bundling for sinatra}
  s.test_files = ["spec/app.rb", "spec/production_app.rb", "spec/sinatra-bundles_spec.rb", "spec/spec_helper.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rainpress>, [">= 0"])
      s.add_runtime_dependency(%q<packr>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 1.2.9"])
      s.add_development_dependency(%q<rack-test>, [">= 0.5.3"])
      s.add_development_dependency(%q<yard>, [">= 0"])
    else
      s.add_dependency(%q<rainpress>, [">= 0"])
      s.add_dependency(%q<packr>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 1.2.9"])
      s.add_dependency(%q<rack-test>, [">= 0.5.3"])
      s.add_dependency(%q<yard>, [">= 0"])
    end
  else
    s.add_dependency(%q<rainpress>, [">= 0"])
    s.add_dependency(%q<packr>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 1.2.9"])
    s.add_dependency(%q<rack-test>, [">= 0.5.3"])
    s.add_dependency(%q<yard>, [">= 0"])
  end
end
