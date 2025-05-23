import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nimbrung_mobile/core/utils/extension/spacing_extension.dart';
import 'package:nimbrung_mobile/themes/color_schemes.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Quote Section
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header dengan profile
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                              radius: 20,
                              backgroundImage: NetworkImage(
                                'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop&crop=face',
                              ),
                            ),
                          ),

                          12.width,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pagi,',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                'Nimbrung',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                          Spacer(),
                          // Icons
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              shape: BoxShape.circle,
                            ),
                            child: SvgPicture.asset(
                              'assets/images/chat.svg',
                              width: 22,
                              height: 22,
                            ),
                          ),
                          8.width,
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              shape: BoxShape.circle,
                            ),
                            child: SvgPicture.asset(
                              'assets/images/bell.svg',
                              width: 24,
                              height: 24,
                            ),
                          ),
                        ],
                      ),
                      24.height,

                      // Greeting
                      Text(
                        'Yuk, Baca Dulu!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      16.height,

                      // Quote text
                      Text(
                        'Kognisi adalah proses mental yang mencakup persepsi, perhatian, ingatan, pemecahan masalah,',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                      ),
                      Text(
                        'dan pengambilan keputusan.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                      ),
                      16.height,

                      // Source
                      Text(
                        'Solso, R. L. (2008). Cognitive Psychology: Edisi Kedelapan. Erlangga.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      24.height,

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Text(
                                'Mulai Nimbrung Yuk . . .',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          12.width,
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.thumb_up_alt_outlined,
                              color: AppColors.primary,
                              size: 22,
                            ),
                          ),
                          8.width,
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.thumb_down_off_alt_rounded,
                              color: AppColors.primary,
                              size: 22,
                            ),
                          ),
                          8.width,
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: SvgPicture.asset(
                              'assets/images/share.svg',
                              width: 22,
                              height: 22,
                            ),
                          ),
                        ],
                      ),
                      20.height,
                    ],
                  ),
                ),
              ),
            ),

            // Book Review Section
            Padding(
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
                  // Book review card
                  Container(
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
                              image: NetworkImage(
                                'https://images.unsplash.com/photo-1543002588-bfa74002ed7e?w=200&h=300&fit=crop',
                              ),
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
                                  'Lorem Ipsum',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                4.height,
                                Text(
                                  'Penulis buku',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                12.height,
                                Text(
                                  'Lorem ipsum dolor sit amet consectetur. Consectetur ac convallis urna eros augue faucibus augue eros. Vitae nisl neque suspendisse risus egestas volutpat sit laoreet quam. Odio suscipit pellentesque a sit blandit arcu et dapibus.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black87,
                                    height: 1.4,
                                  ),
                                  textAlign: TextAlign.justify,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: CircleAvatar(
        radius: 24,
        backgroundColor: AppColors.primary,
        child: SvgPicture.asset('assets/images/chatbot.svg'),
      ),
      // Bottom Navigation
      bottomNavigationBar: Container(
        margin: EdgeInsets.only(bottom: 24, right: 58, left: 58),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Icon(Icons.home_rounded, color: Colors.white, size: 28),
              Icon(Icons.search, color: Colors.white, size: 28),
              Icon(Icons.menu_book, color: Colors.white, size: 28),
              Icon(Icons.person, color: Colors.white, size: 28),
            ],
          ),
        ),
      ),
    );
  }
}
