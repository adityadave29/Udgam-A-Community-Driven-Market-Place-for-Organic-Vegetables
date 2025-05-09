import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static final String supabaseUrl = dotenv.env["SUPABASE_URL"]!;
  static final String supabaseKey = dotenv.env["SUPABASE_KEY"]!;
  static final String s3Bucket = dotenv.env["S3_BUCKET"]!;
  static final String elevenlabs = dotenv.env["ELEVENLAB_API_KEY"]!;
  static final String did = dotenv.env["DID_API_KEY"]!;
  static final String newsData = dotenv.env["NEWS_DATA_API_KEY"]!;
  static final String news = dotenv.env["NEWS_API_KEY"]!;
  static final String upiid = dotenv.env["UPI_ID"]!;
}
