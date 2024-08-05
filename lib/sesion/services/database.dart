import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../constants/constants.dart' as constants;

// Collection reference
class DatabaseService {
  final String uid;
  DatabaseService({required this.uid});

  final CollectionReference userFrecuencyCollection =
      FirebaseFirestore.instance.collection('userFrecuency');

  Future inicializeUserFrequencyRecord() async {
    Map<String, int> userFrecuencyValuesNames = {
      for (var name in constants.userFrecuencyValuesNames) name: 0
    };
    return await userFrecuencyCollection.doc(uid).set(userFrecuencyValuesNames);
  }

  Future updateUserData(Map<String, dynamic> frecuencyValues) async {
    for (var dataFrecuency in frecuencyValues.entries) {
      if (!constants.userFrecuencyValuesNames.contains(dataFrecuency.key) ||
          !dataFrecuency.value is int) {
        return null;
      }
    }
    return await userFrecuencyCollection.doc(uid).set(frecuencyValues);
  }
}
