import 'package:flutter/material.dart';
import '../../data/models/available_member_model.dart';
import '../../../../core/constants/colors.dart';

class NewMessageModal extends StatefulWidget {
  final List<AvailableMemberModel> availableMembers;
  final bool isLoading;
  final Function(AvailableMemberModel) onMemberSelected;
  final VoidCallback onClose;

  const NewMessageModal({
    super.key,
    required this.availableMembers,
    required this.isLoading,
    required this.onMemberSelected,
    required this.onClose,
  });

  @override
  State<NewMessageModal> createState() => _NewMessageModalState();
}

class _NewMessageModalState extends State<NewMessageModal> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<AvailableMemberModel> get _filteredMembers {
    if (_searchQuery.isEmpty) return widget.availableMembers;

    return widget.availableMembers.where((member) {
      return member.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          member.username.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'New Message',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: widget.onClose,
                  icon: const Icon(Icons.close),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.red.withValues(alpha: 0.1),
                    foregroundColor: Colors.red,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Search bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primaryLimeGreen,
                  ),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),

            const SizedBox(height: 16),

            // Members list
            Expanded(
              child: widget.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredMembers.isEmpty
                  ? const Center(
                      child: Text(
                        'No users found',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredMembers.length,
                      itemBuilder: (context, index) {
                        final member = _filteredMembers[index];
                        return Card(
                          elevation: 1,
                          margin: const EdgeInsets.only(bottom: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            leading: CircleAvatar(
                              radius: 24,
                              backgroundImage: NetworkImage(
                                member.profilePictureUrl,
                              ),
                              backgroundColor: Colors.grey[300],
                              onBackgroundImageError: (_, __) {},
                              child: member.profilePictureUrl.isEmpty
                                  ? Text(
                                      member.name.isNotEmpty
                                          ? member.name[0].toUpperCase()
                                          : '?',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    )
                                  : null,
                            ),
                            title: Text(
                              member.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              '@${member.username}',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            trailing: const Icon(
                              Icons.message,
                              color: AppColors.primaryLimeGreen,
                            ),
                            onTap: () => widget.onMemberSelected(member),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
