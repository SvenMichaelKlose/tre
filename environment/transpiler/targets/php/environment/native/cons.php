// TRE to PHP transpiler
// Copyright (c) 2010 Sven Klose <pixel@copei.de>

class __cons {
	public function __construct (&$car, &$cdr)
	{
		$this->car =& $car;
		$this->cdr =& $cdr;
	}
}
