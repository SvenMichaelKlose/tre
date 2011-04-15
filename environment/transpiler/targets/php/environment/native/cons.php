// TRE to PHP transpiler
// Copyright (c) 2010-2011 Sven Klose <pixel@copei.de>

class __cons {
    var $car;
    var $cdr;

	public function __construct ($car, $cdr)
	{
		$this->car = $car;
		$this->cdr = $cdr;
        return $this;
	}

    public function __toString ()
    {
        return "(" . $this->car . "." . $this->cdr . ")";
    }
}
