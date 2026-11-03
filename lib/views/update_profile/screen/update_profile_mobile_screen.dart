part of 'update_profile_screen.dart';

class UpdateProfileMobileScreen extends GetView<UpdateProfileController> {
  const UpdateProfileMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else {
            Get.offAllNamed(Routes.dashboardScreen);
          }
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: _buildAppBar(context),
        body: Obx(() {
          if (controller.isLoading) {
            return const ProfileLoadingSkeleton();
          }
          return _buildBody(context);
        }),
        bottomNavigationBar: Obx(
          () => controller.isLoading ? const SizedBox.shrink() : _buildBottomButton(context),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────
  //  APP BAR
  // ────────────────────────────────────────────────────────────────
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      leadingWidth: 64,
      leading: Padding(
        padding: const EdgeInsetsDirectional.only(start: 12),
        child: Center(
          child: Material(
            color: const Color(0xFFF1F5F9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                } else {
                  Get.offAllNamed(Routes.dashboardScreen);
                }
              },
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
          ),
        ),
      ),
      title: Text(
        DynamicLanguage.key(Strings.editProfile),
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Color(0xFF0F172A),
          letterSpacing: -0.2,
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────
  //  BODY
  // ────────────────────────────────────────────────────────────────
  Widget _buildBody(BuildContext context) {
    return Form(
      key: controller.formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        physics: const BouncingScrollPhysics(),
        children: [
          // Hero Profile Card
          _buildHeroCard(context),
          const SizedBox(height: 20),

          // Section 1: Personal Info
          _buildPersonalInfoCard(context),
          const SizedBox(height: 16),

          // Section 2: Contact Info
          _buildContactCard(context),
          const SizedBox(height: 16),

          // Section 3: Address Info
          _buildAddressCard(context),
          const SizedBox(height: 20),

          // Section 4: Account Actions / Danger Zone
          _buildDangerZoneCard(context),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────
  //  HERO CARD (Brand Gradient with Interactive Avatar)
  // ────────────────────────────────────────────────────────────────
  Widget _buildHeroCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            CustomColor.primary,
            const Color(0xFF063A66),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: CustomColor.primary.withValues(alpha: 0.28),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Ambient decorative circles
          Positioned(
            top: -30,
            right: -20,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),

          // Profile Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildAvatarWidget(context),
              const SizedBox(height: 14),

              // Name
              Obx(
                () {
                  final name = controller.displayName.value.isNotEmpty
                      ? controller.displayName.value
                      : (Get.isRegistered<DashboardController>()
                          ? Get.find<DashboardController>().userFullName.value
                          : '');
                  return Text(
                    name.isNotEmpty ? name : '—',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.2,
                    ),
                  );
                },
              ),
              const SizedBox(height: 4),

              // Email Pill
              Obx(() {
                final email = controller.userEmail.value.isNotEmpty
                    ? controller.userEmail.value
                    : LocalStorage.email;
                if (email.isEmpty) return const SizedBox.shrink();
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.alternate_email_rounded,
                        size: 13,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        email,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────
  //  AVATAR WIDGET (With Camera Badge & Bottom Sheet)
  // ────────────────────────────────────────────────────────────────
  Widget _buildAvatarWidget(BuildContext context) {
    return GestureDetector(
      onTap: () => _showImagePickerSheet(context),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(3.5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Obx(
              () => ClipOval(
                child: SizedBox(
                  width: 90,
                  height: 90,
                  child: controller.imagePath.value.isNotEmpty
                      ? Image.file(
                          File(controller.imagePath.value),
                          fit: BoxFit.cover,
                        )
                      : (controller.isAvailableUserImage.value &&
                              controller.userImage.value.isNotEmpty
                          ? AppCachedImage(
                              imageUrl: controller.userImage.value,
                              width: 90,
                              height: 90,
                              fit: BoxFit.cover,
                              shape: BoxShape.circle,
                              useShimmer: true,
                            )
                          : (Get.isRegistered<DashboardController>()
                              ? AppCachedImage(
                                  imageUrl: Get.find<DashboardController>()
                                      .userProfileImage
                                      .value,
                                  width: 90,
                                  height: 90,
                                  fit: BoxFit.cover,
                                  shape: BoxShape.circle,
                                  useShimmer: true,
                                  errorWidget: AppCachedImage(
                                    imageUrl: Get.find<DashboardController>()
                                        .userDefaultImageUrl
                                        .value,
                                    width: 90,
                                    height: 90,
                                    fit: BoxFit.cover,
                                    shape: BoxShape.circle,
                                    useShimmer: false,
                                  ),
                                )
                              : const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.white,
                                ))),
                ),
              ),
            ),
          ),

          // Camera Edit Badge
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFF1F5F9),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.camera_alt_rounded,
                size: 16,
                color: CustomColor.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────
  //  IMAGE PICKER SHEET
  // ────────────────────────────────────────────────────────────────
  void _showImagePickerSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 20),

            // Sheet Title
            const Text(
              'صورة الملف الشخصي',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'اختر وسيلة لتحديث صورتك الشخصية',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 24),

            // Options Row
            Row(
              children: [
                Expanded(
                  child: _buildPickerCard(
                    icon: Icons.camera_alt_rounded,
                    label: 'الكاميرا',
                    color: CustomColor.primary,
                    onTap: () {
                      Navigator.pop(ctx);
                      controller.pickProfileImage(ImageSource.camera);
                    },
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildPickerCard(
                    icon: Icons.photo_library_rounded,
                    label: 'المعرض',
                    color: const Color(0xFF0284C7),
                    onTap: () {
                      Navigator.pop(ctx);
                      controller.pickProfileImage(ImageSource.gallery);
                    },
                  ),
                ),
              ],
            ),

            // Remove Photo Option if a custom photo is set
            if (controller.imagePath.value.isNotEmpty) ...[
              const SizedBox(height: 16),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Navigator.pop(ctx);
                  controller.removeProfileImage();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.delete_outline_rounded,
                          size: 18, color: Color(0xFFDC2626)),
                      SizedBox(width: 8),
                      Text(
                        'إزالة الصورة الحالية',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFDC2626),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPickerCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 26, color: color),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────
  //  SECTION CARD WRAPPER
  // ────────────────────────────────────────────────────────────────
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: CustomColor.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: CustomColor.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.1,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFFF1F5F9), height: 1, thickness: 1),

          // Fields Container
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────
  //  SECTION 1: PERSONAL INFO
  // ────────────────────────────────────────────────────────────────
  Widget _buildPersonalInfoCard(BuildContext context) {
    return _buildSectionCard(
      title: DynamicLanguage.key(Strings.personalInformation),
      icon: Icons.person_rounded,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildModernTextField(
                controller: controller.firstNameController,
                label: DynamicLanguage.key(Strings.firstName),
                hintText: DynamicLanguage.key(Strings.enterYourFirstName),
                prefixIcon: Icons.person_outline_rounded,
                keyboardType: TextInputType.name,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildModernTextField(
                controller: controller.lastNameController,
                label: DynamicLanguage.key(Strings.lastName),
                hintText: DynamicLanguage.key(Strings.enterYourLastName),
                prefixIcon: Icons.person_outline_rounded,
                keyboardType: TextInputType.name,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ────────────────────────────────────────────────────────────────
  //  SECTION 2: CONTACT INFO
  // ────────────────────────────────────────────────────────────────
  Widget _buildContactCard(BuildContext context) {
    return _buildSectionCard(
      title: DynamicLanguage.key(Strings.contactInformation),
      icon: Icons.contact_phone_rounded,
      children: [
        // Country Selector
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DynamicLanguage.key(Strings.Country),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 6),
            CountryDropDown(
              label: '',
              itemsList: controller.countryList,
              selectMethod: controller.countrySelectMethod,
              showSearchField: true,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              inputBoxHeight: 48,
              fieldPadding: const EdgeInsets.symmetric(horizontal: 14),
              onChanged: (v) {
                if (v != null) {
                  controller.countrySelectMethod.value = v.name;
                  controller.mobileCode.value = v.mobileCode;
                  LocalStorage.save(userCountryCode: v.mobileCode);
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Mobile Phone
        _buildModernTextField(
          controller: controller.mobileController,
          label: DynamicLanguage.key(Strings.Phone),
          hintText: DynamicLanguage.key(Strings.Phone),
          prefixIcon: Icons.phone_iphone_rounded,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 14),

        // Verified Email Display (Read-Only)
        Obx(() {
          final email = controller.userEmail.value.isNotEmpty
              ? controller.userEmail.value
              : LocalStorage.email;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DynamicLanguage.key(Strings.emailAddress),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.mail_outline_rounded,
                      size: 20,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        email.isNotEmpty ? email : '—',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.lock_outline_rounded,
                      size: 16,
                      color: Color(0xFF94A3B8),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  // ────────────────────────────────────────────────────────────────
  //  SECTION 3: ADDRESS INFO
  // ────────────────────────────────────────────────────────────────
  Widget _buildAddressCard(BuildContext context) {
    return _buildSectionCard(
      title: DynamicLanguage.key(Strings.addressInformation),
      icon: Icons.location_on_rounded,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildModernTextField(
                controller: controller.cityController,
                label: DynamicLanguage.key(Strings.City),
                hintText: DynamicLanguage.key(Strings.City),
                prefixIcon: Icons.location_city_rounded,
                keyboardType: TextInputType.text,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildModernTextField(
                controller: controller.stateController,
                label: DynamicLanguage.key(Strings.State),
                hintText: DynamicLanguage.key(Strings.State),
                prefixIcon: Icons.map_outlined,
                keyboardType: TextInputType.text,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        _buildModernTextField(
          controller: controller.addressController,
          label: DynamicLanguage.key(Strings.Address),
          hintText: DynamicLanguage.key(Strings.Address),
          prefixIcon: Icons.home_outlined,
          keyboardType: TextInputType.streetAddress,
        ),
        const SizedBox(height: 14),

        _buildModernTextField(
          controller: controller.zipCodeController,
          label: DynamicLanguage.key(Strings.ZipCode),
          hintText: DynamicLanguage.key(Strings.ZipCode),
          prefixIcon: Icons.numbers_rounded,
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  // ────────────────────────────────────────────────────────────────
  //  SECTION 4: DANGER ZONE (Account Deletion)
  // ────────────────────────────────────────────────────────────────
  Widget _buildDangerZoneCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              size: 22,
              color: Color(0xFFDC2626),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DynamicLanguage.key(Strings.delete),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF991B1B),
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'حذف الحساب نهائياً وكافة البيانات',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFFB91C1C),
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: const Color(0xFFDC2626),
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  builder: (BuildContext ctx) => const DeletePop(),
                );
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Text(
                  'حذف',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────
  //  MODERN TEXT FIELD HELPER
  // ────────────────────────────────────────────────────────────────
  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    IconData? prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: keyboardType,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF0F172A),
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              fontSize: 13,
              color: Color(0xFF94A3B8),
            ),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, size: 20, color: const Color(0xFF64748B))
                : null,
            filled: true,
            fillColor: readOnly ? const Color(0xFFF1F5F9) : const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: CustomColor.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  // ────────────────────────────────────────────────────────────────
  //  BOTTOM BUTTON
  // ────────────────────────────────────────────────────────────────
  Widget _buildBottomButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: CustomColor.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: EdgeInsets.zero,
            ),
            onPressed: controller.isUpdateLoading
                ? null
                : () {
                    controller.updateProfile();
                  },
            child: controller.isUpdateLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.2,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.check_circle_outline_rounded,
                        size: 20,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DynamicLanguage.key(Strings.update),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
