# NutriSnap Logo Setup Guide

## 📥 Adding Your Custom Logo

Your app is now configured to use a custom logo, but you need to add the image file.

### Step 1: Download the Logo

1. Open this link: https://gemini.google.com/share/ce7e9bd47710
2. Download/save the logo image
3. Save it as a PNG file (recommended for transparency)

### Step 2: Prepare the Image

**Recommended specifications:**
- Format: PNG (with transparent background)
- Size: 512x512 pixels (or any square size)
- Name: `nutrisnap_logo.png`

### Step 3: Add to Project

Copy the logo file to the assets folder:

```bash
cp ~/Downloads/your-logo-name.png assets/images/nutrisnap_logo.png
```

Or manually:
1. Navigate to your project folder
2. Go to `assets/images/` directory
3. Paste the logo file
4. Rename it to `nutrisnap_logo.png`

### Step 4: Run the App

```bash
flutter pub get
flutter run
```

## 🎨 Where the Logo Appears

### 1. **Splash Screen** (App Launch)
- Large logo (120x120) on gradient background
- "NutriSnap" text below logo
- "AI-Powered Calorie Tracking" tagline
- Loading indicator

### 2. **Camera Header** (Main Screen)
- Small logo (24x24) in top bar
- Next to "NutriSnap" text
- Gradient pill design

## 🔄 Fallback Behavior

If the logo image is not found:
- **Splash Screen**: Shows 🥗 emoji instead
- **Camera Header**: Shows 🥗 emoji instead

This ensures the app works even without the custom logo.

## 🛠️ Customization

### Change Logo Size (Camera Header)

Edit `lib/features/camera/camera_screen.dart` line ~372:

```dart
SizedBox(
  width: 32,  // Change this
  height: 32, // Change this
  child: Image.asset('assets/images/nutrisnap_logo.png'),
)
```

### Change Logo Size (Splash Screen)

Edit `lib/features/splash/splash_screen.dart` line ~17:

```dart
Container(
  width: 150,  // Change this
  height: 150, // Change this
  ...
)
```

### Change Splash Duration

Edit `lib/main.dart` line ~58:

```dart
await Future.delayed(const Duration(seconds: 3)); // Change duration
```

## 📁 Project Structure

```
calorie_tracker/
├── assets/
│   ├── data/
│   └── images/
│       └── nutrisnap_logo.png  ← Your logo goes here
├── lib/
│   ├── features/
│   │   ├── camera/
│   │   │   └── camera_screen.dart  ← Logo in header
│   │   └── splash/
│   │       └── splash_screen.dart  ← Logo on launch
│   └── main.dart  ← Splash integration
└── pubspec.yaml  ← Assets configuration
```

## ✅ Verification

After adding the logo, check:
1. App launches with splash screen showing your logo
2. Camera header shows your logo (not emoji)
3. No console errors about missing assets

## 🚨 Troubleshooting

### Logo Not Showing

1. **Check file path**:
   ```bash
   ls -la assets/images/nutrisnap_logo.png
   ```

2. **Verify pubspec.yaml** includes:
   ```yaml
   flutter:
     assets:
       - assets/images/
   ```

3. **Clean and rebuild**:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

### Still Using Emoji

- The emoji 🥗 appears if the logo file is missing or has wrong name
- Double-check file name is exactly: `nutrisnap_logo.png`
- File must be in: `assets/images/` directory

## 💡 Tips

- Use a transparent PNG for best results
- Square images work best (1:1 aspect ratio)
- Higher resolution (512x512 or 1024x1024) looks sharper
- Test on both light and dark backgrounds
