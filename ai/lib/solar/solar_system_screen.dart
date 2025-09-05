import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; // Add this import

import 'solar_model.dart';
import 'solar_widget.dart';
import 'widget_loading_overlay.dart';

class SolarSystemScreen extends StatefulWidget {
  const SolarSystemScreen({super.key});

  @override
  State<SolarSystemScreen> createState() => _SolarSystemScreenState();
}

class _SolarSystemScreenState extends State<SolarSystemScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String _currentPlanet = 'Sun';
  final Connectivity _connectivity = Connectivity(); // Add connectivity instance
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription; // Fix type to match onConnectivityChanged

  static const String _baseUrl = 'https://bailus.github.io/WebGL-Solar-System/';

  @override
  void initState() {
    super.initState();
    _initializeWebView();
    _startMonitoringConnectivity(); // Start monitoring connectivity
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel(); // Cancel subscription when disposed
    super.dispose();
  }

  void _startMonitoringConnectivity() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((result) {
      if (result == ConnectivityResult.none) {
        _showNoInternetMessage();
      }
    });
  }

  void _showNoInternetMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.wifi_off, color: Colors.white, size: 20),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Connection lost. Please check your internet connection to explore the solar system.',
                style: TextStyle(fontSize: 14,color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 156, 152, 152),
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        action: SnackBarAction(
          label: 'RETRY',
          textColor: Colors.amber[300],
          onPressed: () {
            _controller.reload();
          },
        ),
      ),
    );
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
            setState(() => _isLoading = false);
            _enableMobileTouchControls();
          },
          onWebResourceError: (WebResourceError error) {
            // Check if error is due to no internet
            if (error.errorCode == -2 || error.errorCode == -1009) {
              _showNoInternetMessage();
            } else {
              _showErrorSnackBar('Failed to load: ${error.description}');
            }
          },
        ),
      )
      ..loadRequest(Uri.parse('$_baseUrl#Sun'));
  }

  /// Injects JavaScript to enable rotation + pinch-to-zoom
  void _enableMobileTouchControls() {
    _controller.runJavaScript('''
      (function() {
        console.log('Enable 3D rotation + zoom controls...');
        
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

          // Single finger drag = rotate
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
              var wheel = new WheelEvent('wheel', {deltaY: -delta, deltaMode: WheelEvent.DOM_DELTA_PIXEL});
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
    // Check connectivity before navigating
    _connectivity.checkConnectivity().then((result) {
      if (result == ConnectivityResult.none) {
        _showNoInternetMessage();
      } else {
        _controller.loadRequest(Uri.parse('$_baseUrl${planet.url}'));
        setState(() => _currentPlanet = planet.name);
        _showPlanetInfoSnackBar(planet);
      }
    });
  }

  void _showPlanetSelector() {
    // Check connectivity before showing planet selector
    _connectivity.checkConnectivity().then((result) {
      if (result == ConnectivityResult.none) {
        _showNoInternetMessage();
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
              if (result == ConnectivityResult.none) {
                _showNoInternetMessage();
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
    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        LoadingOverlay(isLoading: _isLoading),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _showPlanetSelector,
      backgroundColor: const Color.fromARGB(255, 144, 134, 161),
      icon: const Icon(Icons.public),
      label: const Text('Planets'),
    );
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
          '👉 Navigate planets from the menu\n\n',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text('Close')
          ),
        ],
      ),
    );
  }
}