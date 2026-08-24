import 'dart:math';

import 'package:flutter/material.dart';

/// Format paisa as Indian rupees with two decimal places.
String formatCurrency(int paisa) {
  return '₹${(paisa / 100).toStringAsFixed(2)}';
}

String formatCurrencySigned(int paisa) {
  final sign = paisa >= 0 ? '+' : '-';
  return '$sign₹${(paisa.abs() / 100).toStringAsFixed(2)}';
}

String formatPercentage(double value) {
  final sign = value >= 0 ? '+' : '';
  return '$sign${value.toStringAsFixed(2)}%';
}

Color profitColor(BuildContext context, num value) {
  return value >= 0 ? Colors.green : Colors.red;
}
