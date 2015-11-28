# spec/evaluator_spec.rb
require_relative 'spec_helper'

module ArithExprASTEval
  # to avoid having to write ArithExprASTEval::AST

  RSpec.configure do |config|
    #
    ## mapping ast, eval
    #
    @@precision = 0.001

    @@expr = [
      [ArithExprASTEval::AST.build("2 + 3 x 51".gsub(' ', '')), 155],
      [ArithExprASTEval::AST.build("2 x 3 + 5".gsub(' ', '')), 11],
      [ArithExprASTEval::AST.build("4.99 ÷ .7 ÷ 3".gsub(' ', '')), 2.3761], # 2.376190476190476],
      [ArithExprASTEval::AST.build("2 x 3 ^ 5 x 3".gsub(' ', '')), 1458],
      [ArithExprASTEval::AST.build("2 ÷ (3 + 5)".gsub(' ', '')), 0],
      [ArithExprASTEval::AST.build("2.0 ÷ (3 + 5)".gsub(' ', '')), 0.25],
      [ArithExprASTEval::AST.build("2.0 ÷ (3.0 + 5.0)".gsub(' ', '')), 0.25],
      [ArithExprASTEval::AST.build("2 ÷ (3 + 5.0)".gsub(' ', '')), 0.25],
      [ArithExprASTEval::AST.build("( 3 )".gsub(' ', '')), 3],
      [ArithExprASTEval::AST.build("(2 x (3.0 + 2.1)) ^ 5.1".gsub(' ', '')), 139271.0583 ] ,# 139271.05837705694],
      [ArithExprASTEval::AST.build("2.9999 + -.3".gsub(' ', '')), 2.6999],
      [ArithExprASTEval::AST.build("100 + 200 + 3000 + 4000 + 5000 + 6000 + 70.0333 + 8.5 + 9.5678 - 10".gsub(' ', '')), 18378.1011],
      [ArithExprASTEval::AST.build("((2 ^ 3 x (3.0 + (2.1 - 3) x 2)) ^ 5.1)".gsub(' ', '')), 102231.15995572545],
      [ArithExprASTEval::AST.build("((2.1 ^ 7)".gsub(' ', '')), 180.1088 ], # 180.10885410000006],
      [ArithExprASTEval::AST.build("((2.0 ÷ 0.0)".gsub(' ', '')), Float::INFINITY],

    ]

    config.before(:all) do
    end
  end

  RSpec.describe Evaluator do

    context "#eval" do
      @@expr.each do |expr|
        it "parses #{expr.first.traversal(:pre)} returns #{expr.last.nil? ? 'Exception' : expr.last}" do
          if expr.last.nil?
            expect { ArithExprASTEval::Evaluator.run expr.first}.to raise_error(ArithExprASTEval::Evaluator::EvalError)
          else
            res = ArithExprASTEval::Evaluator.run expr.first
            if expr.last.is_a?(Fixnum) || expr.last.is_a?(Bignum)
              expect(res).to eq expr.last
            else
              if res == Float::INFINITY
                expect(res).to eq expr.last
              else
                expect(res).to a_value_within(@@precision).of(expr.last)
              end
            end
          end
        end
      end

    end

  end

end
