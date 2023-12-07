import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import '../utils/Extensions/StringExtensions.dart';

import '../main.dart';
import '../utils/Constants.dart';
import '../utils/Extensions/app_common.dart';
import '../utils/images.dart';
import 'package:google_maps_webservice/places.dart';


class NewGoogleMapScreen extends StatefulWidget {
  final bool? isDestination;

  const NewGoogleMapScreen({super.key, this.isDestination});

  @override
  NewGoogleMapScreenState createState() => NewGoogleMapScreenState();
}

class NewGoogleMapScreenState extends State<NewGoogleMapScreen> {
  static final kInitialPosition = polylineSource;

  PickResult? selectedPlace;
  bool showPlacePickerInContainer = false;
  bool showGoogleMapInContainer = false;
  bool isDemo = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Theme(
            data: ThemeData(iconTheme: IconThemeData(color: Colors.black)),
            child: PlacePicker(
              apiKey: googleMapAPIKey,
              hintText: language.findPlace,
              searchingText: language.pleaseWait,
              selectText: language.selectPlace,
              outsideOfPickAreaText: language.placeNotInArea,
              initialPosition: kInitialPosition,
              useCurrentLocation: true,
              autocompleteComponents: [Component(Component.country, '${sharedPref.getString(COUNTRY).validate(value:defaultCountry)}')],
              selectInitialPosition: true,
              usePinPointingSearch: true,
              usePlaceDetailSearch: true,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: true,
              automaticallyImplyAppBarLeading: false,
              autocompleteLanguage: '',
              onGeocodingSearchFailed: ((value) async {
                print("value->" + value);
                isDemo = true;
                setState(() {});
                await Future.delayed(Duration(seconds: 2)).whenComplete(() {
                  isDemo = false;
                  setState(() {});
                });
              }),
              onCameraMoveStarted: ((p0) {
                isDemo = false;
                setState(() {});
              }),
              pinBuilder: ((context, state) {
                return Image.asset(
                  widget.isDestination == true ? DestinationIcon : SourceIcon,
                  height: 40,
                  width: 40,
                );
              }),
              onMapCreated: (GoogleMapController controller) {
                //
              },
              onPlacePicked: (PickResult result) {
                setState(() {
                  selectedPlace = result;
                  log(selectedPlace!.formattedAddress);
                  Navigator.pop(context, selectedPlace);
                });
              },
              onMapTypeChanged: (MapType mapType) {
                //
              },
            ),
          ),
          if (isDemo == true)
            Container(
              margin: EdgeInsets.only(top: 120),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: radius(),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 2, spreadRadius: 1),
                ],
              ),
              child: Text(
                'NOTE: Drag-drop address place search is disable \nfor demo user',
                style: secondaryTextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}
