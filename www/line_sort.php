<?php

/**
 * @date     17 Nov 2013 
 * @name     Bruce Dearing
 * @purpose  Sorts line numbers of input from scruffy.sh.
 * @params 
 * @methods 
 */
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

    /**
     * @name - set_index
     * @purpose - sets the index of the outside array.
     * @param - line_num - the line number to set the index.
     */
    public function set_index($line_num)
    {
        $this->outer_index = intval($line_num);
        $this->max = intval($line_num) > $this->max ? intval($line_num) : $this->max; 
    }

    /**
     * @name - add_line_num
     * @purpose - adds line number code line to the array. 
     * @param line_num - the line number to add to the array.
     */
    public function add_line_num($line_num)
    {
        $this->line_num_array[$this->outer_index][] = $line_num;
    }
    
    /**
     * @name - add_code
     * @purpose - adds code to the array. 
     * @param code - the code to add to the array.
     */
    public function add_code($code)
    {
        $this->line_num_array[$this->outer_index][] = $code;
    }

    /**
     * @name - print_code
     * @purpose - prints code in each line of the array.
     */
    public function print_code()
    {
        if ($this->max === 0)
        {
            echo "<div class=\"block\">";
            echo "<pre> No errors found in ";
            echo $_FILES['upload']['name'] . "</pre>";
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
                        {
                            echo "<pre style=\" color:red \">";
                            echo "<strong>$num</strong></pre>\n";
                        }
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
