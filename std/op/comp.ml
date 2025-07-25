
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
"=== mlcpp: END ./std/fn/tern.mlp (finally back to std/op/comp.mlp) ==========="

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
