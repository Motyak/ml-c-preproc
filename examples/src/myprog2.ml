"=== mlcpp: BEGIN examples/src/Queue.mlp ======================================"
"=== mlcpp: BEGIN examples/src/List.mlp ======================================="

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

"=== mlcpp: END examples/src/utils.mlp (back to examples/src/List.mlp) ========"
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

"=== mlcpp: END examples/src/List.mlp (back to examples/src/Queue.mlp) ========"


var merge _
merge := (list1, list2):{
    tern(none?(list1), list2, {
        list1 := some(list1)
        Pair?(left(list1), merge(right(list1), list2))
    })
}

var Queue ():{
    var list END

    var front ():{
        none?(list) && {
            print("ERR calling front() on empty Queue")
            exit(1)
        }
        left(some(list))
    }

    var push (x):{
        list := merge(list, Pair?(x, END))
    }

    var pop ():{
        tern(none?(list), {}, {
            list := right(some(list))
        })
    }

    '---------------------

    var dispatcher (msg_id):{
        !tern(msg_id, front, {
            !tern(msg_id + -1, push, {
                !tern(msg_id + -2, pop, {
                    print("ERR invalid msg_id in dispatcher: `" + msg_id + "`")
                    exit(1)
                })
            })
        })
    }

    dispatcher
}

var front (queue):{queue(0)()}
var push (queue, x):{queue(1)(x)}
var pop (queue):{queue(2)()}

"=== mlcpp: END examples/src/Queue.mlp (finally back to examples/src/myprog2.mlp) ==="

var queue Queue()
push(queue, 14)
push(queue, 28)
push(queue, 57)
print(14, front(queue))
pop(queue)
print(28, front(queue))
pop(queue)
print(57, front(queue))
