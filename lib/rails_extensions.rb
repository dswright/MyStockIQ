class Float

	def to_sig_figs(sig_fig)
	    number = self
	    int = number.floor
	    fract = number - int
	    if fract.round(sig_fig) == 0
	      return int
	    else 
	      return number.round(sig_fig)
	    end 
	end


end