
"=== mlcpp: BEGIN ./std/fn/Iterator.mlp ======================================="

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
    nth >= 1 || ERR("nth should be greater than zero")

    var LazyList::subscript (ll, nth):{
        var subscript_rec _
        subscript_rec := (ll, nth):{
            tern(nth == 1, left(some(ll)), {
                subscript_rec(right(some(ll)), nth - 1)
            })
        }
        subscript_rec(ll, nth)
    }

    var is_lambda (x):{
        Str(x) == "<lambda>"
    }

    !tern(is_lambda(iterable), iterable[#nth], {
        LazyList::subscript(iterable, nth)
    })
}
"=== mlcpp: END ./std/fn/LazyList.mlp (back to ./std/fn/Iterator.mlp) ========="


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
"=== mlcpp: END ./std/fn/loops.mlp (back to ./std/fn/Iterator.mlp) ============"
"=== mlcpp: BEGIN ./std/fn/curry.mlp =========================================="

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

"=== mlcpp: END ./std/fn/curry.mlp (back to ./std/fn/Iterator.mlp) ============"


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

-- increasing range from "from" up to "to" included
var RangeIterator<= (from, to):{
    var range LazyRange<=(from, to)

    var Number? (n):{
        Optional($true, n)
    }

    var next (peek?):{
        tern(none?(range), END, {
            var res left(some(range))
            peek? || {
                range := right(some(range))
            }
            Number?(res)
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

var foreach (OUT iterable, fn):{
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

    var Iterator::foreach (iterator, fn):{
        var curr next(iterator)
        until(():{none?(curr)}, ():{
            fn(some(curr))
            curr := next(iterator)
        })
    }

    var is_lambda (x):{
        Str(x) == "<lambda>"
    }

    !tern(is_lambda(iterable), foreach(&iterable, fn), {
        Iterator::foreach(iterable, fn)
    })
}

var foreach' {
    var foreach' (fn, container):{
        foreach(container, fn)
    }

    curry(foreach')
}

"=== mlcpp: END ./std/fn/Iterator.mlp (finally back to std/op/sub.mlp) ========"




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
