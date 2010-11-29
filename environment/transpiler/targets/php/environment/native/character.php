// TRE to PHP transpiler
// Copyright (c) 2010 Sven Klose <pixel@copei.de>

class __character {
	public function __construct ($num)
	{
		$this->n =& $num;
	}

	public function & getCode ()
	{
		return $this->n;
	}
}
