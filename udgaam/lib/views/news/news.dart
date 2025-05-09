import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:translator/translator.dart';
import 'package:udgaam/models/news_model.dart';
import 'package:udgaam/utils/env.dart';

class NewsFetcher extends StatefulWidget {
  const NewsFetcher({super.key});

  @override
  State<NewsFetcher> createState() => _NewsFetcherState();
}

class _NewsFetcherState extends State<NewsFetcher> {
  List<NewsModel> newsList = [];
  bool isLoading = true;
  String errorMessage = '';
  final translator = GoogleTranslator();

  Future<void> fetchNews() async {
    final url = Uri.parse(
        "https://newsapi.org/v2/everything?q=agriculture&apiKey=${Env.news}");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> articles = data['articles'];
        setState(() {
          newsList = articles.map((json) => NewsModel.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "Error: ${response.statusCode} - ${response.body}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Exception occurred: $e";
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchNews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("News"), centerTitle: true),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : ListView.builder(
                  itemCount: newsList.length,
                  padding: EdgeInsets.all(8),
                  itemBuilder: (context, index) {
                    return NewsCard(
                        news: newsList[index], translator: translator);
                  },
                ),
    );
  }
}

class NewsCard extends StatefulWidget {
  final NewsModel news;
  final GoogleTranslator translator;

  const NewsCard({super.key, required this.news, required this.translator});

  @override
  _NewsCardState createState() => _NewsCardState();
}

class _NewsCardState extends State<NewsCard> {
  bool isHindi = false;
  String translatedTitle = '';
  String translatedText = '';
  final FlutterTts flutterTts = FlutterTts();
  bool isPlaying = false;

  void translateNews() async {
    if (!isHindi) {
      final titleTranslation = await widget.translator
          .translate(widget.news.title ?? "No Title", to: 'hi');
      final descriptionTranslation = await widget.translator.translate(
          widget.news.description ?? "No description available",
          to: 'hi');
      setState(() {
        translatedTitle = titleTranslation.text;
        translatedText = descriptionTranslation.text;
        isHindi = true;
      });
    } else {
      setState(() {
        isHindi = false;
      });
    }
  }

  void toggleSpeech() async {
    if (isPlaying) {
      await flutterTts.stop();
    } else {
      String textToSpeak = isHindi
          ? "${translatedTitle.isNotEmpty ? translatedTitle : "No Title"}. ${translatedText.isNotEmpty ? translatedText : "No Description Available"}"
          : "${widget.news.title ?? "No Title"}. ${widget.news.description ?? "No Description Available"}";
      await flutterTts.setLanguage(isHindi ? "hi-IN" : "en-US");
      await flutterTts.setPitch(1.0);
      await flutterTts.speak(textToSpeak);
    }
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: widget.news.urlToImage != null
                  ? Image.network(widget.news.urlToImage!,
                      width: double.infinity, height: 180, fit: BoxFit.cover)
                  : Container(
                      height: 180,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: Icon(Icons.image_not_supported, size: 50)),
            ),
            SizedBox(height: 10),
            Text(
              isHindi
                  ? (translatedTitle.isNotEmpty
                      ? translatedTitle
                      : "Translating...")
                  : widget.news.title ?? "No Title",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Divider(thickness: 1, color: Colors.grey),
            Text(
              isHindi
                  ? (translatedText.isNotEmpty
                      ? translatedText
                      : "Translating...")
                  : widget.news.description ?? "No Description Available",
              style: TextStyle(fontSize: 15),
              textAlign: TextAlign.left,
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                    onPressed: translateNews,
                    child: Text(isHindi ? "English" : "Hindi")),
                IconButton(
                  icon: Icon(isPlaying ? Icons.pause : Icons.music_note_rounded,
                      color: Colors.white),
                  onPressed: toggleSpeech,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
