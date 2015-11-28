require_relative './operator'
require_relative './operand'

module ArithExprASTEval

  class Tokenizer

    def initialize(expr)
      @expr = expr.gsub(/\s+/, '')  # make sure all space are removed
      @ops = Operator.setup
      @oper = Operand.setup
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
          ix = _ops_case(expr, token, ix)
        #
        elsif token =~ @oper.numeric_rexp
          token, ix = _num_case(expr, token, ix)
        #
        elsif token == @ops.p_start # '('
          token, ix = _parens(expr, token, ix + 1)
        #
        elsif token =~ @ops.start_func_rexp  # start with operator funcction like ln, cos, sin ...
          # need to read more fun(...) until closing
          token, ix = _read_func(expr, token, ix + 1)
        else
          raise SyntaxError,
                "unexpected character in expression"
        end
        #
        lst << (ptoken = token)
        token = ''
        ix += (c_ix == ix) ? 1 : 0
      end
      lst
    end

    private

    # _ops_case(...) and _num_case(...), _dec_tail(...)
    #
    # Returns [token, ix]
    #
    def _ops_case(expr, token, ix)
      # ignored expr for now
      # ignored token
      ix += 1
    end

    def _num_case(expr, token, ix)
      if token =~ @oper.signed_int_rexp  # /^(?:\-)?\d$/
        token, ix = _dec_num(expr, token, ix + 1)
      #
      elsif token =~ @oper.signed_dec_rexp  # /^\.$|^\-\.$/
        token = @oper.insert_leading_0(token)
        token, ix = _dec_tail(expr, token, ix + 1)
      else
        raise SyntaxError, "Not a number"
      end
    end

    def _dec_tail(expr, token, ix)
      _read_num(expr, token, ix)
    end

    def _dec_num(expr, token, ix)
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

    def _parens(expr, token, ix)
      paren = 1
      while ix < expr.length    # read until closing @ops.p_end
        token, ix = acc(expr, token, ix)
        jx = ix - 1
        paren += 1 if expr[jx] == @ops.p_start # == '('
        paren -= 1 if expr[jx] == @ops.p_end   # == ')'
        break if paren == 0
      end
      [token, ix]
    end

    def _read_num(expr, token, ix)
      while ix < expr.length
        break if expr[ix] !~ @oper.digit
        token, ix = acc(expr, token, ix)
      end
      [token, ix]
    end

    def _read_func(expr, token, ix)
      while ix < expr.length
        break if expr[ix].downcase !~ /^[a-z]$/
        token, ix = acc(expr, token, ix)
      end
      #
      # expr[ix] must be @ops.p_start
      raise SyntaxError,
            "Mal-formed function expression" if ix >= expr.length
      raise SyntaxError,
            "Expecting #{@ops.p_start}, but got: #{expr[ix]}" unless expr[ix] == @ops.p_start
      token += expr[ix]
      # need to read more fun(...) until @ops.p_end
      _parens(expr, token, ix + 1) # returns [token, ix]
    end

    def acc(expr, token, ix)
      token += expr[ix]
      ix += 1
      [token, ix]
    end

  end

end
