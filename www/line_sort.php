<?php

class Line_sort
{
    private $line_num_array = array(array());
    private $max;
    private $outer_index;
    private $code_index;
    function __construct()
    {
        $this->max = 0;
        $this->outer_index = 0;
        $this->code_index = 0;
    }


    public function set_index($line_num)
    {
        $this->outer_index = intval($line_num);
        $this->max = intval($line_num) > $this->max ? intval($line_num) : $this->max; 
    }

    public function add_line_num($line_num)
    {
        $this->line_num_array[$this->outer_index][] = $line_num;
    }

    public function add_code($code)
    {
        $this->line_num_array[$this->outer_index][] = $code;
    }

    public function print_code()
    {
        if ($this->max === 0)
        {
            echo "<div class=\"block\">";
            echo "<pre> No errors found in " . $_FILES['upload']['name'] . "</pre>";
            echo "</div>";

        }
        else
        {
            for ($i=0; $i<= $this->max; $i++) 
            {
                if (!empty($this->line_num_array[$i]))
                {
                    echo "<div class=\"block\">";
                    foreach ($this->line_num_array[$i] as $num)
                    {
                        if (preg_match("/^\s+\^/i", $num))
                            echo "<pre style=\" color:red \"><strong>$num</strong></pre>\n";
                        else if (preg_match("/^\s*$/i", $num))
                            echo $num. "\n";
                        else
                            echo "<pre>$num</pre>\n";
                    }
                    echo "</div>";
                }
            }
        } 
    }

}


?>
