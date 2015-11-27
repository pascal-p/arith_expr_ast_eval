# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'arith_expr_ast_eval/version'

Gem::Specification.new do |spec|
  spec.name          = "arith_expr_ast_eval"
  spec.version       = ArithExprAstEval::VERSION
  spec.authors       = ["Pascal P"]
  spec.email         = ["lacsap_666@yahoo.fr"]

  spec.summary       = %q{Arithmetic Expression Analyzer}
  spec.description   = %q{Take an arithmetic expression and (try to) build the (corresponding) AST. 
If the syntax is correct then the AST is evaluated (extension give and env for the evaluation)}
  spec.homepage      = ""
  spec.license       = "BSD"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
end
