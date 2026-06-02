# Church App Setup Guide

## Backend Setup (Laravel)

### Prerequisites
- PHP 8.1+
- PostgreSQL 12+
- Composer
- Node.js & npm

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/smapitech/church-app.git
cd church-app/backend
```

2. **Install PHP dependencies**
```bash
composer install
```

3. **Setup environment**
```bash
cp .env.example .env
php artisan key:generate
```

4. **Configure database in .env**
```
DB_CONNECTION=pgsql
DB_HOST=127.0.0.1
DB_PORT=5432
DB_DATABASE=church_app
DB_USERNAME=postgres
DB_PASSWORD=your_password
```

5. **Run migrations**
```bash
php artisan migrate --seed
```

6. **Generate JWT secret**
```bash
php artisan jwt:generate
```

7. **Setup storage link**
```bash
php artisan storage:link
```

8. **Start the development server**
```bash
php artisan serve
```

The API will be available at `http://localhost:8000/api`

### Key Configuration Files
- `.env` - Environment variables
- `config/jwt.php` - JWT configuration
- `config/filesystems.php` - File storage configuration
- `config/services.php` - Third-party services (Stripe, etc.)

---

## Frontend Setup (Flutter)

### Prerequisites
- Flutter SDK (3.0.0+)
- Dart SDK
- Android Studio or Xcode (for mobile)
- Google Chrome (for web)

### Installation

1. **Navigate to frontend directory**
```bash
cd church-app/frontend
```

2. **Get dependencies**
```bash
flutter pub get
```

3. **Update API URL**
Open `lib/services/api_service.dart` and update:
```dart
static const String baseUrl = 'http://your-server-ip:8000/api';
```

4. **Run the app**

**For Android:**
```bash
flutter run -d android
```

**For iOS:**
```bash
flutter run -d ios
```

**For Web:**
```bash
flutter run -d chrome
```

### Project Structure
```
frontend/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── models/                   # Data models
│   ├── screens/                  # UI screens
│   ├── providers/                # State management
│   ├── services/                 # API & business logic
│   └── widgets/                  # Reusable widgets
├── assets/                       # Images, fonts, animations
└── pubspec.yaml                  # Dependencies
```

---

## Database Setup

### Create Database
```bash
createdb church_app -U postgres
```

### Migrate & Seed
```bash
php artisan migrate --seed
```

### Database Tables
- `users` - User accounts
- `sermons` - Sermon content
- `sunday_school_lessons` - Lessons
- `sunday_school_notes` - Student notes
- `bibles` - Bible verses
- `church_workers` - Staff directory
- `live_streams` - Stream sessions
- `donations` - Donation records
- `notifications` - User notifications

---

## Configuration

### AWS S3 Setup (for file storage)
1. Update `.env`:
```
AWS_ACCESS_KEY_ID=your_key
AWS_SECRET_ACCESS_KEY=your_secret
AWS_DEFAULT_REGION=us-east-1
AWS_BUCKET=your_bucket
```

### Stripe Setup (for donations)
1. Update `.env`:
```
STRIPE_PUBLIC_KEY=pk_test_...
STRIPE_SECRET_KEY=sk_test_...
```

2. In Flutter, update `lib/services/stripe_service.dart`

### Firebase Setup (for notifications)
1. Create Firebase project
2. Download `google-services.json` for Android
3. Download `GoogleService-Info.plist` for iOS
4. Add files to respective directories

---

## Deployment

### Backend Deployment (to DigitalOcean/AWS/etc.)

1. **Build for production**
```bash
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

2. **Run migrations on server**
```bash
php artisan migrate --force
```

3. **Setup web server** (Nginx example)
```nginx
server {
    listen 80;
    server_name your-domain.com;
    root /var/www/church-app/backend/public;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass unix:/run/php/php8.1-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
}
```

### Frontend Deployment (Flutter Web)

1. **Build web app**
```bash
flutter build web --release
```

2. **Deploy to hosting service** (Firebase Hosting, Netlify, Vercel, etc.)
```bash
firebase deploy
```

---

## Development Tips

### Database Reset
```bash
php artisan migrate:fresh --seed
```

### Create Admin User
```bash
php artisan tinker
>>> $user = User::create(['name' => 'Admin', 'email' => 'admin@example.com', 'password' => bcrypt('password'), 'role' => 'admin'])
```

### View Database Queries
Enable in `.env`:
```
APP_DEBUG=true
DB_LOG=true
```

### Testing
```bash
php artisan test
```

---

## Support & Documentation

- [Laravel Documentation](https://laravel.com/docs)
- [Flutter Documentation](https://flutter.dev/docs)
- [JWT Auth for Laravel](https://github.com/tymondesigns/jwt-auth)
- [Stripe Documentation](https://stripe.com/docs)

---

## License
MIT License - See LICENSE file for details
