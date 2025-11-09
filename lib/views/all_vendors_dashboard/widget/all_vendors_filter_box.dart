part of '../screen/all_vendors_dashboard_screen.dart';

class AllVendorsFilterBox extends GetView<AllVendorsDashboardController> {
  const AllVendorsFilterBox({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: Dimensions.defaultHorizontalSize,
        vertical: Dimensions.verticalSize * 0.5,
      ),
      decoration: BoxDecoration(
        color: CustomColor.whiteColor,
        borderRadius: BorderRadius.circular(Dimensions.radius),
      ),
      padding: EdgeInsets.all(Dimensions.defaultHorizontalSize),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter Cars',
            style: TextStyle(
              fontSize: Dimensions.titleLarge,
              fontWeight: FontWeight.bold,
              color: CustomColor.typography,
            ),
          ),
          SizedBox(height: Dimensions.verticalSize),
          
          // Car Type Dropdown
          Obx(
            () => CustomDropDown<TypesAll>(
              labelSpacing: Sizes.height.v5,
              label: Strings.SelectType,
              labelFontSize: Dimensions.titleSmall * 0.8,
              hintFontSize: Dimensions.titleSmall * 0.8,
              inputBoxHeight: Dimensions.inputBoxHeight * 0.695,
              fieldPadding: EdgeInsets.symmetric(
                horizontal: Dimensions.horizontalSize * 0.7,
                vertical: Dimensions.verticalSize * 0.37,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radius * 1.2),
                color: CustomColor.background,
              ),
              itemsList: controller.typeList,
              selectMethod: controller.isLoad 
                  ? RxString(Strings.pleaseWait) 
                  : controller.selectedTypeName,
              onChanged: (v) {
                controller.selectedType.value = v!;
                controller.modelList.clear();
                controller.selectedModel.value = null;
                controller.carTypeId.value = v.carTypeId;
                controller.selectedTypeName.value = v.name ?? '';
                controller.typeHasModel();
              },
            ),
          ),
          
          // Car Model Dropdown
          Obx(
            () => CustomDropDown<ModelsAll>(
              labelSpacing: Sizes.height.v5,
              label: Strings.SelectModel,
              labelFontSize: Dimensions.titleSmall * 0.8,
              hintFontSize: Dimensions.titleSmall * 0.8,
              inputBoxHeight: Dimensions.inputBoxHeight * 0.695,
              fieldPadding: EdgeInsets.symmetric(
                horizontal: Dimensions.horizontalSize * 0.7,
                vertical: Dimensions.verticalSize * 0.37,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radius * 1.2),
                color: CustomColor.background,
              ),
              itemsList: controller.modelList,
              selectMethod: controller.isLoad 
                  ? RxString(Strings.pleaseWait) 
                  : controller.selectedModelName,
              onChanged: (v) {
                controller.selectedModel.value = v!;
                controller.carModelId.value = v.id;
                controller.selectedModelName.value = v.name;
                controller.modelHasYears();
              },
            ),
          ),

          // Car Year Dropdown
          Obx(
            () => CustomDropDown<String>(
              labelSpacing: Sizes.height.v5,
              label: Strings.SelectYear,
              labelFontSize: Dimensions.titleSmall * 0.8,
              hintFontSize: Dimensions.titleSmall * 0.8,
              inputBoxHeight: Dimensions.inputBoxHeight * 0.695,
              fieldPadding: EdgeInsets.symmetric(
                horizontal: Dimensions.horizontalSize * 0.7,
                vertical: Dimensions.verticalSize * 0.37,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radius * 1.2),
                color: CustomColor.background,
              ),
              itemsList: controller.modelYearsList,
              selectMethod: controller.isLoad 
                  ? RxString(Strings.pleaseWait) 
                  : controller.selectedYearName,
              onChanged: (v) {
                if (v == null) return;
                controller.selectedYearName.value = v;
                controller.selectedYear.value = int.tryParse(v);
                controller.carYear.value = int.tryParse(v) ?? 0;
              },
            ),
          ),
        ],
      ),
    );
  }
}
