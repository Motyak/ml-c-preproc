
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
"=== mlcpp: END ./std/cond.mlp (finally back to std/Pair.mlp) ================="
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
"=== mlcpp: END ./std/loops.mlp (finally back to std/Pair.mlp) ================"

var Pair (left, right):{
    var selector (id):{
        tern(id == 0, left, {
            tern(id == 1, right, {
                print("ERR unknown Pair selector id: `" + id + "`")
                exit(1)
            })
        })
    }
    selector
}

var left (pair):{
    pair(0)
}

var right (pair):{
    pair(1)
}

"package main"

print("Pair.mlp")
