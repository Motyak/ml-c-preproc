
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

"=== mlcpp: END ./std/fn/Iterator.mlp (finally back to std/op/in.mlp) ========="
"=== mlcpp: BEGIN ./std/fn/functional.mlp ====================================="


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
"=== mlcpp: END ./std/fn/loops.mlp (back to ./std/fn/functional.mlp) =========="

"=== mlcpp: BEGIN ./std/fn/delay.mlp =========================================="

var delay (x):{
    var delayed ():{x}
    delayed
}

"=== mlcpp: END ./std/fn/delay.mlp (back to ./std/fn/functional.mlp) =========="

var foreach (OUT subscriptable, fn):{
    var foreach (OUT container, fn):{
        tern(len(container) == 0, container, {
            var nth 1
            until(():{nth > len(container)}, ():{
                fn(&container[#nth])
                nth += 1
            })
            container
        })
    }

    var Stream::foreach (stream, fn):{
        var foreach_rec _
        foreach_rec := (stream, fn):{
            tern(none?(stream), END, {
                fn(left(some(stream)))
                foreach_rec(right(some(stream)), fn)
            })
        }
        foreach_rec(stream, fn)
        stream
    }

    var is_lambda (x):{
        Str(x) == "<lambda>"
    }

    !tern(is_lambda(subscriptable), foreach(&subscriptable, fn), {
        Stream::foreach(&subscriptable, fn)
    })
}

var foreach' {
    var foreach' (fn, container):{
        foreach(container, fn)
    }

    curry(foreach')
}

var map {
    var map (fn, subscriptable):{
        var map (fn, container):{
            var res container
            foreach(1 .. len(res), (nth):{
                res[#nth] := fn(res[#nth])
            })
            res
        }

        var Stream::map _
        Stream::map := (fn, stream):{
            tern(none?(stream), END, {
                var curr fn(left(some(stream)))
                var next delay(Stream::map(fn, right(some(stream))))
                Pair?(curr, next())
            })
        }

        var is_lambda (x):{
            Str(x) == "<lambda>"
        }

        !tern(is_lambda(subscriptable), map(fn, subscriptable), {
            Stream::map(fn, subscriptable)
        })
    }


    curry(map)
}

var filter {
    var filter (pred, subscriptable):{
        var filter (pred, container):{
            var is_list (x):{
                var str Str(x)
                len(str) > 0 && str[#1] == "[" && str[#-1] == "]"
            }

            var res tern(is_list(container), [], "")
            foreach(1 .. len(container), (nth):{
                pred(container[#nth]) && {
                    is_list(container) && {res += [container[#nth]]}
                    is_list(container) || {res += container[#nth]}
                }
            })
            res
        }

        var Stream::filter _
        Stream::filter := (pred, stream):{
            tern(none?(stream), END, {
                var curr left(some(stream))
                var next delay(Stream::filter(pred, right(some(stream))))
                !tern(pred(curr), next(), {
                    Pair?(curr, next())
                })
            })
        }

        var is_lambda (x):{
            Str(x) == "<lambda>"
        }

        !tern(is_lambda(subscriptable), filter(pred, subscriptable), {
            Stream::filter(pred, subscriptable)
        })
    }

    curry(filter)
}

var reduce {
    var reduce (fn, acc, subscriptable):{
        foreach(subscriptable, (curr):{
            acc := fn(acc, curr)
        })
        acc
    }
    curry(reduce)
}

var min (a, b, others...):{
    var < (lhs, rhs):{
        not(lhs > rhs || lhs == rhs)
    }
    var min (lhs, rhs):{
        tern(lhs < rhs, lhs, rhs)
    }
    reduce(min, a, List(b, others...))
}

var count {
    var count (pred, subscriptable):{
        var fn (lhs, rhs):{
            tern(pred(rhs), lhs + 1, lhs)
        }
        reduce(fn, 0, subscriptable)
    }
    curry(count)
}

var min' {
    var min' (subscriptable):{
        var < (lhs, rhs):{
            not(lhs > rhs || lhs == rhs)
        }
        var min2 (lhs, rhs):{
            tern(lhs < rhs, lhs, rhs)
        }
        var min (container):{
            tern(len(container) == 0, ERR("empty container"), {
                tern(len(container) == 1, container[#1], {
                    reduce(min2, container[#1], container[#2..-1])
                })
            })
        }
        var Stream::min (stream):{
            tern(none?(stream), ERR("empty stream"), {
                reduce(min2, left(some(stream)), right(some(stream)))
            })
        }

        var is_lambda (x):{
            Str(x) == "<lambda>"
        }

        !tern(is_lambda(subscriptable), min(subscriptable), {
            Stream::min(subscriptable)
        })
    }
    curry(min')
}

var max (a, b, others...):{
    var max (lhs, rhs):{
        tern(lhs > rhs, lhs, rhs)
    }
    reduce(max, a, List(b, others...))
}

var max' {
    var max' (subscriptable):{
        var max2 (lhs, rhs):{
            tern(lhs > rhs, lhs, rhs)
        }
        var max (container):{
            tern(len(container) == 0, ERR("empty container"), {
                tern(len(container) == 1, container[#1], {
                    reduce(max2, container[#1], container[#2..-1])
                })
            })
        }
        var Stream::max (stream):{
            tern(none?(stream), ERR("empty stream"), {
                reduce(max2, left(some(stream)), right(some(stream)))
            })
        }

        var is_lambda (x):{
            Str(x) == "<lambda>"
        }

        !tern(is_lambda(subscriptable), max(subscriptable), {
            Stream::max(subscriptable)
        })
    }
    curry(max')
}

"=== mlcpp: END ./std/fn/functional.mlp (finally back to std/op/in.mlp) ======="



var in (elem, subscriptable):{
    var in (elem, container):{
        var i 1
        var found $false
        until(():{found || i > len(container)}, ():{
            found ||= container[#i] == elem
            i += 1
        })
        found
    }

    var Stream::in (elem, stream):{
        var it Iterator(stream)
        var found $false
        var curr next(it)
        until(():{found || none?(curr)}, ():{
            tern(elem == some(curr), {found := $true}, {
                curr := next(it)
            })
        })
        found
    }

    var is_lambda (x):{
        Str(x) == "<lambda>"
    }

    !tern(is_lambda(subscriptable), in(elem, subscriptable), {
        Stream::in(elem, subscriptable)
    })
}

"package main"

var |> (input, fn):{
    fn(input)
}

"g" in "sdf"
"d" in "sdf"

var .. LazyRange<=

foreach(1 .. 10, (i):{
    print("wow amazing, curr val is: " + i)
})

7 in 1 .. 10 |> stdout
11 in 1 .. 10 |> stdout
