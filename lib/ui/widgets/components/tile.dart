import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:newsapp/configs/constants.dart';
import 'package:newsapp/core/models/article.dart';
import 'package:newsapp/core/models/bookmark.dart';
import 'package:newsapp/core/providers/bookmarks.dart';
import 'package:newsapp/core/storage/settings.dart';
import 'package:newsapp/utils/helpers.dart';
import 'package:newsapp/utils/localization.dart';
import 'package:newsapp/utils/routes.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ArticleTile extends StatelessWidget {
  final Article article;
  final bool canSlide;
  const ArticleTile({super.key, required this.article, this.canSlide = false});

  @override
  Widget build(BuildContext context) {
    BookmarksProvider bpW = context.watch<BookmarksProvider>();
    SettingsProvider sp = context.read<SettingsProvider>();

    return Slidable(
      enabled: canSlide,
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (context) async {
                try {
                  await bpW.removeBookmark(Bookmark(id: Bookmark.generateId(article), article: article));
                  if (context.mounted) {
                    CustomSnackBar.info(
                      context,
                      dictionary["@bookmarkRemoved"][sp.language]!,
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    if (e is PostgrestException) {
                      CustomSnackBar.error(
                        context,
                        dictionary[bookmarksErrorMessages[e.code]]
                                [sp.language] ??
                            dictionary["@failedToRemoveBookmark"][sp.language],
                      );
                    } else {
                      CustomSnackBar.error(
                        context,
                        dictionary["@failedToRemoveBookmark"][sp.language]!,
                      );
                    }
                  }
                }
              },
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete,
            ),
          ],
        ),
        child: InkWell(
          onTap: () =>
              context.pushNamed(OtherRoutes.article, extra: article),
          child: ListTile(
            leading: SizedBox(
              width: 100,
              child: CachedNetworkImage(
                cacheKey: article.url,
                imageUrl: article.urlToImage ?? "",
                fit: BoxFit.cover,
                errorListener: (o) {},
                placeholder: (context, url) => Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: AssetImage("assets/placeholder.png"),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: AssetImage("assets/placeholder.png"),
                    ),
                  ),
                ),
              ),
            ),
            title: Text(
              article.title ?? dictionary["@noTitle"][sp.language]!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            subtitle: Text(
              article.source?.name ??
                  dictionary["@noAuthor"][sp.language]!,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ));
  }
}
