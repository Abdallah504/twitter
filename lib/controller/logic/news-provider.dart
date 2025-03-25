import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:twitter/model/bbc-model.dart';
import 'package:http/http.dart' as http;
import 'package:twitter/model/news-model.dart';

class NewsProvider extends ChangeNotifier{
   BbcModel? bbcModel;
   NewsModel? newsModel;

  final String url = 'https://newsapi.org/v2/top-headlines?sources=bbc-news&apiKey=a081436a7034494a92c8920802ecd853';
final String uurl = 'https://newsapi.org/v2/top-headlines?category=sports&apiKey=a081436a7034494a92c8920802ecd853';

  Future<void>gettingNews()async{
    try{
      final response = await http.get(Uri.parse(url));
      final responsed = await http.get(Uri.parse(uurl));
      if(response !=null && responsed !=null){
        dynamic data = json.decode(response.body);
        dynamic data2 = json.decode(responsed.body);
        bbcModel = BbcModel.fromJson(data);
        newsModel = NewsModel.fromJson(data2);
        notifyListeners();
      }
      notifyListeners();
    }catch(e){
      print(e);
      notifyListeners();
    }
    notifyListeners();
  }

}