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

$satisPath = 'satis.json';

// Create /files/uploads/composer/cache directory if it doesn't exist
$cacheDir = '/files/uploads/composer/cache';
if (!is_dir($cacheDir)) {
    if (!mkdir($cacheDir, 0755, true) && !is_dir($cacheDir)) {
        http_response_code(500);
        exit('Failed to create cache directory');
    }
}
putenv("COMPOSER_CACHE_DIR=$cacheDir");

$githubToken = pantheon_get_secret('github-token');
if ($githubToken) {
    $config = file_get_contents($satisPath);
    $config = str_replace('GITHUB_TOKEN', $githubToken, $config);
    file_put_contents('/tmp/satis.json', $config);
    $satisPath = '/tmp/satis.json';
} else {
    http_response_code(500);
    exit('GitHub token not set');
}

// Run the build
$output = [];
$exitCode = 0;
exec("./bin/satis build $satisPath web/ 2>&1", $output, $exitCode);

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
