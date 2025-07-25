
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
"=== mlcpp: BEGIN ./std/op/sub.mlp ============================================"



var - {
    var neg (x):{
        x + -2 * x
    }

    var sub (lhs, rhs):{
        lhs + neg(rhs)
    }

    var - (x, xs...):{
        tern($#varargs == 0, neg(x), {
            sub(x, xs...)
        })
    }

    -
}

"=== mlcpp: END ./std/op/sub.mlp (finally back to std/fn/ascii.mlp) ==========="

var ascii (c):{
    Int(Char(c))
}

var lower (OUT c):{
    tern(ascii(c) >= ascii('a), c, {
        var local_c c
        local_c := Char(local_c) + (ascii('a) - ascii('A))
        local_c
    })
}

var upper (OUT c):{
    tern(ascii(c) <= ascii('Z), c, {
        var local_c c
        local_c := Char(local_c) - (ascii('a) - ascii('A))
        local_c
    })
}
