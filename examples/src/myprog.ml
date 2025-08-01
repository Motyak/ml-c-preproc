"=== mlcpp: BEGIN examples/src/ListIterator.mlp ==============================="

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

"=== mlcpp: END examples/src/utils.mlp (back to examples/src/ListIterator.mlp) ==="
"=== mlcpp: BEGIN examples/src/List.mlp ======================================="


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

"=== mlcpp: END examples/src/Pair.mlp (back to examples/src/List.mlp) ========="
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

"=== mlcpp: END examples/src/Optional.mlp (back to examples/src/List.mlp) ====="


var Pair? (left, right):{
    Optional($true, Pair(left, right))
}
var END {
    Optional($false, _)
}

var List {
    var List-1+ _

    var List (xs...):{
        !tern($#varargs, END, {
            List-1+(xs...)
        })
    }

    List-1+ := (x, xs...):{
        Pair?(x, List(xs...))
    }

    List
}

var subscript {
    var err ():{
        print("ERR not enough elements")
        exit(1)
    }

    var subscript _
    subscript := (list, nth):{
        tern(none?(list), err(), {
            var list some(list)
            !tern(nth + -1, left(list), {
                subscript(right(list), nth + -1)
            })
        })
    }

    subscript
}

var foreach {
    var foreach _

    foreach := (list, do):{
        none?(list) || {
            do(left(some(list)))
            foreach(right(some(list)), do)
        }
    }

    (foreach)
}

var size (list):{
    var count 0
    foreach(list, (_):{count += 1})
    count
}

"=== mlcpp: END examples/src/List.mlp (back to examples/src/ListIterator.mlp) ==="


var ListIterator (list):{
    var cur-pos 1

    var advance ():{
        var res subscript(list, cur-pos)
        cur-pos += 1
        res
    }

    var peek ():{
        subscript(list, cur-pos)
    }

    '----------------

    var dispatcher (msg_id):{
        !tern(msg_id, advance, {
            !tern(msg_id + -1, peek, {
                print("ERR invalid msg_id in dispatcher: `" + msg_id + "`")
                exit(1)
            })
        })
    }

    dispatcher
}

var advance {
    var advance (list-it):{
        list-it(0)()
    }
    curry(advance)
}

var peek {
    var peek (list-it):{
        list-it(1)()
    }
    curry(peek)
}

"=== mlcpp: END examples/src/ListIterator.mlp (finally back to examples/src/myprog.mlp) ==="

var list List(3, 141, 59, 26)

{
    var it ListIterator(list)
    var first advance(it)
    print('first3, first)
    var peeked peek(it)
    print('peeked141, peeked)
    var second advance(it)
    print('second141, second)
    var list-len size(list)
    print('list-len4, list-len)
}

{
    var new-it ListIterator(list)
    var first advance(new-it)
    print('first3, first)
}

```
    using pipe to simulate "method call" syntax
```
{
    var new-it ListIterator(list)
    var first new-it |> advance()
    print('first3, first)
}
