part of '../screen/otp_login_screen.dart';

class HaveAccountWidget extends StatelessWidget {
  const HaveAccountWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextWidget(
          'Or',
          typographyStyle: TypographyStyle.bodyMedium,
        ),
        SizedBox(width: 5),
        InkWell(
          onTap: () {
            Get.toNamed(Routes.loginScreen);
          },
          child: TextWidget(
            Strings.loginWithPassword,
            color: CustomColor.primary,
            fontWeight: FontWeight.w600,
            typographyStyle: TypographyStyle.bodyMedium,
          ),
        ),
      ],
    );
  }
}
