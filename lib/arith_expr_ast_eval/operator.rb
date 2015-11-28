module ArithExprASTEval

  module Operator
    extend self

    #
    # mapping symbol(for operator) - priority, actual operator (String),
    #         associativity, functional arity (unary, binary, ...)
    #
    @func = {
             :ln  => [1, 'Math.log', :right, 1],
             :exp => [1, 'Math.exp', :right, 1],
    }

    @op = {
           :'+' => [ 2, '+', :left, 2 ],
           :'-' => [ 2, '-', :left, 2 ],
           :'x' => [ 3, '*', :left, 2 ],
           :'÷' => [ 3, '/', :left, 2 ],
           :'%' => [ 3, '%', :left, 2 ],
           # unary '-' ?
           :'^' => [ 4, '**', :right, 2 ]
    }
    
    @@_all = @op.merge(@func)
    
    @parens = [ '(', ')' ]
    
    def setup
      self
    end

    def list
      @op.keys
    end

    def func_list
      @func.keys
    end

    def operator?(exp)
      !exp.nil? && list.include?(exp.to_s.downcase.to_sym)
    end

    def func?(exp)
      return false if exp.nil?
      #
      if exp =~ /^([a-z]+)\(.+\)/  # start of a function expression
        func_list.include?($1.to_sym)
      else
        func_list.include?(exp.to_s.downcase.to_sym)
      end
    end

    def p_start
      @parens.first
    end

    def p_end
      @parens.last
    end

    # Returns /^\(.+\)$/
    def parens_rexp
      /^#{p_start}.+#{p_end}$/
    end

    #
    # build a regexp with all the first letter of each pre-defined @fun (Math functions)
    #
    def start_func_rexp
      Regexp.new(@func.keys.map(&:to_s).map {|s| s[0]}.uniq.map {|s| "^#{s}" }.join('|'))
    end

    # val, method(symbol), method name, [method alias, [method args]]
    [
      [   -1, :first, :priority, :prio],
      [   -1, :last, :arity, :ari ],
      [  nil, :[], :value, :val, [1]],
      [ :none, :[], :associativity, :assoc, [2]],
    ].each do |val, m_invoc, m_name, *rest|
      m_alias, args =
               case rest.size
               when 0
                 [nil, []]
               when 1
                 [rest.first, []]
               when 2
                 [rest.first, rest.last]
               else
                 raise SyntaxError
               end
      define_method(m_name) do |op|
        if args.size > 0
          @@_all.fetch(op.to_sym) { [ val ] }.send(m_invoc, *args)
        else
          @@_all.fetch(op.to_sym) { [ val ] }.send(m_invoc)
        end
      end

      alias_method m_alias, m_name unless m_alias.nil?
    end

    #
    # The following is more read-able (but boring to write)
    #

    # def priority(op)
    #   @_all.fetch(op.to_sym) { [ -1 ] }.first
    # end
    # alias_method :prio, :priority

    # def value(op)
    #   @_all.fetch(op.to_sym) { [  ] }[1] # assume at least 2 element in the array
    # end
    # alias_method :val, :value

    # def associativity(op)
    #   @_all.fetch(op.to_sym) { [ :none ] }[2]
    # end
    # alias_method :assoc, :associativity

    # def arity(op)
    #  @_alll.fetch(op.to_sym) { [ -1 ] }.last
    # end
    # alias_method :ari, :arity
  end

end
