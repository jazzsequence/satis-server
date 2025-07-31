<?php
if ( ! function_exists( 'pantheon_get_secret' ) ) {
    exit;
}

// Check for token
$expectedToken = pantheon_get_secret('satis-token');
if (!isset($_GET['token']) || $_GET['token'] !== $expectedToken) {
    http_response_code(403);
    exit('Forbidden');
}

// Run the build
$output = [];
$exitCode = 0;
exec('./bin/satis build satis.json web/ 2>&1', $output, $exitCode);

// Send a basic HTML page
header('Content-Type: text/html; charset=utf-8');
?>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Satis Build Trigger</title>
</head>
<body>
  <h1>Satis Build <?php echo $exitCode === 0 ? 'Succeeded' : 'Failed'; ?></h1>
  <pre><?php echo htmlspecialchars(implode("\n", $output)); ?></pre>
</body>
</html>
