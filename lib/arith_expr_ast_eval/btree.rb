module ArithExprASTEval

  class Node
    include Comparable

    attr_reader :val
    attr_accessor :lnode, :rnode
    
    def initialize(val)
      @val = val
    end

    #
    # val has a type which allow Comparable
    # therefore here we just need to extend that notion to the node
    #
    def <=>(oNode)
      self.val <=> oNode.val
    end

    def leaf?
      @lnode.nil? && @rnode.nil?
    end

    def splat
      return [nil]  if @val.nil?
      return [@val] if leaf?
      return [@val, @lnode, @rnode]
    end
    
    private
    # mutate the value
    #def vmutate(val)
    #  @val = val
    #end

  end

  class BTree
    attr_reader :root, :node_count

    @@id_fun = ->(x) { x }
    
    def initialize(val=nil)
      @node_count ||= 0
      @root = if val.nil?
        nil
      else
        @node_count += 1
        ArithExprASTEval::Node.new(val)
      end
    end

    def empty?
      @node_count == 0
    end

    def leaf?
      @node_count == 1
    end
    
    #
    # add newroot from val
    #
    def newroot(val, dir=:left)
      newroot = ArithExprASTEval::Node.new(val)
      if dir == :left 
        newroot.lnode = @root
      elsif dir == :right
        newroot.rnode = @root
      else
        raise ArgumentError, "expected :right or :left, go #{dir}"
      end
      @root = newroot
      self
    end

    def add_lsubtree(tree)
      @root.lnode = tree.root
      @node_count += tree.node_count
    end

    def add_rsubtree(tree)
      @root.rnode = tree.root
      @node_count += tree.node_count
    end

    def add_subtrees(ltree, rtree)
      add_lsubtree(ltree) unless ltree.nil?
      add_rsubtree(rtree) unless rtree.nil?
      self
    end
    
    #
    # left node, right node - Node here
    #
    def add_l(node)
      @root.lnode = node
      @node_count += 1
      self
    end
    
    def add_r(node)
      @root.rnode = node
      @node_count += 1
      self
    end

    def to_s
      "value: #{@root.val} - left: #{@root.lnode.inspect} / right: #{@root.rnode.inspect}"
    end

    #
    # in-order (:in), pre-order(:pre), post-order(:post)
    # the supplied function cannot mutate the tree
    #
    def traversal(way=:post, lbd=@@id_fun)
      self.send("_#{way}_order".to_sym, @root, lbd)
    end

    private
    # Depth first - recursive version
    # will apply a block (3rd implicit parms) on each node using in-order
    # traversal and collect the result into an array
    #
    def _in_order(root, ary=[], lbd)
      if root.nil?
        ary
      else
        _in_order(root.lnode, ary, lbd)
        ary << lbd.call(root.val)
        _in_order(root.rnode, ary, lbd)
      end
    end

    # Depth first - recursive    
    # return an array - _pre_order = root, left, right
    #
    def _pre_order(root, ary=[], lbd)
      if root.nil?
        ary
      else
        ary << lbd.call(root.val)
        _pre_order(root.lnode, ary, lbd)
        _pre_order(root.rnode, ary, lbd)
      end
    end

    # Depth first
    # return an array - _post_order = root, left, right
    def _post_order(root, ary=[], lbd)
      if root.nil?
        ary
      else
        _post_order(root.lnode, ary, lbd)
        _post_order(root.rnode, ary, lbd)
        ary << lbd.call(root.val)
      end
    end
    
  end
  
end
