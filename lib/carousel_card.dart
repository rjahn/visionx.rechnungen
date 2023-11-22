import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_jvx/flutter_jvx.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

typedef CarouselCardSaveCallback = Function(
    {num? invoiceAmount, DateTime? entryDateTime, DateTime? invoiceDateTime, String? invoiceImage});

class CarouselCard extends StatefulWidget {
  final CarouselCardSaveCallback? saveCallBack;
  final Function()? deleteCallBack;

  final num? invoiceAmount;
  final DateTime? entryDateTime;
  final DateTime? invoiceDateTime;
  final String? invoiceImage;

  const CarouselCard({
    super.key,
    this.invoiceAmount,
    this.entryDateTime,
    this.invoiceDateTime,
    this.invoiceImage,
    this.saveCallBack,
    this.deleteCallBack,
  });

  @override
  State<CarouselCard> createState() => _CarouselCardState();
}

class _CarouselCardState extends State<CarouselCard> {
  TextEditingController amountController = TextEditingController();
  TextEditingController entryDateController = TextEditingController();
  TextEditingController invoiceDateController = TextEditingController();

  num? invoiceAmount;
  String? invoiceImage;
  DateTime? entryDateTime;
  DateTime? invoiceDateTime;

  Widget? _image;

  @override
  void initState() {
    super.initState();

    invoiceAmount = widget.invoiceAmount;
    invoiceImage = widget.invoiceImage;
    entryDateTime = widget.entryDateTime;
    invoiceDateTime = widget.invoiceDateTime;

    if (invoiceAmount != null) {
      amountController.text = invoiceAmount!.toString();
    }

    if (entryDateTime != null) {
      entryDateController.text = DateFormat.yMMMd(IConfigService().getPlatformLocale()).format(entryDateTime!);
    }

    if (invoiceDateTime != null) {
      invoiceDateController.text = DateFormat.yMMMd(IConfigService().getPlatformLocale()).format(invoiceDateTime!);
    }

    updatePicture();
  }

