
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
"=== mlcpp: END ./std/fn/tern.mlp (finally back to std/fn/curry.mlp) =========="

var curry (fn):{
    var - (lhs, rhs):{
        lhs + rhs + -2 * rhs
    }

    var curried _
    curried := (args...):{
        tern($#varargs - len(fn) == 0, fn(args...), {
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

var add (a, b, c):{
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
