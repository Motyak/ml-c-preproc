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

"=== mlcpp: END ./std/fn/loops.mlp (finally back to std/*.mlp) ================"

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
"=== mlcpp: BEGIN ./std/fn/LazyList.mlp ======================================="





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
"=== mlcpp: END ./std/fn/LazyList.mlp (finally back to std/*.mlp) ============="
"=== mlcpp: BEGIN ./std/fn/ArgIterator.mlp ===================================="






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
"=== mlcpp: END ./std/fn/ArgIterator.mlp (finally back to std/*.mlp) =========="

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
"=== mlcpp: BEGIN ./std/op/in.mlp ============================================="



var in (elem, container):{
    var i 1
    var found $false
    until(():{found || i > len(container)}, ():{
        found ||= container[#i] == elem
        i += 1
    })
    found
}

"=== mlcpp: END ./std/op/in.mlp (finally back to std/*.mlp) ==================="
"=== mlcpp: BEGIN ./std/op/pipe.mlp ==========================================="

var |> (input, fn):{
    fn(input)
}
"=== mlcpp: END ./std/op/pipe.mlp (finally back to std/*.mlp) ================="

"=== mlcpp: BEGIN ./std/fn/curry.mlp =========================================="



var curry (fn):{
    var curried _
    curried := (args...):{
        !tern($#varargs - len(fn), fn(args...), {
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

"=== mlcpp: END ./std/fn/curry.mlp (finally back to std/*.mlp) ================"
"=== mlcpp: BEGIN ./std/fn/delay.mlp =========================================="

var delay (x):{
    var delayed ():{x}
    delayed
}

"=== mlcpp: END ./std/fn/delay.mlp (finally back to std/*.mlp) ================"

"=== mlcpp: BEGIN ./std/fn/ascii.mlp =========================================="




var ascii (c):{
    Int(Char(c))
}

var lower (OUT c):{
    tern(ascii(c) >= ascii('a), c, {
        var local_c c
        local_c := Char(local_c) + (ascii('a) - ascii('A))
        local_c
    })
}

var upper (OUT c):{
    tern(ascii(c) <= ascii('Z), c, {
        var local_c c
        local_c := Char(local_c) - (ascii('a) - ascii('A))
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
