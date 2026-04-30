import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookDetailScreen extends StatelessWidget {
  final String bookId;
  final Map<String, dynamic> bookData;

  const BookDetailScreen({Key? key, required this.bookId, required this.bookData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final isOwner = currentUserId == bookData['userId'];
    final imageBase64 = bookData['imageBase64'] ?? '';
    final isSold = bookData['status'] == 'sold';

    return Scaffold(
      backgroundColor: Color(0xFF0a0a1a),
      appBar: AppBar(
        title: Text(bookData['title'] ?? 'Book Details', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF0f0c1f),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book Image
            Container(
              height: 400,
              width: double.infinity,
              color: Colors.white.withOpacity(0.05),
              child: imageBase64.isNotEmpty
                  ? Image.memory(base64Decode(imageBase64), fit: BoxFit.contain)
                  : Center(child: Icon(Icons.book, size: 100, color: Colors.white.withOpacity(0.3))),
            ),
            
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sold Badge
                  if (isSold)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'SOLD',
                        style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                      ),
                    ),
                  SizedBox(height: 10),
                  
                  // Title
                  Text(
                    bookData['title']?.toUpperCase() ?? 'NEVER ENDING SKY',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  SizedBox(height: 4),
                  
                  // Author
                  Text(
                    'by ${bookData['author'] ?? 'Unknown Author'}',
                    style: TextStyle(
                      color: Color(0xFFa78bfa),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 20),
                  
                  // Description
                  Text(
                    'ABOUT THIS BOOK',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFF1E1B3A),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      bookData['description'] ?? 'No description available',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  
                  // Price
                  Row(
                    children: [
                      Text(
                        'PRICE',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                      Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          '\$${bookData['price'] ?? '0'} USD',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  
                  // Seller Contact (for buyers only, if not sold)
                  if (!isOwner && !isSold) ...[
                    Divider(color: Colors.white24),
                    SizedBox(height: 16),
                    Text(
                      'SELLER CONTACT',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color(0xFF1E1B3A),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Color(0xFFa78bfa).withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Contact Seller',
                                  style: TextStyle(color: Colors.white54, fontSize: 12),
                                ),
                                Text(
                                  bookData['contact'] ?? 'contact@example.com',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.message, color: Color(0xFFa78bfa)),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Contact: ${bookData['contact']}')),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  // Mark as Sold button (for owner only, if not sold)
                  if (isOwner && !isSold)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          // Show confirmation dialog
                          bool? confirm = await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: Color(0xFF1E1B3A),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              title: Text('Mark as Sold?', style: TextStyle(color: Colors.white)),
                              content: Text(
                                'This will mark "${bookData['title']}" as sold and remove it from public view.',
                                style: TextStyle(color: Colors.white70),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: Text('Cancel', style: TextStyle(color: Colors.white54)),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                  child: Text('Yes, Mark Sold'),
                                ),
                              ],
                            ),
                          );
                          
                          if (confirm == true) {
                            // Update the book status to sold
                            await FirebaseFirestore.instance
                                .collection('books')
                                .doc(bookId)
                                .update({'status': 'sold'});
                            
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('✅ Book marked as sold!')),
                              );
                              Navigator.pop(context); // Go back to home screen
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text('Mark as Sold', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  
                  // Already sold message (for owner)
                  if (isSold && isOwner)
                    Center(
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.green.withOpacity(0.3)),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green, size: 40),
                            SizedBox(height: 8),
                            Text(
                              'This book has been sold! ✓',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
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
    );
  }
}