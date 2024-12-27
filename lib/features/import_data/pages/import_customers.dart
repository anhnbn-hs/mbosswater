import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart' as e;
import 'dart:io';

import 'package:mbosswater/core/styles/app_colors.dart';

class ImportCustomerExcelPage extends StatefulWidget {
  const ImportCustomerExcelPage({Key? key}) : super(key: key);

  @override
  State<ImportCustomerExcelPage> createState() => _ImportCustomerExcelPageState();
}

class _ImportCustomerExcelPageState extends State<ImportCustomerExcelPage> {
  File? _file;
  bool _isLoading = false;
  String? _error;

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );

      if (result != null) {
        setState(() {
          _file = File(result.files.single.path!);
          _error = null;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error picking file: $e';
      });
    }
  }

  Future<void> _uploadToFirestore() async {
    if (_file == null) {
      setState(() {
        _error = 'Please select a file first';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      var bytes = _file!.readAsBytesSync();
      var excel = e.Excel.decodeBytes(bytes);

      for (var table in excel.tables.keys) {
        var rows = excel.tables[table]!.rows;

        // Skip header row
        for (var i = 1; i < 3; i++) {
          var row = rows[i];
          // Customize this according to your Excel structure
          await FirebaseFirestore.instance.collection('your_collection').add({
            'field1': row[0]?.value?.toString(),
            'field2': row[1]?.value?.toString(),
            // Add more fields as needed
          });
        }
      }

      setState(() {
        _file = null;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Upload successful!')),
        );
      });
    } catch (e) {
      setState(() {
        _error = 'Error uploading file: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Import Excel',
          style: TextStyle(color: AppColors.appBarTitleColor),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.inputFieldColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _error != null ? AppColors.textErrorColor : Colors.grey.shade300,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.cloud_upload_outlined,
                    size: 48,
                    color: AppColors.primaryColor,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _file != null ? _file!.path.split('/').last : 'Select Excel File',
                    style: TextStyle(
                      color: AppColors.textInputColor,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (_error != null)
              Text(
                _error!,
                style: TextStyle(
                  color: AppColors.textErrorColor,
                  fontSize: 14,
                ),
              ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _pickFile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Select File',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _uploadToFirestore,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Text(
                      'Upload',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}