require_relative './btree'
require_relative './operator'
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

    @@number_rexp = /^(?:\-)?\d+(?:\.\d+)?$|^(?:\-)?\.\d+$/
    
    def initialize(expr)
      @ops  = Operator.setup() # ArithExprASTEval::Operator
      @tree = BTree.new() # ArithExprASTEval::BTree
      @expr = expr.gsub(' ', '')
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
      _ret_ast(tree_stack.pop) # return the AST btree
    end
    
    private              
    #
    # either numeric operand xor operator (no symbolic value)
    #
    def _proc(token, tree_stack, ops_stack)
      if @ops.operator?(token)
        _op_case(token, ops_stack, tree_stack)
      #
      elsif token =~ @@number_rexp
        tree_stack << ArithExprASTEval::Node.new(token)
      #
      elsif token =~ /^\(.+\)$/
        tree_stack << build(token.sub(/^\(/, '').sub(/\)$/, ''))
      #
      else
        raise SyntaxError,
              "Unexpected operator/operand found, got #{token} - valid operators: #{@ops.list} "
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

    def _build_btree(tree_stack, op)
      # (!) assuming binary operator here            
      rnode = tree_stack.pop    # can be a btree (if rnode is a node) or a node  
      lnode = tree_stack.pop    # can be a btree (if lnode is a node) or a node
      #
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
