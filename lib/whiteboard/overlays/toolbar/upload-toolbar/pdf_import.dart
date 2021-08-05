import 'dart:typed_data';

import 'package:fluffy_board/utils/image_utils.dart';
import 'package:fluffy_board/whiteboard/overlays/toolbar/settings-toolbar/upload_settings.dart';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:pdf/src/pdf/page_format.dart';
import 'package:flutter/material.dart';
import 'package:file_picker_cross/file_picker_cross.dart';
import 'dart:ui' as ui;

class ImportedPDF {
  List<ui.Image> images;
  List<Uint8List> imageData;
  double spacing;

  ImportedPDF(this.images, this.imageData, this.spacing);
}

class PDFImport extends StatefulWidget {
  @override
  _PDFImportState createState() => _PDFImportState();
}

class _PDFImportState extends State<PDFImport> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("PDF Import"),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                if (constraints.maxWidth > 600) {
                  return (FractionallySizedBox(
                      widthFactor: 0.5, child: PDFImportForm()));
                } else {
                  return (PDFImportForm());
                }
              },
            ),
          ),
        ));
  }
}

class PDFImportForm extends StatefulWidget {
  const PDFImportForm({Key? key}) : super(key: key);

  @override
  _PDFImportFormState createState() => _PDFImportFormState();
}

class _PDFImportFormState extends State<PDFImportForm> {
  final _formKey = GlobalKey<FormState>();
  FilePickerCross? filePickerCross;
  final doc = pw.Document();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    final TextEditingController spacingController = new TextEditingController();
    spacingController.text = 20.toString();
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          ElevatedButton(
              onPressed: () async {
                filePickerCross = await FilePickerCross.importFromStorage(
                    type: FileTypeCross.custom, fileExtension: 'pdf');
              },
              child: Text("Select PDF File")),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: spacingController,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  icon: Icon(Icons.space_dashboard),
                  hintText: "Spacing",
                  labelText: "Spacing"),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a Spacing';
                }
                return null;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
                onPressed: () async {
                  setState(() {
                    loading = true;
                  });
                  if (filePickerCross != null) {
                    List<ui.Image> images = List.empty(growable: true);
                    List<Uint8List> imageDataList = List.empty(growable: true);
                    await for (var page in Printing.raster(filePickerCross!.toUint8List(), dpi: 300)) {
                      Uint8List imageBytes = await page.toPng();
                      imageBytes = ImageUtils.resizeImage(imageBytes, 2);
                      final ui.Codec codec = await PaintingBinding.instance!
                          .instantiateImageCodec(imageBytes);
                      final ui.FrameInfo frameInfo = await codec.getNextFrame();
                        images.add(frameInfo.image);
                      imageDataList.add(imageBytes);
                    }
                    Navigator.pop(
                        context,
                        new ImportedPDF(images, imageDataList,
                            double.parse(spacingController.text)));
                  }
                },
                child: Text("Import")),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: loading ? CircularProgressIndicator() : Container(),
          )
        ],
      )),
    );
  }
}
