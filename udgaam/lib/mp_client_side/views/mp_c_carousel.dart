import 'dart:async';
import 'package:flutter/material.dart';

class CarouselWidget extends StatefulWidget {
  const CarouselWidget({super.key});

  @override
  _CarouselWidgetState createState() => _CarouselWidgetState();
}

class _CarouselWidgetState extends State<CarouselWidget> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late Timer _timer;

  // Sample data for cards: text and gradient colors
  final List<Map<String, dynamic>> carouselData = [
    {
      'text': '“Support organic, sustain the planet!”',
      'gradient': [Colors.green[600]!, Colors.teal[800]!],
    },
    {
      'text': '10% off organic tomatoes this week!',
      'gradient': [Colors.orange[600]!, Colors.red[800]!],
    },
    {
      'text': '“Pure farming, pure living.”',
      'gradient': [Colors.blue[600]!, Colors.indigo[800]!],
    },
    {
      'text': '20% off freshly harvested spinach!',
      'gradient': [Colors.purple[600]!, Colors.pink[800]!],
    },
    {
      'text': '“Organic today, thriving tomorrow.”',
      'gradient': [Colors.teal[600]!, Colors.green[800]!],
    },
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (_currentPage < carouselData.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 150,
          child: PageView.builder(
            controller: _pageController,
            itemCount: carouselData.length,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (context, index) {
              return _buildCarouselCard(
                carouselData[index]['text'],
                carouselData[index]['gradient'],
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        _buildDots(),
      ],
    );
  }

  Widget _buildCarouselCard(String text, List<Color> gradient) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        width: 220,
        height: 150,
        padding: const EdgeInsets.all(16.0), // Padding from all sides
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20), // Rounded corners
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4), // Subtle shadow for depth
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white, // White text
              fontSize: 16,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: Colors.black45,
                  offset: Offset(1, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Build pagination dots
  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(carouselData.length, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          width: _currentPage == index ? 10.0 : 6.0,
          height: 6.0,
          decoration: BoxDecoration(
            color: _currentPage == index ? Colors.green[700] : Colors.grey,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}
