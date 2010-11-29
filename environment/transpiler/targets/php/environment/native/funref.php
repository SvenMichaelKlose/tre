// TRE to PHP transpiler
// Copyright (c) 2010 Sven Klose <pixel@copei.de>

class __funref {
	public function __construct ($name, &$ghost)
	{
		$this->n =& $name;
		$this->g =& $ghost;
	}

	public function & getName ()
	{
		return $this->n;
	}

	public function & getGhost ()
	{
		return $this->v;
	}
}
