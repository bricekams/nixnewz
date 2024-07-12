import 'package:flutter/material.dart';
import 'package:newsapp/configs/constants.dart';
import 'package:newsapp/core/providers/search.dart';
import 'package:newsapp/core/storage/settings.dart';
import 'package:newsapp/utils/localization.dart';
import 'package:provider/provider.dart';

class SearchCriteriaScreen extends StatelessWidget {
  const SearchCriteriaScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Criteria"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 17.0),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    dictionary["@searchBy"]?[context.read<SettingsProvider>().language],
                  ),
                  const SizedBox(width: 10),
                  DropdownButton<String>(
                    value: context.watch<SearchProvider>().sortBy,
                    items: sortOptions.map((String value) {
                      return DropdownMenuItem(
                        value: value.replaceFirst("@", ""),
                        child: Text(
                          dictionary[value]?[context.read<SettingsProvider>().language] ?? value,
                        ),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      context.read<SearchProvider>().sortBy = value!;
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    dictionary["@language"]?[context.read<SettingsProvider>().language],
                  ),
                  const SizedBox(width: 10),
                  DropdownButton<String>(
                    value: context.watch<SearchProvider>().language,
                    items: languages.map((Map<String, String> value) {
                      return DropdownMenuItem(
                        value: value["code"],
                        child: Text(value["name"]!),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      context.read<SearchProvider>().language = value!;
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
