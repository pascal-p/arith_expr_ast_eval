module ArithExprASTEval

  class Tokenizer

    def initialize(expr)
      @expr = expr
    end

    def self.build(expr, ops)
      self.new(expr).tokenize(ops)
    end
    
    # Alt tokenizer - won't work for '(' ')'
    #def tokenize(ops)
    #  ops.list.inject(@expr) {|e, op| e.gsub("#{op}", " #{op} ")}.split(' ')
    #end

    def tokenize(ops)
      expr = @expr
      token, ptoken  = '', ''  # prev. token
      ix, lst = 0, []
      #
      while ix < expr.length        
        token += expr[ix]
        c_ix   = ix      # read next token, next prev, curr and next
        #
        if token == '-' && ops.operator?(ptoken)          
          ix += 1 # unary sign, following expr should be digit or '.' else Exception
          ptoken = token
          next
        #
        elsif ops.operator?(token)          
          ix += 1           # assuming 1 char. length operator
        #
        elsif token =~ /^(?:\-)?\d$/  # Numeric expression
          token, ix = _num(expr, token, ix + 1)
        #
        elsif token =~ /^\.$/  # Numeric expression
          token.sub!(/^\./, '0.') 
          token, ix = _num_w_dot(expr, token, ix + 1)
        #
        elsif token =~ /^\-\.$/  # Numeric expression
          token.sub!(/^\-\./, '-0.')
          token, ix = _num_w_dot(expr, token, ix + 1)
        #
        elsif token == '('
          token, ix = _paren(expr, token, ix + 1)
        #
        else
          raise SyntaxError
        end
        #
        lst << (ptoken = token)
        token = ''
        ix += (c_ix == ix) ? 1 : 0 
      end
      lst
    end

    private
    def _num_w_dot(expr, token, ix)
      _read_num(expr, token, ix) # return [token, ix]
    end
    
    def _num(expr, token, ix)
      token, ix = _read_num(expr, token, ix)
      #
      if ix >= expr.length # end of expr
        return [token, ix] 
      elsif expr[ix] == '.'
        token, ix = _read_num(expr, *acc(expr, token, ix))
        #
        if ix >= expr.length
          return [token, ix] 
        elsif expr[ix] == '.'
          raise SyntaxError,
                "got a second . in numeric expression"  # cannot have 2 . in a number
        else
          return [token, ix] 
        end
      else
        return [token, ix] 
      end
    end

    def _paren(expr, token, ix)
      paren = 1
      while ix < expr.length    # read until closing ')'
        token, ix = acc(expr, token, ix)
        jx = ix - 1        
        paren += 1 if expr[jx] == '('
        paren -= 1 if expr[jx] == ')'
        break if paren == 0
      end      
      [token, ix]
    end
    
    def _read_num(expr, token, ix)
      while ix < expr.length && expr[ix] =~ /^\d/
        token, ix = acc(expr, token, ix)
      end
      [token, ix]
    end
    
    def acc(expr, token, ix)
      token += expr[ix]
      ix += 1
      [token, ix]  
    end
    
  end

end
