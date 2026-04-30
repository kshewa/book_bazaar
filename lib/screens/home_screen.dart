import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';
import 'add_book_screen.dart';
import 'book_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showMyBooksOnly = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 600 ? 3 : 2;
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    
    // IMPORTANT FIX: Build query based on what user wants to see
    Query query = FirebaseFirestore.instance.collection('books');
    
    if (_showMyBooksOnly) {
      // Show only the current user's books (both available AND sold)
      query = query.where('userId', isEqualTo: currentUserId);
    } else {
      // Show ONLY available books from ALL users (excluding sold books)
      query = query.where('status', isEqualTo: 'available');
    }
    
    query = query.orderBy('createdAt', descending: true);
    
    return Scaffold(
      backgroundColor: Color(0xFF0a0a1a),
      appBar: AppBar(
        title: Text(
          _showMyBooksOnly ? 'My Books' : 'BookBazaar',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 1,
          ),
        ),
        backgroundColor: Color(0xFF0f0c1f),
        elevation: 0,
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        // ADD BACK BUTTON when in My Books mode
        automaticallyImplyLeading: false,
        actions: [
          if (_showMyBooksOnly)
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      _showMyBooksOnly = false; // Go back to main home screen
                    });
                  },
                ),
                SizedBox(width: 8),
                Text(
                  'Back to Home',
                  style: TextStyle(color: Color(0xFFa78bfa), fontSize: 14),
                ),
              ],
            ),
        ],
      ),
      drawer: _buildDrawer(),
      body: Stack(
        children: [
          // Background
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.2, 0.3),
                radius: 1.5,
                colors: [
                  Color(0xFF1a1a3a),
                  Color(0xFF0a0a1a),
                  Color(0xFF050510),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
          
          // Content
          SafeArea(
            child: Column(
              children: [
                // Quote Header
                Container(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [Color(0xFFa78bfa), Color(0xFFc084fc)],
                        ).createShader(bounds),
                        child: Text(
                          _showMyBooksOnly ? 'MY LITERARY WORLD' : 'NEVER ENDING SKY',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        _showMyBooksOnly 
                          ? 'where my stories take flight ✨'
                          : 'where are u now never ending sky',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 10,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Book Grid
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: query.snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFa78bfa),
                          ),
                        );
                      }
                      
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Error: ${snapshot.error}',
                            style: TextStyle(color: Colors.white70),
                          ),
                        );
                      }
                      
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _showMyBooksOnly ? Icons.bookmark_border : Icons.book_outlined,
                                size: 80,
                                color: Colors.white24,
                              ),
                              SizedBox(height: 16),
                              Text(
                                _showMyBooksOnly 
                                  ? 'You haven\'t added any books yet'
                                  : 'No books available',
                                style: TextStyle(color: Colors.white70),
                              ),
                              SizedBox(height: 8),
                              if (!_showMyBooksOnly)
                                Text(
                                  'Tap + to add your first book',
                                  style: TextStyle(color: Colors.white54, fontSize: 12),
                                ),
                            ],
                          ),
                        );
                      }
                      
                      final books = snapshot.data!.docs;
                      return GridView.builder(
                        padding: EdgeInsets.all(16),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: 0.68,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: books.length,
                        itemBuilder: (context, index) {
                          final book = books[index];
                          return _buildBookCard(book, _showMyBooksOnly);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: !_showMyBooksOnly
          ? FloatingActionButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddBookScreen()),
                );
                setState(() {}); // Refresh after adding book
              },
              child: Icon(Icons.add, size: 28),
              backgroundColor: Color(0xFF667eea),
              elevation: 5,
              shape: CircleBorder(),
            )
          : null,
    );
  }

  Widget _buildBookCard(QueryDocumentSnapshot book, bool isMyBooksView) {
    final bookData = book.data() as Map<String, dynamic>;
    final imageBase64 = bookData['imageBase64'] ?? '';
    final isSold = bookData['status'] == 'sold';
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final isOwner = currentUserId == bookData['userId'];
    
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookDetailScreen(
              bookId: book.id,
              bookData: bookData,
            ),
          ),
        );
        setState(() {}); // Refresh after returning
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E1B3A).withOpacity(0.85),
              Color(0xFF15122C).withOpacity(0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSold 
              ? Colors.red.withOpacity(0.3) 
              : Color(0xFFa78bfa).withOpacity(0.25),
            width: 0.8,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Book Image
            Expanded(
              flex: 3,
              child: Container(
                margin: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white.withOpacity(0.05),
                  image: imageBase64.isNotEmpty
                      ? DecorationImage(
                          image: MemoryImage(base64Decode(imageBase64)),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: imageBase64.isEmpty
                    ? Center(
                        child: Icon(
                          Icons.book,
                          size: 45,
                          color: Colors.white.withOpacity(0.25),
                        ),
                      )
                    : null,
              ),
            ),
            
            // SOLD badge
            if (isSold)
              Container(
                margin: EdgeInsets.only(top: 4),
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                color: Colors.red.withOpacity(0.3),
                child: Text(
                  'SOLD',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            
            // Book Title
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                bookData['title']?.toUpperCase() ?? 'NEVER ENDING SKY',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isSold ? Colors.white.withOpacity(0.5) : Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            
            // Author
            Text(
              bookData['author']?.toUpperCase() ?? 'WINGS OF FIRE',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFa78bfa),
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
            ),
            
            // Price
            Container(
              margin: EdgeInsets.only(bottom: 12, top: 6),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF667eea).withOpacity(0.3), Color(0xFF764ba2).withOpacity(0.3)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '\$${bookData['price'] ?? '0'}',
                style: TextStyle(
                  color: Color(0xFFc084fc),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    final user = FirebaseAuth.instance.currentUser;
    
    return Drawer(
      backgroundColor: Color(0xFF1a1a2e),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1a1a3a),
              Color(0xFF0f0c1f),
            ],
          ),
        ),
        child: Column(
          children: [
            // User Profile Header
            Container(
              padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF667eea).withOpacity(0.3), Colors.transparent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF667eea).withOpacity(0.5),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    user?.email?.split('@').first ?? 'Book Lover',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '📚 Reader & Seller',
                    style: TextStyle(
                      color: Color(0xFFa78bfa),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            
            Divider(color: Colors.white.withOpacity(0.1), thickness: 1),
            
            // Menu Items
            _drawerMenuItem(
              icon: Icons.person_outline,
              title: 'Profile',
              onTap: () {
                Navigator.pop(context);
                _showProfileDialog();
              },
            ),
            
            _drawerMenuItem(
              icon: Icons.add_box_outlined,
              title: 'Add Book',
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddBookScreen()),
                );
                setState(() {}); // Refresh after adding book
              },
            ),
            
            _drawerMenuItem(
              icon: Icons.bookmark_border,
              title: 'My Books',
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _showMyBooksOnly = true; // Show only user's books
                });
              },
            ),
            
            Divider(color: Colors.white.withOpacity(0.1), thickness: 1),
            
            _drawerMenuItem(
              icon: Icons.logout,
              title: 'Logout',
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                }
              },
              isDestructive: true,
            ),
            
            Spacer(),
            
            // Footer
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(width: 30, height: 1, color: Colors.white.withOpacity(0.1)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(Icons.auto_stories, size: 12, color: Colors.white.withOpacity(0.15)),
                      ),
                      Container(width: 30, height: 1, color: Colors.white.withOpacity(0.1)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'NEVER ENDING SKY',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.15),
                      fontSize: 9,
                      letterSpacing: 2,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'where are u now',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.1),
                      fontSize: 7,
                      fontStyle: FontStyle.italic,
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

  Widget _drawerMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.redAccent : Color(0xFFa78bfa)),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.redAccent : Colors.white70,
          fontSize: 14,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 12, color: Colors.white.withOpacity(0.25)),
      onTap: onTap,
    );
  }

  void _showProfileDialog() {
    final user = FirebaseAuth.instance.currentUser;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Color(0xFF1E1B3A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFF667eea), Color(0xFF764ba2)]),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.person, size: 35, color: Colors.white),
              ),
              SizedBox(height: 16),
              Text(
                user?.email ?? 'Book Lover',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                '@${user?.email?.split('@').first ?? 'reader'}',
                style: TextStyle(color: Color(0xFFa78bfa), fontSize: 12),
              ),
              SizedBox(height: 8),
              Text(
                'Member since ${user?.metadata.creationTime?.year ?? 2024}',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
              SizedBox(height: 16),
              Divider(color: Colors.white24),
              SizedBox(height: 12),
              Text(
                '"Books are wings that carry you\nto never ending skies"',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFa78bfa),
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Color(0xFFa78bfa).withOpacity(0.5)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: Text('Close', style: TextStyle(color: Color(0xFFa78bfa))),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}