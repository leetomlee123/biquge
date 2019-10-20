import 'package:PureBook/entity/Book.dart';
import 'package:flutter/material.dart';

class ShelfModel with ChangeNotifier{
  List<Book> _books;
}