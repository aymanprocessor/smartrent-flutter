part of 'congratulations_screen.dart';

class CongratulationsMobileScreen extends StatelessWidget {
  CongratulationsMobileScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    appBar: const CustomAppBar(Strings.confirmation, showBackButton: false),
    body: _bodyWidget(context),
  );

  _bodyWidget(BuildContext context) => SafeArea(
    child: WillPopScope(
      onWillPop: () async {
        Get.offAllNamed(Routes.dashboardScreen);
        return true;
      },
      child: Column(
        mainAxisAlignment: mainCenter,
        children: [CongratulationsMain(), CongratulationsButton()],
      ),
    ),
  );
}
