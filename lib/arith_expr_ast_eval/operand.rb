module ArithExprASTEval

  module Operand
    extend self

    @num_rexp = /^(?:\-)?\d+(?:\.\d+)?$|^(?:\-)?\.\d+$/

    @signed_int_rexp = /^(?:\-)?\d$/

    @signed_dec_rexp = /^\.$|^\-\.$/

    @digit = /^\d/

    def setup
      self
    end

    def insert_leading_0(token)
      token =~ /^\-/ ?
        token.sub(/^\-\./, '-0.') :
        token.sub(/^\./, '0.')
    end

    def numeric_rexp
      /#{@signed_int_rexp.source}|#{@signed_dec_rexp}/
    end

    attr_reader :num_rexp, :signed_int_rexp, :signed_dec_rexp, :digit

  end

end
