import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

class MessageInput extends StatefulWidget {
  final Function(String text, List<File> mediaFiles) onSendMessage;
  final String? conversationName;
  final bool isLoading;

  const MessageInput({
    super.key,
    required this.onSendMessage,
    this.conversationName,
    this.isLoading = false,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController _textController = TextEditingController();
  final List<File> _selectedFiles = [];
  final ImagePicker _picker = ImagePicker();
  bool _canSend = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_updateCanSend);
  }

  @override
  void dispose() {
    _textController.removeListener(_updateCanSend);
    _textController.dispose();
    super.dispose();
  }

  void _updateCanSend() {
    final newCanSend =
        _textController.text.trim().isNotEmpty || _selectedFiles.isNotEmpty;
    if (newCanSend != _canSend) {
      setState(() {
        _canSend = newCanSend;
      });
    }
  }

  void _sendMessage() {
    final text = _textController.text.trim();

    // Allow sending if either text is not empty OR there are media files
    // This matches the web implementation
    if (text.isNotEmpty || _selectedFiles.isNotEmpty) {
      print(
        'Sending message: text="$text", media files: ${_selectedFiles.length}',
      );
      widget.onSendMessage(text, List.from(_selectedFiles));
      _textController.clear();
      _selectedFiles.clear();
      _updateCanSend();
      setState(() {});
    } else {
      print('Cannot send empty message without text or media');
    }
  }

  Future<void> _pickMedia() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Photo Gallery'),
              onTap: () async {
                Navigator.pop(context);
                await _pickImages();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () async {
                Navigator.pop(context);
                await _pickFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text('Video'),
              onTap: () async {
                Navigator.pop(context);
                await _pickVideo();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    for (final image in images) {
      _selectedFiles.add(File(image.path));
    }
    _updateCanSend();
    setState(() {});
  }

  Future<void> _pickFromCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      _selectedFiles.add(File(image.path));
      _updateCanSend();
      setState(() {});
    }
  }

  Future<void> _pickVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      _selectedFiles.add(File(video.path));
      _updateCanSend();
      setState(() {});
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
    _updateCanSend();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Selected files preview
            if (_selectedFiles.isNotEmpty)
              Container(
                height: 100,
                padding: const EdgeInsets.all(8),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedFiles.length,
                  itemBuilder: (context, index) {
                    final file = _selectedFiles[index];
                    final isVideo = _isVideoFile(file.path);

                    return Container(
                      width: 80,
                      margin: const EdgeInsets.only(right: 8),
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey[200],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: isVideo
                                  ? Stack(
                                      children: [
                                        Container(
                                          color: Colors.black26,
                                          child: const Center(
                                            child: Icon(
                                              Icons.play_circle_filled,
                                              color: Colors.white,
                                              size: 32,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 4,
                                          right: 4,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 4,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.black54,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: const Text(
                                              'VIDEO',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 8,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Image.file(
                                      file,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Container(
                                              color: Colors.grey[300],
                                              child: const Icon(
                                                Icons.image_not_supported,
                                                color: Colors.grey,
                                                size: 24,
                                              ),
                                            );
                                          },
                                    ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => _removeFile(index),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

            // Input area - Figma design
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: Row(
                children: [
                  // Text input with media picker icon inside
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: 'Type your message',
                        hintStyle: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFFA0A49B), // Figma hint color
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: const BorderSide(
                            color: Color(0xFFE8E9E6), // Figma border color
                            width: 1,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 12.h,
                        ),
                        prefixIcon: GestureDetector(
                          onTap: widget.isLoading ? null : _pickMedia,
                          child: Icon(
                            Icons.attach_file,
                            size: 24.sp,
                            color: const Color(0xFF6D6D6D),
                          ),
                        ),
                      ),
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF111B05),
                      ),
                      maxLines: null,
                      enabled: !widget.isLoading,
                      onSubmitted: (_) {
                        _sendMessage();
                      },
                    ),
                  ),

                  SizedBox(width: 16.w),

                  // Send button
                  GestureDetector(
                    onTap: _canSend && !widget.isLoading ? _sendMessage : null,
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: _canSend && !widget.isLoading
                            ? const Color(
                                0xFF8BC342,
                              ) // Figma green when enabled
                            : const Color(0xFFE8E9E6), // Disabled color
                        borderRadius: BorderRadius.circular(
                          50.r,
                        ), // More circular like Figma
                      ),
                      child: widget.isLoading
                          ? SizedBox(
                              width: 20.w,
                              height: 20.h,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Transform.rotate(
                              angle:
                                  -0.785398, // -45 degrees in radians to match Figma
                              child: Icon(
                                Icons.send,
                                size: 20.sp,
                                color: _canSend && !widget.isLoading
                                    ? Colors.white
                                    : const Color(0xFF6D6D6D),
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isVideoFile(String path) {
    final extensions = ['.mp4', '.webm', '.ogg', '.mov', '.avi'];
    return extensions.any((ext) => path.toLowerCase().endsWith(ext));
  }
}
