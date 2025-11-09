import 'package:carbo/views/update_profile/controller/update_profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../base/widgets/country_drop_down.dart';
import '../../../base/utils/local_storage.dart';
import '../../../base/utils/size.dart';
import '../../../base/widgets/primary_input_widget.dart';
import '../../../languages/strings.dart';

class ProfileInputWidget extends GetView<UpdateProfileController> {
  ProfileInputWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.formKey,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: PrimaryInputWidget(
                  controller: controller.firstNameController,
                  label: Strings.firstName,
                  hintText: Strings.firstName,
                  textInputType: TextInputType.name,
                  showBorderSide: true,
                ),
              ),
              Sizes.width.v10,
              Expanded(
                child: PrimaryInputWidget(
                  controller: controller.lastNameController,
                  label: Strings.lastName,
                  hintText: Strings.lastName,
                  textInputType: TextInputType.name,
                  showBorderSide: true,
                ),
              ),
            ],
          ),
          Sizes.height.betweenInputBox,
          CountryDropDown(
            label: Strings.Country,
            itemsList: controller.countryList,
            selectMethod: controller.countrySelectMethod,
            onChanged: (v) {
              controller.countrySelectMethod.value = v!.name;
              controller.mobileCode.value = v.mobileCode;
              LocalStorage.save(userCountryCode: v.mobileCode);
              print(controller.mobileCode);
            },
          ),
          Sizes.height.betweenInputBox,
          PrimaryInputWidget(
            controller: controller.mobileController,
            label: Strings.Phone,
            hintText: Strings.Phone,
            textInputType: TextInputType.phone,
            showBorderSide: true,
          ),
          Sizes.height.betweenInputBox,
          Row(
            children: [
              Expanded(
                child: PrimaryInputWidget(
                  controller: controller.addressController,
                  label: Strings.Address,
                  hintText: Strings.Address,
                  textInputType: TextInputType.streetAddress,
                  showBorderSide: true,
                ),
              ),
              Sizes.width.v10,
              Expanded(
                child: PrimaryInputWidget(
                  controller: controller.cityController,
                  label: Strings.City,
                  hintText: Strings.City,
                  textInputType: TextInputType.text,
                  showBorderSide: true,
                ),
              ),
            ],
          ),
          Sizes.height.betweenInputBox,
          Row(
            children: [
              Expanded(
                child: PrimaryInputWidget(
                  controller: controller.stateController,
                  label: Strings.State,
                  hintText: Strings.State,
                  textInputType: TextInputType.text,
                  showBorderSide: true,
                ),
              ),
              Sizes.width.v10,
              Expanded(
                child: PrimaryInputWidget(
                  controller: controller.zipCodeController,
                  label: Strings.ZipCode,
                  hintText: Strings.ZipCode,
                  textInputType: TextInputType.number,
                  showBorderSide: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
