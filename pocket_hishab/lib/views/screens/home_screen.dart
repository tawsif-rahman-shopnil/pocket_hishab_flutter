import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../constants/colors.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../models/currency.dart';
import '../widgets/income_expense.dart';
import '../widgets/placeholder_info.dart';
import 'add_transaction_screen.dart';
import 'all_transactions_screen.dart';
import 'chart_screen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

  final HomeController _homeController = Get.put(HomeController());
  final ThemeController _themeController = Get.find<ThemeController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        appBar: _buildAppBar(),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 8.0),
                  Text(
                    'Your Balance',
                    style: TextStyle(
                      fontSize: 23.sp,
                      fontWeight: FontWeight.w400,
                      color: _themeController.color,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 15.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${_homeController.selectedCurrency.symbol}${_homeController.totalBalance.value.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 35.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 15.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IncomeExpence(
                    isIncome: true,
                    symbol: _homeController.selectedCurrency.symbol,
                    amount: _homeController.totalIncome.value,
                  ),
                  IncomeExpence(
                    isIncome: false,
                    symbol: _homeController.selectedCurrency.symbol,
                    amount: _homeController.totalExpense.value,
                  ),
                ],
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
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    _homeController.selectedDate.day ==
                        DateTime.now().day
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
                  onTap: () =>
                      Get.to(() => AllTransactionsScreen()),
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
      );
    });
  }

  AppBar _buildAppBar() {
    return AppBar(
      leading: IconButton(
        onPressed: () async {
          _themeController.switchTheme();
        },
        icon: Icon(Get.isDarkMode ? Icons.nightlight : Icons.wb_sunny),
        color: _themeController.color,
      ),
      title: Row(
        children: [
          Image.asset(
            'assets/logo.png',
            width: 200.0,
            height: 80.0,
          ),
          SizedBox(width: 8.0),
          Text(
            _homeController.selectedCurrency.currency,
            style: TextStyle(
              fontSize: 14.sp,
              color: _themeController.color,
            ),
          ),
        ],
      ),
      actions: [
        CustomDropdownButton(
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: _themeController.color,
          ),
          items: Currency.currencies
              .map((item) => item.currency)
              .toList(),
          onSelected: (val) {
            _homeController.updateSelectedCurrency(
              Currency.currencies.firstWhere((item) => item.currency == val),
            );
          },
        ),
        IconButton(
          onPressed: () => Get.to(() => ChartScreen()),
          icon: Icon(
            Icons.bar_chart,
            size: 27.sp,
            color: _themeController.color,
          ),
        ),
        SizedBox(width: 4.0),
      ],
    );
  }

  void _showDatePicker(BuildContext context) async {
    DateTime? pickerDate = await showDatePicker(
      context: context,
      firstDate: DateTime(2012),
      initialDate: DateTime.now(),
      lastDate: DateTime(2122),
    );
    if (pickerDate != null) {
      _homeController.updateSelectedDate(pickerDate);
    }
  }
}

class CustomDropdownButton extends StatelessWidget {
  final Icon icon;
  final List<String> items;
  final Function(String) onSelected;

  const CustomDropdownButton({
    required this.icon,
    required this.items,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      icon: icon,
      itemBuilder: (context) => items
          .map(
            (item) => PopupMenuItem(
          value: item,
          child: Text(item),
        ),
      )
          .toList(),
      onSelected: onSelected,
    );
  }
}
