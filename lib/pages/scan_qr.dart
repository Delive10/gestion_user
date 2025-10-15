import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/services.dart';

const Color _primaryColor = Color(0xFF296239);

class ScanQrPage extends StatefulWidget {
  const ScanQrPage({super.key});

  @override
  State<ScanQrPage> createState() => _ScanQrPageState();
}

class _ScanQrPageState extends State<ScanQrPage>
    with SingleTickerProviderStateMixin {
  final MobileScannerController _cameraController = MobileScannerController();
  bool _isProcessing = false;
  bool _flashOn = false;
  CameraFacing _facing = CameraFacing.back;
  late final AnimationController _lineController;

  @override
  void initState() {
    super.initState();
    _lineController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat();
  }

  @override
  void dispose() {
    _lineController.dispose();
    _cameraController.dispose();
    super.dispose();
  }

  // CHANGED: signature compatible with mobile_scanner versions expecting
  // onDetect: (Barcode barcode, MobileScannerArguments? args)
  void _onDetect(Barcode barcode, MobileScannerArguments? args) async {
    if (_isProcessing) return;
    final String? raw = barcode.rawValue;
    if (raw == null || raw.isEmpty) return;

    setState(() => _isProcessing = true);
    await _cameraController.stop();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('QR détecté'),
        content: Text(raw),
        actions: [
          TextButton(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: raw));
              if (mounted) Navigator.of(context).pop();
            },
            child: const Text('Copier'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Fermer'),
          ),
        ],
      ),
    );

    // reprendre le scan
    if (mounted) {
      await Future.delayed(const Duration(milliseconds: 300));
      await _cameraController.start();
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final previewSize = size.width - 32;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _primaryColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.qr_code_2, color: Colors.black87),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Scan QR Code',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Basculer caméra',
                  onPressed: () {
                    _facing = _facing == CameraFacing.back
                        ? CameraFacing.front
                        : CameraFacing.back;
                    _cameraController.switchCamera();
                    setState(() {});
                  },
                  icon: const Icon(Icons.flip_camera_android),
                ),
                IconButton(
                  tooltip: 'Lampe',
                  onPressed: () {
                    _flashOn = !_flashOn;
                    _cameraController.toggleTorch();
                    setState(() {});
                  },
                  icon: Icon(_flashOn ? Icons.flash_on : Icons.flash_off),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // preview caméra avec overlay
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: SizedBox(
                      width: previewSize,
                      height: previewSize,
                      child: MobileScanner(
                        controller: _cameraController,
                        fit: BoxFit.cover,
                        onDetect: _onDetect, // now matches (Barcode, MobileScannerArguments?)
                      ),
                    ),
                  ),

                  // bordure rouge épaisse
                  Container(
                    width: previewSize,
                    height: previewSize,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: _primaryColor.withOpacity(0.9), width: 3),
                    ),
                  ),

                  // coins (marqueurs)
                  Positioned(
                    left: 10,
                    top: 10,
                    child: _corner(color: _primaryColor),
                  ),
                  Positioned(
                    right: 10,
                    top: 10,
                    child: _corner(rotated: true, color: _primaryColor),
                  ),
                  Positioned(
                    left: 10,
                    bottom: 10,
                    child: _corner(rotated: true, mirror: true, color: _primaryColor),
                  ),
                  Positioned(
                    right: 10,
                    bottom: 10,
                    child: _corner(mirror: true, color: _primaryColor),
                  ),

                  // ligne animée de scan
                  Positioned(
                    top: 20,
                    child: SizedBox(
                      width: previewSize - 40,
                      height: previewSize - 40,
                      child: AnimatedBuilder(
                        animation: _lineController,
                        builder: (context, child) {
                          final t = _lineController.value;
                          return CustomPaint(
                            painter: _ScanLinePainter(progress: t),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // textes d'instruction
            Center(
              child: Column(
                children: const [
                  Text(
                    'Centre le QR code dans la zone',
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Le scan démarrera automatiquement',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ),

            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _corner({bool rotated = false, bool mirror = false, Color color = _primaryColor}) {
    // simple marqueur d'angle
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..rotateZ(rotated ? 0 : 0)
        ..scale(mirror ? -1.0 : 1.0),
      child: Column(
        children: [
          Container(width: 28, height: 4, color: color),
          const SizedBox(height: 4),
          Container(width: 4, height: 28, color: color),
        ],
      ),
    );
  }
}

// Painter pour la ligne animée
class _ScanLinePainter extends CustomPainter {
  final double progress;
  _ScanLinePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _primaryColor.withOpacity(0.95)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final y = size.height * progress;
    canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
  }

  @override
  bool shouldRepaint(covariant _ScanLinePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
