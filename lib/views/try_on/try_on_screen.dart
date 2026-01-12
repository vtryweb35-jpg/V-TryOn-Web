import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../../models/product.dart';
import '../../services/try_on_service.dart';
import '../../widgets/app_scaffold.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_snackbar.dart';

import '../../services/api_service.dart';

class TryOnScreen extends StatefulWidget {
  final Product? product;
  const TryOnScreen({super.key, this.product});

  @override
  State<TryOnScreen> createState() => _TryOnScreenState();
}

class _TryOnScreenState extends State<TryOnScreen>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0; // 0: Upload/Select, 1: AI Processing, 2: Result
  String? _selectedModelUrl;
  Uint8List? _pickedImageBytes;
  String? _resultImageUrl;
  bool _isError = false;
  String _errorMessage = '';
  late AnimationController _scanController;

  final List<String> _sampleModels = [
    "assets/images/person.jpg",
    "assets/images/person1.jpg",
    "assets/images/person2.jpg",
    "assets/images/person4.jpg",
  ];

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  Widget _buildImage(
    String? url, {
    Uint8List? bytes,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
  }) {
    if (bytes != null) {
      return Image.memory(bytes, width: width, height: height, fit: fit);
    }
    if (url != null && url.startsWith('assets/')) {
      return Image.asset(url, width: width, height: height, fit: fit);
    }
    if (url != null) {
      return Image.network(url, width: width, height: height, fit: fit);
    }
    return const SizedBox();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _pickedImageBytes = bytes;
        _selectedModelUrl = null; // Clear preset selection
      });
    }
  }

  void _startAIProcessing() async {
    if (_selectedModelUrl == null && _pickedImageBytes == null) return;

    if (widget.product == null) {
      AppSnackbar.show(
        context,
        message: 'Please select a garment first.',
        isError: true,
      );
      return;
    }

    setState(() {
      _currentStep = 1;
      _isError = false;
    });

    // Log Try-On event for analytics
    try {
      ApiService.post('/analytics/try-on', {
        'productId': widget.product!.id,
      });
    } catch (e) {
      debugPrint('Error logging try-on: $e');
    }

    try {
      // 1. Load Person Image Bytes
      Uint8List personBytes;
      if (_pickedImageBytes != null) {
        personBytes = _pickedImageBytes!;
      } else if (_selectedModelUrl!.startsWith('assets/')) {
        final data = await rootBundle.load(_selectedModelUrl!);
        personBytes = data.buffer.asUint8List();
      } else {
        final response = await http.get(Uri.parse(_selectedModelUrl!));
        if (response.statusCode == 200) {
          personBytes = response.bodyBytes;
        } else {
          throw Exception('Failed to download model image');
        }
      }

      // 2. Load Cloth Image Bytes
      final clothResponse = await http.get(Uri.parse(widget.product!.imageUrl));
      if (clothResponse.statusCode != 200) {
        throw Exception('Failed to download cloth image');
      }
      final clothBytes = clothResponse.bodyBytes;

      // 3. Call API
      final response = await TryOnService.runTryOn(
        personImageBytes: personBytes,
        clothImageBytes: clothBytes,
      );

      if (mounted) {
        setState(() {
          _resultImageUrl = '${TryOnService.baseUrl}${response['result_url']}';
          _currentStep = 2;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentStep = 0;
          _isError = true;
          _errorMessage = e.toString().contains('Exception:') 
              ? e.toString().split('Exception:')[1].trim()
              : e.toString();
        });
        AppSnackbar.show(
          context,
          message: _errorMessage,
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildStepIndicator(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
              child: _buildCurrentState(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.all(40),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _stepIcon(0, Icons.upload_file, 'Choose Image'),
          _stepLine(1),
          _stepIcon(1, Icons.auto_awesome, 'AI Fit'),
          _stepLine(2),
          _stepIcon(2, Icons.check_circle, 'Result'),
        ],
      ),
    );
  }

  Widget _stepIcon(int step, IconData icon, String label) {
    bool isActive = _currentStep >= step;
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primaryColor : Colors.grey[200],
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: isActive ? Colors.white : Colors.black26),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? Colors.black87 : Colors.black26,
          ),
        ),
      ],
    );
  }

  Widget _stepLine(int step) {
    bool isActive = _currentStep >= step;
    return Container(
      width: 100,
      height: 2,
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 25),
      color: isActive ? AppTheme.primaryColor : Colors.grey[200],
    );
  }

  Widget _buildCurrentState() {
    switch (_currentStep) {
      case 0:
        return _buildStep1();
      case 1:
        return _buildStep2();
      case 2:
        return _buildStep3();
      default:
        return const SizedBox();
    }
  }

  Widget _buildStep1() {
    return Column(
      children: [
        const Text(
          'Step 1: Choose a model or upload your own',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 48),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sample Models
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select a Pre-set Model:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  GridView.builder(
                    shrinkWrap: true,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.8,
                        ),
                    itemCount: _sampleModels.length,
                    itemBuilder: (context, index) {
                      bool isSelected =
                          _selectedModelUrl == _sampleModels[index];
                      return GestureDetector(
                        onTap: () => setState(
                          () {
                            _selectedModelUrl = _sampleModels[index];
                            _pickedImageBytes = null; // Clear upload selection
                          },
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.primaryColor
                                  : Colors.black12,
                              width: isSelected ? 3 : 1,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(13),
                            child: Image.asset(
                              _sampleModels[index],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 80),
            // Upload Option
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'OR Upload Your Own Photo:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    height: 350,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.black12,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: _pickedImageBytes == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.cloud_upload_outlined,
                                size: 64,
                                color: Colors.black26,
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                'Drop your photo here',
                                style: TextStyle(color: Colors.black45),
                              ),
                              const SizedBox(height: 32),
                              ElevatedButton(
                                onPressed: _pickImage,
                                child: const Text('BROWSE FILES'),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                height: 250,
                                width: 200,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: AppTheme.primaryColor,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.memory(
                                    _pickedImageBytes!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              OutlinedButton.icon(
                                onPressed: _pickImage,
                                icon: const Icon(Icons.refresh),
                                label: const Text('CHANGE PHOTO'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  side: BorderSide(color: AppTheme.primaryColor.withValues(alpha: 0.5)),
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 80),
        ElevatedButton(
          onPressed: (_selectedModelUrl == null && _pickedImageBytes == null) ? null : _startAIProcessing,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 24),
            backgroundColor: AppTheme.primaryColor,
          ),
          child: const Text('PROCEED TO TRY-ON'),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Center(
      child: Column(
        children: [
          const Text(
            'AI is processing your request...',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 48),
          Container(
            width: 400,
            height: 600,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Colors.black12,
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: _buildImage(
                    _selectedModelUrl,
                    bytes: _pickedImageBytes,
                    width: 400,
                    height: 600,
                  ),
                ),
                AnimatedBuilder(
                  animation: _scanController,
                  builder: (context, child) {
                    return Positioned(
                      top: 600 * _scanController.value,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryColor.withValues(
                                alpha: 0.8,
                              ),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    );
                  },
                ),
                Container(
                  color: Colors.black26,
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
          const Text(
            'Analyzing garment fit and body pose...',
            style: TextStyle(fontSize: 18, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return Center(
      child: Column(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 80),
          const SizedBox(height: 24),
          const Text(
            'Try-On Complete!',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 48),
          Container(
            width: 500,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 40,
                ),
              ],
            ),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: _resultImageUrl != null
                      ? Image.network(
                          _resultImageUrl!,
                          height: 600,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Center(
                                child: Text('Failed to load result image'),
                              ),
                        )
                      : _buildImage(
                          _selectedModelUrl,
                          bytes: _pickedImageBytes,
                          height: 600,
                          width: double.infinity,
                        ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.download),
                        label: const Text('DOWNLOAD'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          backgroundColor: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => setState(() {
                          _currentStep = 0;
                          _selectedModelUrl = null;
                          _pickedImageBytes = null;
                        }),
                        icon: const Icon(Icons.refresh),
                        label: const Text('TRY ANOTHER'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
