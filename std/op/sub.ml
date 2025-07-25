
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
"=== mlcpp: END ./std/fn/tern.mlp (finally back to std/op/sub.mlp) ============"

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

"package main"

-(3)
-(3, 5)

3 - 5
1 - 2 - 3

-- this doesn't work
-- -(1, 2, 3)
