import 'package:flutter_dotenv/flutter_dotenv.dart';

String get baseURL => dotenv.env['BASE_URL'] ?? 'http://localhost:3000';
