import 'dart:async';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class ScraperService {
  static Future<String?> scrapeImageUrl(String productUrl) async {
    final Completer<String?> completer = Completer();
    String? foundUrl;

    final HeadlessInAppWebView headlessWebView = HeadlessInAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(productUrl)),
      onLoadStop: (controller, url) async {
        if (foundUrl != null) return; // Already found, no need to re-run

        const jsScript = """
        (function() {
            // Method 1: JSON-LD
            const scripts = document.querySelectorAll('script[type="application/ld+json"]');
            for (let script of scripts) {
                try {
                    const data = JSON.parse(script.innerText);
                    if (data.image) {
                        let imageUrl = Array.isArray(data.image) ? data.image[0] : data.image;
                        if (typeof imageUrl === 'object' && imageUrl !== null && imageUrl.url) {
                            imageUrl = imageUrl.url;
                        }
                        if (typeof imageUrl === 'string' && imageUrl.length > 0) return imageUrl;
                    }
                } catch (e) {}
            }

            // Method 2: Open Graph
            const ogImage = document.querySelector('meta[property="og:image"]');
            if (ogImage) {
                return ogImage.getAttribute('content');
            }

            return null;
        })();
        """;

        try {
          final result = await controller.evaluateJavascript(source: jsScript);
          if (result != null && result is String && result.isNotEmpty) {
            foundUrl = result;
          }
        } catch (e) {
          // Ignore JS errors
        } finally {
          if (!completer.isCompleted) {
            completer.complete(foundUrl);
          }
        }
      },
    );

    try {
      await headlessWebView.run();

      // Failsafe timeout
      Timer(const Duration(seconds: 15), () {
        if (!completer.isCompleted) {
          completer.complete(null); // Complete with null if it times out
        }
      });

      final result = await completer.future;
      return result;
    } catch (e) {
      return null;
    } finally {
      await headlessWebView.dispose();
    }
  }
}
