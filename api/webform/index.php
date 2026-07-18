<html>
<head>
	<title>CI Web Status / Control</title>

	<style type='text/css'>
		table, td, th
		{
			border: 1px solid black;
			border-collapse: collapse;
		}

		td, th
		{
			padding-left: 10px;
			padding-right: 10px;
		}

		tr:nth-child(even)
		{
			background-color: #a0a0a0;
		}

		tr:nth-child(odd)
		{
			background-color: #d0d0d0;
		}
	</style>
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
		<th>Licenses</th>
		<th>Node</th>
	</tr>

<?php
	$txt = `squeue --format="%.13i %25P %.15j %.8T %.10M %30W %R" --noheader`;
	$lines = explode("\n", $txt);

	foreach($lines as $line)
	{
		if(trim($line) == '')
			continue;

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

		$len = 30;
		$licenses = trim(substr($line, $i, $len));
		$i += $len + 1;

		$len = 25;
		$nodes = trim(substr($line, $i, $len));
		$i += $len + 1;

		echo "<tr>\n";
		echo "<td>$jobid</td>\n";
		echo "<td>$partition</td>\n";
		echo "<td>$name</td>\n";
		echo "<td>$state</td>\n";
		echo "<td>$time</td>\n";
		echo "<td>$licenses</td>\n";
		echo "<td>$nodes</td>\n";
		echo "</tr>\n";
	}
?>

</table>

</body>
</html>
