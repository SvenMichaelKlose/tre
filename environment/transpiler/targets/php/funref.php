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

// All symbols are stored in this array for reuse.
$SYMBOLS = Array ();

class _tresym {
	public function __construct ($name, &$pkg)
	{
		$this->n =& $name;
		$this->v = NULL;
		$this->f = NULL;
		$this->p =& $pkg;
	}

	public function & setName ($x)
	{
		return $this->n = $x;
	}

	public function & getName ()
	{
		return $this->n;
	}

	public function & setValue ($x)
	{
		return $this->v = $x;
	}

	public function & getValue ()
	{
		return $this->v;
	}

	public function & setFunction ($x)
	{
		return $this->f = $x;
	}

	public function & getFunction ()
	{
		return $this->f;
	}
}

// Symbol constructor
//
// It has a function field but that isn't used yet.
function & T37symbol ($name, &$pkg)
{
	return new _tresym ($name, $pkg);
}

// Find symbol by name or create a new one.
//
// Wraps the 'new'-operator.
// XXX rename to %QUOTE ?
function & compiled_symbol ($name, $pkg)
{
	if ($name == "NIL" && !$pkg)
		return NULL;
	$tab =& $SYMBOLS[$pkg];
	if (!$tab) {
		$tab = Array ();
		$SYMBOLS[$pkg] =& $tab;
	}
	$s =& $tab[$name];
	if (!$s) {
		$s =& T37symbol ($name, $pkg);
		$tab[$name] = $s;
	}
	return $s;
}

function & compiled_T37T37usetfSymbolFunction ($v, $x)
{
	return $x->setFunction ($v);
}
