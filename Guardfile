require 'active_support/core_ext/string'
# Defines the matching rules for Guard.
guard :minitest, spring: "bin/rails test", all_on_start: false do
  watch(%r{^test/(.*)/?(.*)_test\.rb$})
  watch('test/test_helper.rb') { 'test' }
  watch('config/routes.rb') { interface_tests }
  watch(%r{^test/fixtures/(.*?)\.yml$}) do |matches|
    "test/models/#{matches[1].singularize}_test.rb"
  end
end

# Returns all tests that hit the interface.
def interface_tests
  integration_tests << "test/controllers"
end
