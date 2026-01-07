import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
import '../Auth/LoginScreen.dart';
import 'MainNav.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  PageController controller = PageController();
  int currentPage = 0;

  @override
  void initState() {
    controller.addListener(() {
      setState(() {
        currentPage = controller.page?.round() ?? 0;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: controller,
        children: [
          HomePageTemplate(
            activePage: currentPage,
            title: "Let's Find Peace with Comfort",
            imagePath: "assets/images/page1.png",
          ),
          HomePageTemplate(
            activePage: currentPage,
            title: "Let's Find Peace with Comfort",
            imagePath: "assets/images/page2.png",
          ),
          HomePageTemplate(
            activePage: currentPage,
            title: "Let's Find Peace with Comfort",
            imagePath: "assets/images/page1.png",
          ),
        ],
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
  final String imagePath;
  final String title;

  const HomePageTemplate(
      {super.key,
      required this.activePage,
      required this.imagePath,
      required this.title});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height,
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.fill,
                  image: AssetImage(
                    imagePath,
                  ),
                ),
              ),
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
                  height: 15.0,
                ),
                PageIndicator(activePage: activePage),
                const SizedBox(
                  height: 50.0,
                ),
                PrimaryButton(
                  text: "Get Started",
                  onPressed: () => Get.offAll(() => const MainNav()),
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