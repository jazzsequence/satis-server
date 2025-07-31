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

// Run Satis build
$output = [];
$exitCode = 0;

// Adjust paths as needed
chdir(__DIR__); // or chdir('/srv/satis')
exec('./bin/satis build satis.json web/ 2>&1', $output, $exitCode);

header('Content-Type: text/plain');
echo implode("\n", $output);
http_response_code($exitCode === 0 ? 200 : 500);
