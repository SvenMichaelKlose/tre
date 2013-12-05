// tré – Copyright (c) 2013 Sven Michael Klose <pixel@copei.de>

function cpsIdentity (x)
{
}

function cpsMethodcall ()
{
    var args = Array.prototype.slice.call (arguments);
    var obj = args.shift ();
    var fun = args.shift ();
    if (typeof fun._cpsTransformedT63 != "undefined")
        fun.apply (obj, args);
    else {
        var continuer = args.shift ();
        continuer.call (null, fun.apply (obj, args));
    }
}
