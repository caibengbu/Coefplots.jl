"""
    DISABLE_ESCAPE = false

Automatic escaping of the variables names. Disable escaping by calling `disable_escape!()`. Enable escaping by calling `enable_escape!()`.
"""
DISABLE_ESCAPE = false

function enable_escape!()
    global DISABLE_ESCAPE = false
end

function disable_escape!()
    global DISABLE_ESCAPE = true
end

"""
    _escape_string(str::AbstractString[, esc]; keep = ())::AbstractString
    _escape_string(io, str::AbstractString[, esc]; keep = ())::Nothing
    
Almost the same as the Base.escape_string except that _escape_string escapes `,` , `(`, `)`, and `.` by putting it in a pair of brackets.
"""
function _escape_string(io::IO, s::AbstractString, esc=""; keep = ())
    a = Iterators.Stateful(s)
    for c::AbstractChar in a
        if c in esc
            print(io, '\\', c)
        elseif c in keep
            print(io, c)
        elseif isascii(c)
            c == ','           ? print(io, "{,}") : # escape comma as {,}
            c == '('           ? print(io, "{(}") : # escape parenthesis
            c == ')'           ? print(io, "{)}") : # escape parenthesis
            c == '.'           ? print(io, "{.}") : # escape point
            c == '\0'          ? print(io, escape_nul(peek(a)::Union{AbstractChar,Nothing})) :
            c == '\e'          ? print(io, "\\e") :
            c == '\\'          ? print(io, "\\\\") :
            '\a' <= c <= '\r'  ? print(io, '\\', "abtnvfr"[Int(c)-6]) :
            isprint(c)         ? print(io, c) :
                                 print(io, "\\x", string(UInt32(c), base = 16, pad = 2))
        elseif !isoverlong(c) && !ismalformed(c)
            isprint(c)         ? print(io, c) :
            c <= '\x7f'        ? print(io, "\\x", string(UInt32(c), base = 16, pad = 2)) :
            c <= '\uffff'      ? print(io, "\\u", string(UInt32(c), base = 16, pad = need_full_hex(peek(a)::Union{AbstractChar,Nothing}) ? 4 : 2)) :
                                 print(io, "\\U", string(UInt32(c), base = 16, pad = need_full_hex(peek(a)::Union{AbstractChar,Nothing}) ? 8 : 4))
        else # malformed or overlong
            u = bswap(reinterpret(UInt32, c)::UInt32)
            while true
                print(io, "\\x", string(u % UInt8, base = 16, pad = 2))
                (u >>= 8) == 0 && break
            end
        end
    end
end

_escape_string(s::AbstractString, esc=('\"',); keep = ()) =
    sprint((io)->_escape_string(io, s, esc; keep = keep), sizehint=lastindex(s))


"""
    latex_escape(s::AbstractString)

Escapes `,`, `(`, `)`, and `.` by putting it in a pair of brackets, also esxapes `&` and `%` by adding `\\`
"""
latex_escape(s::AbstractString) = DISABLE_ESCAPE ? s : _escape_string(s,"&%"; keep='\\')