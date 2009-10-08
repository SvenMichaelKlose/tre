<?php

function T37funref ($f, $g)
{
	$r = function () {
		$a = func_get_args ();
		array_unshift ($a, $g);
		return call_user_func_array ($f, $a);
	};
	$r.treArgs = cdr ($f.treArgs);
	return $r;
}
