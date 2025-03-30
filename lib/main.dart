import 'package:flutter/material.dart';

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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade200,
              Colors.blue.shade100,
            ],
          ),
        ),
        child: SafeArea(
          child: _showWelcome ? _buildWelcomeScreen() : _buildQuestionsScreen(),
        ),
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
            'Welcome to\nYour Meditation Journey',
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
      ),
    );
  }

  Widget _buildAgeQuestion() {
    return _buildQuestionContainer(
      'What\'s your age group?',
      Column(
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
              // Navigate to main app screen
              print('Starting meditation journey...');
            },
            child: const Text('Start Meditating'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionContainer(String question, Widget content) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            question,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          content,
          const SizedBox(height: 30),
          Row(
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
