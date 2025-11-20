import 'package:flutter/material.dart';
import 'package:flutter_application_2/Pages/event_detail_page.dart';
import 'package:flutter_application_2/Pages/verify_personal_page.dart';
import 'package:flutter_application_2/models/employee.dart';
import 'package:flutter_application_2/models/event.dart';
import 'package:flutter_application_2/service/event_service.dart';
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
  String filtroEstado = 'En preparación';

  @override
  void initState() {
    super.initState();
    loadRequestEvents();
  }

  Future<void> loadRequestEvents() async {
    setState(() {
      _isLoading = true;
    });

    final result = await _eventService.getEvents();
    eventRequest = result.data ?? [];

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
        backgroundColor: const Color(0xff142047),
        foregroundColor: Colors.white,
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
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: SingleChildScrollView(
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
                    ),
                    // Contador de eventos
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getEventCountText(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Lista de eventos
                      Expanded(child: _buildListaEventos()),
                  ],
                ),
              ),
    );
  }

  String _getEventCountText() {
    final eventosFiltrados = _getFilteredEvents();
    if (filtroEstado == 'Todos') {
      return "Mostrando ${eventosFiltrados.length} de ${eventRequest.length} eventos";
    } else {
      return "Mostrando ${eventosFiltrados.length} eventos en estado: $filtroEstado";
    }
  }

  List<Event> _getFilteredEvents() {
    if (filtroEstado == 'Todos') return eventRequest;
    return eventRequest.where((e) => e.estado == filtroEstado).toList();
  }

  Widget _buildFilterButton(String estado) {
    final count = estado == 'Todos' 
        ? eventRequest.length 
        : eventRequest.where((e) => e.estado == estado).length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            filtroEstado = estado; // cambia el filtro actual
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: filtroEstado == estado 
              ? const Color(0xff142047) 
              : Colors.grey[200],
          foregroundColor: filtroEstado == estado 
              ? Colors.white 
              : Colors.black87,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(estado),
            if (count > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: filtroEstado == estado 
                      ? Colors.white 
                      : const Color(0xff142047),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    color: filtroEstado == estado 
                        ? const Color(0xff142047) 
                        : Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildListaEventos() {
    final eventosFiltrados = _getFilteredEvents();

    if (eventosFiltrados.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              filtroEstado == 'Todos'
                  ? 'No hay eventos registrados'
                  : 'No hay eventos en estado: $filtroEstado',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Los eventos aparecerán aquí cuando estén disponibles',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: loadRequestEvents,
      child: ListView.builder(
        itemCount: eventosFiltrados.length,
        itemBuilder: (context, index) {
          final evento = eventosFiltrados[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          evento.nombre,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _buildEstadoBadge(evento.estado??''),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('dd/MM/yyyy').format(evento.fechaIni),
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.access_time, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        "${evento.duracion}h",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          evento.direccion,
                          style: const TextStyle(color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _buildAcciones(evento),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEstadoBadge(String estado) {
    Color backgroundColor;
    Color textColor;

    switch (estado.toLowerCase()) {
      case 'pendiente':
        backgroundColor = Colors.red;
        textColor = Colors.white;
        break;
      case 'en preparación':
        backgroundColor = Colors.yellowAccent;
        textColor = Colors.black;
        break;
      case 'en ejecución':
        backgroundColor = Colors.green[900]!;
        textColor = Colors.white;
        break;
      case 'finalizado':
        backgroundColor = Colors.green;
        textColor = Colors.white;
        break;
      case 'cancelado':
        backgroundColor = Colors.red;
        textColor = Colors.white;
        break;
      default:
        backgroundColor = Colors.grey;
        textColor = Colors.white;
    }

    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        textAlign:  TextAlign.center,
        estado,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  List<Widget> _buildAcciones(Event evento) {
    final acciones = <Widget>[];

    acciones.add(
      OutlinedButton.icon(
        onPressed: () => _verDetalles(evento),
        icon: const Icon(Icons.info_outline, size: 16),
        label: const Text("Detalles"),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xff142047),
          side: const BorderSide(color: Color(0xff142047)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );

    if (evento.estado == "Pendiente") {
      acciones.add(
        ElevatedButton.icon(
          onPressed: () => _verificarDisponibilidad(evento),
          icon: const Icon(Icons.verified_outlined, size: 16),
          label: const Text("Verificar"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange[900],
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VerifyAvailabilityPage(event: evento),
      ),
    );
  }

  _iniciarEjecucion(Event evento) {
    // Lógica para iniciar ejecución
    print("Iniciando ejecución para el evento ${evento.cod}");
  }
}
