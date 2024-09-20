<?php
require 'vendor/autoload.php';

\Stripe\Stripe::setApiKey('sk_test_51PxPNgP0fjL2h56DU6LbRBaWPa4hOkjUEqhY9UEgKQpz9nTyn21fkad5MqAnj0chxk4MF5DjiminXl7ZEKgu3nKO00NKPUNxU7');

header('Content-Type: application/json');

try {
  $paymentIntent = \Stripe\PaymentIntent::create([
    'amount' => 19900, // Amount in cents (e.g., $199.00)
    'currency' => 'usd',
  ]);
  
  echo json_encode([
    'clientSecret' => $paymentIntent->client_secret,
  ]);
} catch (Error $e) {
  http_response_code(500);
  echo json_encode(['error' => $e->getMessage()]);
}
?>
