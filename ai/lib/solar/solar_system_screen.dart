import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

import 'solar_model.dart';
import 'solar_widget.dart';
import '../widgets/no_connection_widget.dart';

// Loading Overlay Widget
class LoadingOverlay extends StatefulWidget {
  final bool isLoading;

  const LoadingOverlay({
    Key? key,
    required this.isLoading,
  }) : super(key: key);

  @override
  State<LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<LoadingOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: widget.isLoading ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: IgnorePointer(
        ignoring: !widget.isLoading,
        child: Container(
          color: Colors.black.withOpacity(0.7),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated rotating planet icon
                RotationTransition(
                  turns: _animationController,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue[400]!,
                          Colors.cyan[300]!,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.6),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.public,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Loading text with gradient
                ShaderMask(
                  shaderCallback: (bounds) {
                    return LinearGradient(
                      colors: [Colors.cyan[300]!, Colors.blue[400]!],
                    ).createShader(bounds);
                  },
                  child: const Text(
                    'Loading Solar System',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Animated dots
                _buildAnimatedDots(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            final animValue =
                (_animationController.value * 3 - index).clamp(0, 1);
            final opacity = (animValue - (animValue - 0.5).abs()).clamp(0, 1);

            return Opacity(
              opacity: opacity.toDouble() * 0.7 + 0.3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.cyan[300],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

// Main Solar System Screen
class SolarSystemScreen extends StatefulWidget {
  const SolarSystemScreen({super.key});

  @override
  State<SolarSystemScreen> createState() => _SolarSystemScreenState();
}

class _SolarSystemScreenState extends State<SolarSystemScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String _currentPlanet = 'Sun';
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  static const String _baseUrl = 'https://bailus.github.io/WebGL-Solar-System/';
  static const String _cacheDir = 'solar_system_cache';

  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _checkInitialConnectivity();
    _startMonitoringConnectivity();
    _initializeWebView();
    _cacheWebGLContent();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  Future<void> _checkInitialConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    if (result.contains(ConnectivityResult.none)) {
      if (mounted) setState(() => _isOffline = true);
    }
  }

  void _startMonitoringConnectivity() {
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((result) {
      final isOffline = result.contains(ConnectivityResult.none);
      if (isOffline != _isOffline) {
        if (mounted) setState(() => _isOffline = isOffline);
      }
    });
  }

  Future<void> _cacheWebGLContent() async {
    try {
      final connectivity = await _connectivity.checkConnectivity();
      if (connectivity.contains(ConnectivityResult.none)) {
        return; // No internet, skip caching
      }

      final appDir = await getApplicationDocumentsDirectory();
      final cacheDir = Directory('${appDir.path}/$_cacheDir');

      if (!await cacheDir.exists()) {
        await cacheDir.create(recursive: true);
      }

      // Check if already cached
      final indexFile = File('${cacheDir.path}/index.html');
      if (await indexFile.exists()) {
        return; // Already cached
      }

      // Download the main HTML file
      final response = await http.get(Uri.parse(_baseUrl)).timeout(
            const Duration(seconds: 30),
          );

      if (response.statusCode == 200) {
        await indexFile.writeAsString(response.body);
        debugPrint('✓ Solar System cached successfully');
      }
    } catch (e) {
      debugPrint('Caching error: $e');
      // Continue normally if caching fails
    }
  }

  Future<String> _getLoadUrl() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final indexFile = File('${appDir.path}/$_cacheDir/index.html');

      if (await indexFile.exists()) {
        return indexFile.readAsStringSync();
      }
    } catch (e) {
      debugPrint('Error loading cached file: $e');
    }

    // Fallback to online version
    return '';
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            // Keep loading indicator for a bit longer while hiding UI elements
            Future.delayed(const Duration(milliseconds: 1500), () {
              setState(() => _isLoading = false);
            });
            _enableMobileTouchControls();
          },
          onWebResourceError: (WebResourceError error) {
            setState(() => _isLoading = false);
            if (error.errorCode == -2 || error.errorCode == -1009) {
            } else {
              _showErrorSnackBar('Failed to load: ${error.description}');
            }
          },
        ),
      )
      ..loadRequest(Uri.parse('$_baseUrl#Sun'));
  }

