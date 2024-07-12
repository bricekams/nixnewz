import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:newsapp/configs/constants.dart';
import 'package:newsapp/configs/extensions.dart';
import 'package:newsapp/core/providers/auth.dart';
import 'package:newsapp/core/providers/feeds.dart';
import 'package:newsapp/core/storage/settings.dart';
import 'package:newsapp/ui/widgets/components/category_chip.dart';
import 'package:newsapp/ui/widgets/screens/errors/feed_error.dart';
import 'package:newsapp/ui/widgets/screens/feeds.dart';
import 'package:newsapp/ui/widgets/screens/search_delegate.dart';
import 'package:newsapp/ui/widgets/screens/shimmer.dart';
import 'package:newsapp/utils/localization.dart';
import 'package:newsapp/utils/routes.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static final ScrollController scrollController = ScrollController();

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        // todo: the next line should be called in a loading screen before the home screen
        context.read<AuthProvider>().init(context);
        final homeFeedsProvider = context.read<HomeFeedsProvider>();
        if (homeFeedsProvider.error == null &&
            homeFeedsProvider.articles.isEmpty) {
          _fetchArticles(context, clean: true);
        }
      }
    });

    HomeScreen.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    HomeScreen.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    if (HomeScreen.scrollController.offset ==
            HomeScreen.scrollController.position.maxScrollExtent &&
        !context.read<HomeFeedsProvider>().loadingMore) {
      _fetchMoreArticles(context);
    }
  }

  Future<void> _fetchArticles(BuildContext context,
      {bool clean = false}) async {
    final homeFeedsProvider = context.read<HomeFeedsProvider>();
    final selectedCategory = homeFeedsProvider.selectedCategory;
    final category = categories["en"]![selectedCategory].toLowerCase();

    await homeFeedsProvider.fetchArticles(context,
        params: {'category': category}, clean: clean);
  }

  Future<void> _fetchMoreArticles(BuildContext context) async {
    final homeFeedsProvider = context.read<HomeFeedsProvider>();
    final selectedCategory = homeFeedsProvider.selectedCategory;
    final language = context.read<SettingsProvider>().language;
    final category = categories[language]![selectedCategory].toLowerCase();

    homeFeedsProvider
        .fetchMoreArticles(context, params: {'category': category});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: _buildFloatingActionButton(context),
      drawer: _buildDrawer(context),
      appBar: _buildAppBar(context),
      body: _buildBody(context),
    );
  }

  Widget? _buildFloatingActionButton(BuildContext context) {
    final homeFeedsProvider = context.watch<HomeFeedsProvider>();
    final showFloatingActionButton = !homeFeedsProvider.loading &&
        homeFeedsProvider.error == null &&
        homeFeedsProvider.articles.isNotEmpty;

    if (!showFloatingActionButton) return null;

    return SizedBox(
      height: 35,
      width: 35,
      child: FloatingActionButton(
        onPressed: () {
          if (HomeScreen.scrollController.hasClients) {
            HomeScreen.scrollController.animateTo(
              0.0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
            );
          }
        },
        child: const Icon(Icons.arrow_drop_up),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text(appName),
      actions: [
        IconButton(
          onPressed: () {
            showSearch(context: context, delegate: CustomSearchDelegate());
          },
          icon: const Icon(Icons.search),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: _buildCategoryChips(context),
      ),
    );
  }

  Widget _buildCategoryChips(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final categoriesList = categories[settingsProvider.language]!;

    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categoriesList.length,
        separatorBuilder: (_, __) => const SizedBox(width: 5),
        itemBuilder: (_, i) => Padding(
          padding: EdgeInsets.only(
            left: i == 0 ? 13 : 0,
            right: i == categoriesList.length - 1 ? 13 : 0,
          ),
          child: CategoryChip(
            index: i,
            feedsProviderRead: context.read<HomeFeedsProvider>(),
            feedsProviderWatch: context.watch<HomeFeedsProvider>(),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Consumer<HomeFeedsProvider>(
      builder: (_, feeds, __) {
        if (feeds.loading) {
          return const LoadingShimmer();
        } else if (feeds.error != null) {
          return FeedErrorWidget(
            feedsProviderRead: feeds,
            onRetry: () => _fetchArticles(context, clean: true),
          );
        } else {
          return FeedsWidgets(
            feedsProviderRead: context.read<HomeFeedsProvider>(),
            feedsProviderWatch: context.watch<HomeFeedsProvider>(),
            scrollController: HomeScreen.scrollController,
            onRefresh: () async {
              await _fetchArticles(context, clean: true);
            },
          );
        }
      },
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(),
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage(
                  "assets/placeholder.png",
                ),
              ),
            ),
            child: null,
          ),
          ListTile(
            leading: const Icon(Icons.school_outlined),
            title: Text(context.localize("@scholarships")),
            // trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.pushNamed(OtherRoutes.scholarships);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.work_history_outlined),
            title: Text(context.localize("@jobs")),
            // trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.pushNamed(OtherRoutes.jobs);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.feed),
            title: Text(context.localize("@entrances")),
            // trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.pushNamed(OtherRoutes.entrances);
            },
          ),
          const Divider(),
        ],
      ),
    );
  }
}
