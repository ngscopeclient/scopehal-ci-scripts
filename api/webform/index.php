<html>
<head>
	<title>CI Web Status / Control</title>
</head>
<body>

<h1>CI Status</h1>

<table>
	<tr>
		<th>Job ID</th>
		<th>Partition</th>
		<th>Name</th>
		<th>State</th>
		<th>Time</th>
	</tr>

<?php
	$txt = `squeue --format="%.13i %25P %.15j %.8T %.10M %30W %R" --noheader`
	$lines = explode("\n", $txt);

	foreach($lines as $line)
	{
		$i = 0;
		$len = 13;
		$jobid = trim(substr($line, $i, $len));
		$i += $len + 1;

		$len = 25;
		$partition = trim(substr($line, $i, $len));
		$i += $len + 1;

		$len = 15;
		$name = trim(substr($line, $i, $len));
		$i += $len + 1;

		$len = 8;
		$state = trim(substr($line, $i, $len));
		$i += $len + 1;

		$len = 10;
		$time = trim(substr($line, $i, $len));
		$i += $len + 1;

		echo "<tr>\n";
		echo "<td>$jobid</td>\n";
		echo "<td>$partition</td>\n";
		echo "<td>$name</td>\n";
		echo "<td>$state</td>\n";
		echo "<td>$time</td>\n";
		echo "</tr>\n";
	}
?>

</table>

</body>
</html>
