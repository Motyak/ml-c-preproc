
"=== mlcpp: BEGIN ./std/fn/ArgIterator.mlp ===================================="

"=== mlcpp: BEGIN ./std/fn/LazyList.mlp ======================================="

"=== mlcpp: BEGIN ./std/fn/Pair.mlp ==========================================="

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
"=== mlcpp: END ./std/fn/tern.mlp (back to ./std/fn/Pair.mlp) ================="

var Pair (left, right):{
    var dispatcher (msg_id):{
        tern(msg_id == 0, left, {
            tern(msg_id == 1, right, {
                print("ERR unknown Pair dispatcher msg_id: `" + msg_id + "`")
                exit(1)
            })
        })
    }
    dispatcher
}

var left (pair):{
    pair(0)
}

var right (pair):{
    pair(1)
}
"=== mlcpp: END ./std/fn/Pair.mlp (back to ./std/fn/LazyList.mlp) ============="
"=== mlcpp: BEGIN ./std/fn/Optional.mlp ======================================="



var Optional (some?, val):{
    var none? ():{
        not(some?)
    }

    var some ():{
        some? || {
            print("ERR calling some() on empty Optional")
            exit(1)
        }
        val
    }

    '----------------

    var dispatcher (msg_id):{
        tern(msg_id == 0, none?, {
            tern(msg_id == 1, some, {
                print("ERR unknown Optional dispatcher msg_id: `" + msg_id + "`")
                exit(1)
            })
        })
    }

    dispatcher
}

var none? (opt):{
    opt(0)()
}

var some (opt):{
    opt(1)()
}
"=== mlcpp: END ./std/fn/Optional.mlp (back to ./std/fn/LazyList.mlp) ========="


var LazyList {
    var Pair? (left, right):{
        Optional($true, Pair(left, right))
    }
    var END {
        Optional($false, _)
    }

    var LazyList-1+ _

    var LazyList (xs...):{
        tern($#varargs == 0, END, {
            LazyList-1+(xs...)
        })
    }

    LazyList-1+ := (x, xs...):{
        Pair?(x, LazyList(xs...))
    }

    LazyList
}
"=== mlcpp: END ./std/fn/LazyList.mlp (back to ./std/fn/ArgIterator.mlp) ======"




var ArgIterator (args...):{
    var args LazyList(args...)

    var Arg? (arg):{
        Optional($true, arg)
    }
    var END {
        Optional($false, _)
    }

    var next (peek?):{
        tern(none?(args), END, {
            var res left(some(args))
            peek? || {
                args := right(some(args))
            }
            Arg?(res)
        })
    }

    next
}

var next (iterator):{
    iterator(0)
}
var peek (iterator):{
    iterator(1)
}
"=== mlcpp: END ./std/fn/ArgIterator.mlp (finally back to std/op/sub.mlp) ====="

"=== mlcpp: BEGIN ./std/fn/loops.mlp =========================================="



var while _
while := (cond, do):{
    cond() && {
        do()
        while(cond, do)
    }
}

var until _
until := (cond, do):{
    cond() || {
        do()
        until(cond, do)
    }
}

var do_while _
do_while := (do, cond):{
    do()
    while(cond, do)
}

var do_until _
do_until := (do, cond):{
    do()
    until(cond, do)
}

var foreach (OUT container, fn):{
    var i 1
    var foreach_rec _
    foreach_rec := (OUT container, fn):{
        fn(&container[#i])
        tern(i == len(container), container, {
            i += 1
            foreach_rec(&container, fn)
        })
    }

    tern(len(container) == 0, container, {
        -- we create a local var in case..
        -- ..user has passed by delay rather..
        -- ..than ref (otherwise "lvaluing $nil" error)
        var local_container container
        foreach_rec(&local_container, fn)
        container := local_container
        local_container
    })
}

"=== mlcpp: END ./std/fn/loops.mlp (finally back to std/op/sub.mlp) ==========="


var - {
    var neg (x):{
        x := Int(x)
        x + -2 * x
    }

    var sub (a, b, varargs...):{
        var otherArgs ArgIterator(b, varargs...)

        var lhs a
        var rhs next(otherArgs)
        do_until(():{
            var rhs' some(rhs)
            lhs := lhs + neg(rhs')
            rhs := next(otherArgs)
        }, ():{none?(rhs)})

        lhs
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

'---

-(3, 5)
3 - 5

'---

-(1, 2, 3)
1 - 2 - 3
