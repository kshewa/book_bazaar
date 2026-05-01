import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class AddBookScreen extends StatefulWidget {
  @override
  _AddBookScreenState createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contactController = TextEditingController();
  bool _isLoading = false;
  File? _selectedImage;
  String? _imageBase64;
  String? _imageError;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      
      // Get image size in bytes
      int fileSize = await imageFile.length();
      int fileSizeKB = fileSize ~/ 1024;
      
      // Check if image is too large (max 500KB)
      if (fileSize > 500 * 1024) { // 500KB limit
        setState(() {
          _imageError = 'Image too large (${fileSizeKB}KB). Please use image under 500KB.';
          _selectedImage = null;
          _imageBase64 = null;
        });
        return;
      }
      
      // Clear any previous error
      setState(() {
        _imageError = null;
      });
      
      // Read and convert image to Base64
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64String = base64Encode(imageBytes);
      
      setState(() {
        _selectedImage = imageFile;
        _imageBase64 = base64String;
      });
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Image loaded (${fileSizeKB}KB)'),
          duration: Duration(seconds: 1),
          backgroundColor: Colors.green,
        ),
      );
    }
  }


//3,

  Future<void> _addBook() async {
    // Validate required fields
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter book title')),
      );
      return;
    }
    
    if (_authorController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter author name')),
      );
      return;
    }
    
    if (_priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter price')),
      );
      return;
    }

//2,


    setState(() => _isLoading = true);

    try {
      // Prepare book data
      Map<String, dynamic> bookData = {
        'title': _titleController.text.trim(),
        'author': _authorController.text.trim(),
        'price': double.tryParse(_priceController.text.trim()) ?? 0.0,
        'description': _descriptionController.text.trim(),
        'contact': _contactController.text.trim(),
        'imageBase64': _imageBase64 ?? '',
        'status': 'available',
        'createdAt': FieldValue.serverTimestamp(),
        'userId': FirebaseAuth.instance.currentUser?.uid,
      };


     // Save to Firestore
      await FirebaseFirestore.instance.collection('books').add(bookData);

      if (mounted) {
        // Show success dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Color(0xFF1E1B3A),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 28),
                SizedBox(width: 10),
                Text('Success!', style: TextStyle(color: Colors.white)),
              ],
            ),
            content: Text(
              '✨ "${_titleController.text.trim()}" has been added to Book Bazaar!\n\nOther readers can now discover this book.',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back to home screen
                },
                child: Text('Great!', style: TextStyle(color: Color(0xFFa78bfa))),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0a0a1a),
      appBar: AppBar(
        title: Text('Add New Book', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF0f0c1f),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // Image Picker Section
            
            
            //1,
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _imageError != null 
                        ? Colors.red.withOpacity(0.5) 
                        : Colors.white.withOpacity(0.1),
                  ),


                  image: _selectedImage != null
                      ? DecorationImage(image: FileImage(_selectedImage!), fit: BoxFit.cover)
                      : null,
                ),
                child: _selectedImage == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud_upload, size: 50, color: Colors.white38),
                          SizedBox(height: 8),
                          Text(
                            'Tap to upload book cover',
                            style: TextStyle(color: Colors.white38),
                          ),
                          Text(
                            'Max 500KB',
                            style: TextStyle(color: Colors.white24, fontSize: 10),
                          ),
                        ],
                      )
                    : null,
              ),
            ),
            
            // Image Error Message
            if (_imageError != null)
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  _imageError!,
                  style: TextStyle(color: Colors.redAccent, fontSize: 12),
                ),
              ),
            
            SizedBox(height: 20),
            
            // Book Title Field
            TextField(
              controller: _titleController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Book Title *',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF667eea)),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 16),
            
            // Author Field
            TextField(
              controller: _authorController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Author *',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF667eea)),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 16),
            
            // Price Field
            TextField(
              controller: _priceController,
              style: TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Price (USD) *',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF667eea)),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 16),
            
            // Description Field
            TextField(
              controller: _descriptionController,
              style: TextStyle(color: Colors.white),
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF667eea)),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 16),
            
            // Contact Info Field
            TextField(
              controller: _contactController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Contact Info (Email/Phone)',
                labelStyle: TextStyle(color: Colors.white70),
                hintText: 'e.g., booklover@example.com',
                hintStyle: TextStyle(color: Colors.white38),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF667eea)),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 32),
            
            // Submit Button
            if (_isLoading)
              Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFa78bfa),
                ),
              )
            else
              ElevatedButton(
                onPressed: _addBook,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF667eea),
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Add Book',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            
            SizedBox(height: 20),
            
            // Info text
            Text(
              '* Required fields',
              style: TextStyle(color: Colors.white38, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}