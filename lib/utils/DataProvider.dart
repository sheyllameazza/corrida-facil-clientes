import 'package:flutter/material.dart';
import '../main.dart';
import '../model/LanguageDataModel.dart';
import '../model/TextModel.dart';
import 'images.dart';

List<TexIModel> getBookList() {
  List<TexIModel> list = [];
  list.add(TexIModel(title: 'Home', iconData: Icons.home));
  list.add(TexIModel(title: 'Work', iconData: Icons.work));
  list.add(TexIModel(title: 'Recently', iconData: Icons.history));
  return list;
}

List<LanguageDataModel> languageList() {
  return [
    LanguageDataModel(
        id: 1,
        name: 'Português',
        subTitle: 'Brasil',
        languageCode: 'en',
        fullLanguageCode: 'pt-BR',
        flag: ic_brasil),
  ];
}

List<String> getCancelReasonList() {
  List<String> list = [];
  list.add(language.driverGoingWrongDirection);
  list.add(language.pickUpTimeTakingTooLong);
  list.add(language.driverAskedMeToCancel);
  list.add(language.others);
  return list;
}
