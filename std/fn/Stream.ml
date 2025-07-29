
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

"=== mlcpp: END ./std/fn/Pair.mlp (finally back to std/fn/Stream.mlp) ========="
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

"=== mlcpp: END ./std/fn/Optional.mlp (finally back to std/fn/Stream.mlp) ====="
"=== mlcpp: BEGIN ./std/fn/curry.mlp =========================================="



-- useful for variadic functions
var curry_fixed (fixedParams, fn):{
    var - (lhs, rhs):{
        lhs + rhs + -2 * rhs
    }

    var >= (lhs, rhs):{
        lhs > rhs || lhs == rhs
    }

    var remaining {
        tern(fixedParams > len(fn), fixedParams, {
            len(fn) - fixedParams
        })
    }

    var curried _
    curried := (args...):{
        tern($#varargs - len(fn) >= remaining, fn(args...), {
            (args2...):{curried(args..., args2...)}
        })
    }
    curried
}

var curry (fn):{
    curry_fixed(len(fn), fn)
}

var stdout {
    curry_fixed(1, print)
}

"=== mlcpp: END ./std/fn/curry.mlp (finally back to std/fn/Stream.mlp) ========"


var Pair? (left, right):{
    Optional($true, Pair(left, right))
}
var END {
    Optional($false, _)
}

var LazyList {
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

-- increasing range from "from" up to "to" included
var LazyRange<= _
LazyRange<= := (from, to):{
    from := Int(from)
    to := Int(to)
    tern(from > to, END, {
        Pair?(from, LazyRange<=(from + 1, to))
    })
}

var subscript (subscriptable, nth):{
    nth == 0 && ERR("nth should differ from zero (less or greater)")
    var - (lhs, rhs):{
        lhs + rhs + -2 * rhs
    }

    var Stream::subscript (stream, nth):{
        nth > 0 || ERR("nth should be greater than zero")
        var subscript_rec _
        subscript_rec := (stream, nth):{
            tern(nth == 1, left(some(stream)), {
                subscript_rec(right(some(stream)), nth - 1)
            })
        }
        subscript_rec(stream, nth)
    }

    var is_lambda (x):{
        Str(x) == "<lambda>"
    }

    !tern(is_lambda(subscriptable), subscriptable[#nth], {
        Stream::subscript(subscriptable, nth)
    })
}

var subscript' {
    curry(subscript)
}

"package main"

"=== testing subscript on a LazyList ==="

var id (x):{
    print("evaluated: " + x)
    x
}

var stream LazyList(1, id(2), 3)

"we don't need to eval #2 to eval #3"
print(subscript(stream, 3))

"#2 gets evaluated here"
print(subscript(stream, 2))

"once an element has been evaluated once, it's not re-evaluated"
print(subscript(stream, 2))
