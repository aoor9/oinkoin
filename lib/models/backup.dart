import 'package:piggybank/models/category-type.dart';
import 'package:piggybank/models/record.dart';

import 'category.dart';
import 'model.dart';
import 'dart:convert';

class Backup extends Model {
  List<Record> records;
  List<Category> categories;
  var created_at;

  Backup(this.categories, this.records) {
    created_at = new DateTime.now().millisecondsSinceEpoch;
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'records': List.generate(records.length, (index) => records[index].toMap()),
      'categories': List.generate(categories.length, (index) => categories[index].toMap()),
      'created_at': created_at,
    };
    return map;
  }

  static Backup fromMap(Map<String, dynamic> map) {
    // Step 1: load categories
    var categories = List.generate(map["categories"].length, (i) {
      return Category.fromMap(map["categories"][i]);
    });

    // Step 2: load records
    var records = List.generate(map["records"].length, (i) {
      Map<String, dynamic> currentRowMap = Map<String, dynamic>.from(map["records"][i]);
      String categoryName = currentRowMap["category_name"];
      CategoryType categoryType = CategoryType.values[currentRowMap["category_type"]];
      Category matchingCategory = categories.firstWhere((element) => element.categoryType == categoryType && element.name == categoryName, orElse: null);
      if (matchingCategory == null) {
        throw Exception("Can't find category during the backup import. Backup file is corrupted.");
      }
      currentRowMap["category"] = matchingCategory;
      return Record.fromMap(currentRowMap);
    });
    return Backup(categories, records);
  }

}