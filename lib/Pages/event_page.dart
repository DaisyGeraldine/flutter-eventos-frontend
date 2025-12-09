import 'package:flutter/material.dart';
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
  String filtroFecha = 'Todos'; // Nuevo: filtro de fecha para finalizados

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
                            _buildFilterButton("Finalizado"),
                          ],
                        ),
                      ),
                    ),
                    // Filtro de fecha solo para eventos finalizados
                    if (filtroEstado == 'Finalizado') ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              Icon(
                                Icons.filter_list,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 8),
                              _buildDateFilterChip("Todos"),
                              const SizedBox(width: 8),
                              _buildDateFilterChip("Último mes"),
                              const SizedBox(width: 8),
                              _buildDateFilterChip("Últimos 3 meses"),
                              const SizedBox(width: 8),
                              _buildDateFilterChip("Último año"),
                            ],
                          ),
                        ),
                      ),
                    ],
                    // Contador de eventos
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
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

  Widget _buildDateFilterChip(String filtro) {
    final isSelected = filtroFecha == filtro;

    return FilterChip(
      label: Text(filtro),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          filtroFecha = filtro;
        });
      },
      selectedColor: const Color(0xff142047),
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey[700],
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      backgroundColor: Colors.grey[200],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  String _getEventCountText() {
    final eventosFiltrados = _getFilteredEvents();
    if (filtroEstado == 'Todos') {
      return "Mostrando ${eventosFiltrados.length} de ${eventRequest.length} eventos";
    } else if (filtroEstado == 'Finalizado' && filtroFecha != 'Todos') {
      return "Mostrando ${eventosFiltrados.length} eventos finalizados ($filtroFecha)";
    } else {
      return "Mostrando ${eventosFiltrados.length} eventos en estado: $filtroEstado";
    }
  }

  List<Event> _getFilteredEvents() {
    List<Event> filtered = eventRequest;

    // Filtrar por estado
    if (filtroEstado != 'Todos') {
      filtered = filtered.where((e) => e.estado == filtroEstado).toList();
    }

    // Filtrar por fecha solo si el estado es "Finalizado"
    if (filtroEstado == 'Finalizado' && filtroFecha != 'Todos') {
      final now = DateTime.now();
      DateTime? fechaLimite;

      switch (filtroFecha) {
        case 'Último mes':
          fechaLimite = DateTime(now.year, now.month - 1, now.day);
          break;
        case 'Últimos 3 meses':
          fechaLimite = DateTime(now.year, now.month - 3, now.day);
          break;
        case 'Último año':
          fechaLimite = DateTime(now.year - 1, now.month, now.day);
          break;
      }

      if (fechaLimite != null) {
        filtered =
            filtered.where((e) {
              return e.fechaFin.isAfter(fechaLimite!) ||
                  e.fechaFin.isAtSameMomentAs(fechaLimite);
            }).toList();
      }
    }

    return filtered;
  }

  Widget _buildFilterButton(String estado) {
    final count =
        estado == 'Todos'
            ? eventRequest.length
            : eventRequest.where((e) => e.estado == estado).length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            filtroEstado = estado;
            // Resetear filtro de fecha cuando se cambia de estado
            if (estado != 'Finalizado') {
              filtroFecha = 'Todos';
            }
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor:
              filtroEstado == estado
                  ? const Color(0xff142047)
                  : Colors.grey[200],
          foregroundColor:
              filtroEstado == estado ? Colors.white : Colors.black87,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
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
                  color:
                      filtroEstado == estado
                          ? Colors.white
                          : const Color(0xff142047),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    color:
                        filtroEstado == estado
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
            Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
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
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
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
          final isFinalizado = evento.estado?.toLowerCase() == 'finalizado';

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
                      _buildEstadoBadge(evento.estado ?? ''),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('dd/MM/yyyy').format(evento.fechaIni),
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey,
                      ),
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
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey,
                      ),
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
                  // Mostrar indicador de presupuesto solo si está finalizado
                  if (isFinalizado &&
                      evento.presupuesto != null &&
                      evento.presupuestoModificado != null) ...[
                    const SizedBox(height: 12),
                    _buildPresupuestoIndicator(evento),
                  ],

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

  Widget _buildPresupuestoIndicator(Event evento) {
    final presupuestoInicial = evento.presupuesto ?? 0.0;
    final presupuestoFinal = evento.presupuestoModificado ?? 0.0;
    final diferencia = presupuestoFinal - presupuestoInicial;
    final porcentajeDiferencia =
        presupuestoInicial > 0
            ? (diferencia / presupuestoInicial * 100).abs()
            : 0.0;

    Color indicadorColor;
    IconData iconoEstado;

    if (diferencia <= 0) {
      // Igual o más barato - Verde
      indicadorColor = Colors.green[600]!;
      iconoEstado = Icons.trending_down;
    } else if (porcentajeDiferencia <= 10) {
      // Exceso leve (hasta 10%) - Amarillo
      indicadorColor = Colors.amber[600]!;
      iconoEstado = Icons.trending_flat;
    } else {
      // Exceso grande (más de 10%) - Rojo
      indicadorColor = Colors.red[600]!;
      iconoEstado = Icons.trending_up;
    }

    return Container(
      alignment: Alignment.topCenter,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: indicadorColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(iconoEstado, color: indicadorColor, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Presupuesto',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Inicial: ',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '€${presupuestoInicial.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      'Final: ',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '€${presupuestoFinal.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (diferencia != 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: indicadorColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${diferencia > 0 ? '+' : ''}${diferencia.toStringAsFixed(0)}€',
                style: TextStyle(
                  color: indicadorColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEstadoBadge(String estado) {
    Color backgroundColor;
    Color textColor;

    switch (estado.toLowerCase()) {
      case 'pendiente':
        backgroundColor = Colors.redAccent;
        textColor = Colors.white;
        break;
      case 'en preparación':
        backgroundColor = Colors.amberAccent;
        textColor = Colors.black;
        break;
      case 'en ejecución':
        backgroundColor = Colors.greenAccent;
        textColor = Colors.white;
        break;
      case 'finalizado':
        backgroundColor = Colors.blueAccent;
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
        textAlign: TextAlign.center,
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
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
            backgroundColor: Colors.orange[500],
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      );
    }

    if (evento.estado == "En ejecución") {
      acciones.add(
        ElevatedButton.icon(
          onPressed: () => _actualizarPresupuestoFinal(evento),
          icon: const Icon(Icons.edit, size: 16),
          label: const Text("Actualizar Presupuesto"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[600],
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

  void _actualizarPresupuestoFinal(Event evento) {
    final TextEditingController presupuestoController = TextEditingController(
      text:
          evento.presupuestoModificado?.toStringAsFixed(2) ??
          evento.presupuesto?.toStringAsFixed(2) ??
          '',
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.edit, color: const Color(0xff142047)),
                const SizedBox(width: 8),
                const Text('Actualizar Presupuesto Final'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Evento: ${evento.nombre}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (evento.presupuesto != null)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Presupuesto inicial: €${evento.presupuesto!.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                TextField(
                  controller: presupuestoController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Presupuesto Final (€)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.euro),
                    hintText: 'Ej: 1500.00',
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 12),
                Text(
                  'Este será el costo real del evento.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final presupuestoText = presupuestoController.text.trim();

                  if (presupuestoText.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Por favor ingresa un presupuesto'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }

                  final presupuestoFinal = double.tryParse(presupuestoText);

                  if (presupuestoFinal == null || presupuestoFinal < 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ingresa un presupuesto válido'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  Navigator.of(context).pop();

                  // Mostrar loading
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder:
                        (context) =>
                            const Center(child: CircularProgressIndicator()),
                  );

                  // Actualizar presupuesto en el backend
                  final result = await _eventService.updatePresupuestoFinal(
                    evento.cod,
                    presupuestoFinal,
                  );

                  // Cerrar loading
                  Navigator.of(context).pop();

                  if (result.success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Presupuesto actualizado exitosamente'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    // Recargar eventos
                    loadRequestEvents();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${result.message}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff142047),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Actualizar'),
              ),
            ],
          ),
    );
  }

  _verDetalles(Event evento) {
    Navigator.pushNamed(context, '/event_detail', arguments: evento);
  }

  _verificarDisponibilidad(Event evento) async {
    print("Verificando disponibilidad para el evento ${evento.cod}");
    await Navigator.pushNamed(context, '/verify_personal', arguments: evento);
    setState(() {
      loadRequestEvents();
    });
  }

  _iniciarEjecucion(Event evento) {
    print("Iniciando ejecución para el evento ${evento.cod}");
  }
}
