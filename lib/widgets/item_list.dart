// lib/widgets/item_list.dart
import 'package:flutter/material.dart';

class ItemList extends StatelessWidget {
  final List<Map<String, dynamic>> items;

  ItemList({required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          leading: CircleAvatar(backgroundImage: NetworkImage(item['image'])),
          title: Text(item['name']),
          subtitle: Text(item['category']),
        );
      },
    );
  }
}
