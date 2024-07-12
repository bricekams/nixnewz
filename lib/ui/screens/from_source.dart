import 'package:flutter/material.dart';
import 'package:newsapp/core/models/source.dart';
import 'package:newsapp/core/providers/feeds.dart';
import 'package:newsapp/ui/widgets/screens/errors/feed_error.dart';
import 'package:newsapp/ui/widgets/screens/feeds.dart';
import 'package:newsapp/ui/widgets/screens/shimmer.dart';
import 'package:provider/provider.dart';

class FromSourceScreen extends StatefulWidget {
  final Source source;

  const FromSourceScreen({super.key, required this.source});
  static final ScrollController scrollController = ScrollController();


  @override
  State<FromSourceScreen> createState() => _FromSourceScreenState();
}

class _FromSourceScreenState extends State<FromSourceScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (context.read<FromSourceFeedsProvider>().error == null &&
            context.read<FromSourceFeedsProvider>().articles.isEmpty) {
          context.read<FromSourceFeedsProvider>().fetchArticles(
                context,
                params: {
                  "sources": widget.source.id,
                },
                clean: true,
              );
        }
      },
    );
    FromSourceScreen.scrollController.addListener(() {
      if (mounted) {
        if (FromSourceScreen.scrollController.offset ==
                FromSourceScreen.scrollController.position.maxScrollExtent &&
            context.read<FromSourceFeedsProvider>().loadingMore == false) {
          context.read<FromSourceFeedsProvider>().fetchMoreArticles(
            context,
            params: {
              "sources": widget.source.id,
            },
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool showFloatingActionButton =
        context.watch<FromSourceFeedsProvider>().loading == false &&
            context.watch<FromSourceFeedsProvider>().error == null &&
            context.watch<FromSourceFeedsProvider>().articles.isNotEmpty;

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: showFloatingActionButton
          ? SizedBox(
              height: 35,
              width: 35,
              child: FloatingActionButton(
                onPressed: () {
                  if (FromSourceScreen.scrollController.hasClients) {
                    FromSourceScreen.scrollController.position
                        .restoreOffset(0.0);
                  }
                },
                child: const Icon(Icons.arrow_drop_up),
              ),
            )
          : null,
      appBar: AppBar(
        title: Text(widget.source.name ?? widget.source.id!),
      ),
      body: Consumer<FromSourceFeedsProvider>(builder: (_, feeds, __) {
        final bool loading = feeds.loading;
        switch (loading) {
          case true:
            return const LoadingShimmer();
          case false:
            if (feeds.error != null) {
              return FeedErrorWidget(
                feedsProviderRead: context.read<FromSourceFeedsProvider>(),
                onRetry: () {
                  feeds.resetPage();
                  feeds.fetchArticles(
                    context,
                    params: {
                      "sources": widget.source.id,
                    },
                    clean: true,
                  );
                },
              );
            } else {
              return FeedsWidgets(
                feedsProviderRead: context.read<FromSourceFeedsProvider>(),
                feedsProviderWatch: context.watch<FromSourceFeedsProvider>(),
                scrollController: FromSourceScreen.scrollController,
                  onRefresh: () async {
                    context.read<FromSourceFeedsProvider>().fetchArticles(
                      context,
                      params: {
                        "sources": widget.source.id,
                      },
                      clean: true,
                    );
                  }

              );
            }
        }
      }),
    );
  }
}
