<!DOCTYPE HTML >

    
<head>  
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />

<title> Style Checker Uploader</title>
</head>     
<body>

<h2> C Style checker [ local edition ] </h2>

<p>
This site applies the C style checker to verify that a C source file conforms to COMP 2103 style conventions.
</p>
<p>
Bear in mind that the <strong> C style checker</strong> does not
identify all style errors it is your responsibility to follow
the style conventions.
</p>
<p>
To submit a source file for style checking,
</p>
<ol>
  <li>
    Click <strong>Browse...</strong> 
    and select the file.
  </li>
  <li>
    Click <strong>Submit</strong>.
  </li>
</ol>

<?php

Print "<form action=\"stylecheck.php\" method=\"post\""; 
Print "enctype=\"multipart/form-data\">";
Print "<div><label id=\"upload\">Select file to upload: "; 
Print "<input type=\"file\" id=\"upload\" name=\"upload\"/></label></div>";
Print "<div>"; 
Print "<input type=\"hidden\" name=\"action\" value=\"upload\"/>";
Print "<input type=\"submit\" value=\"Submit\"/>";
Print "</div>";
Print "</form>";

?>

</body>

</html>

