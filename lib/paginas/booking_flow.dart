//import 'dart:io';
import 'package:flutter/foundation.dart'    show kIsWeb, defaultTargetPlatform, TargetPlatform;

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';

import 'login_page.dart';


class BookingFlow extends StatefulWidget {
  const BookingFlow({Key? key}) : super(key: key);
  @override
  State<BookingFlow> createState() => _BookingFlowState();
}

class _BookingFlowState extends State<BookingFlow> {
  final _firestore = FirebaseFirestore.instance;

  int _currentStep = 0;

  // Paso 1: cacheo y estado
  List<String> _departments = [];
  bool _loadingDepts = true;

  List<String> _services = [];
  bool _loadingServices = false;

  List<Map<String, dynamic>> _offices = [];
  bool _loadingOffices = false;

  String? selectedDept;
  String? selectedService;
  String? selectedOfficeId;

  // Paso 2:
  DateTime _focusedDay = DateTime.now();
  DateTime? selectedDay;
  String? selectedTime;

  // Paso 3:
  final _formKey = GlobalKey<FormState>();
  String? selectedDocType, docNumber, name, cell, email;
  bool _isHuman = false;

  @override
  void initState() {
    super.initState();
    _loadDepartments();
  }

  Future<void> _loadDepartments() async {
    final snap = await _firestore.collection('departments').get();
    setState(() {
      _departments = snap.docs.map((d) => d.id).toList();
      _loadingDepts = false;
    });
  }

  Future<void> _loadServices(String dept) async {
    setState(() {
      _loadingServices = true;
      _services = [];
    });
    final snap = await _firestore
        .collection('departments')
        .doc(dept)
        .collection('services')
        .get();
    setState(() {
      _services = snap.docs.map((d) => d.id).toList();
      _loadingServices = false;
    });
  }

