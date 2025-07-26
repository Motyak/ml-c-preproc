
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
"=== mlcpp: END ./std/fn/tern.mlp (finally back to std/fn/loops.mlp) =========="

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

"package main"

```
    testing foreach fn
```

var list "0123456789" + "ABCDEF"
-- var list [0 .. 9, 'A .. 'F] |> join("")

_ := foreach(list, (d1):{
    foreach(list, (d2):{
        print("0x" + d1 + d2)
    })
})
