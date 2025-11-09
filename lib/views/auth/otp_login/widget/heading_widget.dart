part of '../screen/otp_login_screen.dart';

class HeadingWidget extends StatelessWidget {
  const HeadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: Dimensions.verticalSize),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            child: TextWidget(
              padding: EdgeInsets.only(bottom: Dimensions.verticalSize * 0.1),
              textAlign: TextAlign.center,
              Strings.login,
              fontWeight: FontWeight.bold,
              typographyStyle: TypographyStyle.titleLarge,
            ),
          ),
          TextWidget(
            maxLines: 3,
            'Enter your mobile number to receive a verification code via WhatsApp',
            fontWeight: FontWeight.w400,
            typographyStyle: TypographyStyle.labelLarge,
            colorShade: ColorShade.mediumForty,
          ),
        ],
      ),
    );
  }
}
