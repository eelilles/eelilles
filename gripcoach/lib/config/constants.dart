/// GripCoach - Core Constants
/// All teaching values and thresholds for the app

// ignore_for_file: constant_identifier_names

/// Gravity constant (m/s²)
const double G = 9.81;

/// Friction coefficients (mu_avail) by road condition
const Map<String, double> FRICTION_MU = {
  'dry': 0.80,
  'wet': 0.55,
  'snow': 0.30,
  'ice': 0.10,
};

/// Driver profiles with safety factor (S) and reaction time (t_react)
const Map<String, Map<String, double>> DRIVER_PROFILES = {
  'new': {'S': 0.55, 't_react': 1.5},
  'intermediate': {'S': 0.70, 't_react': 1.2},
  'experienced': {'S': 0.85, 't_react': 1.0},
};

/// Road sensitivity multipliers for jerk thresholds
const Map<String, double> ROAD_SENSITIVITY = {
  'ice': 0.60,
  'snow': 0.75,
  'wet': 0.90,
  'dry': 1.00,
};

/// Recommended following distance in seconds by road condition
const Map<String, int> HEADWAY_SECONDS = {
  'dry': 2,
  'wet': 3,
  'snow': 4,
  'ice': 6,
};

// ============ Motion Lock Thresholds ============

/// Speed threshold for locking controls (km/h)
const double MOTION_LOCK_SPEED_KMH = 5.0;

/// Speed threshold for locking controls (mph)
const double MOTION_LOCK_SPEED_MPH = 3.0;

/// Speed threshold for unlocking controls (km/h)
const double MOTION_UNLOCK_SPEED_KMH = 2.0;

/// Duration required at low speed to unlock (seconds)
const double MOTION_UNLOCK_DURATION_S = 3.0;

// ============ Traction Bar Thresholds ============

/// Green zone upper limit (fraction of traction budget)
const double GREEN_THRESHOLD = 0.60;

/// Yellow zone upper limit (fraction of traction budget)
const double YELLOW_THRESHOLD = 0.85;

/// Red zone upper limit (at 1.0, exceeding budget)
const double RED_THRESHOLD = 1.00;

/// Hysteresis for color transitions
const double COLOR_HYSTERESIS = 0.03;

/// Duration for traction exceedance event (seconds)
const double TRACTION_EXCEEDANCE_DURATION = 0.3;

// ============ LED Bar Configuration ============

/// Number of segments in left/right LED bars
const int LED_BAR_SEGMENTS = 14;

/// Animation duration for LED bar updates (ms)
const int LED_BAR_ANIMATION_MS = 250;

// ============ Smoothing Time Constants ============

/// Display path EMA time constant (seconds) - smoother for UI
const double DISPLAY_TAU_S = 0.8;

/// Event path EMA time constant (seconds) - faster for event detection
const double EVENT_TAU_S = 0.15;

// ============ Auto Grade Estimation ============

/// EMA time constant for grade estimation (seconds)
const double GRADE_TAU_S = 10.0;

/// Maximum grade change rate (%/second)
const double GRADE_MAX_RATE = 1.0;

/// Duration required for steady-state detection (seconds)
const double STEADY_STATE_DURATION_S = 3.0;

/// Minimum speed for grade updates (km/h)
const double STEADY_STATE_SPEED_MIN_KMH = 15.0;

/// Maximum acceleration for steady-state (g units)
const double STEADY_STATE_ACCEL_MAX_G = 0.05;

// ============ Grade Slider ============

/// Minimum grade value (%)
const double GRADE_MIN_PERCENT = -12.0;

/// Maximum grade value (%)
const double GRADE_MAX_PERCENT = 12.0;

/// Preset grade values (%)
const List<double> GRADE_PRESETS = [-10, -6, -3, 0, 3, 6, 10];

// ============ Jerk Detection Thresholds ============

/// Base threshold for yaw jerk (rad/s²) - Dry, Sedan
const double JERK_YAW_THRESHOLD = 2.0;

/// Base threshold for lateral jerk (m/s³) - Dry, Sedan
const double JERK_LAT_THRESHOLD = 3.0;

/// Base threshold for longitudinal jerk (m/s³) - Dry, Sedan
const double JERK_LONG_THRESHOLD = 2.5;

/// Base threshold for delta yaw rate (rad/s) over 200ms
const double DELTA_YAW_RATE_THRESHOLD = 0.25;

/// Minimum speed for steering jerk detection (km/h)
const double JERK_STEERING_MIN_SPEED_KMH = 20.0;

/// Minimum speed for brake jerk detection (km/h)
const double JERK_BRAKE_MIN_SPEED_KMH = 10.0;

/// Cooldown between jerk events (seconds)
const double JERK_EVENT_COOLDOWN_S = 3.0;

/// Duration to show "Choppy" label (seconds)
const double CHOPPY_DISPLAY_DURATION_S = 3.0;

// ============ Sensor Configuration ============

/// Target sensor update rate (Hz)
const int SENSOR_RATE_HZ = 50;

/// GPS update interval (seconds)
const int GPS_UPDATE_INTERVAL_S = 1;

/// Session data logging rate (Hz)
const int SESSION_LOG_RATE_HZ = 5;

// ============ Calibration ============

/// Duration for calibration capture (seconds)
const double CALIBRATION_DURATION_S = 3.0;

/// Expected gravity magnitude (m/s²)
const double EXPECTED_GRAVITY = 9.81;

/// Acceptable variance during calibration (m/s²)
const double CALIBRATION_VARIANCE_MAX = 0.3;

// ============ Unit Conversions ============

/// Meters to feet conversion
const double METERS_TO_FEET = 3.28084;

/// km/h to m/s conversion
const double KMH_TO_MS = 1.0 / 3.6;

/// mph to m/s conversion
const double MPH_TO_MS = 0.44704;

/// Average car length (meters) for display
const double CAR_LENGTH_M = 4.5;

// ============ Disclaimer Text ============

const String DISCLAIMER_ONBOARDING = '''
GripCoach is for education and coaching only.

It does not detect actual road friction and does not replace safe driving judgment.

Set options while parked. Do not interact while driving. Always follow local laws and drive according to conditions.
''';

const String DISCLAIMER_SETUP_FOOTER = 'Educational tool only. Not a safety device.';

const String DISCLAIMER_MOTION_LOCK = 'Controls locked while moving. Pull over safely to adjust settings.';
