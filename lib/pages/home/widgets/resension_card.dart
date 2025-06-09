import 'package:flutter/material.dart';
import 'package:nimbrung_mobile/core/utils/extension/spacing_extension.dart';

import '../../../themes/color_schemes.dart';

class ResensionCard extends StatefulWidget {
  const ResensionCard({super.key});

  @override
  State<ResensionCard> createState() => _ResensionCardState();
}

class _ResensionCardState extends State<ResensionCard> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> bookReviews = [
    {
      'title': 'Lorem Ipsum',
      'author': 'Penulis Pertama',
      'cover':
          'https://images.unsplash.com/photo-1543002588-bfa74002ed7e?w=200&h=300&fit=crop',
      'review':
          'Lorem ipsum dolor sit amet consectetur. Consectetur ac convallis urna eros augue faucibus augue eros. Vitae nisl neque suspendisse risus egestas volutpat sit laoreet quam. Odio suscipit pellentesque a sit blandit arcu et dapibus.',
    },
    {
      'title': 'Dolor Sit Amet',
      'author': 'Penulis Kedua',
      'cover':
          'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=200&h=300&fit=crop',
      'review':
          'Dolor sit amet, consectetur adipiscing elit. Nullam in dui mauris. Vivamus hendrerit arcu sed erat molestie vehicula. Sed auctor neque eu tellus rhoncus ut eleifend nibh porttitor.',
    },
    {
      'title': 'Consectetur Adipiscing',
      'author': 'Penulis Ketiga',
      'cover':
          'https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=200&h=300&fit=crop',
      'review':
          'Consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
    },
  ];
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resensi Buku',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          16.height,

          // Book review carousel
          SizedBox(
            height: 180,
            child: PageView.builder(
              controller: _pageController,
              itemCount: bookReviews.length,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.secondary.withValues(
                          red: 0.9,
                          green: 0.9,
                          blue: 0.9,
                        ),
                        spreadRadius: 1,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Book cover
                      Container(
                        width: 80,
                        height: 160,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(bookReviews[index]['cover']!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      // Book details
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                bookReviews[index]['title']!,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              4.height,
                              Text(
                                bookReviews[index]['author']!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              12.height,
                              Text(
                                bookReviews[index]['review']!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                  height: 1.4,
                                ),
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.justify,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Indicator
          12.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List<Widget>.generate(
              bookReviews.length,
              (index) => Container(
                width: 8,
                height: 8,
                margin: EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      _currentPage == index
                          ? AppColors.primary
                          : Colors.grey.withOpacity(0.4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
