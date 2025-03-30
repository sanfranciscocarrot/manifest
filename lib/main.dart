import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:weather/weather.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:ui';

void main() {
  runApp(const MeditationApp());
}

class MeditationApp extends StatelessWidget {
  const MeditationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meditation App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  bool _showWelcome = false;
  bool _showQuestions = false;
  int _currentQuestion = 0;
  AnimationController? _welcomeController;
  Animation<double>? _welcomeOpacity;
  Animation<Offset>? _welcomeSlide;
  final TextEditingController _nameController = TextEditingController();
  String _selectedAge = '';
  String _selectedGender = '';
  String _selectedPurpose = '';
  Weather? _weather;
  bool _isLoading = true;

  // Controllers for question transitions
  final PageController _pageController = PageController();
  bool _isAnimating = false;

  final List<String> _ageOptions = ['18-25', '26-35', '36-45', '46+'];
  final List<String> _genderOptions = ['Male', 'Female', 'Others'];
  final List<String> _purposeOptions = [
    'Stress Relief',
    'Better Sleep',
    'Focus & Concentration',
    'Emotional Balance',
    'Spiritual Growth'
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _getWeather();
  }

  String _getWeatherDescription(int? code) {
    if (code == null) return 'Unknown';
    
    switch (code) {
      case 200: return 'Thunderstorm with light rain';
      case 201: return 'Thunderstorm with rain';
      case 202: return 'Thunderstorm with heavy rain';
      case 210: return 'Light thunderstorm';
      case 211: return 'Thunderstorm';
      case 212: return 'Heavy thunderstorm';
      case 221: return 'Ragged thunderstorm';
      case 230: return 'Thunderstorm with light drizzle';
      case 231: return 'Thunderstorm with drizzle';
      case 232: return 'Thunderstorm with heavy drizzle';
      case 300: return 'Light intensity drizzle';
      case 301: return 'Drizzle';
      case 302: return 'Heavy intensity drizzle';
      case 310: return 'Light intensity drizzle rain';
      case 311: return 'Drizzle rain';
      case 312: return 'Heavy intensity drizzle rain';
      case 313: return 'Shower rain and drizzle';
      case 314: return 'Heavy shower rain and drizzle';
      case 321: return 'Shower drizzle';
      case 500: return 'Light rain';
      case 501: return 'Moderate rain';
      case 502: return 'Heavy intensity rain';
      case 503: return 'Very heavy rain';
      case 504: return 'Extreme rain';
      case 511: return 'Freezing rain';
      case 520: return 'Light intensity shower rain';
      case 521: return 'Shower rain';
      case 522: return 'Heavy intensity shower rain';
      case 531: return 'Ragged shower rain';
      case 600: return 'Light snow';
      case 601: return 'Snow';
      case 602: return 'Heavy snow';
      case 611: return 'Sleet';
      case 612: return 'Light shower sleet';
      case 613: return 'Shower sleet';
      case 615: return 'Light rain and snow';
      case 616: return 'Rain and snow';
      case 620: return 'Light shower snow';
      case 621: return 'Shower snow';
      case 622: return 'Heavy shower snow';
      case 701: return 'Mist';
      case 711: return 'Smoke';
      case 721: return 'Haze';
      case 731: return 'Sand/dust whirls';
      case 741: return 'Fog';
      case 751: return 'Sand';
      case 761: return 'Dust';
      case 762: return 'Volcanic ash';
      case 771: return 'Squalls';
      case 781: return 'Tornado';
      case 800: return 'Clear sky';
      case 801: return 'Few clouds: 11-25%';
      case 802: return 'Scattered clouds: 25-50%';
      case 803: return 'Broken clouds: 51-84%';
      case 804: return 'Overcast clouds: 85-100%';
      default: return 'Unknown';
    }
  }

  IconData _getWeatherIcon(int? code) {
    if (code == null) return Icons.wb_sunny;
    
    if (code >= 200 && code < 300) return Icons.flash_on;
    if (code >= 300 && code < 400) return Icons.grain;
    if (code >= 500 && code < 600) return Icons.beach_access;
    if (code >= 600 && code < 700) return Icons.ac_unit;
    if (code >= 700 && code < 800) return Icons.cloud;
    if (code == 800) return Icons.wb_sunny;
    if (code > 800) return Icons.cloud;
    
    return Icons.wb_sunny;
  }

