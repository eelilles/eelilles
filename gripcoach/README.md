# GripCoach

A teaching/coaching Flutter app for new drivers that visualizes traction usage and stopping distance in real-time.

## Overview

GripCoach helps driving instructors and parents teach new drivers about:
- **Traction Budget**: How much grip is being used for steering, braking, and acceleration
- **Stopping Distance**: How far it takes to stop based on speed, road conditions, and grade
- **Smooth Driving**: Detection and feedback on jerky inputs

**Important**: This is an educational tool only. It does not detect actual road friction and does not replace safe driving judgment.

## Features

### Live Traction Bars View
- Three LED-style bars showing left/right/center traction usage
- Color-coded zones: Green (safe) → Yellow (caution) → Red (danger)
- Real-time smoothness indicator (Smooth/Choppy)

### Live Stopping Distance View
- Large display showing total stopping distance
- Breakdown into reaction + braking distance
- Grade-adjusted calculations with warnings

### Safety Features
- **Motion Lock**: All settings and mode changes are locked when speed > 5 km/h
- **No Background Location**: Only uses location while app is open
- **No Gamification**: No scores, challenges, or leaderboards
- **Safety Disclaimers**: Prominent warnings about not interacting while driving

### Post-Drive Review
- Traction usage breakdown (time in each zone)
- Teachable moments list with timestamps
- Self-reflection questions for learning

## Getting Started

### Prerequisites
- Flutter SDK (3.0.0 or later)
- Dart SDK (3.0.0 or later)
- Android Studio or Xcode for device deployment

### Installation

1. **Clone the repository**
   ```bash
   cd gripcoach
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run on device/simulator**
   ```bash
   # Android
   flutter run -d android

   # iOS
   flutter run -d ios

   # List available devices
   flutter devices
   ```

### Testing on Simulator
The app includes a `MockSensorService` for testing without real sensors. This is automatically used in the current build. For production, replace `MockSensorService` with `SensorService` in `live_screen.dart`.

## Permissions

### iOS
- **Location (When In Use)**: Required for speed calculation
- **Motion & Fitness**: Required for accelerometer and gyroscope

### Android
- **Fine Location**: Required for GPS speed
- **Motion Sensors**: Required for accelerometer and gyroscope (no permission needed)

## Project Structure

```
lib/
├── main.dart              # App entry point
├── app.dart               # MaterialApp configuration
├── config/
│   ├── constants.dart     # All teaching values and thresholds
│   └── theme.dart         # Visual theme (dark mode)
├── models/
│   ├── session_settings.dart   # User-configurable settings
│   ├── session_data.dart       # Complete session data
│   ├── driving_event.dart      # Event types (jerk, exceedance)
│   ├── data_point.dart         # Time-series data point
│   ├── calibration_data.dart   # Phone→vehicle transform
│   └── tuning_params.dart      # Dev-adjustable parameters
├── providers/
│   ├── app_state.dart          # Global app state
│   ├── session_provider.dart   # Active session state
│   └── tuning_provider.dart    # Dev tuning state
├── services/
│   ├── sensor_service.dart         # Accelerometer, gyro, GPS
│   ├── calibration_service.dart    # Mount calibration flow
│   ├── signal_processor.dart       # EMA smoothing, derivatives
│   ├── traction_calculator.dart    # Friction circle math
│   ├── stopping_calculator.dart    # Stopping distance math
│   ├── jerk_detector.dart          # Jerky input detection
│   ├── grade_estimator.dart        # Auto grade estimation
│   ├── storage_service.dart        # Local session storage
│   └── permission_service.dart     # Permission handling
├── screens/
│   ├── setup_screen.dart       # Settings configuration
│   ├── calibration_screen.dart # Mount calibration
│   ├── checklist_screen.dart   # Pre-drive checklist
│   ├── live_screen.dart        # Live driving display
│   ├── debrief_screen.dart     # Post-drive reflection
│   ├── review_screen.dart      # Session review
│   └── dev_screen.dart         # Hidden tuning screen
├── widgets/
│   ├── led_bar.dart                    # Vertical LED bar
│   ├── center_bar.dart                 # Split accel/brake bar
│   ├── speed_display.dart              # Large speed number
│   ├── grade_display.dart              # Grade indicator
│   ├── following_distance_card.dart    # Distance recommendation
│   ├── stopping_distance_display.dart  # Big stopping number
│   ├── smoothness_label.dart           # Smooth/Choppy label
│   └── motion_lock_banner.dart         # Lock warning banner
└── utils/
    └── conversions.dart    # Unit conversion helpers
```

## Dependencies

| Package | Purpose |
|---------|---------|
| `provider` | State management |
| `sensors_plus` | Accelerometer and gyroscope access |
| `geolocator` | GPS location and speed |
| `shared_preferences` | Persistent settings storage |
| `path_provider` | File system access for sessions |
| `vector_math` | Matrix operations for calibration |
| `uuid` | Unique session identifiers |

## Technical Details

### Traction Calculation
```
mu_budget = mu_avail × safety_factor
long_frac = |a_long| / (g × mu_budget)
lat_frac = |a_lat| / (g × mu_budget)
combined_frac = sqrt(a_long² + a_lat²) / (g × mu_budget)
```

### Stopping Distance Calculation
```
v = speed_kmh / 3.6  (convert to m/s)
eff_mu = mu_avail + grade  (grade adjustment)
d_reaction = v × t_react
d_brake = v² / (2 × g × eff_mu)
d_total = d_reaction + d_brake
```

### Default Values
| Road | μ (friction) |
|------|-------------|
| Dry | 0.80 |
| Wet | 0.55 |
| Snow | 0.30 |
| Ice | 0.10 |

| Driver | Safety Factor | Reaction Time |
|--------|--------------|---------------|
| New | 0.55 | 1.5s |
| Intermediate | 0.70 | 1.2s |
| Experienced | 0.85 | 1.0s |

## Hidden Dev Mode

Tap the settings icon in the Setup screen 7 times to access the dev tuning screen. This allows adjustment of:
- Smoothing time constants
- Jerk detection thresholds
- Motion lock thresholds
- Traction color thresholds
- Road sensitivity multipliers

## Building for Release

### Android
```bash
flutter build apk --release
# or for App Bundle
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## Safety & Compliance Notes

1. **Store Safety**: No gamification elements that could encourage unsafe driving
2. **Minimal Permissions**: Only requests location while app is in use
3. **Motion Lock**: Controls are disabled while vehicle is moving
4. **Educational Purpose**: Clear disclaimers that this is a teaching tool

## License

MIT License - See LICENSE file for details.

## Contributing

This is an MVP implementation. Contributions welcome for:
- Real device sensor testing and calibration
- Additional teaching visualizations
- Improved event detection algorithms
- Unit and integration tests
