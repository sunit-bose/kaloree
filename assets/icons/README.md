# Kaloree App Icons

This directory contains the app icon assets for Kaloree.

## Required Files

Based on the brand kit, you need to add these image files:

### App Icon (Main)
- **`app_icon.png`** - 1024x1024 pixels
  - Used for iOS App Store and as base for Android
  - Should be the flame logo on purple background (#2D0B3D)

### Adaptive Icon (Android)
- **`app_icon_foreground.png`** - 1024x1024 pixels with transparent background
  - Just the flame logo, centered with safe area padding
  - Background color is set to #2D0B3D in config

### Splash Screen
- **`splash_logo.png`** - 512x512 pixels
  - Flame logo for native splash screen
  - Should have transparent background

## Brand Colors (From Brand Kit)

```css
/* Background gradient */
--gradient-background: linear-gradient(135deg, #2D0B3D 0%, #5C1A66 50%, #2D0B3D 100%);

/* Flame gradient */
--gradient-flame: linear-gradient(135deg, #FFA726 0%, #FF6B35 35%, #FF2E7E 70%, #E91E8C 100%);

/* Glow overlay */
--gradient-glow: linear-gradient(180deg, rgba(255,167,38,0.3) 0%, rgba(233,30,140,0.3) 100%);
```

## Color Palette

| Color | Hex | Usage |
|-------|-----|-------|
| Deep Purple | #2D0B3D | Background |
| Mid Purple | #5C1A66 | Gradient center |
| Flame Orange | #FFA726 | Flame top |
| Deep Orange | #FF6B35 | Flame middle |
| Flame Pink | #FF2E7E | Flame lower |
| Magenta | #E91E8C | Flame base |

## Generating Icons

After adding the PNG files, run:

```bash
flutter pub get
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

## Asset Sizes Reference (From Brand Kit)

- iOS App Store Icon: 1024x1024
- Android Adaptive: 192x192, 144x144, 96x96, 72x72, 48x48
- Splash Screen: 1080x1920 (portrait)
- Full Width Banner: 1080x540
- Profile Image: 512x512
- Thumbnail: 300x300
