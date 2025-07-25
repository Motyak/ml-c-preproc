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

"=== mlcpp: BEGIN ./std/op/comp.mlp ==========================================="



var <> (a, b, varargs...):{
    not(==(a, b, varargs...))
}

var <= (a, b, varargs...):{
    not(>(a, b, varargs...))
}

var < (a, b, varargs...):{
    tern(==(a, b, varargs...), $false, {
        tern(>(a, b, varargs...), $false, {
            $true
        })
    })
}

var >= (a, b, varargs...):{
    tern(==(a, b, varargs...), $true, {
        tern(>(a, b, varargs...), $true, {
            $false
        })
    })
}
"=== mlcpp: END ./std/op/comp.mlp (finally back to std/*.mlp) ================="
"=== mlcpp: BEGIN ./std/op/sub.mlp ============================================"



var - {
    var neg (x):{
        x + -2 * x
    }

    var sub (lhs, rhs):{
        lhs + neg(rhs)
    }

    var - (x, xs...):{
        tern($#varargs == 0, neg(x), {
            sub(x, xs...)
        })
    }

    -
}

"=== mlcpp: END ./std/op/sub.mlp (finally back to std/*.mlp) =================="
"=== mlcpp: BEGIN ./std/fn/loops.mlp =========================================="



var while _
while := (cond, do):{
    cond() && {
        do()
        while(cond, do)
    }
}

var until (cond, do):{
    while(():{not(cond())}, do)
}

var do_while _
do_while := (do, cond):{
    do()
    cond() && do_while(do, cond)
}

var do_until (do, cond):{
    do_while(do, cond)
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

"=== mlcpp: BEGIN ./std/fn/-len.mlp ==========================================="



var -len (container):{
    -(len(container))
}
"=== mlcpp: END ./std/fn/-len.mlp (finally back to std/*.mlp) ================="
"=== mlcpp: BEGIN ./std/fn/curry.mlp =========================================="



var curry (fn):{
    var curried _
    curried := (args...):{
        !tern($#varargs + -len(fn), fn(args...), {
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
