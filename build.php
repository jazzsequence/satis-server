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
if (!$githubToken) {
    http_response_code(500);
    exit('GitHub token not set');
}
$dirs = ['include', 'p2', 'dist'];
foreach ($dirs as $dir) {
    if (!is_dir($dir)) {
        mkdir($dir, 0775, true);
    }
}

foreach (['.', 'include', 'p2'] as $path) {
    echo "$path writable: " . (is_writable($path) ? 'yes' : 'no') . "<br>";
}

$config = file_get_contents($satisPath);
$config = str_replace('GITHUB_TOKEN', $githubToken, $config);
$satisPath = '/tmp/satis.json';
// Check if we can actually put contents into a file. If we can't, we need to bail because the site needs to be in SFTP mode.
$bytesWritten = @file_put_contents($satisPath, $config);
if ($bytesWritten === false) {
    http_response_code(500);
    echo '<h1>Build Failed: Cannot write to /tmp</h1>';
    echo '<p>This environment may be in read-only Git mode. Satis cannot build in this context. Please switch to SFTP mode in the Pantheon dashboard.</p>';
    exit;
}

// Run the build
$output = [];
$exitCode = 0;
exec("./bin/satis build $satisPath . 2>&1", $output, $exitCode);

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
