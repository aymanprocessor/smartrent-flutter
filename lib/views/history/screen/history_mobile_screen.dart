part of 'history_screen.dart';

class HistoryMobileScreen extends GetView<HistoryController> {
  const HistoryMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        Strings.history,
        centerTitle: false,
        showBackButton: true,
      ),
      body: Obx(() => controller.isLoading ? Loader() : _bodyWidget()),
    );
  }

  _bodyWidget() {
    return SafeArea(
      child: controller.historyList.isNotEmpty
          ? Padding(
              padding: EdgeInsets.only(top: Dimensions.verticalSize),
              child: ListView.builder(
                itemCount: controller.historyList.length,
                itemBuilder: (context, index) {
                  if (index >= controller.historyList.length) {
                    return SizedBox.shrink();
                  }
                  return HistoryCard(index);
                },
              ),
            )
          : EmptyDataWidget(),
    );
  }
}
