// TRE to PHP transpiler
// Copyright (c) 2010-2011 Sven Klose <pixel@copei.de>

class __l {
    var $d;

	public function __construct ()
	{
		$this->d = Array ();
        return $this;
	}

    public function g ($i)
    {
            return $this->d[$i];
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
