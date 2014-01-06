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

var CPSSTEPT63 = 0;
var INCPSLOOPT61 = false;
var CPSNEXT = null;
var CPSNEXTARGS = null;

function cpsLoop ()
{
    var old = INCPSLOOPT61;
    INCPSLOOPT61 = true;
    while (CPSNEXT) {
      var next = CPSNEXT;
      CPSNEXT = null;
      next.apply (null, CPSNEXTARGS);
    }
    INCPSLOOPT61 = old;
}
    
function T37cpsStep ()
{
    var args = Array.prototype.slice.call (arguments);
    if (CPSSTEPT63) {
        var next = args.shift ();
        next.apply (null, args);
    } else {
        CPSNEXT = args.shift ();
        CPSNEXTARGS = args;
        if (!INCPSLOOPT61)
            cpsLoop ();
    }
}
