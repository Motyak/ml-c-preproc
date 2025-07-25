
"=== mlcpp: BEGIN examples/src/utils.mlp ======================================"


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

var * {
    var * _

    * := (lhs, rhs):{
        !tern(rhs, 0, {
            !tern(rhs + -1, lhs, {
                lhs + *(lhs, rhs + -1)
            })
        })
    }

    *
}

var - (n):{
    n + -2 * n
}

var -len (n):{
    -(len(n))
}

var curry (fn):{
    var curried _

    curried := (args...):{
        !tern($#varargs + -len(fn), fn(args...), {
            (args2...):{curried(args..., args2...)}
        })
    }

    curried
}

var |> (input, fn):{
    fn(input)
}

"=== mlcpp: END examples/src/utils.mlp (finally back to examples/src/Stream.mlp) ==="
"=== mlcpp: BEGIN examples/src/Pair.mlp ======================================="




var Pair (left, right):{
    (selector):{selector(left, right)}
}

var left (pair):{
    pair((left, right):{left})
}

var right (pair):{
    pair((left, right):{right})
}

"=== mlcpp: END examples/src/Pair.mlp (finally back to examples/src/Stream.mlp) ==="
"=== mlcpp: BEGIN examples/src/Optional.mlp ==================================="




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
        !tern(msg_id, none?, {
            !tern(msg_id + -1, some, {
                print("ERR invalid msg_id in dispatcher: `" + msg_id + "`")
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

"=== mlcpp: END examples/src/Optional.mlp (finally back to examples/src/Stream.mlp) ==="


var Pair? (left, right):{
    Optional($true, Pair(left, right))
}
var END {
    Optional($false, _)
}

var Stream Pair?

var stream-filter {
    var stream-filter _

    stream-filter := (pred, stream):{
        tern(none?(stream), END, {
            var stream some(stream)
            !tern(pred(left(stream)), stream-filter(pred, right(stream)), {
                Stream(left(stream), stream-filter(pred, right(stream)))
            })
        })
    }

    stream-filter
}

var subscript {
    var err ():{
        print("ERR not enough elements")
        exit(1)
    }

    var subscript _
    subscript := (stream, nth):{
        tern(none?(stream), err(), {
            var stream some(stream)
            !tern(nth + -1, left(stream), {
                subscript(right(stream), nth + -1)
            })
        })
    }

    subscript
}

"package main"

print("Stream.mlp")
