import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nimbrung_mobile/presentation/themes/color_schemes.dart';

import '../../providers/visibility_provider.dart';

class SearchFriendsPage extends StatefulWidget {
  const SearchFriendsPage({super.key});

  @override
  State<SearchFriendsPage> createState() => _SearchFriendsPageState();
}

class _SearchFriendsPageState extends State<SearchFriendsPage>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isLoading = false;
  bool _hasSearched = false;

  List<UserSearchResult> searchResults = [
    UserSearchResult(
      id: "1",
      name: "Adit Irawan",
      description: "Psikologi",
      profileImageUrl:
          "https://raw.githubusercontent.com/kfahmi77/api-mockup-nimbrung/refs/heads/main/Rectangle%2033.png",
      isOnline: true,
      mutualFriends: 5,
    ),
    UserSearchResult(
      id: "2",
      name: "Adit Hiramawan",
      description: "Biologi",
      profileImageUrl:
          "https://raw.githubusercontent.com/kfahmi77/api-mockup-nimbrung/refs/heads/main/Rectangle%2033.png",
      isOnline: false,
      mutualFriends: 2,
    ),
    UserSearchResult(
      id: "1",
      name: "Adit Irawan",
      description: "Psikologi",
      profileImageUrl:
          "https://raw.githubusercontent.com/kfahmi77/api-mockup-nimbrung/refs/heads/main/Rectangle%2033.png",
      isOnline: true,
      mutualFriends: 5,
    ),
    UserSearchResult(
      id: "2",
      name: "Adit Hiramawan",
      description: "Biologi",
      profileImageUrl:
          "https://raw.githubusercontent.com/kfahmi77/api-mockup-nimbrung/refs/heads/main/Rectangle%2033.png",
      isOnline: false,
      mutualFriends: 2,
    ),
    UserSearchResult(
      id: "3",
      name: "Budi Santoso",
      description: "Teknik Informatika",
      profileImageUrl:
          "https://raw.githubusercontent.com/kfahmi77/api-mockup-nimbrung/refs/heads/main/Rectangle%2033.png",
      isOnline: true,
      mutualFriends: 3,
    ),
    UserSearchResult(
      id: "4",
      name: "Siti Aminah",
      description: "Ekonomi",
      profileImageUrl:
          "https://raw.githubusercontent.com/kfahmi77/api-mockup-nimbrung/refs/heads/main/Rectangle%2033.png",
      isOnline: false,
      mutualFriends: 1,
    ),
    UserSearchResult(
      id: "5",
      name: "Joko Widodo",
      description: "Politik",
      profileImageUrl:
          "https://raw.githubusercontent.com/kfahmi77/api-mockup-nimbrung/refs/heads/main/Rectangle%2033.png",
      isOnline: true,
      mutualFriends: 4,
    ),
  ];

  List<UserSearchResult> filteredResults = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    // Simulate API call delay
    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() {
        _isLoading = false;
        if (query.isEmpty) {
          filteredResults = [];
        } else {
          filteredResults =
              searchResults
                  .where(
                    (user) =>
                        user.name.toLowerCase().contains(query.toLowerCase()),
                  )
                  .toList();
        }
      });
      _animationController.forward();
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      filteredResults = [];
      _hasSearched = false;
    });
    _animationController.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,

        title: const Text(
          "Cari Teman",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Simulate refresh
          await Future.delayed(const Duration(milliseconds: 1000));
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 10),

              // Enhanced Search Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Masukkan nama teman...",
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: Container(
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        Icons.search_rounded,
                        color: Colors.grey[400],
                        size: 22,
                      ),
                    ),
                    suffixIcon:
                        _searchController.text.isNotEmpty
                            ? IconButton(
                              icon: const Icon(
                                Icons.clear_rounded,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              onPressed: _clearSearch,
                            )
                            : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {});
                    if (value.isNotEmpty) {
                      _performSearch(value);
                    } else {
                      _clearSearch();
                    }
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Search Results Section
              Expanded(child: _buildSearchResults()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (!_hasSearched) {
      return _buildEmptyState(
        icon: Icons.search_rounded,
        title: "Mulai Mencari",
        subtitle: "Ketik nama teman yang ingin kamu cari",
      );
    }

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
        ),
      );
    }

    if (filteredResults.isEmpty) {
      return _buildEmptyState(
        icon: Icons.person_search_rounded,
        title: "Tidak Ada Hasil",
        subtitle: "Coba kata kunci yang berbeda",
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: filteredResults.length,
        itemBuilder: (context, index) {
          final user = filteredResults[index];
          return AnimatedContainer(
            duration: Duration(milliseconds: 100 * (index + 1)),
            child: EnhancedUserSearchTile(user: user),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class EnhancedUserSearchTile extends ConsumerWidget {
  final UserSearchResult user;

  const EnhancedUserSearchTile({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // Navigate to user profile
            _showUserProfile(context, ref);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Profile Picture with Online Status
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: NetworkImage(user.profileImageUrl),
                    ),
                    if (user.isOnline)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(width: 16),

                // User Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.description,
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${user.mutualFriends} teman bersama",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Add Friend Button
                InkWell(
                  onTap: () {
                    // Handle add friend action
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Permintaan pertemanan terkirim ke ${user.name}",
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "Tambah",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showUserProfile(BuildContext context, WidgetRef ref) {
    ref.read(bottomNavVisibilityProvider.notifier).state = false;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(user.profileImageUrl),
                ),
                const SizedBox(height: 16),
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user.description,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Text(
                          "Tambah Teman",
                          style: TextStyle(color: AppColors.scaffoldBackground),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Text("Kirim Pesan"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
    ).whenComplete(
      () => ref.read(bottomNavVisibilityProvider.notifier).state = true,
    );
  }
}

class UserSearchResult {
  final String id;
  final String name;
  final String description;
  final String profileImageUrl;
  final bool isOnline;
  final int mutualFriends;

  UserSearchResult({
    required this.id,
    required this.name,
    required this.description,
    required this.profileImageUrl,
    this.isOnline = false,
    this.mutualFriends = 0,
  });
}
