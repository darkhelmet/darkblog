# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{darkhelmet-sinatra_more}
  s.version = "0.3.35"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Nathan Esquenazi", "Daniel Huckstep"]
  s.date = %q{2010-01-07}
  s.default_executable = %q{sinatra_gen}
  s.description = %q{Expands sinatra with standard helpers and tools to allow for complex applications}
  s.email = %q{nesquena@gmail.com}
  s.executables = ["sinatra_gen"]
  s.extra_rdoc_files = ["LICENSE", "README.rdoc", "TODO"]
  s.files = [".document", ".gitignore", "IDEAS.md", "LICENSE", "README.rdoc", "ROADMAP", "Rakefile", "TODO", "VERSION", "bin/sinatra_gen", "generators/base_app/.gitignore", "generators/base_app/Gemfile", "generators/base_app/app/.empty_directory", "generators/base_app/app/helpers/.empty_directory", "generators/base_app/app/helpers/view_helpers.rb", "generators/base_app/app/mailers/.empty_directory", "generators/base_app/app/models/.empty_directory", "generators/base_app/app/routes/.empty_directory", "generators/base_app/app/views/.empty_directory", "generators/base_app/config.ru.tt", "generators/base_app/config/boot.rb.tt", "generators/base_app/config/dependencies.rb.tt", "generators/base_app/lib/.empty_directory", "generators/base_app/log/.empty_directory", "generators/base_app/public/images/.empty_directory", "generators/base_app/public/images/.gitignore", "generators/base_app/public/javascripts/.empty_directory", "generators/base_app/public/stylesheets/.empty_directory", "generators/base_app/test/models/.empty_directory", "generators/base_app/test/routes/.empty_directory", "generators/base_app/test/test_config.rb.tt", "generators/base_app/tmp/.empty_directory", "generators/base_app/vendor/gems/.empty_directory", "generators/components/component_actions.rb", "generators/components/mocks/mocha_mock_gen.rb", "generators/components/mocks/rr_mock_gen.rb", "generators/components/orms/activerecord_orm_gen.rb", "generators/components/orms/couchrest_orm_gen.rb", "generators/components/orms/datamapper_orm_gen.rb", "generators/components/orms/mongomapper_orm_gen.rb", "generators/components/orms/sequel_orm_gen.rb", "generators/components/renderers/erb_renderer_gen.rb", "generators/components/renderers/haml_renderer_gen.rb", "generators/components/scripts/jquery_script_gen.rb", "generators/components/scripts/prototype_script_gen.rb", "generators/components/scripts/rightjs_script_gen.rb", "generators/components/tests/bacon_test_gen.rb", "generators/components/tests/riot_test_gen.rb", "generators/components/tests/rspec_test_gen.rb", "generators/components/tests/shoulda_test_gen.rb", "generators/components/tests/testspec_test_gen.rb", "generators/generator_actions.rb", "generators/skeleton_generator.rb", "lib/sinatra_more.rb", "lib/sinatra/mailer_plugin.rb", "lib/sinatra/mailer_plugin/mail_object.rb", "lib/sinatra/mailer_plugin/mailer_base.rb", "lib/sinatra/markup_plugin.rb", "lib/sinatra/markup_plugin/asset_tag_helpers.rb", "lib/sinatra/markup_plugin/form_builder/abstract_form_builder.rb", "lib/sinatra/markup_plugin/form_builder/standard_form_builder.rb", "lib/sinatra/markup_plugin/form_helpers.rb", "lib/sinatra/markup_plugin/format_helpers.rb", "lib/sinatra/markup_plugin/output_helpers.rb", "lib/sinatra/markup_plugin/tag_helpers.rb", "lib/sinatra/render_plugin.rb", "lib/sinatra/render_plugin/render_helpers.rb", "lib/sinatra/routing_plugin.rb", "lib/sinatra/routing_plugin/named_route.rb", "lib/sinatra/routing_plugin/routing_helpers.rb", "lib/sinatra/support_lite.rb", "lib/sinatra/warden_plugin.rb", "lib/sinatra/warden_plugin/warden_helpers.rb", "sinatra_more.gemspec", "test/active_support_helpers.rb", "test/fixtures/mailer_app/app.rb", "test/fixtures/mailer_app/views/demo_mailer/sample_mail.erb", "test/fixtures/mailer_app/views/sample_mailer/anniversary_message.erb", "test/fixtures/mailer_app/views/sample_mailer/birthday_message.erb", "test/fixtures/markup_app/app.rb", "test/fixtures/markup_app/views/capture_concat.erb", "test/fixtures/markup_app/views/capture_concat.haml", "test/fixtures/markup_app/views/content_for.erb", "test/fixtures/markup_app/views/content_for.haml", "test/fixtures/markup_app/views/content_tag.erb", "test/fixtures/markup_app/views/content_tag.haml", "test/fixtures/markup_app/views/fields_for.erb", "test/fixtures/markup_app/views/fields_for.haml", "test/fixtures/markup_app/views/form_for.erb", "test/fixtures/markup_app/views/form_for.haml", "test/fixtures/markup_app/views/form_tag.erb", "test/fixtures/markup_app/views/form_tag.haml", "test/fixtures/markup_app/views/link_to.erb", "test/fixtures/markup_app/views/link_to.haml", "test/fixtures/markup_app/views/mail_to.erb", "test/fixtures/markup_app/views/mail_to.haml", "test/fixtures/markup_app/views/meta_tag.erb", "test/fixtures/markup_app/views/meta_tag.haml", "test/fixtures/render_app/app.rb", "test/fixtures/render_app/views/erb/test.erb", "test/fixtures/render_app/views/haml/test.haml", "test/fixtures/render_app/views/template/_user.haml", "test/fixtures/render_app/views/template/haml_template.haml", "test/fixtures/render_app/views/template/some_template.haml", "test/fixtures/routing_app/app.rb", "test/fixtures/routing_app/views/index.haml", "test/fixtures/warden_app/app.rb", "test/fixtures/warden_app/views/dashboard.haml", "test/generators/test_skeleton_generator.rb", "test/helper.rb", "test/mailer_plugin/test_mail_object.rb", "test/mailer_plugin/test_mailer_base.rb", "test/markup_plugin/test_asset_tag_helpers.rb", "test/markup_plugin/test_form_builder.rb", "test/markup_plugin/test_form_helpers.rb", "test/markup_plugin/test_format_helpers.rb", "test/markup_plugin/test_output_helpers.rb", "test/markup_plugin/test_tag_helpers.rb", "test/test_mailer_plugin.rb", "test/test_render_plugin.rb", "test/test_routing_plugin.rb", "test/test_warden_plugin.rb"]
  s.homepage = %q{http://github.com/nesquena/sinatra_more}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Expands sinatra to allow for complex applications}
  s.test_files = ["test/active_support_helpers.rb", "test/fixtures/mailer_app/app.rb", "test/fixtures/markup_app/app.rb", "test/fixtures/render_app/app.rb", "test/fixtures/routing_app/app.rb", "test/fixtures/warden_app/app.rb", "test/generators/test_skeleton_generator.rb", "test/helper.rb", "test/mailer_plugin/test_mail_object.rb", "test/mailer_plugin/test_mailer_base.rb", "test/markup_plugin/test_asset_tag_helpers.rb", "test/markup_plugin/test_form_builder.rb", "test/markup_plugin/test_form_helpers.rb", "test/markup_plugin/test_format_helpers.rb", "test/markup_plugin/test_output_helpers.rb", "test/markup_plugin/test_tag_helpers.rb", "test/test_mailer_plugin.rb", "test/test_render_plugin.rb", "test/test_routing_plugin.rb", "test/test_warden_plugin.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<sinatra>, [">= 0.9.2"])
      s.add_runtime_dependency(%q<tilt>, [">= 0.2"])
      s.add_runtime_dependency(%q<thor>, [">= 0.11.8"])
      s.add_runtime_dependency(%q<activesupport>, [">= 2.2.2"])
      s.add_runtime_dependency(%q<bundler>, [">= 0"])
      s.add_runtime_dependency(%q<pony>, [">= 0"])
      s.add_development_dependency(%q<haml>, [">= 2.2.14"])
      s.add_development_dependency(%q<shoulda>, [">= 2.10.2"])
      s.add_development_dependency(%q<mocha>, [">= 0.9.7"])
      s.add_development_dependency(%q<rack-test>, [">= 0.5.0"])
      s.add_development_dependency(%q<webrat>, [">= 0.5.1"])
    else
      s.add_dependency(%q<sinatra>, [">= 0.9.2"])
      s.add_dependency(%q<tilt>, [">= 0.2"])
      s.add_dependency(%q<thor>, [">= 0.11.8"])
      s.add_dependency(%q<activesupport>, [">= 2.2.2"])
      s.add_dependency(%q<bundler>, [">= 0"])
      s.add_dependency(%q<pony>, [">= 0"])
      s.add_dependency(%q<haml>, [">= 2.2.14"])
      s.add_dependency(%q<shoulda>, [">= 2.10.2"])
      s.add_dependency(%q<mocha>, [">= 0.9.7"])
      s.add_dependency(%q<rack-test>, [">= 0.5.0"])
      s.add_dependency(%q<webrat>, [">= 0.5.1"])
    end
  else
    s.add_dependency(%q<sinatra>, [">= 0.9.2"])
    s.add_dependency(%q<tilt>, [">= 0.2"])
    s.add_dependency(%q<thor>, [">= 0.11.8"])
    s.add_dependency(%q<activesupport>, [">= 2.2.2"])
    s.add_dependency(%q<bundler>, [">= 0"])
    s.add_dependency(%q<pony>, [">= 0"])
    s.add_dependency(%q<haml>, [">= 2.2.14"])
    s.add_dependency(%q<shoulda>, [">= 2.10.2"])
    s.add_dependency(%q<mocha>, [">= 0.9.7"])
    s.add_dependency(%q<rack-test>, [">= 0.5.0"])
    s.add_dependency(%q<webrat>, [">= 0.5.1"])
  end
end
