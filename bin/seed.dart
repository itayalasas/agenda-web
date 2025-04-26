// bin/seed.dart
// @dart=2.19

import 'package:agenda_web/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

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

Future<void> main() async {
  // Inicializa Firebase en Web, iOS, Android...
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final db = FirebaseFirestore.instance;

  // 1) Departments → services → offices
  for (var deptEntry in _departments.entries) {
    final deptId = deptEntry.key;
    final services = deptEntry.value['services'] as Map<String, dynamic>;
    final deptRef = db.collection('departments').doc(deptId);
    await deptRef.set({}); // crea el doc de departamento

    for (var svcEntry in services.entries) {
      final svcId = svcEntry.key;
      final offices = (svcEntry.value as Map)['offices'] as List<dynamic>;
      final svcRef = deptRef.collection('services').doc(svcId);
      await svcRef.set({}); // crea el doc de servicio

      for (var off in offices) {
        final offId = off['id'] as String;
        final officeData = {
          'name': off['name'],
          'hours': off['hours'],
          'coords': off['coords'],
        };
        final offRef = svcRef.collection('offices').doc(offId);
        await offRef.set(officeData); // crea doc de oficina
      }
    }
  }

  // 2) Slots: crea colección `slots/{officeId}` con mapa service→(fecha→[horas])
  for (var slotEntry in _slots.entries) {
    final officeId = slotEntry.key;
    final slotRef = db.collection('slots').doc(officeId);
    await slotRef.set({}, SetOptions(merge: true));

    for (var svcEntry in slotEntry.value.entries) {
      final svcId = svcEntry.key;
      final datesMap = svcEntry.value; // Map<String date, List<String> times>
      await slotRef.update({svcId: datesMap});
    }
  }

  print('🔥 Seed data completado con éxito! 🔥');
  // Opcional: salirse de la app si la ejecutaste en consola
  // exit(0);
}
