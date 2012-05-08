// tré - Copyright (c) 2012 Sven Michael Klose <pixel@copei.de>

$ARRAYS = Array ();
$ARRAYID = 0;

class __array {
    var $id;

	public function __construct ($phparray = Array ())
	{
		$this->id = ++$GLOBALS['ARRAYID'];
		$GLOBALS['ARRAYS'][$this->id] = $phparray;
        return $this;
	}

    public function g ($i)
    {
		return $GLOBALS['ARRAYS'][$this->id][$i];
    }

    public function a ($i)
    {
		return $GLOBALS['ARRAYS'][$this->id];
    }

    public function s ($i, $v)
    {
		$GLOBALS['ARRAYS'][$this->id][$i] = $v;
        return $v;
    }

    public function p ($v)
    {
		$GLOBALS['ARRAYS'][$this->id][] = $v;
    }

    public function r ($i)
    {
		unset ($GLOBALS['ARRAYS'][$this->id][$i]);
    }

    public function __toString ()
    {
        return "array";
    }
}
