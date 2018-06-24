# You know that feel when you could have written this code
# at a higher abstraction to make it more elegant but you 
# didn't and you really should? ... that's a feel I'm feeling.
function Ledecka.arbitrary(::Type{String})
    function arg(size, rng) 
        string_size = choose(Integer, 0:240)(size, rng)
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

