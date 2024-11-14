import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mbosswater/core/styles/app_styles.dart';
import 'package:mbosswater/core/utils/dialogs.dart';
import 'package:mbosswater/core/widgets/leading_back_button.dart';
import 'package:mbosswater/features/guarantee/data/model/product.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrcodeScannerPage extends StatefulWidget {
  const QrcodeScannerPage({super.key});

  @override
  State<QrcodeScannerPage> createState() => _QrcodeScannerPageState();
}

class _QrcodeScannerPageState extends State<QrcodeScannerPage>
    with SingleTickerProviderStateMixin {
  late MobileScannerController controller;

  late AnimationController animationController;

  ValueNotifier<TorchState> torchStateNotifier = ValueNotifier(TorchState.off);
  ValueNotifier<CameraFacing> cameraDirectionNotifier =
      ValueNotifier(CameraFacing.back);

  bool isProcessingScan = false;

  @override
  void initState() {
    super.initState();

    controller = MobileScannerController();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    // Start the camera when the page is first created
    controller.start();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Start camera khi quay lại trang
    print("CAM START _______________");
    if (ModalRoute.of(context)?.isCurrent == true) {
      controller.start(); // Khởi động lại camera
    }
  }

  @override
  void dispose() {
    print("CAM STOPPED _______________");
    controller.stop();
    animationController.dispose();
    controller.dispose();
    super.dispose();
  }

  void switchTorch() {
    controller.toggleTorch();
    // Toggle between front and back camera
    torchStateNotifier.value = torchStateNotifier.value == TorchState.off
        ? TorchState.on
        : TorchState.off;
  }

  void switchCamera() {
    controller.switchCamera();
    // Toggle between front and back camera
    cameraDirectionNotifier.value =
        cameraDirectionNotifier.value == CameraFacing.back
            ? CameraFacing.front
            : CameraFacing.back;
  }

  Future<void> handleScannedCode(String code) async {
    if (isProcessingScan) return; // Skip if already processing a scan
    isProcessingScan = true;

    // Your handling logic here
    try {
      Map<String, dynamic> data = jsonDecode(code);
      if (data["code"] == "mbosswater") {
        // QR code valid
        DialogUtils.showLoadingDialog(context);
        await Future.delayed(const Duration(seconds: 1), () {
          isProcessingScan = false;
        });
        // Extract data to get product
        if (data["product"] != null) {
          final productItem = Product.fromJson(data["product"]);
          // Stop camera
          await controller
              .stop()
              .then((value) => controller.stop());
          // Navigate
          DialogUtils.hide(context);
          context.push(
            "/guarantee-active",
            extra: productItem,
          );
          return;
        }
        DialogUtils.hide(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mã QR không hợp lệ!'),
            duration: Duration(seconds: 2),
          ),
        );
        isProcessingScan = false;
        return;
      }
    } on Exception {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mã QR không hợp lệ!'),
          duration: Duration(seconds: 2),
        ),
      );
      isProcessingScan = false;
      return;
    }

    // Reset processing flag after a delay
    await Future.delayed(const Duration(seconds: 2), () {
      isProcessingScan = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Quét mã QR",
          style: AppStyle.appBarTitle,
        ),
        centerTitle: true,
        leading: const LeadingBackButton(),
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: torchStateNotifier,
              builder: (context, state, child) {
                return Icon(
                  state == TorchState.on ? Icons.flash_on : Icons.flash_off,
                );
              },
            ),
            onPressed: () => switchTorch(),
          ),
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: cameraDirectionNotifier,
              builder: (context, state, child) {
                return Icon(
                  state == CameraFacing.front
                      ? Icons.camera_front
                      : Icons.camera_rear,
                );
              },
            ),
            onPressed: () => switchCamera(),
          ),
        ],
      ),
      body: Column(
        children: [
          const Flexible(
            flex: 1,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Đặt mã QR vào trong vùng",
                    style: TextStyle(
                      fontFamily: 'BeVietNam',
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Color(0xff201E1E),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Hệ thống sẽ quét mã tự động",
                    style: TextStyle(
                      fontFamily: 'BeVietNam',
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Color(0xffb7b7b7),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Flexible(
            flex: 3,
            child: Center(
              child: Stack(
                children: [
                  Container(
                    height: size.width * 0.8,
                    width: size.width * 0.8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: MobileScanner(
                      controller: controller,
                      placeholderBuilder: (p0, p1) {
                        return const Center(
                          child: Text("Đang khởi tạo máy ảnh"),
                        );
                      },
                      fit: BoxFit.fill,
                      scanWindowUpdateThreshold: 2,
                      onDetect: (capture) async {
                        final List<Barcode> barcodes = capture.barcodes;
                        for (final barcode in barcodes) {
                          final String? code = barcode.rawValue;
                          if (code != null) {
                            await handleScannedCode(code);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('No value found in the scanned code'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ),
                  AnimatedBuilder(
                    animation: animationController,
                    builder: (context, child) {
                      return CustomPaint(
                        size: Size(size.width * 0.8, size.width * 0.8),
                        painter: ScannerOverlayPainter(
                          animationValue: animationController.value,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Flexible(
            flex: 1,
            child: Container(),
          )
        ],
      ),
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  final double animationValue;

  ScannerOverlayPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final double scanAreaSize = size.width * 0.7;
    final double scanAreaHeight = scanAreaSize;
    final double left = (size.width - scanAreaSize) / 2;
    final double top = (size.height - scanAreaHeight) / 2;
    final double right = left + scanAreaSize;
    final double bottom = top + scanAreaHeight;

    // Draw semi-transparent overlay
    final Paint backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    Path backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    Path transparentPath = Path()
      ..addRect(Rect.fromLTRB(left, top, right, bottom));

    final Path overlayPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      transparentPath,
    );

    canvas.drawPath(overlayPath, backgroundPaint);

    // Draw scanning area border
    final Paint borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    // Draw corner lines
    final double cornerLength = 20.0;

    // Top left corner
    canvas.drawLine(
        Offset(left, top + cornerLength), Offset(left, top), borderPaint);
    canvas.drawLine(
        Offset(left, top), Offset(left + cornerLength, top), borderPaint);

    // Top right corner
    canvas.drawLine(
        Offset(right - cornerLength, top), Offset(right, top), borderPaint);
    canvas.drawLine(
        Offset(right, top), Offset(right, top + cornerLength), borderPaint);

    // Bottom left corner
    canvas.drawLine(
        Offset(left, bottom - cornerLength), Offset(left, bottom), borderPaint);
    canvas.drawLine(
        Offset(left, bottom), Offset(left + cornerLength, bottom), borderPaint);

    // Bottom right corner
    canvas.drawLine(Offset(right - cornerLength, bottom), Offset(right, bottom),
        borderPaint);
    canvas.drawLine(Offset(right, bottom), Offset(right, bottom - cornerLength),
        borderPaint);

    // Draw scan line with smooth animation
    final Paint scanLinePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withOpacity(0.0),
          Colors.white.withOpacity(0.7),
          Colors.white.withOpacity(0.0),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTRB(left, top, right, bottom));

    // Smooth up and down animation
    final double scanLineY = top + (bottom - top) * animationValue;

    canvas.drawLine(
      Offset(left, scanLineY),
      Offset(right, scanLineY),
      scanLinePaint..strokeWidth = 3.0,
    );
  }

  @override
  bool shouldRepaint(covariant ScannerOverlayPainter oldDelegate) {
    return animationValue != oldDelegate.animationValue;
  }
}
