require_relative './btree'
require_relative './operator'
require_relative './operand'
require_relative './tokenizer'

module ArithExprASTEval

  #
  # Unbounded stack
  #

  class Stack

    class EmptyStackError < StandardError; end
    
    def initialize
      @st = []
    end
    
    def <<(v)
      @st << v
    end
    
    alias_method :push, :<<
                          
    def top
      raise EmptyStackError if @st.size == 0
      @st.last
    end
    
    def pop
      raise EmptyStackError if @st.size == 0
      @st.pop
    end

    def empty?
      @st.size == 0
    end

    def to_s
      @st.to_s
    end

    def size
      @st.size
    end
  end

  #
  # take an arithmetic expression (ar_expr) as input and build and return the AST
  # if ar_expr was syntactically correct, raise and exception otherwise 
  #
  
  class AST

    def initialize(expr)
      @ops  = Operator.setup()   # ArithExprASTEval::Operator
      @operand = Operand.setup() # ArithExprASTEval::Operand
      @tree = BTree.new()        # ArithExprASTEval::BTree
      @expr = expr.gsub(' ', '') # make sur all spaces are stripped off
    end
    
    def self.build(expr)
      self.new(expr).build(expr)
    end
    
    def build(expr)
      tree_stack = Stack.new   # ArithExprASTEval::Stack, to store the nodes
      ops_stack  = Stack.new   # ArithExprASTEval::Stack, to store the operators
      #
      Tokenizer.build(expr, @ops).each do |token|
        next if token == ''
        _proc(token, tree_stack, ops_stack)
      end      
      raise SyntaxError,
            "Unexpected expression or empty?" if tree_stack.empty?            
      _finish_ast_build(tree_stack, ops_stack) unless ops_stack.empty?
      @ast = _ret_ast(tree_stack.pop) # return the AST btree      
    end

    def empty?
      @ast.empty?
    end
    
    private              
    #
    # either numeric operand xor operator (no symbolic value)
    #
    def _proc(token, tree_stack, ops_stack)
      #STDOUT.print("===> proc. token <#{token}>\n")
      #
      if @ops.operator?(token)
       # STDOUT.print("===> token <#{token}> is an OPERATOR\n")
        _op_case(token, ops_stack, tree_stack)
      #
      elsif @ops.func?(token)
        #STDOUT.print("===> token <#{token}> is a FUNCTION EXPR\n")
        # recursion here...
        tree_stack << build(_func_case(token, ops_stack, tree_stack))
        # now pop the function itself
        op = ops_stack.pop
        #STDOUT.print("===> token <#{token}> // AFTR REC CALL with op: #{op}\n")
        _build_btree_n_push(tree_stack, op)
        #
      elsif token =~ @operand.num_rexp
        #STDOUT.print("===> token <#{token}> is NUMERIC\n")
        tree_stack << ArithExprASTEval::Node.new(token)
        #
      elsif token =~ @ops.parens_rexp # /^\(.+\)$/
        #STDOUT.print("===> token <#{token}> is PARENTHESES <#{@ops.parens_rexp}>?? \n")
        # recursion here...
        tree_stack << build(token.sub(/^\(/, '').sub(/\)$/, ''))
      #
      else
        raise SyntaxError,
              "Unexpected operator/operand found, got: #{token}" +
              " valid operators: #{@ops.list} //" +
              " valid functions: #{@ops.func_list}"
      end
    end

    def _op_case(op, ops_stack, tree_stack)
      if ops_stack.empty? || @ops.prio(op) > @ops.prio(ops_stack.top)
        ops_stack << op    # empty op stack || curr. op prio higher => just push onto it
      #
      elsif @ops.priority(op) < @ops.priority(ops_stack.top)
        _build_btree_n_push(tree_stack, ops_stack.pop)
        ops_stack << op
      #
      else
        _op_case_with_assoc(op, ops_stack, tree_stack)
      end
    end

    def _op_case_with_assoc(op, ops_stack, tree_stack)
      case @ops.assoc(op)
      when :left
           _build_btree_n_push(tree_stack, ops_stack.pop)
           ops_stack << op
      #
      when :right
           ops_stack << op
      #    
      else
        raise SyntaxError, "Unexpected operator/operand found"
      end
    end

    def _func_case(token, ops_stack, tree_stack)
      #raise NotImplementedError,                                                             
      #      "#{__method__} no yet implemented"
      if token =~ /^([a-z]+)\((.+)\)/
        fun, expr = $1, $2
        ops_stack << fun
        expr
      else
        raise SyntaxError,
              "Unexpected function expression - valid format is func(...)"
      end
      
    end

    # arity 2
    def _build_btree_2(tree_stack, op)
      rnode = tree_stack.pop    # can be a btree (if rnode is a node) or a node  
      lnode = tree_stack.pop    # can be a btree (if lnode is a node) or a node
      if lnode.is_a?(BTree) && rnode.is_a?(BTree)
        BTree.new(op).add_subtrees(lnode, rnode) # ArithExprASTEval::BTree
      #
      elsif lnode.is_a? BTree    # ArithExprASTEval::BTree
        lnode.newroot(op, :left).add_r(rnode)
      #
      elsif rnode.is_a? BTree    # ArithExprASTEval::BTree
        rnode.newroot(op, :right).add_l(lnode)
        #
      else
        BTree.new(op).add_l(lnode).add_r(rnode) # ArithExprASTEval::BTree
      end
    end

    # arity 1
    def _build_btree_1(tree_stack, op)
      rnode = tree_stack.pop
      if rnode.is_a?(BTree)
        BTree.new(op).add_subtrees(nil, rnode)
      else
        BTree.new(op).add_r(rnode) # ArithExprASTEval::BTree
      end 
    end
    
    def _build_btree(tree_stack, op)
      # (!) assuming binary operator here
      if @ops.arity(op) == 2
        _build_btree_2(tree_stack, op)
      elsif @ops.arity(op) == 1
        _build_btree_1(tree_stack, op)
      else
        raise SyntaxError,
              "Operator arity is 2, function arity is 1 - but #{op} arity is not 1 nor 2"
      end      
    end

    def _build_btree_n_push(tree_stack, op)
      tree_stack << _build_btree(tree_stack, op)
    end
    
    def _finish_ast_build(tree_stack, ops_stack)
      while ! ops_stack.empty?
        op = ops_stack.pop
        _build_btree_n_push(tree_stack, op)
      end      
    end

    def _ret_ast(top)
      if top.is_a?(BTree)   # ArithExprASTEval::BTree
        top
      elsif top.is_a?(Node) # ArithExprASTEval::Node
        BTree.new(top.val)  # ArithExprASTEval::BTree
      else
        raise SyntaxError, "Unexpected expression"
      end
    end
    
  end

end
