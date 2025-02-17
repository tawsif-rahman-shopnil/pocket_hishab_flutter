import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../constants/categories.dart';
import '../../constants/colors.dart';
import '../../constants/theme.dart';
import '../../controllers/add_transaction_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../models/transaction.dart';
import '../../providers/database_provider.dart';
import '../widgets/input_field.dart';

class AddTransactionScreen extends StatelessWidget {
  final AddTransactionController _addTransactionController =
  Get.put(AddTransactionController());

  final _themeController = Get.find<ThemeController>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final List<String> _transactionTypes = ['Income', 'Expense'];
  final DateTime now = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: _appBar(),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Transaction Image',
                style: Themes().labelStyle,
              ),
              SizedBox(height: 8.h),
              _addTransactionController.selectedImage.isNotEmpty
                  ? GestureDetector(
                onTap: () => _showOptionsDialog(context),
                child: CircleAvatar(
                  radius: 30.r,
                  backgroundImage: FileImage(
                    File(_addTransactionController.selectedImage),
                  ),
                ),
              )
                  : GestureDetector(
                onTap: () => _showOptionsDialog(context),
                child: CircleAvatar(
                  radius: 30.r,
                  backgroundColor: Get.isDarkMode
                      ? Colors.grey.shade800
                      : Colors.grey.shade300,
                  child: Center(
                    child: Icon(
                      Icons.add_a_photo,
                      color: _themeController.color,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              InputField(
                hint: 'Enter transaction name',
                label: 'Transaction Name',
                controller: _nameController,
              ),
              InputField(
                hint: 'Enter transaction amount',
                label: 'Transaction Amount',
                controller: _amountController,
              ),
              Row(
                children: [
                  Expanded(
                    child: InputField(
                      hint: _addTransactionController.selectedDate.isNotEmpty
                          ? _addTransactionController.selectedDate
                          : DateFormat.yMd().format(now),
                      label: 'Date',
                      widget: IconButton(
                        onPressed: () => _getDateFromUser(context),
                        icon: Icon(
                          Icons.calendar_month_outlined,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: InputField(
                      hint: _addTransactionController.selectedTime.isNotEmpty
                          ? _addTransactionController.selectedTime
                          : DateFormat('hh:mm a').format(now),
                      label: 'Time',
                      widget: IconButton(
                        onPressed: () => _getTimeFromUser(context),
                        icon: Icon(
                          Icons.access_time_rounded,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              InputField(
                hint: _addTransactionController.selectedCategory.isNotEmpty
                    ? _addTransactionController.selectedCategory
                    : categories[0],
                label: 'Category',
                widget: CustomDropdownButton(
                  icon: Icon(
                    Icons.keyboard_arrow_down_sharp,
                    color: _themeController.color,
                  ),
                  items: categories,
                  onSelected: (val) {
                    _addTransactionController.updateSelectedCategory(val);
                  },
                ),
              ),
              InputField(
                hint: _addTransactionController.selectedMode.isNotEmpty
                    ? _addTransactionController.selectedMode
                    : cashModes[0],
                isAmount: true,
                label: 'Mode',
                widget: CustomDropdownButton(
                  icon: Icon(
                    Icons.keyboard_arrow_down_sharp,
                    color: _themeController.color,
                  ),
                  items: cashModes,
                  onSelected: (val) {
                    _addTransactionController.updateSelectedMode(val);
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: primaryColor,
          onPressed: () => _addTransaction(),
          child: Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      );
    });
  }

  _addTransaction() async {
    if (_nameController.text.isEmpty || _amountController.text.isEmpty) {
      Get.snackbar(
        'Required',
        'All fields are required',
        backgroundColor:
        Get.isDarkMode ? Color(0xFF212121) : Colors.grey.shade100,
        colorText: pinkClr,
      );
    } else {
      final TransactionModel transactionModel = TransactionModel(
        id: DateTime.now().toString(),
        type: _addTransactionController.transactionType.isNotEmpty
            ? _addTransactionController.transactionType
            : _transactionTypes[0],
        image: _addTransactionController.selectedImage,
        name: _nameController.text,
        amount: _amountController.text,
        date: _addTransactionController.selectedDate.isNotEmpty
            ? _addTransactionController.selectedDate
            : DateFormat.yMd().format(now),
        time: _addTransactionController.selectedTime.isNotEmpty
            ? _addTransactionController.selectedTime
            : DateFormat('hh:mm a').format(now),
        category: _addTransactionController.selectedCategory.isNotEmpty
            ? _addTransactionController.selectedCategory
            : categories[0],
        mode: _addTransactionController.selectedMode.isNotEmpty
            ? _addTransactionController.selectedMode
            : cashModes[0],
      );
      await DatabaseProvider.insertTransaction(transactionModel);
      Get.back();
    }
  }

  _showOptionsDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        children: [
          SimpleDialogOption(
            onPressed: () async {
              final image = await ImagePicker().pickImage(
                source: ImageSource.gallery,
              );
              if (image != null) {
                _addTransactionController.updateSelectedImage(image.path);
              }
            },
            child: Row(children: [
              Icon(Icons.image),
              Padding(
                padding: EdgeInsets.all(7),
                child: Text(
                  'Gallery',
                  style: TextStyle(
                    fontSize: 20.sp,
                  ),
                ),
              )
            ]),
          ),
          SimpleDialogOption(
            onPressed: () async {
              final image = await ImagePicker().pickImage(
                source: ImageSource.camera,
              );
              if (image != null) {
                _addTransactionController.updateSelectedImage(image.path);
              }
            },
            child: Row(children: [
              Icon(Icons.camera),
              Padding(
                padding: EdgeInsets.all(7),
                child: Text(
                  'Camera',
                  style: TextStyle(
                    fontSize: 20.sp,
                  ),
                ),
              )
            ]),
          ),
          SimpleDialogOption(
            onPressed: () => Get.back(),
            child: Row(children: [
              Icon(Icons.cancel),
              Padding(
                padding: EdgeInsets.all(7),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 20.sp,
                  ),
                ),
              )
            ]),
          ),
        ],
      ),
    );
  }

  _getTimeFromUser(BuildContext context) async {
    String? formattedTime;
    await showTimePicker(
      initialEntryMode: TimePickerEntryMode.input,
      context: context,
      initialTime: TimeOfDay(
        hour: DateTime.now().hour,
        minute: DateTime.now().minute,
      ),
    ).then((value) => formattedTime = value?.format(context));

    _addTransactionController.updateSelectedTime(formattedTime!);
  }

  _getDateFromUser(BuildContext context) async {
    DateTime? pickerDate = await showDatePicker(
      context: context,
      firstDate: DateTime(2012),
      initialDate: DateTime.now(),
      lastDate: DateTime(2122),
    );

    if (pickerDate != null) {
      _addTransactionController
          .updateSelectedDate(DateFormat.yMd().format(pickerDate));
    }
  }

  _appBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      title: Text(
        'Add Transaction',
        style: TextStyle(color: _themeController.color),
      ),
      leading: IconButton(
        onPressed: () => Get.back(),
        icon: Icon(Icons.arrow_back, color: _themeController.color),
      ),
      actions: [
        Row(
          children: [
            Text(
              _addTransactionController.transactionType.isEmpty
                  ? _transactionTypes[0]
                  : _addTransactionController.transactionType,
              style: TextStyle(
                fontSize: 14.sp,
                color: _themeController.color,
              ),
            ),
            SizedBox(
              width: 40,
              child: PopupMenuButton(
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: _themeController.color,
                ),
                itemBuilder: (context) => _transactionTypes
                    .map(
                      (item) => PopupMenuItem(
                    value: item,
                    child: Text(item),
                  ),
                )
                    .toList(),
                onSelected: (val) {
                  _addTransactionController.changeTransactionType(val as String);
                },
              ),
            ),
          ],
        ),
      ],
    );
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
