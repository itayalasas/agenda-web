import 'package:latlong2/latlong.dart';

class Office {
  final int id;
  final String name;
  final String hours;
  final LatLng coords;
  Office(this.id, this.name, this.hours, this.coords);
}