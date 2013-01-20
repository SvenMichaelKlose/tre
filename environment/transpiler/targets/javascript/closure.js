// tré – Copyright (c) 2009–2010,2013 Sven Michael Klose <pixel@copei.de>

function __manualArrayCopy (x)
{
	var a = [];
 	for (var i = 0; i < x.length; i++)
		a[i] = x[i];
	return a;
}

function T37closure (f, g)
{
	var r = function () {
	    var a = __manualArrayCopy (arguments); // XXX no native function for this already?
		a.unshift (g);
		return f.apply (null, a);
	};
	r.treArgs = cdr (f.treArgs); // TRE-ARGS may be obfuscated.
	return r;
}
