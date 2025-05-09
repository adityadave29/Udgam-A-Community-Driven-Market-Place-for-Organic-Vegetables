import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:udgaam/models/news_model.dart';
import 'package:udgaam/utils/env.dart';

class NewsController {
  Future<NewsModel> FetchNews() async {
    String url =
        "https://newsapi.org/v2/everything?q=agriculture&apiKey=${Env.news}";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return NewsModel.fromJson(body);
    }

    throw Exception('Error');
  }
}
