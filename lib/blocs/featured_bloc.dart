import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:travel_hour/models/place.dart';

class FeaturedBloc with ChangeNotifier {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<Place> _data = [];
  List<Place> get data => _data;

  List featuredList = [];

  Future<List> _getFeaturedList() async {
    final DocumentReference ref =
        firestore.collection('featured').doc('featured_list');
    DocumentSnapshot snap = await ref.get();
    featuredList = snap['places'] ?? [];
    return featuredList;
  }

  Future getData() async {
    _getFeaturedList().then((featuredList) async {
      QuerySnapshot rawData;
      rawData = await firestore
          .collection('places')
          .where('timestamp', whereIn: featuredList)
          .limit(5)
          .get();

      List<DocumentSnapshot> _snap = [];

      rawData.docs.map((DocumentSnapshot document) {
        Map<String, dynamic> datas = document.data() as Map<String, dynamic>;
        _snap.add(document);
        _data.add(Place.fromFirestore(datas));
      }).toList();

      notifyListeners();
    });
  }

  onRefresh() {
    featuredList.clear();
    _data.clear();
    getData();
    notifyListeners();
  }
}