  void _enableMobileTouchControls() {
    _controller.runJavaScript('''
      (function() {
        console.log('Enable 3D rotation + zoom controls...');
        
        // Function to hide UI elements but keep canvas visible
        function hideAllUI() {
          // Find and keep only the canvas element visible
          var canvas = document.querySelector('canvas');
          if (canvas) {
            // Ensure canvas is visible and interactive
            canvas.style.display = 'block';
            canvas.style.visibility = 'visible';
            canvas.style.opacity = '1';
            canvas.style.pointerEvents = 'auto';
            canvas.style.width = '100%';
            canvas.style.height = '100%';
          }
          
          // Hide planet lists and menus specifically
          var planetLists = document.querySelectorAll(
            'ul, ol, .list, .planet-list, .planets, nav, aside, ' +
            'select, option, ' +
            '[class*="menu"]:not(canvas), [class*="list"]:not(canvas), ' +
            '[class*="nav"]:not(canvas), [class*="planet"]:not(canvas), ' +
            '[class*="sidebar"], [class*="panel"], [class*="dropdown"]'
          );
          planetLists.forEach(function(el) {
            if (!el.querySelector('canvas') && el.tagName !== 'CANVAS') {
              el.style.display = 'none';
              el.style.visibility = 'hidden';
              el.style.opacity = '0';
            }
          });
          
          // Hide buttons and controls but not canvas
          var buttons = document.querySelectorAll('button, .button, [class*="btn"], [class*="control"]');
          buttons.forEach(function(el) {
            if (!el.querySelector('canvas') && el.tagName !== 'CANVAS') {
              el.style.display = 'none';
            }
          });
          
          // Hide text overlays but not canvas
          var textElements = document.querySelectorAll('div, span, p, h1, h2, h3, h4, h5, h6, label');
          textElements.forEach(function(el) {
            if (!el.querySelector('canvas') && el.tagName !== 'CANVAS' && el !== document.body && el !== document.documentElement) {
              var hasVisibleText = el.innerText && el.innerText.trim().length > 0;
              if (hasVisibleText) {
                el.style.display = 'none';
              }
            }
          });
        }
        
        // Hide UI after a delay to let WebGL initialize
        setTimeout(function() {
          hideAllUI();
          
          // Keep checking and hiding UI elements periodically
          var hideInterval = setInterval(hideAllUI, 500);
          
          var canvas = document.querySelector('canvas');
          if (canvas) {
            // Simulate multiple zoom out wheel events
            for (var i = 0; i < 15; i++) {
              var wheel = new WheelEvent('wheel', {deltaY: 100, deltaMode: WheelEvent.DOM_DELTA_PIXEL});
              canvas.dispatchEvent(wheel);
            }
          }
        }, 800);
        
        var canvas = document.querySelector('canvas');
        if (canvas) {
          canvas.style.touchAction = 'none';
          canvas.style.userSelect = 'none';
          canvas.style.webkitUserSelect = 'none';
          canvas.style.webkitTouchCallout = 'none';
          
          var isMouseDown = false;
          var lastTouchX = 0, lastTouchY = 0;
          var lastTouchDistance = 0;
          var isZooming = false;

          canvas.addEventListener('touchstart', function(e) {
            if (e.touches.length === 1) {
              var t = e.touches[0];
              lastTouchX = t.clientX;
              lastTouchY = t.clientY;
              isMouseDown = true;
              canvas.dispatchEvent(new MouseEvent('mousedown', {clientX: t.clientX, clientY: t.clientY, button: 0}));
            }
            if (e.touches.length === 2) {
              var t1 = e.touches[0], t2 = e.touches[1];
              lastTouchDistance = Math.hypot(t2.clientX - t1.clientX, t2.clientY - t1.clientY);
              isZooming = true;
            }
          }, {passive:false});

          canvas.addEventListener('touchmove', function(e) {
            if (e.touches.length === 1 && isMouseDown) {
              var t = e.touches[0];
              canvas.dispatchEvent(new MouseEvent('mousemove', {clientX: t.clientX, clientY: t.clientY, button:0, buttons:1}));
              lastTouchX = t.clientX;
              lastTouchY = t.clientY;
            }
            if (e.touches.length === 2 && isZooming) {
              var t1 = e.touches[0], t2 = e.touches[1];
              var dist = Math.hypot(t2.clientX - t1.clientX, t2.clientY - t1.clientY);
              var delta = dist - lastTouchDistance;
              var wheel = new WheelEvent('wheel', {deltaY: -delta * 2, deltaMode: WheelEvent.DOM_DELTA_PIXEL});
              canvas.dispatchEvent(wheel);
              lastTouchDistance = dist;
            }
          }, {passive:false});

          canvas.addEventListener('touchend', function(e) {
            if (isMouseDown && e.touches.length === 0) {
              canvas.dispatchEvent(new MouseEvent('mouseup', {clientX:lastTouchX, clientY:lastTouchY, button:0}));
              isMouseDown = false;
            }
            if (e.touches.length < 2) isZooming = false;
          }, {passive:false});
        }
      })();
    ''');
  }

