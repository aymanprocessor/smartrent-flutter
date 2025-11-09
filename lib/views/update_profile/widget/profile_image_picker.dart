import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carbo/views/update_profile/controller/update_profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../base/utils/basic_import.dart';
import '../../dashboard/controller/dashboard_controller.dart';

class ProfileImagePicker extends GetView<UpdateProfileController> {
  ProfileImagePicker({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.symmetric(vertical: Dimensions.verticalSize),
      child: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => _imagePickerBottomSheetWidget(context),
          );
        },
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(width: 10, color: CustomColor.background),
              ),
              child: Obx(
                () => Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(width: 2, color: CustomColor.primary),
                  ),
                  child: controller.imagePath.value != ''
                      ? CircleAvatar(
                          backgroundColor: CustomColor.background,
                          backgroundImage: FileImage(
                            File(controller.imagePath.value),
                          ),
                          radius: Dimensions.radius * 5,
                        )
                      : Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              width: 2,
                              color: CustomColor.primary,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: Dimensions.radius * 4.5,
                            backgroundColor: Colors.transparent,
                            child: ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: Get.find<DashboardController>()
                                    .userProfileImage
                                    .value,
                                errorWidget: (context, url, error) =>
                                    Image.network(
                                      Get.find<DashboardController>()
                                          .userDefaultImageUrl
                                          .value,
                                      fit: BoxFit.cover,
                                    ),
                                imageBuilder: (context, imageProvider) =>
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                              ),
                            ),
                          ),
                        ),
                ),
              ),
            ),
            Positioned(
              bottom: 17,
              right: 8,
              child: CircleAvatar(
                backgroundColor: CustomColor.whiteColor,
                radius: Dimensions.radius * 1.3,
                child: Icon(
                  Icons.camera,
                  color: CustomColor.primary,
                  size: Dimensions.iconSizeDefault * 0.8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _imagePickerBottomSheetWidget(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.15,
      margin: EdgeInsets.all(Dimensions.verticalSize * 0.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.all(Dimensions.paddingSize),
            child: IconButton(
              onPressed: () {
                Get.back();
                controller.pickImage(ImageSource.gallery);
              },
              icon: Icon(Icons.image, color: CustomColor.primary, size: 50),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(Dimensions.paddingSize),
            child: IconButton(
              onPressed: () {
                Get.back();
                controller.pickImage(ImageSource.camera);
              },
              icon: Icon(Icons.camera, color: CustomColor.primary, size: 50),
            ),
          ),
        ],
      ),
    );
  }
}
