$ARRAYS = Array ();
$ARRAYID = 0;

class __array {
    var $id;

	function __construct ($phparray = Array ())
	{
		$this->id = ++$GLOBALS['ARRAYID'];
		$GLOBALS['ARRAYS'][$this->id] = $phparray;
        return $this;
	}

    private function _chk ($i)
    {
        if (is_string ($i) || is_int ($i) || is_float ($i))
            return;
        echo "__array(): invalid index $i";
        debug_print_backtrace ();
    }

    function g ($i)
    {
//        $this->_chk ($i);
		if (isset ($GLOBALS['ARRAYS'][$this->id][$i]))
		    return $GLOBALS['ARRAYS'][$this->id][$i];
        return NULL;
    }

    function a ()
    {
		return $GLOBALS['ARRAYS'][$this->id];
    }

    function s ($i, $v)
    {
//        $this->_chk ($i);
		$GLOBALS['ARRAYS'][$this->id][$i] = $v;
        return $v;
    }

    function p ($v)
    {
		$GLOBALS['ARRAYS'][$this->id][] = $v;
    }

    function r ($i)
    {
//        $this->_chk ($i);
		unset ($GLOBALS['ARRAYS'][$this->id][$i]);
    }

    function keys ()
    {
        $h = NULL;
        foreach ($GLOBALS['ARRAYS'][$this->id] as $k => $v)
            $h = new __cons ($k, $h);
        return $h;
    }

    function length ()
    {
        return count ($GLOBALS['ARRAYS'][$this->id]);
    }

    function __toString ()
    {
        return "tré array object";
    }
}

function tre_phphashHashTable ($x)
{
    $h = new __array ();
    foreach ($x as $k => $v)
        $h->s ($k, $v);
    return $h;
}

function tre_phphashHashkeys ($x)
{
    $h = Array ();
    foreach ($x as $k => $v)
        $h[] = $k;
    return $h;
}