  Future<void> _loadOffices(String dept, String svc) async {
    setState(() {
      _loadingOffices = true;
      _offices = [];
    });
    final snap = await _firestore
        .collection('departments')
        .doc(dept)
        .collection('services')
        .doc(svc)
        .collection('offices')
        .get();
    setState(() {
      _offices = snap.docs
          .map((d) {
        final m = d.data();
        return {
          'id': d.id,
          'name': m['name'],
          'hours': m['hours'],
        };
      })
          .toList();
      _loadingOffices = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // ¿Mostramos login en escritorio?
    // Chequeo: si NO es web y el targetPlatform está entre escritorio…
    final bool mostrarLogin = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.linux   ||
            defaultTargetPlatform == TargetPlatform.macOS);

    return Scaffold(
      appBar: AppBar(title: const Text('Reserva de Turno'),
      actions: [
        if (mostrarLogin)
          IconButton(
            icon: const Icon(Icons.login),
            tooltip: 'Login Admin',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
          ),
      ],
    ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        // <-- Aquí envolvemos todo en Center:
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1) Header con pasos
                _buildStepsHeader(),
                const SizedBox(height: 24),
                // 2) Contenido dinámico
                _buildStepContent(),
                // 3) Controles
                _buildStepControls(),
              ],
            ),
          ),
        ),
      ),
    );
  }




  /// 1) Construye la barra de pasos con círculos y labels
  Widget _buildStepsHeader() {
    final steps = ['Ubicación', 'Día y Hora', 'Datos'];
    return Row(
      children: List.generate(steps.length, (i) {
        final active = i == _currentStep;
        final done = i < _currentStep;
        return Expanded(
          child: Column(
            children: [
              // Círculo con número
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: active
                      ? Colors.blue
                      : done
                      ? Colors.blue.shade100
                      : Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${i + 1}',
                  style: TextStyle(
                    color: active || done ? Colors.white : Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Texto del paso
              Text(
                steps[i],
                style: TextStyle(
                  color: active
                      ? Colors.blue
                      : done
                      ? Colors.black87
                      : Colors.black45,
                  fontWeight: active ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  /// 2) Devuelve el contenido según _currentStep
  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _locationStep();
      case 1:
        return _dateTimeStep();
      case 2:
        return _applicantStep();
      default:
        return const SizedBox.shrink();
    }
  }

  /// 3) Botones de navegación entre pasos
  Widget _buildStepControls() {
    final isLast = _currentStep == 2;
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentStep > 0)
            OutlinedButton(
              onPressed: _onBack,
              child: const Text('Atrás'),
            )
          else
            const SizedBox(width: 100),
          ElevatedButton(
            onPressed: _onNext,
            child: Text(isLast ? 'Finalizar' : 'Siguiente'),
          ),
        ],
      ),
    );
  }


  Widget _locationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Departamentos
        if (_loadingDepts)
          const Center(child: CircularProgressIndicator())
        else
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Departamento'),
            items: _departments
                .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                .toList(),
            value: selectedDept,
            onChanged: (v) {
              if (v == selectedDept) return;
              setState(() {
                selectedDept = v;
                selectedService = null;
                selectedOfficeId = null;
              });
              if (v != null) _loadServices(v);
            },
          ),

        const SizedBox(height: 16),

        // Servicios
        if (selectedDept != null)
          if (_loadingServices)
            const Center(child: CircularProgressIndicator())
          else
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Trámite'),
              items: _services
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              value: selectedService,
              onChanged: (v) {
                if (v == selectedService) return;
                setState(() {
                  selectedService = v;
                  selectedOfficeId = null;
                });
                if (selectedDept != null && v != null) {
                  _loadOffices(selectedDept!, v);
                }
              },
            ),

        const SizedBox(height: 16),

        // Oficinas
        if (selectedService != null)
          if (_loadingOffices)
            const Center(child: CircularProgressIndicator())
          else
            Column(
              children: _offices.map((m) {
                return RadioListTile<String>(
                  title: Text('${m['name']} • ${m['hours']}'),
                  value: m['id'] as String,
                  groupValue: selectedOfficeId,
                  onChanged: (v) => setState(() => selectedOfficeId = v),
                );
              }).toList(),
            ),
      ],
    );
  }

  Widget _dateTimeStep() {
    if (selectedOfficeId == null) {
      return const Text('Seleccione primero ubicación');
    }

    return FutureBuilder<DocumentSnapshot>(
      future: _firestore.collection('slots').doc(selectedOfficeId).get(),
      builder: (ctx, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        // 1) Traigo el documento y extraigo el sub-map del servicio
        final raw = snap.data!.data() as Map<String, dynamic>? ?? {};
        final svcRaw = raw[selectedService];
        if (svcRaw == null || svcRaw is! Map<String, dynamic>) {
          return const Text('No hay fechas disponibles para este trámite');
        }

        // 2) Convierto a Map<DateTime, List<String>>
        final slots = <DateTime, List<String>>{};
        svcRaw.forEach((dayStr, timesRaw) {
          final d = DateTime.parse(dayStr);
          final key = DateTime(d.year, d.month, d.day);

          List<String> timesList;
          if (timesRaw is Iterable) {
            // caso normal: un List<String>
            timesList = timesRaw.map((e) => e.toString()).toList();
          } else if (timesRaw is Map) {
            // defensivo: si por algún motivo se guardó como Map
            // aquí tomamos las claves (o podrías usar values)
            timesList = (timesRaw as Map<String, dynamic>)
                .keys
                .map((e) => e.toString())
                .toList();
          } else {
            timesList = [];
          }

          slots[key] = timesList;
        });

        if (slots.isEmpty) {
          return const Text('No hay fechas disponibles para este trámite');
        }

        // 3) Determino el rango para el TableCalendar
        final days = slots.keys.toList()..sort();
        final firstDay = days.first;
        final lastDay = days.last;

        // 4) Aseguro que _focusedDay esté dentro de [firstDay, lastDay]
        final effectiveFocused = (_focusedDay.isBefore(firstDay) ||
            _focusedDay.isAfter(lastDay))
            ? firstDay
            : _focusedDay;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TableCalendar(
              firstDay: firstDay,
              lastDay: lastDay,
              focusedDay: effectiveFocused,
              headerStyle: const HeaderStyle(formatButtonVisible: false),
              availableGestures: AvailableGestures.horizontalSwipe,
              selectedDayPredicate: (day) =>
              selectedDay != null && isSameDay(day, selectedDay),
              onDaySelected: (day, focused) {
                setState(() {
                  selectedDay = DateTime(day.year, day.month, day.day);
                  _focusedDay = focused;
                  selectedTime = null;
                });
              },
              onPageChanged: (focused) => _focusedDay = focused,
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (ctx, day, focused) {
                  final key = DateTime(day.year, day.month, day.day);
                  final avail = slots.containsKey(key);
                  return Container(
                    margin: const EdgeInsets.all(4),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: avail ? Colors.green.shade200 : null,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${day.day}',
                      style: TextStyle(
                        color: avail ? Colors.black : Colors.grey,
                      ),
                    ),
                  );
                },
              ),
            ),

            // 5) Si ya seleccionó un día con slots, muestro las horas
            if (selectedDay != null && slots.containsKey(selectedDay!)) ...[
              const SizedBox(height: 16),
              ...slots[selectedDay!]!
                  .map((t) => RadioListTile<String>(
                title: Text('$t hs'),
                value: t,
                groupValue: selectedTime,
                onChanged: (v) => setState(() => selectedTime = v),
              ))
                  .toList(),
            ],
          ],
        );
      },
    );
  }


  Widget _applicantStep() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Tipo de Documento'),
            items: ['Cédula', 'Pasaporte', 'NIE']
                .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                .toList(),
            onChanged: (v) => setState(() => selectedDocType = v),
            validator: (v) => v == null ? 'Obligatorio' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Número'),
            validator: (v) => v!.isEmpty ? 'Obligatorio' : null,
            onSaved: (v) => docNumber = v,
          ),
          const SizedBox(height: 12),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Nombre / Empresa'),
            validator: (v) => v!.isEmpty ? 'Obligatorio' : null,
            onSaved: (v) => name = v,
          ),
          const SizedBox(height: 12),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Celular'),
            validator: (v) => v!.isEmpty ? 'Obligatorio' : null,
            onSaved: (v) => cell = v,
          ),
          const SizedBox(height: 12),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Correo electrónico'),
            validator: (v) => v!.isEmpty ? 'Obligatorio' : null,
            onSaved: (v) => email = v,
          ),
          const SizedBox(height: 24),
          FormField<bool>(
            initialValue: _isHuman,
            validator: (v) => v == true ? null : 'Confirma que no eres un robot',
            builder: (state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CheckboxListTile(
                    title: const Text('No soy un robot'),
                    value: state.value,
                    onChanged: (v) {
                      state.didChange(v);
                      setState(() => _isHuman = v ?? false);
                    },
                  ),
                  if (state.hasError)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(state.errorText!,
                          style: const TextStyle(color: Colors.red)),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  void _onNext() {
    switch (_currentStep) {
      case 0:
        if (selectedDept == null ||
            selectedService == null ||
            selectedOfficeId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Completa todos los campos')));
          return;
        }
        break;
      case 1:
        if (selectedDay == null || selectedTime == null) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Selecciona fecha y hora')));
          return;
        }
        _reserveSlot();
        break;
      case 2:
        if (!_formKey.currentState!.validate()) return;
        _formKey.currentState!.save();
        _submitBooking();
        return;
    }
    setState(() => _currentStep = (_currentStep + 1).clamp(0, 2));
  }

  void _onBack() {
    setState(() => _currentStep = (_currentStep - 1).clamp(0, 2));
  }

  Future<void> _reserveSlot() async {
    final docRef = _firestore.collection('slots').doc(selectedOfficeId);

    // 1) Saca la fecha en formato YYYY-MM-DD para que coincida con la key
    final dateKey = '${selectedDay!.year.toString().padLeft(4,'0')}-'
        '${selectedDay!.month.toString().padLeft(2,'0')}-'
        '${selectedDay!.day.toString().padLeft(2,'0')}';

    // 2) En lugar de leer, mutar y volver a escribir el mapa completo,
    // simplemente le decimos a Firestore que quite ese valor del array.
    await docRef.update({
      // esto apunta al array en slots/{officeId}/{service}/{dateKey}
      '$selectedService.$dateKey': FieldValue.arrayRemove([selectedTime])
    });

    // (Opcional) Si quieres que al quedarte sin ningún horario en esa fecha
    // elimine también el campo dateKey, podrías hacer:
    final snap = await docRef.get();
    final svcMap = (snap.data() ?? {})[selectedService] as Map<String, dynamic>? ?? {};
    final remaining = (svcMap[dateKey] as List<dynamic>?)?.length ?? 0;
    if (remaining == 0) {
      await docRef.update({
        '$selectedService.$dateKey': FieldValue.delete(),
      });
    }
  }

  Future<void> _submitBooking() async {
    // 1) Guardamos la reserva en Firestore
    await _firestore.collection('bookings').add({
      'department': selectedDept,
      'service': selectedService,
      'office': selectedOfficeId,
      'date': selectedDay!.toIso8601String(),
      'time': selectedTime,
      'user': {
        'docType': selectedDocType,
        'docNumber': docNumber,
        'name': name,
        'cell': cell,
        'email': email,
      },
    });

    // 2) Mostramos diálogo de éxito con botón OK
    final okPressed = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // obliga a pulsar OK
      builder: (_) => AlertDialog(
        title: const Text('¡Listo!'),
        content: const Text('Reserva creada correctamente.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    // 3) Si pulsó OK, reseteamos todo y volvemos al paso 0
    if (okPressed == true) {
      setState(() {
        _currentStep = 0;

        // Limpieza paso 1
        selectedDept = null;
        selectedService = null;
        selectedOfficeId = null;
        _services = [];
        _offices = [];

        // Limpieza paso 2
        selectedDay = null;
        selectedTime = null;
        _focusedDay = DateTime.now();

        // Limpieza paso 3
        _formKey.currentState?.reset();
        selectedDocType = null;
        docNumber = name = cell = email = null;
        _isHuman = false;
      });

      // 4) (Opcional) Recargamos departamentos para iniciar limpio
      await _loadDepartments();
    }
  }


}