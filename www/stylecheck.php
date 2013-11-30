<!DOCTYPE HTML >


<head>  
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<link rel="stylesheet" type="text/css" href="checkstyle.css" />

<script src="jquery.js"></script> 
<script>
    function save()
    {
      var note = document.getElementById('codeblock').innerHTML;
      note = note.replace(/<\/[^>]*>/g, '');
      note = note.replace(/<div>/g, '');
      note = note.replace(/<br>/g, '\n');
      /* replaces some html entities */
      note = note.replace(/&nbsp;/g, ' ');
      note = note.replace(/&amp;/g, '&');
      note = note.replace(/&lt;/g, '<');
      note = note.replace(/&gt;/g, '>');
      document.getElementById('saveButton').setAttribute(
        'href',
        'data:Content-type: text/plain, ' + escape(note)
      );
    }
</script>
<title> Style Checker Uploader</title>
</head>


<body>

<h2> C Style checker Local edition </h2>
<div>
<?php require("line_sort.php"); ?>
<?php

$linefix = new line_sort();

copy($_FILES['upload']['tmp_name'], $_FILES['upload']['name']);
$tmp = file_get_contents($_FILES['upload']['name']);
/*$output = shell_exec('cp ./testcode/analyse.c test.c 2>&1');*/
$count = count(explode(PHP_EOL, $tmp));
$execute = sprintf("sh scruffy.sh %s 2>&1", $_FILES['upload']['name']);
//echo "<pre>$output<pre>";
$output = shell_exec($execute);

$lines = explode(PHP_EOL, $output);
foreach($lines as $line)
{
    if (preg_match("/^[0-9]/i", $line)) 
    {
        $linefix->set_index(substr($line, 0, strspn($line, "0123456789")));
        $linefix->add_line_num($line);
    }
    else if (preg_match("/^indent.*/i", $line))
    {
		$indent_num = preg_replace('/^[^\.]+\.c:/i', '', $line);
		$indent_num = substr($indent_num, 0, strspn($indent_num, "0123456789"));
		$linefix->set_index($indent_num);
		$linefix->add_line_num($indent_num. ":\n" );
		$linefix->add_code(preg_replace('/^[^\:]*\:[^\:]*\:[^\:]*:/i', '', $line));
	}
	else
        $linefix->add_code($line);
}
$linefix->print_code();

?>
</div>
<div class = "skinny">
<?php for ($i = 1; $i < $count; $i++)
		echo $i . ":<br/>\n";
?>
</div>
<div class="printoff">

<pre id = "codeblock" contenteditable>
<?php echo $tmp; ?>
</pre>
<a id="saveButton" target="" download=<?php echo "\"". $_FILES['upload']['name'] ."\""; ?> href="#" onclick="save();">Save file changes</a>
</div>
</body>

</html>


