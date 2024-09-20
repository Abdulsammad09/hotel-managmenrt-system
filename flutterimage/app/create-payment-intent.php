<?php
require '../vendor/autoload.php';

\Stripe\Stripe::setApiKey('sk_test_51PxPNgP0fjL2h56DU6LbRBaWPa4hOkjUEqhY9UEgKQpz9nTyn21fkad5MqAnj0chxk4MF5DjiminXl7ZEKgu3nKO00NKPUNxU7');  // Replace with your Stripe Secret Key

header('Content-Type: application/json');

$input = file_get_contents('php://input');
$data = json_decode($input, true);

$amount = $data['amount'];  // Amount in dollars (or your preferred currency unit)
$currency = $data['currency'];  // Currency (e.g., USD)

try {
  // Create a PaymentIntent
  $paymentIntent = \Stripe\PaymentIntent::create([
    'amount' => $amount * 100,  // Convert amount to cents (for USD)
    'currency' => $currency,
  ]);

  $response = [
    'client_secret' => $paymentIntent->client_secret,
  ];

  echo json_encode($response);
} catch (Exception $e) {
  http_response_code(500);
  echo json_encode(['error' => $e->getMessage()]);
}
