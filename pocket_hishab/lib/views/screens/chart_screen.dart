import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../constants/colors.dart';
import '../../controllers/chart_controller.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/theme_controller.dart';
import '../widgets/chart.dart';
import '../widgets/placeholder_info.dart';
import 'add_transaction_screen.dart';
import 'all_transactions_screen.dart';

class ChartScreen extends StatelessWidget {
  final List<String> _transactionTypes = ['Income', 'Expense'];
  ChartScreen({Key? key}) : super(key: key);
  final ChartController _chartController = Get.put(ChartController());
  final _themeController = Get.find<ThemeController>();
  final _homeController = Get.find<HomeController>();
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        appBar: _appBar(),
        body: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 20.w,
            vertical: 12.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 8.h,
              ),
              Chart(
                isExpense: _chartController.isExpense.value,
                myTransactions: _homeController.myTransactions,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * .04.h,
              ),
              _homeController.myTransactions.isEmpty
                  ? Container()
                  : Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 10.h,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          child: Center(
                              child: IconButton(
                                  onPressed: () => _showDatePicker(context),
                                  icon: Icon(
                                    Icons.calendar_month,
                                    color: _themeController.color,
                                  ))),
                        ),
                        title: Text(
                          _homeController.selectedDate.day == DateTime.now().day
                              ? 'Today'
                              : DateFormat.yMd()
                                  .format(_homeController.selectedDate),
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        trailing: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            SizedBox(
                              height: 7.h,
                            ),
                            Text(
                              _homeController.totalForSelectedDate < 0
                                  ? 'You spent'
                                  : 'You earned',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(
                              height: 3.h,
                            ),
                            Text(
                              '${_homeController.selectedCurrency.symbol}${_homeController.totalForSelectedDate.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
              PlaceholderInfo(),
              _homeController.myTransactions.isNotEmpty
                  ? Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(bottom: 10.h),
                      child: GestureDetector(
                        onTap: () => Get.to(() => AllTransactionsScreen()),
                        child: Text('Show all transactions,'),
                      ),
                    )
                  : SizedBox(),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: primaryColor,
          onPressed: () async {
            await Get.to(() => AddTransactionScreen());
            _homeController.getTransactions();
          },
          child: Icon(
            Icons.add,
          ),
        ),
      ),
    );
  }

  _appBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      title: Text(
        'Chart',
        style: TextStyle(color: _themeController.color),
      ),
      leading: IconButton(
        onPressed: () => Get.back(),
        icon: Icon(Icons.arrow_back, color: _themeController.color),
      ),
      actions: _homeController.myTransactions.isEmpty
          ? []
          : [
              Row(
                children: [
                  Text(
                    _chartController.transactionType.isEmpty
                        ? _transactionTypes[0]
                        : _chartController.transactionType,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: _themeController.color,
                    ),
                  ),
                  SizedBox(
                    width: 40,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton2(

                        customButton: Icon(
                          Icons.keyboard_arrow_down,
                          color: _themeController.color,
                        ),
                        items: _transactionTypes
                            .map(
                              (item) => DropdownMenuItem(
                                value: item,
                                child: Text(
                                  item,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          _chartController
                              .changeTransactionType((val as String));
                        },

                      ),
                    ),
                  ),
                ],
              ),
            ],
    );
  }

  _showDatePicker(BuildContext context) async {
    DateTime? pickerDate = await showDatePicker(
        context: context,
        firstDate: DateTime(2012),
        initialDate: DateTime.now(),
        lastDate: DateTime(2122));
    if (pickerDate != null) {
      _homeController.updateSelectedDate(pickerDate);
    }
  }
}
