function &T37funref_exec ($f, $g)
{
	$a = func_get_args ();
	array_unshift ($a, $g);
	return call_user_func_array ($f, $a);
}

function &T37funref ($f, $g)
{
	$r->treArgs = cdr ($f->treArgs);
	return $r;
}
