// tré – Copyright (c) 2013 Sven Michael Klose <pixel@copei.de>

function cpsFuncall ()
{
    var args = Array.prototype.slice.call (arguments);
    var fun = args.shift ();
    if (typeof fun.treCps != "undefined")
        fun.apply (null, args);
    else {
        var continuer = args.shift ();
        continuer.call (fun.apply (null, args));
    }
}
