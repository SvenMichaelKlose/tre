// TRE to PHP transpiler
// Copyright (c) 2010 Sven Klose <pixel@copei.de>

class __cons {
	public function __construct (&$car, &$cdr)
	{
		$this->car =& $car;
		$this->cdr =& $cdr;
	}

	public function & setCar (&$car)
	{
		$this->car =& $car;
		return $car;
	}

	public function & setCdr (&$cdr)
	{
		$this->cdr =& $cdr;
		return $cdr;
	}

	public function & getCar ()
	{
		return $this->car;
	}

	public function & getCdr ()
	{
		return $this->car;
	}
}
