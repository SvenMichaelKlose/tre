// tré - Copyright (c) 2010-2012 Sven Michael Klose <pixel@copei.de>

$CARS = Array ();
$CDRS = Array ();
$CONSID = 0;

class __cons {
    var $id;

	public function __construct ($car, $cdr)
	{
        $this->id = ++$GLOBALS['CONSID'];
		$GLOBALS['CARS'][$this->id] = $car;
		$GLOBALS['CDRS'][$this->id] = $cdr;
        return $this;
	}

    public function a ()
    {
		return $GLOBALS['CARS'][$this->id];
	}

    public function d ()
    {
		return $GLOBALS['CDRS'][$this->id];
	}

    public function sa ($x)
    {
		return $GLOBALS['CARS'][$this->id] = $x;
	}

    public function sd ($x)
    {
		return $GLOBALS['CDRS'][$this->id] = $x;
	}

    public function __toString ()
    {
        return '(' . $this->a () . ' . ' . $this->d () . ')';
    }
}
