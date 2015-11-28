# spec/ast_spec.rb
require_relative 'spec_helper'

module ArithExprASTEval
  # to avoid having to write ArithExprASTEval::AST

  RSpec.configure do |config|
    #
    ## mapping arithmetic expr => ast
    #
    @@expr = [
      ['ln(2 + 3)', ['ln', '+', '2', '3']],
      ['ln(2 + 3) + 1 ', ['+', 'ln', '+', '2', '3', '1']],
      ['ln(ln(2 + 3) + 1)', ['ln', '+', 'ln', '+', '2', '3', '1']],
      ['2 + 3 x 51', ["+", "2", "x", "3", "51"]],
      ['2 x 3 + 51', ["+", "x", "2", "3", "51"]],
      ['4.99 ÷ .7 ÷ 3', ["÷", "÷", "4.99", "0.7", "3"]],
      ["2 x 3 ^ 5 x 3", ["x", "2", "x", "^", "3", "5", "3"]],
      ["2 ÷ (3 + 5)", ["÷", "2", "+", "3", "5"]],
      ["(2 + 3.0) ÷ 5.1", ["÷", "+", "2", "3.0", "5.1"]],
      ["(3)", ["3"]],
      ["()", nil],
      ["!", nil],
      ["(2 x (3.0 + 2.1)) ^ 5.1", ["^", "x", "2", "+", "3.0", "2.1", "5.1"]],
      ["2.9999 + -.3", ["+", "2.9999", "-0.3" ]],
      ["2.99.99 + -.3", nil],
      ["", nil],
      ["100 + 200 + 3000 + 4000 + 5000 + 6000 + 70.0333 + 8.5 + 9.5678 - 10",
       ["-", "+", "+", "+", "+", "+", "+", "+", "+", "100", "200", "3000", "4000", "5000", "6000", "70.0333", "8.5", "9.5678", "10"]],
      ["((2 ^ 3 x (3.0 + (2.1  - 3) x 2)) ^ 5.1)", ["^", "x", "^", "2", "3", "+", "3.0", "x", "-", "2.1", "3", "2", "5.1"]],
    ]

    config.before(:all) do
    end
  end

  RSpec.describe AST do

    context "#build" do
      @@expr.each do |expr|
        it "parses #{expr.first} returns #{expr.last.nil? ? 'Exception' : expr.last}" do
          if expr.last.nil?
            expect { ArithExprASTEval::AST.build expr.first.gsub(' ', '')}.to raise_error(SyntaxError)
          else
            ast = ArithExprASTEval::AST.build expr.first.gsub(' ', '')
            expect(ast.traversal(:pre)).to eq expr.last
          end
        end
      end

    end

  end

end
