// tré – Copyright (c) 2010–2013,2016 Sven Michael Klose <pixel@copei.de>

$CONSID = 0;

class __cons {
    var $id;
    var $a;
    var $d;
    var $p;

	public function __construct ($car, $cdr)
	{
        $this->id = ++$GLOBALS['CONSID'];
		$this->a = $car;
		$this->d = $cdr;
		$this->p = NULL;
        return $this;
	}

    public function __toString ()
    {
        return '(' . $this->a () . ' . ' . $this->d () . ')';
    }
}
