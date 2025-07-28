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
"=== mlcpp: END ./std/fn/tern.mlp (finally back to std/*.mlp) ================="
"=== mlcpp: BEGIN ./std/op/pipe.mlp ==========================================="

var |> (input, fn):{
    fn(input)
}
"=== mlcpp: END ./std/op/pipe.mlp (finally back to std/*.mlp) ================="
"=== mlcpp: BEGIN ./std/fn/delay.mlp =========================================="

var delay (x):{
    var delayed ():{x}
    delayed
}

"=== mlcpp: END ./std/fn/delay.mlp (finally back to std/*.mlp) ================"

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

"=== mlcpp: END ./std/fn/curry.mlp (finally back to std/*.mlp) ================"
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
"=== mlcpp: END ./std/fn/loops.mlp (finally back to std/*.mlp) ================"
"=== mlcpp: BEGIN ./std/fn/ascii.mlp =========================================="



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

"=== mlcpp: END ./std/fn/ascii.mlp (finally back to std/*.mlp) ================"
"=== mlcpp: BEGIN ./std/fn/ByteStr.mlp ========================================"



var ByteStr {
    var ByteStr-1+ _

    var ByteStr (xs...):{
        !tern($#varargs, "", {
            ByteStr-1+(xs...)
        })
    }

    ByteStr-1+ := (x, xs...):{
        Char(x) + ByteStr(xs...)
    }

    ByteStr
}

"=== mlcpp: END ./std/fn/ByteStr.mlp (finally back to std/*.mlp) =============="
"=== mlcpp: BEGIN ./std/fn/Pair.mlp ==========================================="



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

"=== mlcpp: END ./std/fn/Pair.mlp (finally back to std/*.mlp) ================="
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

"=== mlcpp: END ./std/fn/Optional.mlp (finally back to std/*.mlp) ============="

"=== mlcpp: BEGIN ./std/fn/Stream.mlp ========================================="





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
    tern(from > to, END, {
        Pair?(from, LazyRange<=(from + 1, to))
    })
}

var subscript (subscriptable, nth):{
    var - (lhs, rhs):{
        lhs + rhs + -2 * rhs
    }

    nth > 0 || ERR("nth should be greater than zero")

    var Stream::subscript (stream, nth):{
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

"=== mlcpp: END ./std/fn/Stream.mlp (finally back to std/*.mlp) ==============="

"=== mlcpp: BEGIN ./std/fn/functional.mlp ====================================="






-- var foreach (OUT subscriptable, fn):{
    var foreach (OUT container, fn):{
        tern(len(container) == 0, container, {
            -- we create a local var in case..
            -- ..user has passed by delay rather..
            -- ..than ref (otherwise "lvaluing $nil" error)
            var container' container

            var nth 1
            until(():{nth > len(container)}, ():{
                fn(&container'[#nth])
                nth += 1
            })

            container := container'
            container'
        })
    }

    var Stream::foreach _
    Stream::foreach := (stream, fn):{
        tern(none?(stream), END, {
            fn(left(some(stream)))
            Stream::foreach(right(some(stream)), fn)
        })
    }

    var is_lambda (x):{
        Str(x) == "<lambda>"
    }

    !tern(is_lambda(subscriptable), foreach(&subscriptable, fn), {
        Stream::foreach(&subscriptable, fn)
    })
}

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

    var Stream::foreach _
    Stream::foreach := (stream, fn):{
        tern(none?(stream), END, {
            fn(left(some(stream)))
            Stream::foreach(right(some(stream)), fn)
        })
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

"=== mlcpp: END ./std/fn/functional.mlp (finally back to std/*.mlp) ==========="
"=== mlcpp: BEGIN ./std/fn/Iterator.mlp ======================================="






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

"=== mlcpp: END ./std/fn/Iterator.mlp (finally back to std/*.mlp) ============="

"=== mlcpp: BEGIN ./std/op/in.mlp ============================================="





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
            found ||= elem == some(curr)
            curr := next(it)
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

"=== mlcpp: END ./std/op/in.mlp (finally back to std/*.mlp) ==================="
"=== mlcpp: BEGIN ./std/op/cmp.mlp ============================================"






var <> (a, b, varargs...):{
    not(==(a, b, varargs...))
}

var < (a, b, varargs...):{
    var otherArgs ArgIterator(b, varargs...)

    var ge $false
    var lhs a
    var rhs next(otherArgs)
    do_until(():{
        var rhs' some(rhs)
        tern(lhs > rhs' || lhs == rhs', {ge := $true}, {
            lhs := rhs'
            rhs := next(otherArgs)
        })
    }, ():{ge || none?(rhs)})

    not(ge)
}

var <= (a, b, varargs...):{
    var otherArgs ArgIterator(b, varargs...)

    var gt $false
    var lhs a
    var rhs next(otherArgs)
    do_until(():{
        var rhs' some(rhs)
        !tern(lhs > rhs' || lhs == rhs', {gt := $true}, {
            lhs := rhs'
            rhs := next(otherArgs)
        })
    }, ():{gt || none?(rhs)})

    not(gt)
}

var >= (a, b, varargs...):{
    var otherArgs ArgIterator(b, varargs...)

    var lt $false
    var lhs a
    var rhs next(otherArgs)
    do_until(():{
        var rhs' some(rhs)
        !tern(lhs > rhs' || lhs == rhs', {lt := $true}, {
            lhs := rhs'
            rhs := next(otherArgs)
        })
    }, ():{lt || none?(rhs)})

    not(lt)
}

"=== mlcpp: END ./std/op/cmp.mlp (finally back to std/*.mlp) =================="
"=== mlcpp: BEGIN ./std/op/sub.mlp ============================================"






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

"=== mlcpp: END ./std/op/sub.mlp (finally back to std/*.mlp) =================="
