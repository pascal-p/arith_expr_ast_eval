module ArithExprASTEval

  module Operator
    extend self

    # mapping symbol(for operator) - priority, actual operator (String), associativity
    @op = {
           :'+' => [ 1, '+', :left],
           :'-' => [ 1, '-', :left ],
           :'x' => [ 2, '*', :left ],
           :'÷' => [ 2, '/', :left ],
           :'%' => [ 2, '%', :left ],
           # unary '-' ?
           :'^' => [ 3, '^', :right ],
           # '(' and ')'
           # ln, exp, cos, sin ...
    }
    
    def setup
      self
    end

    def list
      @op.keys
    end

    def operator?(exp)
      !exp.nil? && list.include?(exp.to_s.downcase.to_sym)
    end

    # val, method(symbol), method name, [method alias, [method args]] 
    [ [-1, :first, :priority, :prio],
      [:none, :last, :associativity, :assoc],
      [nil, :[], :value, :val, [1]] ].each do |val, m_invoc, m_name, *rest|
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
          @op.fetch(op.to_sym) { [ val ] }.send(m_invoc, *args)
        else
          @op.fetch(op.to_sym) { [ val ] }.send(m_invoc)
        end        
      end

      alias_method m_alias, m_name unless m_alias.nil?
    end
    
    #
    # The following is more read-able (but boring to write)
    #
    
    # def priority(op)
    #   @op.fetch(op.to_sym) { [ -1 ] }.first
    # end
    # alias_method :prio, :priority
    
    # def associativity(op)
    #   @op.fetch(op.to_sym) { [ :none ] }.last
    # end
    # alias_method :assoc, :associativity
    
    # def value(op)
    #   @op.fetch(op.to_sym) { [  ] }[1] # assume at least 2 element in the array 
    # end
    # alias_method :val, :value
    
  end

end
