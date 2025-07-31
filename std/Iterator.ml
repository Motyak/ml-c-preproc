
"=== mlcpp: BEGIN ./std/cond.mlp =============================================="

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
"=== mlcpp: END ./std/cond.mlp (finally back to std/Iterator.mlp) ============="
"=== mlcpp: BEGIN ./std/loops.mlp ============================================="



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
"=== mlcpp: END ./std/loops.mlp (finally back to std/Iterator.mlp) ============"

"=== mlcpp: BEGIN ./std/Pair.mlp =============================================="




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

"=== mlcpp: END ./std/Pair.mlp (finally back to std/Iterator.mlp) ============="
"=== mlcpp: BEGIN ./std/Optional.mlp =========================================="






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

"=== mlcpp: END ./std/Optional.mlp (finally back to std/Iterator.mlp) ========="
"=== mlcpp: BEGIN ./std/Stream.mlp ============================================"







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
var LazyRange<= (from, to):{
    "accepts as input Int, Char or Str"
    var str? (x):{
        len(Str(x + 0)) > len(Str(x))
    }
    var charInputs? {
        var charInputs? str?(from) && len(from) == 1
        charInputs? &&= str?(to) && len(to) == 1
        charInputs?
    }
    from := tern(charInputs?, Char, Int)(from)
    to := tern(charInputs?, Char, Int)(to)

    var LazyRange<= _
    LazyRange<= := (from, to):{
        tern(from > to, END, {
            Pair?(from, LazyRange<=(from + 1, to))
        })
    }

    LazyRange<=(from, to)
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

    var lambda? (x):{
        var < (lhs, rhs):{
            not(lhs > rhs || lhs == rhs)
        }
        Str(x) == "<lambda>" && len(x) < 8
    }

    !tern(lambda?(subscriptable), subscriptable[#nth], {
        Stream::subscript(subscriptable, nth)
    })
}

"=== mlcpp: END ./std/Stream.mlp (finally back to std/Iterator.mlp) ==========="

var Iterator (subscriptable):{
    var Iterator (container):{
        var nth 1
        var next (peek?):{
            tern(nth > len(container), END, {
                var res container[#nth]
                peek? || {nth += 1}
                Optional($true, res)
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
                Optional($true, res)
            })
        }
        next
    }

    var lambda? (x):{
        var < (lhs, rhs):{
            not(lhs > rhs || lhs == rhs)
        }
        Str(x) == "<lambda>" && len(x) < 8
    }

    !tern(lambda?(subscriptable), Iterator(subscriptable), {
        Iterator::fromStream(subscriptable)
    })
}

var ArgIterator (args...):{
    Iterator(LazyList(args...))
}

var next (iterator):{
    iterator(0)
}
var peek (iterator):{
    iterator(1)
}

"package main"

print("Iterator.mlp")
