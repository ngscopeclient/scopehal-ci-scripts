<?php
/**
	@file
	@author Andrew D. Zonenberg
	@brief	Web hook called by GitHub when a new push comes in
 */

//Get the secret that GitHub will use to HMAC authenticate the webhook delivery
$secret = trim(file_get_contents('/home/ci/github-webhook-secret'));

//Get the signature sent by GitHub
$headers = getallheaders();
$sig = $headers['X-Hub-Signature-256'];

//Log file for webhook debugging
$log = fopen('/tmp/webhook.log', 'w');

//Verify the signature
$rawbody = file_get_contents('php://input');
$expectedSig = hash_hmac('sha256', $rawbody, $secret);
if(!hash_equals('sha256=' . $expectedSig, $sig))
{
	fwrite($log, "Signature check failure!\n");
	fwrite($log, "Hook signature: $auth\n");
	fwrite($log, "Calculated signature: $sig\n");
	http_response_code(401);
	echo 'Unauthorized';
	fclose($log);
	exit(0);
}
fprintf($log, "Signature is valid\n");

//The incoming request is a JSON blob, parse it to get out the stuff we really care about (the branch and commit hash)
//For now, ignore everything else and assume it's a push to scopehal-apps
//(because that's the only hook we have configured)
$json = json_decode($rawbody, true);
if(!$json)
{
	fwrite($log, 'json decode failed\n');
	fwrite($log, $rawbody);
	http_response_code(500);
	echo 'Internal error';
	fclose($log);
	exit(0);
}
$ref = $json['ref'];
$after = $json['after'];

//We now have what should be a branch name and hash
//Sanitize them to make sure there's nothing nasty.
$branch = str_replace('refs/heads/', '', $ref);

//Make sure branch name is purely alphanumeric and doesn't start with a dash
if(!preg_match('#^[a-zA-Z0-9][a-zA-Z0-9\-]*$#', $branch))
{
	fwrite($log, "Malformed branch name $branch\n");
	fwrite($log, $rawbody);
	http_response_code(500);
	echo "Internal error";
	fclose($log);
	exit(0);
}

//Make sure hash is purely lowercase hex characters
if(!preg_match('#^[a-f0-9]+$#', $after))
{
	fwrite($log, "Malformed commit hash $after\n");
	fwrite($log, $rawbody);
	http_response_code(500);
	echo "Internal error";
	fclose($log);
	exit(0);
}

//Launch the actual builds as the "ci" user
//Put config in the environment so we have named variables to work with rather than positional arguments
putenv("BRANCH=$branch");
putenv("COMMIT=$after");
$launchlog = shell_exec('sudo -i --user=ci /home/ci/scopehal-ci-scripts/batch-launcher.sh');

fwrite($log, "\nSubmit log\n");
fwrite($log, $launchlog);

//Clean up
fclose($log);
?>
