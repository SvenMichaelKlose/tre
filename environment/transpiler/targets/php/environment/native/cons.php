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

class __l {
    var $d;

	public function __construct ()
	{
		$this->d = Array ();
        return $this;
	}

    public function g ($i)
    {
//        if (isset ($this->d[$i]))
            return $this->d[$i];
 //       else
  //          error ("no context " . $i);
    }

    public function s ($i, $v)
    {
        $this->d[$i] = $v;
    }

    public function __toString ()
    {
        return $this->d;
    }
}
