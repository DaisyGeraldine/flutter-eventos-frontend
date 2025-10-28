import 'package:flutter/material.dart';
import 'package:flutter_application_2/Pages/event_detail_page.dart';
import 'package:flutter_application_2/models/employee.dart';
import 'package:flutter_application_2/models/event.dart';
import 'package:flutter_application_2/models/request_event.dart';
import 'package:flutter_application_2/service/event-service.dart';
import 'package:intl/intl.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  final EventService _eventService = EventService();
  List<Event> eventRequest = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String filtroEstado = 'Todos';

  @override
  void initState() {
    super.initState();
    loadRequestEvents();
  }

  Future<void> loadRequestEvents() async {
    setState(() {
      _isLoading = true;
    });

    // try {
    final result = await _eventService.getEvents();
    eventRequest = result.data ?? [];
    // } catch (e) {
    //   print('Error loading events: $e');
    //   _errorMessage = 'Error loading events';
    // }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final employee = Employee();
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Gestión de Eventos'),
            Text(
              '${employee.nombre} ${employee.apellidos} : ${employee.categoriaPersona?.toUpperCase()}',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    // const Padding(
                    //   padding: EdgeInsets.all(16.0),
                    //   child: Text(
                    //     'Solicitudes de Eventos',
                    //     style: TextStyle(
                    //       fontSize: 24,
                    //       fontWeight: FontWeight.bold,
                    //     ),
                    //   ),
                    // ),

                    // Expanded(
                    //   child: SingleChildScrollView(
                    //     child: Table(
                    //       border: TableBorder.all(),
                    //       children: [
                    //         TableRow(
                    //           children: [
                    //             Padding(
                    //               padding: const EdgeInsets.all(8.0),
                    //               child: Text(
                    //                 'Evento',
                    //                 style: TextStyle(
                    //                   fontWeight: FontWeight.bold,
                    //                 ),
                    //               ),
                    //             ),
                    //             Padding(
                    //               padding: const EdgeInsets.all(8.0),
                    //               child: Text(
                    //                 'Descripción Material',
                    //                 style: TextStyle(
                    //                   fontWeight: FontWeight.bold,
                    //                 ),
                    //               ),
                    //             ),
                    //             Padding(
                    //               padding: const EdgeInsets.all(8.0),
                    //               child: Text(
                    //                 'Descripción Personal',
                    //                 style: TextStyle(
                    //                   fontWeight: FontWeight.bold,
                    //                 ),
                    //               ),
                    //             ),
                    //           ],
                    //         ),

                    //         // Aquí deberías agregar los eventos obtenidos de la API
                    //         // Por ejemplo, si tienes una lista de eventos llamada `events`:
                    //         ...eventRequest.map((event) {
                    //           return TableRow(
                    //             children: [
                    //               Padding(
                    //                 padding: const EdgeInsets.all(8.0),
                    //                 child: TextButton(
                    //                   onPressed: () {
                    //                     Navigator.push(
                    //                       context,
                    //                       MaterialPageRoute(
                    //                         builder:
                    //                             (context) => EventDetailPage(
                    //                               requestEvent: event,
                    //                             ),
                    //                       ),
                    //                     );
                    //                   },
                    //                   child: Text(event.cod ?? 'Sin código'),
                    //                 ),
                    //               ),
                    //               Padding(
                    //                 padding: const EdgeInsets.all(8.0),
                    //                 child: Text(
                    //                   event.descripcionMaterial ??
                    //                       'Sin descripción',
                    //                 ),
                    //               ),
                    //               Padding(
                    //                 padding: const EdgeInsets.all(8.0),
                    //                 child: Text(
                    //                   event.descripcionPersonal ??
                    //                       'Sin descripción',
                    //                 ),
                    //               ),
                    //             ],
                    //           );
                    //         }).toList(),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    // Expanded(
                    //   child: ListView.builder(
                    //     itemCount: eventRequest.length,
                    //     itemBuilder: (context, index) {
                    //       final evento = eventRequest[index];
                    //       return Card(
                    //         margin: EdgeInsets.all(8),
                    //         child: ExpansionTile(
                    //           title: Text(evento.nombre),
                    //           subtitle: Text(
                    //             "${DateFormat('dd/MM/yyyy').format(evento.fechaIni)} "
                    //             "| Estado: ${evento.estado}",
                    //           ),
                    //           children: [
                    //             ListTile(
                    //               title: Text("Ubicación: ${evento.direccion}"),
                    //             ),
                    //             ListTile(
                    //               title: Text(
                    //                 "Cliente: ${evento.nombreUsuario}",
                    //               ),
                    //             ),
                    //             ListTile(
                    //               title: Text(
                    //                 "Duración: ${evento.duracion} horas",
                    //               ),
                    //             ),
                    //             ListTile(
                    //               title: Text(
                    //                 "Aforo: ${evento.aforo} personas",
                    //               ),
                    //             ),
                    //             ListTile(
                    //               title: Text(
                    //                 "Anotaciones: ${evento.anotaciones}",
                    //               ),
                    //             ),
                    //             ButtonBar(
                    //               alignment: MainAxisAlignment.end,
                    //               children: _buildAcciones(evento),
                    //             ),
                    //           ],
                    //         ),
                    //       );
                    //     },
                    //   ),
                    // ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          _buildFilterButton("Pendiente"),
                          _buildFilterButton("En preparación"),
                          _buildFilterButton("En ejecución"),
                        ],
                      ),
                    ),
                    const Divider(),
                    // Lista de eventos
                    Expanded(child: _buildListaEventos()),
                  ],
                ),
              ),
    );
  }

  Widget _buildFilterButton(String estado) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            filtroEstado = estado; // cambia el filtro actual
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor:
              filtroEstado == estado ? Colors.blue : Colors.grey[300],
          foregroundColor: filtroEstado == estado ? Colors.white : Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
        child: Text(estado),
      ),
    );
  }

  Widget _buildListaEventos() {
    final eventosFiltrados =
        eventRequest.where((e) {
          if (filtroEstado == null) return true;
          return e.estado == filtroEstado;
        }).toList();

    return ListView.builder(
      itemCount: eventosFiltrados.length,
      itemBuilder: (context, index) {
        final evento = eventosFiltrados[index];
        return Card(
          margin: const EdgeInsets.all(8),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  evento.nombre,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text("Estado: ${evento.estado}"),
                Text(
                  "Fecha: ${DateFormat('dd/MM/yyyy').format(evento.fechaIni)}",
                ),
                Text("Ubicación: ${evento.direccion}"),
                const SizedBox(height: 8),
                Wrap(spacing: 8, children: _buildAcciones(evento)),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildAcciones(Event evento) {
    final acciones = <Widget>[];

    acciones.add(
      ElevatedButton.icon(
        onPressed: () => _verDetalles(evento),
        icon: const Icon(Icons.info_outline),
        label: const Text("Ver detalle"),
      ),
    );

    if (evento.estado == "Pendiente") {
      acciones.add(
        ElevatedButton.icon(
          onPressed: () => _verificarDisponibilidad(evento),
          icon: const Icon(Icons.verified_outlined),
          label: const Text("Verificar disponibilidad"),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
        ),
      );
    } else if (evento.estado == "En preparación") {
      acciones.add(
        ElevatedButton.icon(
          onPressed: () => _iniciarEjecucion(evento),
          icon: const Icon(Icons.play_arrow),
          label: const Text("Iniciar ejecución"),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
        ),
      );
    }

    return acciones;
  }

  _verDetalles(Event evento) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventDetailPage(requestEvent: evento),
      ),
    );
  }

  _verificarDisponibilidad(Event evento) {
    // Lógica para verificar disponibilidad
    print("Verificando disponibilidad para el evento ${evento.cod}");
  }

  _iniciarEjecucion(Event evento) {
    // Lógica para iniciar ejecución
    print("Iniciando ejecución para el evento ${evento.cod}");
  }
}
