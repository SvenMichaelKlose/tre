// TRE to PHP transpiler
// Copyright (c) 2010-2011 Sven Klose <pixel@copei.de>

class __symbol {
	public function __construct ($name, &$pkg)
	{
        global $NULL;
		$this->n =& $name;
		$this->v =& $NULL;
		$this->f =& $NULL;
		$this->p =& $pkg;
	}

	public function & setName (&$x)
	{
		return $this->n =& $x;
	}

	public function & getName ()
	{
		return $this->n;
	}

	public function & setValue (&$x)
	{
		return $this->v =& $x;
	}

	public function & getValue ()
	{
		return $this->v;
	}

	public function & setFunction (&$x)
	{
		return $this->f =& $x;
	}

	public function & getFunction ()
	{
		return $this->f;
	}
}

$KEYWORDPACKAGE = new __symbol ("", __w(NULL));
