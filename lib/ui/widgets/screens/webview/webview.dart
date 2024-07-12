import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:newsapp/configs/extensions.dart';
import 'package:newsapp/core/storage/settings.dart';
import 'package:newsapp/ui/widgets/screens/webview/js_warning_dialog.dart';
import 'package:newsapp/utils/helpers.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewCustomWidget extends StatefulWidget {
  final String url;
  static WebViewController webViewController = WebViewController();

  const WebViewCustomWidget({super.key, required this.url});

  @override
  State<WebViewCustomWidget> createState() => _WebViewCustomWidgetState();
}

class _WebViewCustomWidgetState extends State<WebViewCustomWidget> {
  var loadingPercentage = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        WebViewCustomWidget.webViewController
          ..setJavaScriptMode(context.read<SettingsProvider>().jsActive
              ? JavaScriptMode.unrestricted
              : JavaScriptMode.disabled)
          ..setBackgroundColor(Theme.of(context).scaffoldBackgroundColor)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (url) {
                // propose to enable js if it is disabled in dialog with do not show again checkbox
                if (context.read<SettingsProvider>().jsActive == false &&
                    context.read<SettingsProvider>().jsWarningDisplay == true) {
                  if (mounted) {
                    showDialog(
                      context: context,
                      builder: (context) => JsWarningDialog(
                        onConfirm: () {
                          WebViewCustomWidget.webViewController.reload();
                        },
                      ),
                    );
                  }
                }
               if (mounted) {
                  setState(() {
                    loadingPercentage = 0;
                  });
                }
              },
              onProgress: (int progress) {
                if (mounted) {
                  setState(() {
                    loadingPercentage = progress;
                  });
                }
              },
              onPageFinished: (url) {
                if (mounted) {
                  setState(() {
                    loadingPercentage = 100;
                  });
                }
              },
            ),
          )
          ..loadRequest(Uri.parse(widget.url));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    SettingsProvider spR = context.read<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton(
            onPressed: () {
              WebViewCustomWidget.webViewController.canGoBack().then((value) {
                if (value) {
                  WebViewCustomWidget.webViewController.goBack();
                } else {
                  CustomSnackBar.info(
                      context, context.localize('@noPreviousPage'));
                }
              });
            },
            icon: const Icon(Icons.arrow_back_ios, size: 18),
          ),
          IconButton(
            onPressed: () async {
              WebViewCustomWidget.webViewController.canGoForward().then((value) {
                if (value) {
                  WebViewCustomWidget.webViewController.goForward();
                } else {
                  CustomSnackBar.info(
                      context, context.localize('@noNextPage'));
                }
              });
            },
            icon: const Icon(Icons.arrow_forward_ios, size: 18),
          ),
          IconButton(
            onPressed: () {
              WebViewCustomWidget.webViewController.reload();
            },
            icon: const Icon(Icons.refresh),
          ),
          PopupMenuButton(
            onSelected: (value) {},
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: () async {
                  if (spR.jsActive) {
                    showAdaptiveDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text(
                            context.localize("@disableJs"),
                            style: const TextStyle(
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          content: Text(
                            context.localize("@disableJsConfirm"),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                context.pop();
                              },
                              child: Text(
                                context.localize("@no"),
                              ),
                            ),
                            FilledButton(
                              onPressed: () async {
                                context.pop();
                                await spR.toggleJsMode();
                                WebViewCustomWidget.webViewController.setJavaScriptMode(JavaScriptMode.disabled);
                                WebViewCustomWidget.webViewController.reload();
                                spR.setJsWarningDisplay(false);
                              },
                              child: Text(
                                context.localize("@yes"),
                              ),
                            )
                          ],
                        );
                      },
                    );
                  } else {
                    await spR.toggleJsMode();
                    WebViewCustomWidget.webViewController.setJavaScriptMode(JavaScriptMode.unrestricted);
                    WebViewCustomWidget.webViewController.reload();
                  }
                },
                child: spR.jsActive
                    ? Text(context.localize("@disableJs"))
                    : Text(context.localize("@enableJs")),
              ),
              PopupMenuItem(
                onTap: () {
                  Share.shareUri(
                    Uri.parse(widget.url),
                  );
                },
                child: Text(context.localize("@share")),
              ),
            ],
          )
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: WebViewCustomWidget.webViewController),
          if (loadingPercentage < 100)
            LinearProgressIndicator(
              value: loadingPercentage / 100.0,
            ),
        ],
      ),
    );
  }
}
