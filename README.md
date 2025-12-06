iPrayer: Your All-in-One Islamic Companion

iPrayer is a beautifully designed, modern iOS application built with SwiftUI that provides essential tools and resources for daily Islamic life. It features accurate prayer times, a digital Tasbih counter, a Qibla compass, and the full text of the Holy Quran.

✨ Features

iPrayer is divided into five main functional modules, accessible via a custom floating tab bar:

1. Prayer Times (Salah)

Accurate Calculations: Fetches prayer times (Fajr, Sunrise, Dhuhr, Asr, Maghrib, Isha) based on the user's current GPS location using the highly reliable Adhan Swift Package.

Real-time Countdown: Displays a dynamic countdown timer to the next upcoming prayer.

Local Notifications: Schedules local notifications for each prayer time, using a custom Adhan sound (adhan.mp3) for alert.

Customizable Settings: Users can adjust calculation methods (e.g., Muslim World League, Egyptian, ISNA) and juristic methods (Shafi/Standard or Hanafi) to ensure accuracy based on their school of thought.

2. Qibla Compass

Direction Finder: Calculates and displays the precise direction of the Kaaba (Qibla) in Mecca based on the device's location.

Interactive Compass: Uses CoreLocation to provide a live, rotating compass dial.

Visual Feedback: Provides clear visual indicators and text status when the user is accurately facing the Qibla (within 5 degrees).

3. The Holy Quran (Digital Mushaf)

Full Surah Index: Fetches a complete list of all 114 Surahs (chapters) of the Quran, including Arabic name, English name, translation, and number of Ayahs (verses), using the alquran.cloud API.

Verse Display: Allows users to tap a Surah to view its full text, rendered in the classic Uthmani script (Arabic text).

Structure: Displays the Basmala (In the name of God, the Most Gracious, the Most Merciful) at the start of each Surah (with exceptions for Surah At-Tawbah).

4. Digital Tasbih Counter

Zikr/Dhikr Counter: A simple, yet interactive digital counter for repeating praises (Tasbih/Dhikr).

Cycle Tracking: Tracks the count and displays progress on a circular ring towards a common cycle target (default: 33 taps).

Haptic Feedback: Provides satisfying haptic feedback (vibration) on each tap, with special feedback when a cycle is completed.

Persistence: The count is saved locally using AppStorage to maintain progress across sessions.

5. Settings

A dedicated view for configuring the prayer time calculation parameters (method and madhab).

🛠️ Technology Stack

Platform: iOS

UI Framework: SwiftUI

Language: Swift

External Dependencies:

adhan-swift: A remote Swift Package used for highly accurate Islamic prayer time calculation and Qibla direction.

APIs:

alquran.cloud: Used to fetch the list of Surahs and the detailed Arabic text for the Quran view.

Core Services:

CoreLocation: For accessing the user's GPS coordinates for prayer calculations and magnetic heading for the Qibla compass.

UserNotifications: For scheduling local alerts for prayer times with the custom adhan.mp3 sound.

📐 Architecture & Structure

The app follows a modern MVVM (Model-View-ViewModel) pattern typical for complex SwiftUI applications:

iPrayerApp.swift: The main entry point, handling the app lifecycle, notification permissions, and managing the SplashScreenView.

ContentView.swift: The main tab container, which manages the custom floating tab bar and switches between the five primary views.

PrayerViewModel.swift: Manages all location updates, communicates with the Adhan library to calculate and publish prayer times and Qibla direction, and schedules notifications.

PrayerListView.swift: Displays the prayer times in an aesthetically pleasing "Glass Card" design with a large countdown timer.

QuranViewModel.swift / SurahDetailViewModel.swift: Handles asynchronous network fetching of Quran metadata and individual Surah verses, respectively.

QiblaCompassView.swift: Renders the graphical compass and the Qibla indicator, reacting to real-time heading updates from the PrayerViewModel.

TasbihView.swift: Contains the logic and UI for the digital counter, including haptic feedback and progress tracking.
