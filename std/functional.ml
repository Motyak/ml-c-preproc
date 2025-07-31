
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
"=== mlcpp: END ./std/cond.mlp (finally back to std/functional.mlp) ==========="
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
"=== mlcpp: END ./std/loops.mlp (finally back to std/functional.mlp) =========="

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

"=== mlcpp: END ./std/Pair.mlp (finally back to std/functional.mlp) ==========="
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

"=== mlcpp: END ./std/Optional.mlp (finally back to std/functional.mlp) ======="
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

"=== mlcpp: END ./std/Stream.mlp (finally back to std/functional.mlp) ========="

"=== mlcpp: BEGIN ./std/Iterator.mlp =========================================="
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

"=== mlcpp: END ./std/Iterator.mlp (finally back to std/functional.mlp) ======="
"=== mlcpp: BEGIN ./std/op.mlp ================================================"
var .. LazyRange<=

var |> (input, fn):{
    fn(input)
}

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

    var lambda? (x):{
        Str(x) == "<lambda>" && len(x) < 8
    }

    !tern(lambda?(subscriptable), in(elem, subscriptable), {
        Stream::in(elem, subscriptable)
    })
}

var !in (elem, subscriptable):{
    not(in(elem, subscriptable))
}

"=== mlcpp: END ./std/op.mlp (finally back to std/functional.mlp) ============="

```
    basically, make a function "pipe-able"..
    ..(with parentheses)

    e.g.: `x |> print()` normally doesn't work
    same for `str |> map(upper)`
    unless they are augmented by curry.
```
var curry_fixed (fixedParams, fn):{
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

var stdout print

var subscript' {
    curry(subscript)
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

    var lambda? (x):{
        Str(x) == "<lambda>" && len(x) < 8
    }

    !tern(lambda?(subscriptable), foreach(&subscriptable, fn), {
        Stream::foreach(subscriptable, fn)
    })
}

var foreach' {
    var foreach' (fn, container):{
        foreach(container, fn)
    }
    curry(foreach')
}

var map {
    var delay (x):{
        var delayed ():{x}
        delayed
    }

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

        var lambda? (x):{
            Str(x) == "<lambda>" && len(x) < 8
        }

        !tern(lambda?(subscriptable), map(fn, subscriptable), {
            Stream::map(fn, subscriptable)
        })
    }


    curry(map)
}

var filter {
    var delay (x):{
        var delayed ():{x}
        delayed
    }

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

        var lambda? (x):{
            Str(x) == "<lambda>" && len(x) < 8
        }

        !tern(lambda?(subscriptable), filter(pred, subscriptable), {
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

var split {
    var split (sep, str):{
        var res []
        var curr ""
        foreach(str, (c):{
            !tern(c == sep, {curr += c}, {
                res += [curr]
                curr := ""
            })
        })
        len(curr) > 0 && {res += [curr]}
        res
    }
    curry(split)
}

var join {
    var join (sep, container):{
        var res ""
        var first_it $true
        foreach(container, (str):{
            first_it || {res += sep}
            res += str
            first_it := $false
        })
        res
    }
    curry(join)
}

"package main"

"=== testing foreach ==="

var id (x):{
    print("evaluated: " + x)
    x
}

{
    var str "fds"
    var list [1, 2, 3]
    var stream LazyList(1, id(2), 3)

    foreach(&str, (OUT c):{c := 'x})
    print(str)
    var newstr foreach(str, (OUT c):{c := 'y})
    print(str)
    print(newstr)

    foreach(&list, (OUT n):{n := 0})
    print(list)
    var newlist foreach(list, (OUT n):{n := 7})
    print(list)
    print(newlist)

    foreach(stream, (x):{print(x)})
    stream |> foreach'((x):{print(x)})
}

"test curryable foreach"

{
    var ascii (c):{
        Int(Char(c))
    }

    var upper (OUT c):{
        c := Char(c) - (ascii('a) - ascii('A))
    }

    var str "fds"

    print(str |> foreach'(upper))
}

"=== testing filter/reduce on LazyRange ==="

var ERR (msg):{
    print("ERR: " + msg)
    exit(1)
}

var ascii (c):{
    Int(Char(c))
}

var sumOfDigits (n):{
    var <= (a, b):{
        not(a > b)
    }

    n := Str(n)
    var res 0
    foreach(n, (c):{
        ascii('0) <= c && c <= ascii('9) || ERR("not a number")
        res += ascii(c) - ascii('0)
    })
    res
}

-- mod 10 not equal zero
var %10<>0 (n):{
    Str(n)[#-1] <> '0
}

var predicate (n):{
    %10<>0(n) && sumOfDigits(n) < 10
}

var fn (n):{
    n * 11 * 999
}

var seq LazyRange<=(1, 90)
-- foreach(seq, print)

seq := seq |> filter(predicate)
-- foreach(seq, print)

seq := seq |> map(fn)
-- foreach(seq, print)

"=== testing map/filter ==="

{
    var seq [1, 2, 3, 4, 5]
    seq := seq |> map((n):{2 * n})
    seq := seq |> filter((n):{n > 4})
    _ := seq |> foreach'(curry_fixed(1, print))
}

{
    var seq 1 .. 10
    seq := seq |> map((n):{2 * n})
    seq := seq |> filter((n):{n > 4})
    _ := seq |> foreach'(curry_fixed(1, print))
}

"=== testing reduce ==="

reduce(+, 0, [1, 2, 3]) |> stdout
reduce(+, 'T, "ommy") |> stdout

1 .. 5 |> reduce(+, 0) |> stdout

var ab'cd'ef [14, 28, 57]
var abc'def [142, 857]

print('ab'cd'ef, ab'cd'ef, ab'cd'ef |> reduce(+, 0))
print('abc'def, abc'def, abc'def |> reduce(+, 0))

var range2str (range):{
    reduce(+, "", range)
}
['0 .. '9, 'a .. 'z] |> map(range2str) |> reduce(+, "") |> stdout

"=== testing split/join ==="

var upper (OUT c):{
    var ascii (c):{
        Int(Char(c))
    }
    tern(ascii(c) <= ascii('Z), c, {
        var local_c Char(c)
        local_c -= ascii('a) - ascii('A)
        c := local_c
        local_c
    })
}

"hello" |> map(upper) |> stdout
"fds" |> join(",") |> stdout
[1, 2, 3] |> join(" ") |> stdout

"abc fds 123" |> split(" ") |> stdout

"f,d,s" |> split(",") |> map(upper) |> join("_") |> stdout
