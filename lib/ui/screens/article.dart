import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:newsapp/configs/constants.dart';
import 'package:newsapp/configs/extensions.dart';
import 'package:newsapp/core/models/article.dart';
import 'package:newsapp/core/models/bookmark.dart';
import 'package:newsapp/core/providers/auth.dart';
import 'package:newsapp/core/providers/bookmarks.dart';
import 'package:newsapp/core/storage/settings.dart';
import 'package:newsapp/ui/widgets/screens/webview/webview.dart';
import 'package:newsapp/utils/helpers.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ArticleScreen extends StatefulWidget {
  final Article article;

  const ArticleScreen({super.key, required this.article});

  @override
  State<ArticleScreen> createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreen> {
  bool processing = false;

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.read<SettingsProvider>();
    final bookmarksProvider = context.read<BookmarksProvider>();
    final isBookmarked =
        bookmarksProvider.isBookmarked(Bookmark.generateId(widget.article));

    return Scaffold(
      floatingActionButton: processing
          ? FloatingActionButton.small(
              backgroundColor: Colors.transparent,
              elevation: 0,
              onPressed: () {},
              child: const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
            )
          : null,
      appBar: AppBar(
        actions: [
          PopupMenuButton(
            onSelected: (value) {},
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: () => _onBookmark(context),
                child: Text(
                  isBookmarked
                      ? context.localize('@removeBookmark')
                      : context.localize('@addBookmark'),
                ),
              ),
              PopupMenuItem(
                onTap: () => _shareArticle(context),
                child: Text(context.localize('@share')),
              ),
            ],
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 17.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildArticleImage(context, settingsProvider),
            const SizedBox(height: 10),
            Text(
              widget.article.title ?? context.localize('@noTitle'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 5),
            Text(
              widget.article.source?.name ?? context.localize('@noSource'),
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
            ),
            const SizedBox(height: 20),
            _buildArticleContent(context),
            const SizedBox(height: 20),
            _buildArticleMetadata(context),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleImage(BuildContext context, SettingsProvider sp) {
    return SizedBox(
      height: 150,
      width: MediaQuery.of(context).size.width,
      child: CachedNetworkImage(
        cacheKey: widget.article.url,
        imageUrl: widget.article.urlToImage ?? "",
        errorListener: (o) {},
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildPlaceholderImage(sp),
        errorWidget: (context, url, error) => _buildPlaceholderImage(sp),
      ),
    );
  }

  Widget _buildPlaceholderImage(SettingsProvider sp) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage(
            sp.darkMode
                ? "assets/placeholder_dark.png"
                : "assets/placeholder.png",
          ),
        ),
      ),
    );
  }

  Widget _buildArticleContent(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: widget.article.content != null
                ? "${widget.article.content!.substring(0, widget.article.content!.length - 5)}... "
                : "",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          TextSpan(
            text: context.localize('@read'),
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                  decoration: TextDecoration.underline,
                ),
            recognizer: TapGestureRecognizer()
              ..onTap = () => _openArticleInWebView(context),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleMetadata(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.article.author != null
              ? '${context.localize('@by')} ${widget.article.author}'
              : context.localize('@noAuthor'),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Text(
          _formatPublishedDate(context),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  String _formatPublishedDate(BuildContext context) {
    return DateTime.parse(widget.article.publishedAt!)
        .toLocal()
        .toString()
        .substring(0, widget.article.publishedAt!.length - 4)
        .split(" ")
        .join(" ${context.localize('@at')} ");
  }

  void _shareArticle(BuildContext context) {
    if (widget.article.url != null) {
      Share.share(widget.article.url!);
    } else {
      CustomSnackBar.info(context, context.localize('@cannotOpenArticle'));
    }
  }

  void _openArticleInWebView(BuildContext context) {
    if (widget.article.url != null) {
      // I didn't find a way to clear WebViewController cache before opening new article
      WebViewCustomWidget.webViewController = WebViewController();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WebViewCustomWidget(url: widget.article.url!),
        ),
      );
    } else {
      CustomSnackBar.info(context, context.localize('@cannotOpenArticle'));
    }
  }

  Future<void> _onBookmark(BuildContext context) async {
    final bookmarksProvider = context.read<BookmarksProvider>();
    final isBookmarked =
        bookmarksProvider.isBookmarked(Bookmark.generateId(widget.article));
    final authenticated = context.read<AuthProvider>().authenticated == true;

    if (!authenticated) {
      CustomSnackBar.info(context, context.localize('@bookmarkRequiresSignin'));
      return;
    }

    setState(() => processing = true);

    try {
      if (isBookmarked) {
        await bookmarksProvider.removeBookmark(
          Bookmark(
              id: Bookmark.generateId(widget.article), article: widget.article),
        );
        if (context.mounted) {
          CustomSnackBar.info(context, context.localize('@bookmarkRemoved'));
        }
      } else {
        await bookmarksProvider.addBookmark(
          context,
          bookmark: Bookmark(
              id: Bookmark.generateId(widget.article), article: widget.article),
        );
        if (context.mounted) {
          CustomSnackBar.info(context, context.localize('@bookmarkAdded'));
        }
      }
    } catch (e) {
      if (context.mounted) {
        _handleBookmarkError(context, e);
      }
    }

    if (context.mounted) {
      setState(() => processing = false);
    }
  }

  void _handleBookmarkError(BuildContext context, dynamic error) {
    if (error is PostgrestException) {
      CustomSnackBar.error(
          context,
          context.localize(
              bookmarksErrorMessages[error.code] ?? '@failedToRemoveBookmark'));
    } else {
      CustomSnackBar.error(
        context,
        context.localize('@failedToRemoveBookmark'),
      );
    }
  }
}
