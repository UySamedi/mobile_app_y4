import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
// import 'package:google_fonts/google_fonts.dart';
import '../Auth/LoginScreen.dart';
import 'MainNav.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  Future<void> _completeOnboardingAndNavigate(BuildContext context) async {
    final box = GetStorage();
    await box.write('onboarding', true);

    // If there's already a token stored, go to main; otherwise go to login
    final token = box.read('token') ?? '';
    if (token != null && token.toString().isNotEmpty) {
      // token exists - navigate to main
      Get.offAll(() => const MainNav());
    } else {
      Get.offAll(() => LoginScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show a single onboarding page (matching the design: large illustration, title, subtitle, Start Now button)
    return Scaffold(
      body: SafeArea(
        child: HomePageTemplate(
          controller: null,
          activePage: 2,
          pageIndex: 2,
          title: "Find Your Perfect Room",
          subtitle:
              "Browse, compare, and book rooms near you in just a few taps. Comfort and convenience, made simple.",
          imagePath: "assets/images/onboarding_img.png",
        ),
      ),
    );
  }
}

class Constants {
  static final Color primaryColor = Color.fromRGBO(71, 148, 255, 1);
  static final Color highlightColor = Color.fromRGBO(71, 148, 255, 0.2);
  static final Color highlightColor2 = Color.fromRGBO(71, 148, 255, 0.3);
}

class HomePageTemplate extends StatelessWidget {
  final int activePage;
  final int pageIndex;
  final PageController? controller;
  final String imagePath;
  final String title;
  final String subtitle;

  const HomePageTemplate(
      {super.key,
      required this.activePage,
      required this.pageIndex,
      this.controller,
      required this.imagePath,
      required this.title,
      required this.subtitle});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height,
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: AssetImage(imagePath),
                    ),
                  ),
                ),
                // Top small progress indicators (centered)
                Positioned(
                  top: 40,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        width: index == activePage ? 24 : 10,
                        height: 6,
                        decoration: BoxDecoration(
                          color: index == activePage
                              ? Constants.primaryColor
                              : Constants.highlightColor2,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            constraints: BoxConstraints(minWidth: size.height * 0.4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 26.0,
                    height: 1.5,
                    color: Color.fromRGBO(33, 45, 82, 1),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(
                  height: 12.0,
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14.0,
                    color: Color.fromRGBO(64, 74, 106, 1),
                  ),
                ),
                const SizedBox(
                  height: 30.0,
                ),
                PrimaryButton(
                  text: pageIndex == 2 ? "Start Now" : "Next",
                  onPressed: () {
                    if (pageIndex < 2) {
                      controller?.animateToPage(pageIndex + 1,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut);
                    } else {
                      // Call the parent's onboarding completion helper
                      final state = context.findAncestorStateOfType<_OnboardingScreenState>();
                      state?._completeOnboardingAndNavigate(context);
                    }
                  },
                )
              ],
            ),
          ),
          Center(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              runAlignment: WrapAlignment.center,
              children: [
                const Text(
                  "Already have an account?",
                  style: TextStyle( // GoogleFonts.inter
                    fontSize: 14.0,
                    color: Color.fromRGBO(64, 74, 106, 1),
                  ),
                ),
                TextButton(
                  onPressed: () => Get.to(() => LoginScreen()),
                  child: Text(
                    "Log In",
                    style: TextStyle( // GoogleFonts.inter
                      fontSize: 14.0,
                      color: Constants.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(
            height: 15.0,
          ),
        ],
      ),
    );
  }
}

class PageIndicator extends StatelessWidget {
  final int activePage;
  const PageIndicator({super.key, required this.activePage});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        3,
        (index) => Container(
          width: index == activePage ? 22.0 : 10.0,
          height: 10.0,
          margin: const EdgeInsets.only(right: 10.0),
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(index == activePage ? 10.0 : 50.0),
            color: index == activePage
                ? Constants.primaryColor
                : Constants.highlightColor2,
          ),
        ),
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;

  const PrimaryButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:onPressed,
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: Constants.primaryColor,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(169, 176, 185, 0.42),
              spreadRadius: 0,
              blurRadius: 8.0,
              offset: Offset(0, 2),
            )
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle( // GoogleFonts.roboto
              color: Colors.white,
              fontSize: 16.0,
            ),
          ),
        ),
      ),
    );
  }
}