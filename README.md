# book_bazaar

Group Members

| Name | ID |
|------|-----|
| [Kidist shambel] | [0642/15] |
| [Jerusalem Dereje] | [0589/15] |
| [Elias Kemal] | [0882/15] |
| [Mena Ochan] | [0721/15] |
| [Jibril MohammED] | [0591/15] |

Project Description

**Book Bazaar** is a mobile application that allows users to buy and sell books within a community. Users can create accounts, browse books listed by other users, add their own books for sale, manage their listings, and mark books as sold when they are no longer available.

The app is built using **Flutter** framework with **Firebase** providing backend services including authentication and cloud database storage.

---

##  Features

### User Authentication
- Sign up with email and password
- Secure login
- User session management

### Browse Books
- View all available books from all users
- Real-time updates using Firestore
- Responsive grid layout (2-3 columns based on screen size)

### Add Books
- Upload book cover images (max 500KB)
- Enter book details: title, author, price, description
- Add contact information for buyers
- Image validation and size checking

### My Books
- View only books you have listed
- Mark books as sold when purchased
- Sold books show "SOLD" badge

### Book Details
- View full book description
- See seller contact information
- Owner can mark books as sold

### Menu Drawer
- View profile information
- Add new books
- Access "My Books"
- Logout

---

## Technology Stack

| Technology | Purpose |
|------------|---------|
| **Flutter 3.41.8** | Frontend framework |
| **Dart** | Programming language |
| **Firebase Authentication** | User signup/login |
| **Cloud Firestore** | Database for books data |
| **Image Picker** | Camera/gallery access |
| **Base64 Encoding** | Image storage in Firestore |

---

## 📱 Screens

1. **Login Screen** - Sign in / Sign up with email/password
2. **Home Screen** - Browse all available books
3. **Add Book Screen** - Upload book info and image
4. **Book Detail Screen** - View full details and seller contact
5. **My Books** - Manage your own listings

---

## 🚀 How to Run the Project

### Prerequisites
- Flutter SDK installed
- Android device or emulator
- USB debugging enabled on Android phone

### Steps

```bash
# 1. Clone the repository
git clone https://github.com/YOUR_USERNAME/book_bazaar.git

# 2. Navigate to project folder
cd book_bazaar

# 3. Get dependencies
flutter pub get

# 4. Run the app
flutter run



- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
