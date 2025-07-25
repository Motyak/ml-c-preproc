
"=== mlcpp: BEGIN ./std/fn/-len.mlp ==========================================="

"=== mlcpp: BEGIN ./std/op/sub.mlp ============================================"

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
"=== mlcpp: END ./std/fn/tern.mlp (back to ./std/op/sub.mlp) =================="

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

"=== mlcpp: END ./std/op/sub.mlp (back to ./std/fn/-len.mlp) =================="

var -len (container):{
    -(len(container))
}
"=== mlcpp: END ./std/fn/-len.mlp (finally back to std/fn/curry.mlp) =========="

var curry (fn):{
    var curried _
    curried := (args...):{
        !tern($#varargs + -len(fn), fn(args...), {
            (args2...):{curried(args..., args2...)}
        })
    }
    curried
}

var stdout {
    curry((x):{
        print(x)
    })
}

"package main"

"===curried_add example==="

let add (a, b, c):{
    a + b + c
}

var curried_add curry(add)
curried_add(1)(2)(3)
curried_add(1, 2)(3)
curried_add(1)(2, 3)
curried_add(1, 2, 3)

"===pipe op and stdout==="

var |> (input, fn):{
    fn(input)
}

123 |> stdout
123 |> stdout()
stdout |> stdout()