  void _navigateToPlanet(Planet planet) {
    _connectivity.checkConnectivity().then((result) {
      if (result.contains(ConnectivityResult.none)) {
      } else {
        _controller.loadRequest(Uri.parse('$_baseUrl${planet.url}'));
        setState(() => _currentPlanet = planet.name);
        _showPlanetInfoSnackBar(planet);
      }
    });
  }

  void _showPlanetSelector() {
    _connectivity.checkConnectivity().then((result) {
      if (result.contains(ConnectivityResult.none)) {
      } else {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (context) => PlanetSelectorSheet(
            currentPlanet: _currentPlanet,
            onPlanetSelected: _navigateToPlanet,
          ),
        );
      }
    });
  }

  void _showPlanetInfoSnackBar(Planet planet) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${planet.name}: ${planet.description}'),
        backgroundColor: Colors.deepPurple,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text('Solar System - $_currentPlanet'),
      backgroundColor: Colors.black87,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            _connectivity.checkConnectivity().then((result) {
              if (result.contains(ConnectivityResult.none)) {
              } else {
                _controller.reload();
              }
            });
          },
        ),
        IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: _showAboutDialog,
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_isOffline) {
      return NoConnectionWidget(
        onRetry: () {
          _controller.reload();
          _checkInitialConnectivity();
        },
        message: 'Internet connection is required to explore the Solar System.',
      );
    }

    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        LoadingOverlay(isLoading: _isLoading),
        _buildZoomControls(),
      ],
    );
  }

  Widget _buildZoomControls() {
    return const Positioned(
      right: 16,
      bottom: 100,
      child: Column(
        children: [
          SizedBox(height: 8),
        ],
      ),
    );
  }

  void _zoomIn() {
    _controller.runJavaScript('''
      var canvas = document.querySelector('canvas');
      if (canvas) {
        // Hide any popups that might appear
        document.querySelectorAll('.dialog, .info-box, .popup, [class*="dialog"]').forEach(function(el) {
          el.style.display = 'none';
        });
        
        for (var i = 0; i < 3; i++) {
          var wheel = new WheelEvent('wheel', {deltaY: -50, deltaMode: WheelEvent.DOM_DELTA_PIXEL});
          canvas.dispatchEvent(wheel);
        }
      }
    ''');
  }

  void _zoomOut() {
    _controller.runJavaScript('''
      var canvas = document.querySelector('canvas');
      if (canvas) {
        // Hide any popups that might appear
        document.querySelectorAll('.dialog, .info-box, .popup, [class*="dialog"]').forEach(function(el) {
          el.style.display = 'none';
        });
        
        for (var i = 0; i < 3; i++) {
          var wheel = new WheelEvent('wheel', {deltaY: 50, deltaMode: WheelEvent.DOM_DELTA_PIXEL});
          canvas.dispatchEvent(wheel);
        }
      }
    ''');
  }

  void _resetView() {
    _controller.runJavaScript('''
      var canvas = document.querySelector('canvas');
      if (canvas) {
        // Hide any popups that might appear
        document.querySelectorAll('.dialog, .info-box, .popup, [class*="dialog"]').forEach(function(el) {
          el.style.display = 'none';
        });
        
        for (var i = 0; i < 15; i++) {
          var wheel = new WheelEvent('wheel', {deltaY: 100, deltaMode: WheelEvent.DOM_DELTA_PIXEL});
          canvas.dispatchEvent(wheel);
        }
      }
    ''');
  }

  Widget? _buildFloatingActionButton() {
    return null; // Hide the Planets button completely
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('About Solar System Explorer',
            style: TextStyle(color: Colors.white)),
        content: const Text(
          '🌍 Explore our solar system in 3D!\n\n'
          '👉 Drag to rotate\n'
          '👉 Pinch to zoom in/out\n'
          '👉 Use zoom buttons on the right\n'
          '👉 Navigate planets from the menu\n\n'
          'Content is cached for faster loading!',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
