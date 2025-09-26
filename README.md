# VETRA - Digital Tournament Booking Application

A comprehensive platform for managing and participating in tournaments with both admin and user interfaces. The application is designed with a focus on usability, aesthetic appeal, and responsiveness.

## File Structure

```
lib/
  ├── main.dart                      # App entry point with route definitions
  ├── models/                        # Data models
  │   ├── user.dart                  # User model (admin & regular users)
  │   ├── tournament.dart            # Tournament model
  │   ├── booking.dart               # Booking model
  │   └── notification.dart          # Notification model
  ├── screens/                       # Application screens
  │   ├── landing_page.dart          # Landing page with admin/user options
  │   ├── profile_edit_screen.dart   # Profile editing screen
  │   ├── admin/                     # Admin screens
  │   │   └── admin_dashboard_screen.dart  # Admin dashboard
  │   └── users/                     # User screens
  │       └── user_dashboard_screen.dart   # User dashboard
  ├── utils/                         # Utility classes
  │   └── app_theme.dart             # Theme definitions
  └── widgets/                       # Reusable UI components
      ├── app_drawer.dart            # Navigation drawer
      ├── tournament_card.dart       # Tournament display card
      ├── booking_card.dart          # Booking display card
      ├── notification_card.dart     # Notification display card
      └── profile_card.dart          # Profile information card
```

## Features Implemented

### UI Components

1. **App Drawer Navigation**:
   - Custom drawer with user profile header
   - Different menu items for admin and user roles
   - Selected item highlighting
   - Responsive design

2. **Dashboard Components**:
   - Stats cards for quick information
   - Tournament listings
   - Booking management
   - Notification handling

3. **Profile Management**:
   - Profile display with photo
   - Profile editing capability
   - Role-specific styling

4. **Cards and Lists**:
   - Tournament cards with status indicators
   - Booking cards with action buttons
   - Notification cards with read/unread states

### Screens

1. **Landing Page**:
   - Role selection (Admin/User)
   - App branding
   - Login/Signup options

2. **Admin Dashboard**:
   - Overview statistics
   - Tournament management
   - Booking management
   - Profile management

3. **User Dashboard**:
   - Available tournaments
   - Personal bookings
   - Notifications
   - Profile management

4. **Profile Edit Screen**:
   - Form for updating personal information
   - Profile photo management

## Design Style

- **Color Scheme**:
  - Admin theme: Purple (#6f42c1)
  - User theme: Green (#94c142)
  - Consistent application of colors for different user roles

- **UI Elements**:
  - Card-based design for clear information separation
  - Consistent spacing and typography
  - Status indicators with appropriate colors
  - Progress bars for availability visualization

- **Responsiveness**:
  - Adaptable layouts for different screen sizes
  - Scrollable content sections
  - Proper sizing constraints

## Getting Started

1. Ensure Flutter is installed on your machine
2. Run `flutter pub get` to install dependencies
3. Run `flutter run` to start the application

## Additional Resources

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
