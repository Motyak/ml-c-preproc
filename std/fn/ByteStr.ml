
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
"=== mlcpp: END ./std/fn/tern.mlp (finally back to std/fn/ByteStr.mlp) ========"

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

"package main"

var \U000020ac ByteStr(0xE2, 0x82, 0xAC)

print("10,23", \U000020ac)
