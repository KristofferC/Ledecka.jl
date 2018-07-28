function empty_biased_choice(::Type{X},range) where X
    function emc(size, rng)
        empty_probability = 0.02
        if arbitrary(Float32)(size,rng) < empty_probability
            0 
        else 
          choose(X, range)(size,rng)
        end
    end
end

function Ledecka.arbitrary(::Type{Char})
    function arb(size, rng)
        attempts = 1000;
        for i in 0:attempts
            char_index = arbitrary(UInt32)(size, rng)
            try
            ch = Char(char_index)
            if isvalid(ch)
                return ch
            end
            catch e 
            end
        end
        # We didn't find a char in 1000 tries? 
        # Press F to pay respects. 
        return Char('F')
    end
    arb
end





Ledecka.arbitrary(::Type{AbstractString}) = Ledecka.arbitrary(String)
# You know that feel when you could have written this code
# at a higher abstraction to make it more elegant but you 
# didn't and you really should? ... that's a feel I'm feeling.
function Ledecka.arbitrary(::Type{String})
    function arg(size, rng) 
        string_size = empty_biased_choice(Integer, 0:240)(size, rng)
        s = "" 
        if string_size == 0 
            return s
        end
        return String(join([Char(x) for x in rand(rng,0x0020:0x007F, string_size)], ""))
    end
    arg
end

function Ledecka.shrink(s::String) 
    function shr(size, rng)
        if s == ""
            return s
        end
        
        len = length(s) 
        shrink_size = choose(Integer, 0:Integer(floor(len/2)))(size,rng)
        smaller_value = arbitrary(String)(shrink_size, rng)
        smaller_value[1:shrink_size]
    end
    shr
end