  @override
  void dispose() {
    amountController.dispose();
    entryDateController.dispose();
    invoiceDateController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CarouselCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.invoiceImage != invoiceImage) {
      updatePicture();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 20),
        child: Material(
          color: Theme.of(context).primaryColor,
          elevation: 5.0,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 250),
                  child: Material(
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    borderRadius: BorderRadius.circular(20),
                    elevation: 2.5,
                    child: image,
                  ),
                ),
                const SizedBox(height: 8),
                getImageButtons(),
                const SizedBox(height: 16),
                Material(
                  borderRadius: BorderRadius.circular(10),
                  elevation: 2.5,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        amountTextField,
                        const SizedBox(height: 16),
                        entryDateField,
                        const SizedBox(height: 16),
                        invoiceDateField,
                      ],
                    ),
                  ),
                ),
                getBottomButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget getImageButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Material(
          borderRadius: BorderRadius.circular(10),
          elevation: 2.5,
          clipBehavior: Clip.hardEdge,
          child: InkWell(
            onTap: deleteImage,
            child: const Padding(padding: EdgeInsets.all(8), child: Icon(Icons.delete_forever)),
          ),
        ),
        const SizedBox(width: 16),
        Material(
          borderRadius: BorderRadius.circular(10),
          elevation: 2.5,
          clipBehavior: Clip.hardEdge,
          child: InkWell(
            onTap: () => pressedImageButton(camera: true),
            child: const Padding(padding: EdgeInsets.all(8), child: Icon(Icons.camera_alt)),
          ),
        ),
        const SizedBox(width: 16),
        Material(
          borderRadius: BorderRadius.circular(10),
          elevation: 2.5,
          clipBehavior: Clip.hardEdge,
          child: InkWell(
            onTap: () => pressedImageButton(camera: false),
            child: const Padding(padding: EdgeInsets.all(8), child: Icon(Icons.folder)),
          ),
        )
      ],
    );
  }

  Widget getBottomButtons() {
    if (widget.deleteCallBack != null && widget.saveCallBack != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            createDeleteButton(),
            createSaveButton(),
          ],
        ),
      );
    } else if (widget.deleteCallBack != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Align(
          alignment: Alignment.centerLeft,
          child: createDeleteButton(),
        ),
      );
    } else if (widget.saveCallBack != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Align(
          alignment: Alignment.centerRight,
          child: createSaveButton(),
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  Material createSaveButton() {
    return Material(
      borderRadius: BorderRadius.circular(10),
      elevation: 2.5,
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () {
          widget.saveCallBack?.call(
            invoiceAmount: double.tryParse(amountController.text),
            invoiceDateTime: invoiceDateTime,
            invoiceImage: invoiceImage,
            entryDateTime: entryDateTime,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            FlutterUI.translate("Save"),
            style: const TextStyle(color: Colors.blue),
          ),
        ),
      ),
    );
  }

  Material createDeleteButton() {
    return Material(
      borderRadius: BorderRadius.circular(10),
      elevation: 2.5,
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: widget.deleteCallBack,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            FlutterUI.translate("Delete"),
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }

  Widget createTextField(TextEditingController controller, String label, IconData? icon,
      [bool readOnly = false, Function()? onTap]) {
    return TextField(
      onTap: onTap,
      controller: controller,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(12),
        labelText: FlutterUI.translate(label),
        border: const OutlineInputBorder(),
        suffixIcon: createSuffixIcon(icon),
        suffixIconConstraints: const BoxConstraints(minHeight: 24, minWidth: 24),
        isDense: true,
      ),
      readOnly: readOnly,
      textAlign: TextAlign.left,
      textAlignVertical: TextAlignVertical.center,
      minLines: 1,
      maxLines: 1,
      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: false),
    );
  }

  Widget? createSuffixIcon(IconData? icon) {
    if (icon == null) {
      return null;
    }

    return Padding(
      padding: const EdgeInsets.only(left: 5, right: 5),
      child: Icon(icon),
    );
  }

  Widget get amountTextField => createTextField(amountController, "Amount", null);

  Widget get entryDateField => createTextField(entryDateController, "Entry Date", Icons.date_range, true, () {
        showDatePicker(
          context: context,
          initialDate: entryDateTime ?? DateTime.now(),
          firstDate: DateTime(1970),
          lastDate: DateTime(DateTime.now().year + 1),
        ).then((value) {
          entryDateTime = value;
          entryDateController.text = entryDateTime != null
              ? DateFormat.yMMMd(IConfigService().getPlatformLocale()).format(entryDateTime!)
              : "";
          setState(() {});
        });
      });

  Widget get invoiceDateField => createTextField(invoiceDateController, "Invoice Date", Icons.date_range, true, () {
        showDatePicker(
          context: context,
          initialDate: entryDateTime ?? DateTime.now(),
          firstDate: DateTime(1970),
          lastDate: DateTime(DateTime.now().year + 1),
        ).then((value) {
          invoiceDateTime = value;
          invoiceDateController.text = invoiceDateTime != null
              ? DateFormat.yMMMd(IConfigService().getPlatformLocale()).format(invoiceDateTime!)
              : "";
          setState(() {});
        });
      });

  Widget get image => _image != null ? _image! : const Icon(Icons.image, size: 200);

  void pressedImageButton({required bool camera}) async {
    double? maxRes = IConfigService().pictureResolution.value?.toDouble();

    XFile? filePicked = await ImagePicker().pickImage(
      source: camera ? ImageSource.camera : ImageSource.gallery,
      maxWidth: maxRes,
      maxHeight: maxRes,
    );

    if (filePicked != null) {
      invoiceImage = base64Encode(await filePicked.readAsBytes());
      updatePicture();
      setState(() {});
    }
  }

  void updatePicture() {
    _image = invoiceImage != null ? Image(image: MemoryImage(base64Decode(invoiceImage!))) : null;
  }

  void deleteImage() {
    invoiceImage = null;
    updatePicture();
    setState(() {});
  }
}
