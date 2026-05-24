import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/preferences_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Map<String, String>> _slides = [
    {
      'title': 'Write Faster with AI',
      'body': 'Generate structure, refine tone, and overcome writer\'s block instantly.',
      'icon': 'AutoAwesome',
    },
    {
      'title': 'Stay Organized',
      'body': 'Keep all your scripts in project folders — YouTube, TikTok, Podcast, and more.',
      'icon': 'FolderSpecial',
    },
    {
      'title': 'Record with Confidence',
      'body': 'Launch the teleprompter anywhere. Your words, your pace.',
      'icon': 'PlayCircle',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = kIsWeb || MediaQuery.of(context).size.width >= 900;
    
    Widget content = _buildCarousel(context);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: isDesktop
          ? Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560, maxHeight: 600),
                child: Card(
                  color: AppColors.bgSurface,
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: content,
                  ),
                ),
              ),
            )
          : SafeArea(
              child: content,
            ),
    );
  }

  Widget _buildCarousel(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: _slides.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Placeholder for illustration
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: AppColors.accentBlue.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        index == 0 ? Icons.auto_awesome : (index == 1 ? Icons.folder_special : Icons.play_circle_filled),
                        size: 80,
                        color: AppColors.accentBlue,
                      ),
                    ),
                    const SizedBox(height: 64),
                    Text(
                      _slides[index]['title']!,
                      style: Theme.of(context).textTheme.displaySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _slides[index]['body']!,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        // Bottom Controls
        Padding(
          padding: const EdgeInsets.all(32.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Page Indicators
              Row(
                children: List.generate(
                  _slides.length,
                  (index) => Container(
                    margin: const EdgeInsets.only(right: 8),
                    height: 8,
                    width: _currentIndex == index ? 24 : 8,
                    decoration: BoxDecoration(
                      color: _currentIndex == index ? AppColors.accentBlue : AppColors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              // Next / Start Button
              ElevatedButton(
                onPressed: () async {
                  if (_currentIndex == _slides.length - 1) {
                    await PreferencesService.instance
                        .setOnboardingComplete(true);
                    if (context.mounted) context.go('/projects');
                  } else {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                child: Text(
                  _currentIndex == _slides.length - 1 ? 'Get Started' : 'Next',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
