
"=== mlcpp: BEGIN ./std/fn/Iterator.mlp ======================================="

"=== mlcpp: BEGIN ./std/fn/Stream.mlp ========================================="

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

"=== mlcpp: END ./std/fn/Pair.mlp (back to ./std/fn/Stream.mlp) ==============="
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

"=== mlcpp: END ./std/fn/Optional.mlp (back to ./std/fn/Stream.mlp) ==========="
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

"=== mlcpp: END ./std/fn/curry.mlp (back to ./std/fn/Stream.mlp) =============="


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

"=== mlcpp: END ./std/fn/Stream.mlp (back to ./std/fn/Iterator.mlp) ==========="




var Iterator (subscriptable):{
    var Elem? (val):{
        Optional($true, val)
    }

    var Iterator (container):{
        var nth 1

        var next (peek?):{
            tern(nth > len(container), END, {
                var res container[#nth]
                peek? || {nth += 1}
                Elem?(res)
            })
        }

        next
    }

    var Iterator::fromStream (stream):{
        var next (peek?):{
            tern(none?(stream), END, {
                var res left(some(stream))
                peek? || {
                    stream := right(some(stream))
                }
                Elem?(res)
            })
        }

        next
    }

    var is_lambda (x):{
        Str(x) == "<lambda>"
    }

    !tern(is_lambda(subscriptable), Iterator(subscriptable), {
        Iterator::fromStream(subscriptable)
    })
}

var ArgIterator (args...):{
    var args LazyList(args...)

    var Arg? (arg):{
        Optional($true, arg)
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

"=== mlcpp: END ./std/fn/Iterator.mlp (finally back to std/fn/algorithm.mlp) ==="

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
"=== mlcpp: END ./std/fn/loops.mlp (finally back to std/fn/algorithm.mlp) ====="

var any {
    var any (pred, subscriptable):{
        var it Iterator(subscriptable)
        var any $false
        var curr next(it)
        until(():{any || none?(curr)}, ():{
            tern(pred(some(curr)), {any := $true}, {
                curr := next(it)
            })
        })
        any
    }
    curry(any)
}

var all {
    var all (pred, subscriptable):{
        var it Iterator(subscriptable)
        var any $false
        var curr next(it)
        until(():{any || none?(curr)}, ():{
            !tern(pred(some(curr)), {any := $true}, {
                curr := next(it)
            })
        })
        not(any)
    }
    curry(all)
}

"package main"

var |> (input, fn):{
    fn(input)
}

var .. LazyRange<=

var is_even (n):{
    var in (elem, container):{
        var i 1
        var found $false
        until(():{found || i > len(container)}, ():{
            found ||= container[#i] == elem
            i += 1
        })
        found
    }
    Str(Int(n))[#-1] in "02468"
}

var id (x):{
    print("evaluated: " + x)
    x
}

"=== testing any ==="
[1, 3] |> any(is_even) |> stdout
-- short circuit
LazyList(1, 2, id(3)) |> any(is_even) |> stdout

"=== testing all ==="
[2, 4, 6] |> all(is_even) |> stdout
-- short circuit
LazyList(2, 5, id(6)) |> all(is_even) |> stdout
