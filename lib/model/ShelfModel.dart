import 'package:PureBook/entity/Book.dart';
import 'package:flutter/material.dart';

class ShelfModel extends ShelfEntity with ChangeNotifier {

}

class ShelfEntity {
  List<Book> _books;
}
