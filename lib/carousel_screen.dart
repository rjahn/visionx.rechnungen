import 'package:carousel_app/carousel_card.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_jvx/flutter_jvx.dart';

class CarouselScreen extends StatefulWidget {
  static const String SCREEN_KEY =
      "app.visionx.apps.rechnungen.screens.ErfassungWorkScreen:L1_MI_DOOPENWORKSCREEN_APP-VIS-APP-REC-SCR-ERFWORSCR";
  static const String DATAPROVIDER_KEY = "Rechnungen/Erf-25/erfassung#0";

  const CarouselScreen({super.key});

  @override
  State<CarouselScreen> createState() => _CarouselScreenState();
}

class _CarouselScreenState extends State<CarouselScreen> {
  CarouselController carouselController = CarouselController();
  DataChunk dataChunk = DataChunk.empty();
  int? selectedIndex;
  List<Widget> dataCards = [];

  @override
  void initState() {
    super.initState();

    IUiService().registerDataSubscription(
      pDataSubscription: DataSubscription(
        subbedObj: this,
        dataProvider: CarouselScreen.DATAPROVIDER_KEY,
        onDataChunk: receiveDataChunk,
        onSelectedRecord: receiveSelectedRecord,
        from: 0,
      ),
    );
  }

  @override
  void dispose() {
    IUiService().disposeSubscriptions(pSubscriber: this);
    super.dispose();
  }

  void receiveDataChunk(DataChunk pDataChunk) {
    dataChunk = pDataChunk;
    dataCards.clear();

    updateSelection();
    setState(() {});
  }

  void receiveSelectedRecord(DataRecord? pDataRecord) {
    if (selectedIndex != pDataRecord?.index) {
      selectedIndex = pDataRecord?.index;

      updateSelection();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return CarouselSlider.builder(
                itemBuilder: _buildCard,
                itemCount: dataChunk.data.length,
                options: CarouselOptions(
                  height: double.infinity,
                  viewportFraction: 0.75,
                  enableInfiniteScroll: false,
                  enlargeCenterPage: true,
                  onPageChanged: (index, _) => sendSelectedRecord(index),
                  initialPage: 0,
                ),
                carouselController: carouselController,
              );
            },
          ),
        ),
        createFloatingButton(context),
      ],
    );
  }

  Positioned createFloatingButton(BuildContext context) {
    return Positioned(
      right: 25,
      bottom: 25,
      child: FloatingActionButton(
        heroTag: null,
        backgroundColor: Theme.of(context).colorScheme.primary,
        onPressed: () {
          IUiService().sendCommand(
            InsertRecordCommand(
                dataProvider: CarouselScreen.DATAPROVIDER_KEY, reason: "Pressed floating insert button"),
          );
        },
        child: const Icon(
          Icons.add,
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, int index, int realIndex) {
    var dataRow = dataChunk.data[index]!;
    int? id = dataRow[dataChunk.getColumnIndex("ID")];
    num? invoiceAmount = dataRow[dataChunk.getColumnIndex("BETRAG")];
    num? entryDate = dataRow[dataChunk.getColumnIndex("ERFASSUNGSDATUM")];
    num? invoiceDate = dataRow[dataChunk.getColumnIndex("RECHNUNGSDATUM")];
    String? invoiceImage = dataRow[dataChunk.getColumnIndex("RECHNUNG")];

    DateTime? entryDateTime;
    if (entryDate != null) {
      entryDateTime = DateTime.fromMillisecondsSinceEpoch(entryDate.truncate());
    }
    DateTime? invoiceDateTime;
    if (invoiceDate != null) {
      invoiceDateTime = DateTime.fromMillisecondsSinceEpoch(invoiceDate.truncate());
    }

    return CarouselCard(
      key: id != null ? ValueKey(id) : null,
      index: index,
      totalAmount: dataChunk.data.length,
      invoiceAmount: invoiceAmount,
      entryDateTime: entryDateTime,
      invoiceDateTime: invoiceDateTime,
      invoiceImage: invoiceImage,
      saveCallBack: ({entryDateTime, invoiceAmount, invoiceDateTime, invoiceImage}) {
        saveValues(
          id: id,
          entryDateTime: entryDateTime,
          invoiceImage: invoiceImage,
          invoiceDateTime: invoiceDateTime,
          invoiceAmount: invoiceAmount,
        );
      },
      deleteCallBack: () => delete(id),
    );
  }

  void delete(int? id) {
    IUiService().sendCommand(
      DeleteRecordCommand(
        dataProvider: CarouselScreen.DATAPROVIDER_KEY,
        filter: id != null
            ? Filter(
                columnNames: ["ID"],
                values: [id],
              )
            : const Filter.empty(),
        reason: "Pressed delete",
      ),
    );
  }

  void saveValues({
    int? id,
    num? invoiceAmount,
    DateTime? entryDateTime,
    DateTime? invoiceDateTime,
    String? invoiceImage,
  }) {
    IUiService().sendCommand(
      QueuedFunctionCommand(
        () => [
          SetValuesCommand(
            dataProvider: CarouselScreen.DATAPROVIDER_KEY,
            columnNames: ["ERFASSUNGSDATUM", "RECHNUNGSDATUM", "BETRAG", "RECHNUNG"],
            values: [
              entryDateTime?.millisecondsSinceEpoch,
              invoiceDateTime?.millisecondsSinceEpoch,
              invoiceAmount,
              invoiceImage
            ],
            filter: Filter(
              columnNames: ["ID"],
              values: [id],
            ),
            reason: "Pressed save",
          ),
          DalSaveCommand(
            dataProvider: CarouselScreen.DATAPROVIDER_KEY,
            reason: "Pressed save",
          ),
        ],
        reason: "Pressed save",
      ),
    );
  }

  void sendSelectedRecord(int pIndex) {
    if (dataChunk.data.length > pIndex && pIndex >= 0 && pIndex != selectedIndex) {
      selectedIndex = pIndex;
      int id = dataChunk.data[pIndex]![dataChunk.getColumnIndex("ID")];
      IUiService().sendCommand(
        SelectRecordCommand.select(
          reason: "Scrolled",
          dataProvider: CarouselScreen.DATAPROVIDER_KEY,
          filter: Filter(
            columnNames: ["ID"],
            values: [id],
          ),
        ),
      );
    }
  }

  void updateSelection() {
    final index = selectedIndex;
    if (index != null) {
      carouselController.animateToPage(index);
    }
  }
}
