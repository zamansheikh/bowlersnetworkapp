import 'package:flutter/material.dart';

import 'app.dart';
import 'bootstrap.dart';

void main() async {
  await bootstrap();
  runApp(const BowlersNetworkApp());
}
