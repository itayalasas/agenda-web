import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreSeeder {
  final FirebaseFirestore _db;

  FirestoreSeeder(this._db);

  Future<void> seedAll() async {
    await _seedDepartments();
    await _seedSlots();
    print('🔥 Seed data completado con éxito! 🔥');
  }

  /// Estructura de datos de prueba
  final Map<String, Map<String, dynamic>> _departments = {
    'MONTEVIDEO': {
      'services': {
        'Solicitud de CVA': {
          'offices': [
            {
              'id': '1',
              'name': 'Fernández Crespo 1534',
              'hours': '9:30 a 16:15 hs',
              'coords': {'lat': -34.89, 'lng': -56.191}
            },
          ]
        },
        'Otros Certificados': {
          'offices': [
            {
              'id': '2',
              'name': '18 de Julio 125',
              'hours': '10:00 a 17:00 hs',
              'coords': {'lat': -34.907, 'lng': -56.198}
            },
          ]
        },
      }
    },
    'CANELONES': {
      'services': {
        'Turnos Registro': {
          'offices': [
            {
              'id': '3',
              'name': 'Centro Canelones',
              'hours': '9:00 a 16:00 hs',
              'coords': {'lat': -34.836, 'lng': -56.285}
            },
          ]
        }
      }
    },
    'MALDONADO': {
      'services': {
        'Certificados Especiales': {
          'offices': [
            {
              'id': '4',
              'name': 'Av. Gorlero 999',
              'hours': '10:00 a 18:00 hs',
              'coords': {'lat': -34.904, 'lng': -54.957}
            },
          ]
        }
      }
    },
  };


  Future<void> _seedDepartments() async {
    for (var deptEntry in _departments.entries) {
      final deptId = deptEntry.key;
      final services = deptEntry.value['services'] as Map<String, dynamic>;
      final deptRef = _db.collection('departments').doc(deptId);
      await deptRef.set({});

      for (var svcEntry in services.entries) {
        final svcId = svcEntry.key;
        final offices = (svcEntry.value as Map)['offices'] as List<dynamic>;
        final svcRef = deptRef.collection('services').doc(svcId);
        await svcRef.set({});

        for (var off in offices) {
          final offId = off['id'] as String;
          final officeData = {
            'name':   off['name'],
            'hours':  off['hours'],
            'coords': off['coords'],
          };
          await svcRef
              .collection('offices')
              .doc(offId)
              .set(officeData);
        }
      }
    }
  }

  /// Turnos de prueba para cada oficina y servicio
  final Map<String, Map<String, Map<String, List<String>>>> _slots = {
    // officeId : { serviceId: { dateString: [times] } }
    '1': {
      'Solicitud de CVA': {
        '2025-04-25': ['08:30', '09:15', '11:00'],
        '2025-04-28': ['11:30'],
        '2025-04-29': ['11:30', '12:30'],
        '2025-04-30': ['09:00', '10:00'],
      }
    },
    '2': {
      'Otros Certificados': {
        '2025-04-25': ['10:00', '14:00'],
        '2025-04-29': ['12:00', '15:00'],
      }
    },
    '3': {
      'Turnos Registro': {
        '2025-04-28': ['09:00', '10:30'],
        '2025-04-30': ['13:00', '16:00'],
      }
    },
    '4': {
      'Certificados Especiales': {
        '2025-04-27': ['11:00', '14:30'],
        '2025-04-29': ['10:00', '12:00', '15:00'],
      }
    },
  };

  Future<void> _seedSlots() async {
    for (var slotEntry in _slots.entries) {
      final officeId = slotEntry.key;
      final slotRef = _db.collection('slots').doc(officeId);
      await slotRef.set({}, SetOptions(merge: true));

      for (var svcEntry in slotEntry.value.entries) {
        final svcId    = svcEntry.key;
        final datesMap = svcEntry.value; // Map<String, List<String>>
        await slotRef.update({ svcId: datesMap });
      }
    }
  }
}
