import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../services/rating_service.dart';
import '../auth/auth_service.dart';

class RatingsListScreen extends StatefulWidget {
  final String userId;
  final bool showReceivedRatings;
  final bool isOwnerView;

  const RatingsListScreen({
    super.key,
    required this.userId,
    this.showReceivedRatings = true,
    this.isOwnerView = false,
  });

  @override
  State<RatingsListScreen> createState() => _RatingsListScreenState();
}

class _RatingsListScreenState extends State<RatingsListScreen> {
  String? _selectedRoleFilter;
  String? _selectedJobFilter;
  final Map<String, String> _jobTitles = {
    'job1': 'Tukar Minyak Hitam',
    'job2': 'Servis Brek',
    'job3': 'Baiki Enjin',
    'job4': 'Tukar Tayar',
    'job5': 'Servis Penghawa Dingin',
    'job6': 'Tukar Spark Plug',
    'job7': 'Servis Transmisi',
    'job8': 'Tukar Aircond Filter',
    'job9': 'Balancing Tayar',
    'job10': 'Tukar Bateri',
    '': 'All Jobs',
  };

  final Map<String, String> _roleFilters = {
    'foreman': 'Foreman',
    'workshop_owner': 'Workshop Owner',
    '': 'All Roles',
  };

  Future<void> _deleteRating(String ratingId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Rating'),
            content: const Text(
              'Are you sure you want to delete this rating? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    final ratingService = Provider.of<RatingService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      // Check if user is workshop owner
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(authService.currentUser!.uid)
              .get();

      if (userDoc.exists && userDoc.data()?['role'] == 'workshop_owner') {
        await ratingService.deleteRating(ratingId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Rating deleted successfully')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Only workshop owners can delete ratings'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting rating: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.showReceivedRatings ? 'Ratings Received' : 'Ratings Given',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.1),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withOpacity(0.03),
              theme.colorScheme.secondary.withOpacity(0.05),
            ],
          ),
        ),
        child: Column(
          children: [
            if (_selectedRoleFilter != null || _selectedJobFilter != null)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    if (_selectedRoleFilter != null)
                      FilterChip(
                        label: Text(_roleFilters[_selectedRoleFilter]!),
                        onSelected: (_) => _removeRoleFilter(),
                      ),
                    if (_selectedJobFilter != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: FilterChip(
                          label: Text(_jobTitles[_selectedJobFilter]!),
                          onSelected: (_) => _removeJobFilter(),
                        ),
                      ),
                  ],
                ),
              ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('ratings')
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error loading ratings',
                        style: TextStyle(
                          color: theme.colorScheme.error,
                          fontSize: 16,
                        ),
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.primary,
                        ),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.star_outline_rounded,
                            size: 48,
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No ratings found',
                            style: TextStyle(
                              fontSize: 18,
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.7,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final filteredDocs =
                      snapshot.data!.docs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final roleMatch =
                            _selectedRoleFilter == null ||
                            _selectedRoleFilter!.isEmpty ||
                            data['role'] == _selectedRoleFilter;
                        final jobMatch =
                            _selectedJobFilter == null ||
                            _selectedJobFilter!.isEmpty ||
                            data['jobId'] == _selectedJobFilter;
                        return roleMatch && jobMatch;
                      }).toList();

                  if (filteredDocs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.filter_alt_off,
                            size: 48,
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No ratings match your filters',
                            style: TextStyle(
                              fontSize: 18,
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.7,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _selectedRoleFilter = null;
                                _selectedJobFilter = null;
                              });
                            },
                            child: const Text('Clear filters'),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredDocs.length,
                    separatorBuilder:
                        (context, index) => Divider(
                          height: 24,
                          thickness: 0.5,
                          color: theme.dividerColor.withOpacity(0.3),
                        ),
                    itemBuilder: (context, index) {
                      final doc = filteredDocs[index];
                      final data = doc.data() as Map<String, dynamic>;

                      int stars = data['stars'] ?? 0;
                      String comment = data['comment'] ?? '';
                      String jobId = data['jobId'] ?? 'N/A';
                      String role = data['role'] ?? 'Unknown';
                      String jobTitle = _jobTitles[jobId] ?? 'General Service';
                      DateTime? createdAt;

                      if (data['createdAt'] is Timestamp) {
                        createdAt = (data['createdAt'] as Timestamp).toDate();
                      } else if (data['createdAt'] is String) {
                        try {
                          createdAt = DateTime.parse(data['createdAt']);
                        } catch (e) {
                          createdAt = null;
                        }
                      }

                      String dateText =
                          createdAt != null
                              ? dateFormat.format(createdAt)
                              : 'Date not available';
                      return Container(
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          trailing:
                              widget.isOwnerView
                                  ? PopupMenuButton(
                                    icon: const Icon(Icons.more_vert),
                                    itemBuilder:
                                        (context) => [
                                          const PopupMenuItem(
                                            value: 'delete',
                                            child: Text('Delete Rating'),
                                          ),
                                        ],
                                    onSelected: (value) {
                                      if (value == 'delete') {
                                        _deleteRating(doc.id);
                                      }
                                    },
                                  )
                                  : null,
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      jobTitle,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    dateText,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Job ID: $jobId',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'For Role: ${_roleFilters[role] ?? role}',
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.8),
                                  ),
                                ),
                                if (comment.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.surface
                                          .withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      comment,
                                      style: TextStyle(
                                        color: theme.colorScheme.onSurface
                                            .withOpacity(0.9),
                                      ),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: List.generate(5, (i) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 2,
                                            ),
                                            child: Icon(
                                              i < stars
                                                  ? Icons.star_rounded
                                                  : Icons.star_outline_rounded,
                                              color: Colors.amber,
                                              size: 20,
                                            ),
                                          );
                                        }),
                                      ),
                                    ),
                                    if (data['ratedByName'] != null)
                                      Text(
                                        'By: ${data['ratedByName']}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: theme.colorScheme.onSurface
                                              .withOpacity(0.6),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filter Ratings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedRoleFilter,
                decoration: const InputDecoration(
                  labelText: 'Filter by Role',
                  border: OutlineInputBorder(),
                ),
                items:
                    _roleFilters.entries.map((entry) {
                      return DropdownMenuItem(
                        value: entry.key,
                        child: Text(entry.value),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRoleFilter = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedJobFilter,
                decoration: const InputDecoration(
                  labelText: 'Filter by Job Type',
                  border: OutlineInputBorder(),
                ),
                items:
                    _jobTitles.entries.map((entry) {
                      return DropdownMenuItem(
                        value: entry.key,
                        child: Text(entry.value),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedJobFilter = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedRoleFilter = null;
                  _selectedJobFilter = null;
                });
                Navigator.pop(context);
              },
              child: const Text('Clear All'),
            ),
          ],
        );
      },
    );
  }

  void _removeRoleFilter() {
    setState(() {
      _selectedRoleFilter = null;
    });
  }

  void _removeJobFilter() {
    setState(() {
      _selectedJobFilter = null;
    });
  }
}
