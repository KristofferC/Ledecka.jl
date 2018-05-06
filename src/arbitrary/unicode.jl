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