  Future<void> _getWeather() async {
    try {
      // Request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      
      if (permission == LocationPermission.denied) {
        print('Location permissions are denied');
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition();
      print('Location: ${position.latitude}, ${position.longitude}');
      
      // Fetch weather data
      WeatherFactory wf = WeatherFactory('64d6dcf54eefcfa7a409d578d6df4561');
      Weather weather = await wf.currentWeatherByLocation(
        position.latitude,
        position.longitude,
      );

      print('Weather Data:');
      print('Temperature: ${weather.temperature?.celsius}°C');
      print('Weather Condition: ${weather.weatherMain}');
      print('Description: ${weather.weatherDescription}');
      print('Humidity: ${weather.humidity}%');
      print('Wind Speed: ${weather.windSpeed} m/s');
      print('Weather Code: ${weather.weatherConditionCode}');
      print('Weather Code Description: ${_getWeatherDescription(weather.weatherConditionCode)}');

      setState(() {
        _weather = weather;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching weather: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Color _getWeatherColor() {
    if (_weather == null) return Colors.blue.shade200;
    
    // Get weather condition code
    int? condition = _weather!.weatherConditionCode;
    print('Weather Condition Code: $condition');
    
    // Return different colors based on weather condition
    if (condition == null) return Colors.blue.shade200;
    
    if (condition >= 200 && condition < 300) {
      return Colors.deepPurple.shade700; // Thunderstorm - deep purple
    } else if (condition >= 300 && condition < 400) {
      return Colors.indigo.shade400; // Drizzle - indigo
    } else if (condition >= 500 && condition < 600) {
      return Colors.blue.shade600; // Rain - blue
    } else if (condition >= 600 && condition < 700) {
      return Colors.lightBlue.shade100; // Snow - light blue
    } else if (condition >= 700 && condition < 800) {
      return Colors.blueGrey.shade400; // Atmosphere - blue grey
    } else if (condition == 800) {
      return Colors.lightBlue.shade300; // Clear - bright blue
    } else if (condition > 800) {
      // Different colors for different cloud conditions
      switch (condition) {
        case 801: return Colors.lightBlue.shade200; // Few clouds
        case 802: return Colors.blue.shade300; // Scattered clouds
        case 803: return Colors.blue.shade400; // Broken clouds
        case 804: return Colors.blue.shade500; // Overcast clouds
        default: return Colors.blue.shade400;
      }
    }
    
    return Colors.blue.shade200;
  }

  void _initializeAnimations() {
    _welcomeController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _welcomeOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _welcomeController!,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    ));

    _welcomeSlide = Tween<Offset>(
      begin: const Offset(0.0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _welcomeController!,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));

    // Show welcome message immediately
    setState(() {
      _showWelcome = true;
    });

    // Start the animation sequence
    _welcomeController!.forward().then((_) {
      // Wait for 1 second after the welcome message is shown
      Future.delayed(const Duration(seconds: 1), () {
        // Reverse the animation to fade out
        _welcomeController!.reverse().then((_) {
          // Show the questions after the welcome message fades out
          setState(() {
            _showWelcome = false;
            _showQuestions = true;
          });
        });
      });
    });
  }

  @override
  void dispose() {
    _welcomeController?.dispose();
    _nameController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextQuestion() {
    if (_currentQuestion < 4 && !_isAnimating) {
      _isAnimating = true;
      setState(() {
        _currentQuestion++;
      });
      
      _pageController.animateToPage(
        _currentQuestion,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      ).then((_) {
        _isAnimating = false;
      });
    }
  }

  void _previousQuestion() {
    if (_currentQuestion > 0 && !_isAnimating) {
      _isAnimating = true;
      setState(() {
        _currentQuestion--;
      });
      
      _pageController.animateToPage(
        _currentQuestion,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      ).then((_) {
        _isAnimating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Weather background layer
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _getWeatherColor(),
                  _getWeatherColor().withOpacity(0.8),
                ],
              ),
            ),
            child: _weather != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getWeatherIcon(_weather!.weatherConditionCode),
                          size: 80,
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ],
                    ),
                  )
                : null,
          ),
          
          // Frosted glass effect
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.01),
                    Colors.white.withOpacity(0.01),
                    Colors.white.withOpacity(0.01),
                  ],
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
          
          // Content
          SafeArea(
            child: _showWelcome ? _buildWelcomeScreen() : _buildQuestionsScreen(),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeScreen() {
    return SlideTransition(
      position: _welcomeSlide!,
      child: FadeTransition(
        opacity: _welcomeOpacity!,
        child: const Center(
          child: Text(
            'Hey there',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionsScreen() {
    if (!_showQuestions) return Container();

    return PageView(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildNameQuestion(),
        _buildAgeQuestion(),
        _buildGenderQuestion(),
        _buildPurposeQuestion(),
        _buildFinalScreen(),
      ],
    );
  }

  Widget _buildQuestionContainer(String question, Widget content) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Text(
                    question,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  content,
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (_currentQuestion > 0)
                ElevatedButton(
                  onPressed: _previousQuestion,
                  child: const Text('Previous'),
                ),
              if (_currentQuestion < 4)
                ElevatedButton(
                  onPressed: _nextQuestion,
                  child: const Text('Next'),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNameQuestion() {
    return _buildQuestionContainer(
      'What\'s your name?',
      TextField(
        controller: _nameController,
        decoration: const InputDecoration(
          hintText: 'Enter your name',
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
        autofocus: true,
      ),
    );
  }

  Widget _buildAgeQuestion() {
    return _buildQuestionContainer(
      'What\'s your age group?',
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _ageOptions.map((age) => _buildOptionButton(
          age,
          _selectedAge == age,
          () => setState(() => _selectedAge = age),
        )).toList(),
      ),
    );
  }

  Widget _buildGenderQuestion() {
    return _buildQuestionContainer(
      'What\'s your gender?',
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _genderOptions.map((gender) => _buildOptionButton(
          gender,
          _selectedGender == gender,
          () => setState(() => _selectedGender = gender),
        )).toList(),
      ),
    );
  }

  Widget _buildPurposeQuestion() {
    return _buildQuestionContainer(
      'What brings you here?',
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _purposeOptions.map((purpose) => _buildOptionButton(
          purpose,
          _selectedPurpose == purpose,
          () => setState(() => _selectedPurpose = purpose),
        )).toList(),
      ),
    );
  }

  Widget _buildFinalScreen() {
    return _buildQuestionContainer(
      'You\'re all set!',
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Let\'s begin your meditation journey',
            style: TextStyle(fontSize: 24, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const MeditationScreen(),
                ),
              );
            },
            child: const Text('Start this Journey'),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton(String text, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: () {
          onTap();
          if (_currentQuestion < 4) {
            Future.delayed(const Duration(milliseconds: 300), _nextQuestion);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.blue : Colors.white,
          foregroundColor: isSelected ? Colors.white : Colors.black,
          minimumSize: const Size(double.infinity, 50),
        ),
        child: Text(text),
      ),
    );
  }
}

class MeditationScreen extends StatefulWidget {
  const MeditationScreen({super.key});

  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen> with TickerProviderStateMixin {
  final List<String> _motivationalQuotes = [
    "Peace comes from within. Do not seek it without.",
    "The journey of a thousand miles begins with one step.",
    "Breathe in peace, breathe out tension.",
    "In the silence of meditation, find your true self.",
    "Every moment is a fresh beginning.",
    "Let go of what was, embrace what is.",
    "Your mind is a garden, your thoughts are the seeds.",
    "Find peace in the present moment.",
    "The quieter you become, the more you can hear.",
    "Inner peace begins the moment you choose not to allow another person or event to control your emotions.",
  ];

  String _currentQuote = '';
  bool _showQuote = false;
  bool _showSettings = false;
  AnimationController? _quoteController;
  Animation<double>? _quoteOpacity;
  Animation<Offset>? _quoteSlide;
  AnimationController? _settingsController;
  Animation<double>? _settingsOpacity;
  Animation<Offset>? _settingsSlide;

  // Settings state
  double _meditationDuration = 10.0;
  String _selectedVoice = 'Female';
  bool _enableBackgroundSounds = true;
  double _backgroundVolume = 0.5;
  String _selectedTheme = 'Calm Blue';

  @override
  void initState() {
    super.initState();
    _initializeQuoteAnimation();
    _initializeSettingsAnimation();
    _updateQuote();
  }

  void _initializeQuoteAnimation() {
    _quoteController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _quoteOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _quoteController!,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    ));

    _quoteSlide = Tween<Offset>(
      begin: const Offset(0.0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _quoteController!,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));
  }

  void _initializeSettingsAnimation() {
    _settingsController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _settingsOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _settingsController!,
      curve: Curves.easeInOut,
    ));

    _settingsSlide = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _settingsController!,
      curve: Curves.easeOut,
    ));
  }

  void _updateQuote() {
    setState(() {
      _showQuote = false;
      _quoteController?.reset();
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _currentQuote = _motivationalQuotes[DateTime.now().millisecondsSinceEpoch % _motivationalQuotes.length];
        _showQuote = true;
        _quoteController?.forward();
      });
    });
  }

  void _toggleSettings() {
    setState(() {
      _showSettings = !_showSettings;
      if (_showSettings) {
        _settingsController?.forward();
      } else {
        _settingsController?.reverse();
      }
    });
  }

  @override
  void dispose() {
    _quoteController?.dispose();
    _settingsController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.blue.shade900,
                  Colors.blue.shade800,
                ],
              ),
            ),
          ),
          
          // Content
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: _showQuote && _quoteSlide != null && _quoteOpacity != null
                          ? SlideTransition(
                              position: _quoteSlide!,
                              child: FadeTransition(
                                opacity: _quoteOpacity!,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                                  child: Text(
                                    _currentQuote,
                                    key: ValueKey<String>(_currentQuote),
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w300,
                                      color: Colors.white,
                                      height: 1.5,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            )
                          : null,
                    ),
                  ),
                ),
                
                // Bottom buttons
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Left button
                      _buildCircularButton(
                        icon: Icons.play_arrow_rounded,
                        onTap: _updateQuote,
                      ),
                      
                      // Right button (Settings)
                      _buildCircularButton(
                        icon: Icons.menu_rounded,
                        onTap: _toggleSettings,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Settings Panel
          if (_showSettings && _settingsSlide != null && _settingsOpacity != null)
            Material(
              color: Colors.transparent,
              child: GestureDetector(
                onTap: _toggleSettings,
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  child: SlideTransition(
                    position: _settingsSlide!,
                    child: FadeTransition(
                      opacity: _settingsOpacity!,
                      child: Container(
                        margin: const EdgeInsets.only(top: 100),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(30),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 12),
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Settings',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  _buildSettingItem(
                                    'Meditation Duration',
                                    '${_meditationDuration.round()} minutes',
                                    Slider(
                                      value: _meditationDuration,
                                      min: 5,
                                      max: 60,
                                      divisions: 11,
                                      label: '${_meditationDuration.round()}',
                                      onChanged: (value) {
                                        setState(() {
                                          _meditationDuration = value;
                                        });
                                      },
                                    ),
                                  ),
                                  _buildSettingItem(
                                    'Voice Guide',
                                    _selectedVoice,
                                    DropdownButton<String>(
                                      value: _selectedVoice,
                                      items: ['Male', 'Female'].map((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        if (newValue != null) {
                                          setState(() {
                                            _selectedVoice = newValue;
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                  _buildSettingItem(
                                    'Background Sounds',
                                    _enableBackgroundSounds ? 'On' : 'Off',
                                    Switch(
                                      value: _enableBackgroundSounds,
                                      onChanged: (bool value) {
                                        setState(() {
                                          _enableBackgroundSounds = value;
                                        });
                                      },
                                    ),
                                  ),
                                  if (_enableBackgroundSounds)
                                    _buildSettingItem(
                                      'Sound Volume',
                                      '${(_backgroundVolume * 100).round()}%',
                                      Slider(
                                        value: _backgroundVolume,
                                        min: 0,
                                        max: 1,
                                        divisions: 10,
                                        label: '${(_backgroundVolume * 100).round()}%',
                                        onChanged: (value) {
                                          setState(() {
                                            _backgroundVolume = value;
                                          });
                                        },
                                      ),
                                    ),
                                  _buildSettingItem(
                                    'Theme',
                                    _selectedTheme,
                                    DropdownButton<String>(
                                      value: _selectedTheme,
                                      items: ['Calm Blue', 'Deep Purple', 'Ocean Green'].map((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        if (newValue != null) {
                                          setState(() {
                                            _selectedTheme = newValue;
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCircularButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.1),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }

  Widget _buildSettingItem(String title, String value, Widget control) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          control,
        ],
      ),
    );
  }
}
