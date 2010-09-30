// Copyright (c) 2009-2010 Sven Klose <pixel@copei.de>
function __manualArrayCopy (x)
{
	var a = [];
 	for (var i = 0; i < x.length; i++)
		a[i] = x[i];
	return a;
}
function T37funref (f, g)
{
	var r = function () {
	    var a = __manualArrayCopy (arguments);
		a.unshift (g);
		return f.apply (null, a);
	};
	r.treArgs = cdr (f.treArgs); // TRE-ARGS may be obfuscated.
	return r;
}
