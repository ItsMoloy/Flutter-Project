import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/auth_provider.dart';
import '../services/api_service.dart';

// A 1x1 transparent PNG used as an in-memory placeholder for FadeInImage
const List<int> _kTransparentImageBytes = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,
  0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41,
  0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00,
  0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
];

final kTransparentImage = Uint8List.fromList(_kTransparentImageBytes);

class AuthImage extends StatefulWidget {
  final String? imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;

  const AuthImage({
    super.key,
    required this.imagePath,
    this.width = 48,
    this.height = 48,
    this.fit = BoxFit.cover,
  });

  @override
  State<AuthImage> createState() => _AuthImageState();
}

class _AuthImageState extends State<AuthImage> {
  Uint8List? _bytes;
  String? _url;
  String? _error;
  bool _loading = false;
  bool _visible = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _prepare();
  }

  Future<void> _prepare() async {
    final url = ApiService.imageUrlFor(widget.imagePath);
    setState(() {
      _url = url;
      _error = null;
      _bytes = null;
    });
    if (url == null) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final api = auth.api;

    // Attempt to fetch image bytes using the app http client so we can add
    // Authorization headers when required. On web this may fail if CORS
    // doesn't allow Authorization; we'll fall back to Image.network in that case.
    final token = auth.token;
    final headers = <String, String>{'Accept': 'image/*'};
    if (token != null && token.isNotEmpty) headers['Authorization'] = token.startsWith('Bearer ') ? token : 'Bearer $token';

    // On web, HTTP requests with Authorization headers are often blocked by
    // CORS preflight unless the server explicitly allows them. To avoid
    // persistent XMLHttpRequest/CORS errors in the browser, skip the byte
    // fetch on web and let the build() fallback to a NetworkImage which may
    // succeed if the server allows anonymous cross-origin image requests.
    if (kIsWeb) {
      setState(() {
        _loading = false;
        _error = null;
        _bytes = null;
      });
      return;
    }

    setState(() => _loading = true);
    try {
      // ignore: avoid_print
      print('AuthImage: attempting byte fetch for $url (web=$kIsWeb)');
      final res = await api.client.get(Uri.parse(url), headers: headers);
      // ignore: avoid_print
      print('AuthImage: status ${res.statusCode} for $url');
      if (res.statusCode >= 200 && res.statusCode < 300 && res.bodyBytes.isNotEmpty) {
        setState(() {
          _bytes = res.bodyBytes;
          _visible = true;
        });
        return;
      }
      setState(() => _error = 'Image fetch failed: ${res.statusCode}');
    } catch (e) {
      // ignore: avoid_print
      print('AuthImage: fetch error for $url: $e');
      setState(() => _error = 'Image fetch error');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_url == null) return const CircleAvatar(child: Icon(Icons.person));
    if (_bytes != null) {
      final passWidth = (widget.width == double.infinity) ? null : widget.width;
      final passHeight = (widget.height == double.infinity) ? null : widget.height;
      Widget img = Image.memory(
        _bytes!,
        width: passWidth,
        height: passHeight,
        fit: widget.fit,
      );
      if (passWidth != null || passHeight != null) {
        img = ClipRRect(borderRadius: BorderRadius.circular(6), child: img);
      } else {
        img = ClipRRect(borderRadius: BorderRadius.circular(6), child: img);
      }

      return GestureDetector(
        onTap: () async {
          final uri = Uri.tryParse(_url!);
          if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
        },
        child: AnimatedOpacity(duration: const Duration(milliseconds: 420), opacity: _visible ? 1 : 0, child: img),
      );
    }
    if (_loading) return SizedBox(width: widget.width, height: widget.height, child: const Center(child: CircularProgressIndicator()));

    // If we didn't fetch bytes, fall back to network image with fade-in.
    final passWidth = (widget.width == double.infinity) ? null : widget.width;
    final passHeight = (widget.height == double.infinity) ? null : widget.height;
    final image = FadeInImage(
      placeholder: MemoryImage(kTransparentImage),
      image: NetworkImage(_url!),
      width: passWidth,
      height: passHeight,
      fit: widget.fit,
      imageErrorBuilder: (c, o, e) => Container(color: Colors.grey.shade200, width: passWidth, height: passHeight, child: const Icon(Icons.broken_image)),
    );

    final imageWidget = GestureDetector(
      onTap: () async {
        final uri = Uri.tryParse(_url!);
        if (uri != null) {
          // Open external browser/tab
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      child: ClipRRect(borderRadius: BorderRadius.circular(6), child: image),
    );

    if (_error == null) return imageWidget;

    return Stack(
      alignment: Alignment.center,
      children: [
        imageWidget,
        Positioned(
          right: 6,
          top: 6,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              _prepare();
            },
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.45), borderRadius: BorderRadius.circular(20)),
              child: const Icon(Icons.refresh, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }
}
