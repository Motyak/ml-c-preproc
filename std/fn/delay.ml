
var delay (x):{
    var delayed ():{x}
    delayed
}

"package main"

var fncall (a, b):{
    -- eval args
    _ := a
    _ := b
}

var fncall2 (a, b):{
    -- discard args
}

var id (x):{
    print("evaluated: " + x)
    x
}

-- name delay arguments
var a delay(id(123))
var b delay(id('someval))

"arguments get evaluated in the function (if used)"
"fncall(a(), b())"
fncall(a(), b())
"fncall2(a(), b())"
fncall2(a(), b())
