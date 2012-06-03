# Copyright (c) 2012 Sven Michael Klose <pixel@copei.de>

function tre_backtrace ($msg)
{
    header ("HTTP/1.0 404 Not Found");
    header ("Status: 404 Not Found");
    echo "<html><body>$msg<pre>";
    debug_print_backtrace ();
    echo "</pre></body></html>";
    die ();
}

function tre_error_handler ($errno, $errstr, $file, $line, $context)
{
    tre_backtrace ("<b>$errstr</b> in file <b>$file</b> on line <b>$line</b>");
}

set_error_handler ('tre_error_handler');
