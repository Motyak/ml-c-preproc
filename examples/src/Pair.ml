
"=== mlcpp: BEGIN examples/src/utils.mlp ======================================"


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

var * {
    var * _

    * := (lhs, rhs):{
        !tern(rhs, 0, {
            !tern(rhs + -1, lhs, {
                lhs + *(lhs, rhs + -1)
            })
        })
    }

    *
}

var - (n):{
    n + -2 * n
}

var -len (n):{
    -(len(n))
}

var curry (fn):{
    var curried _

    curried := (args...):{
        !tern($#varargs + -len(fn), fn(args...), {
            (args2...):{curried(args..., args2...)}
        })
    }

    curried
}

var |> (input, fn):{
    fn(input)
}

"=== mlcpp: END examples/src/utils.mlp (finally back to examples/src/Pair.mlp) ==="


var Pair (left, right):{
    (selector):{selector(left, right)}
}

var left (pair):{
    pair((left, right):{left})
}

var right (pair):{
    pair((left, right):{right})
}

"package main"

print("Pair.mlp")
