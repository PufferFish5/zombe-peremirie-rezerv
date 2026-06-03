import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:flop6/core/app_colors.dart';
import 'package:flop6/core/app_theme.dart';
import 'package:flop6/data/calendar_service.dart';
import 'package:flop6/data/database_service.dart';
import 'package:flop6/data/local_storage_service.dart';
import 'package:flop6/data/models/post.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<List<Post>> _postsFuture;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  void _loadPosts() {
    setState(() {
      _postsFuture = DatabaseService.getPosts();
    });
  }

  Future<void> _addToGoogleCalendar(Post post) async {
    final success = await CalendarService.addEventToCalendar(post);
    if (success == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Event "${post.title}" added to Google Calendar!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        
        title: const Text('OMEGA ENERGY'),
        
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          )
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        onRefresh: () async {
          _loadPosts();
          await _postsFuture;
        },
        child: FutureBuilder<List<Post>>(
          future: _postsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }
            
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error loading data:\n${snapshot.error}',
                  style: const TextStyle(color: AppColors.error),
                  textAlign: TextAlign.center,
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  'No data available.',
                  style: TextStyle(color: AppColors.textDisabled),
                ),
              );
            }

            final posts = snapshot.data!;
            
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                return _buildPostCard(posts[index]);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildPostCard(Post post) {
    final isEvent = post.type == 'event';
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 20.0),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 340,
                width: double.infinity,
                color: AppColors.surfaceVariant,
                child: _buildSmartImage(post.imageUrl),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isEvent ? AppColors.accent : AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: (isEvent ? AppColors.accent : AppColors.primary).withAlpha(100),
                        blurRadius: 8,
                        spreadRadius: 1, 
                      )
                    ],
                  ),
                  child: Text(
                    isEvent ? 'event' : 'post',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.background,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.title, style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(post.body, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 16),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isEvent ? Icons.event : Icons.access_time,
                          size: 16,
                          color: AppColors.textDisabled,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isEvent && post.eventDate != null
                              ? DateFormat('dd.MM.yyyy HH:mm').format(post.eventDate!)
                              : DateFormat('dd.MM.yyyy').format(post.createdAt),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.textDisabled,
                          ),
                        ),
                      ],
                    ),
                    if (isEvent)
                      OutlinedButton.icon(
                        onPressed: () => _addToGoogleCalendar(post),
                        icon: const Icon(Icons.edit_calendar, size: 18),
                        label: const Text('Add to Calendar'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.accent,
                          side: const BorderSide(color: AppColors.accent),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildSmartImage(String imagePath) {
    if (imagePath.isEmpty) {
      return _buildPlaceholder();
    }
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }
    if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }

    final file = File(imagePath);
    if (file.existsSync()) {
      return Image.file(
        file,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }
    return _buildPlaceholder();
  }
  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.surfaceVariant,
      child: const Center(
        child: Icon(
          Icons.image_not_supported,
          color: AppColors.textDisabled,
          size: 50,
        ),
      ),
    );
  }
}