
"=== mlcpp: BEGIN ./std/fn/tern.mlp ==========================================="

var tern (cond, if_true, if_false):{
    var res _
    cond && {res := if_true}
    cond || {res := if_false}
    res
}

var !tern (cond, if_false, if_true):{
    tern(cond, if_true, if_false)
}

var not (bool):{
    tern(bool, $false, $true)
}
"=== mlcpp: END ./std/fn/tern.mlp (finally back to std/fn/ascii.mlp) =========="

var ascii (c):{
    Int(Char(c))
}

var lower (OUT c):{
    var >= (lhs, rhs):{
        lhs > rhs || lhs == rhs
    }

    var - (lhs, rhs):{
        lhs + rhs + -2 * rhs
    }

    tern(ascii(c) >= ascii('a), c, {
        var local_c Char(c)
        local_c += ascii('a) - ascii('A)
        c := local_c
        local_c
    })
}

var upper (OUT c):{
    var <= (lhs, rhs):{
        not(lhs > rhs)
    }

    var - (lhs, rhs):{
        lhs + rhs + -2 * rhs
    }

    tern(ascii(c) <= ascii('Z), c, {
        var local_c Char(c)
        local_c -= ascii('a) - ascii('A)
        c := local_c
        local_c
    })
}

"package main"

var char 'f
upper(&char)
print(char)
lower(&char)
print(char)
