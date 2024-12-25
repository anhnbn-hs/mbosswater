import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

@immutable
class UploadState {}

class UploadInitial extends UploadState {}

class UploadInProgress extends UploadState {}

class UploadSuccess extends UploadState {
  final List<String> downloadUrls;

  UploadSuccess(this.downloadUrls);
}

class UploadFailure extends UploadState {
  final String error;

  UploadFailure(this.error);
}

class UploadCubit extends Cubit<UploadState> {
  final FirebaseStorage storage;

  UploadCubit({FirebaseStorage? firebaseStorage})
      : storage = firebaseStorage ?? FirebaseStorage.instance,
        super(UploadInitial());

  Future<XFile> compressImage(File file, {int quality = 80}) async {
    final outputPath = file.path.replaceAll('.jpg', '_compressed.jpg');
    final result = await FlutterImageCompress.compressAndGetFile(
      file.path,
      outputPath,
      quality: quality,
    );
    return result!;
  }

  /// Upload multi file from XFile
  String storageFolder = "/images/guarantee_request";
  Future<void> uploadFilesFromXFiles(List<XFile> files) async {
    emit(UploadInProgress());
    try {
      final uploadTasks = files.map((xFile) async {
        String fileName = xFile.name;
        String storagePath = "$storageFolder/$fileName";

        File originalFile = File(xFile.path);
        XFile compressedFile = await compressImage(originalFile);

        final task = await storage.ref(storagePath).putFile(File(compressedFile.path));

        return await task.ref.getDownloadURL();
      }).toList();

      final downloadUrls = await Future.wait(uploadTasks);

      emit(UploadSuccess(downloadUrls));
    } catch (e) {
      emit(UploadFailure("Failed to upload all files: ${e.toString()}"));
    }
  }

}
