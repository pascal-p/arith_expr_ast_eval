require_relative './ast'
require_relative './operator'
require_relative './operand'

module ArithExprASTEval

  class Evaluator

    class EvalError < StandardError; end
    
    def initialize(ast, env={})
      @ops  = Operator.setup()   # ArithExprASTEval::Operator
      @operand = Operand.setup()
      @env = env  # for the eval...
      @ast = ast
    end

    def self.run(ast, env={})
      self.new(ast, env).eval_()
    end
    
    def eval_(node=@ast.root, env=@env)
      _s_eval(node, env)
    end

    private
    def _s_eval(node, env)
      # STDOUT.print("==> node: #{node.inspect}\n")      
      if node.leaf? # node.empty?
        return s_to_num(node)
      else
        op, oper1, oper2 = node.splat
        #
        if oper1.val =~ @operand.num_rexp && oper2.val =~ @operand.num_rexp
          # reduction
          begin
            r1 = s_to_num(oper1)
            r2 = s_to_num(oper2)
            r  = r1.send(@ops.value(op).to_sym, r2)
            return r
          rescue Exception => e
            raise EvalError, e.message
          end
          #
        elsif oper1.val =~ @operand.num_rexp
          r   = eval_(oper2, env)
          r1  = s_to_num(oper1)
          return r1.send(@ops.value(op).to_sym, r)
          #
        elsif oper2.val =~ @operand.num_rexp
          r  = eval_(oper1, env)
          r2 = s_to_num(oper2)
          return r.send(@ops.value(op).to_sym, r2)
        else
          r1 = eval_(oper1, env)
          r2 = eval_(oper2, env)
          return r1.send(@ops.value(op).to_sym, r2)
          #
        end
      end
    end

    def s_to_num(oper)
      oper.val =~ /\./ ? oper.val.to_f : oper.val.to_i
    end
    
  end
  
end
