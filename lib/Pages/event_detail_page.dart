import 'package:flutter/material.dart';
import 'package:flutter_application_2/Pages/verify_personal_page.dart';
import 'package:flutter_application_2/models/event.dart';
import 'package:intl/intl.dart';

class EventDetailPage extends StatefulWidget {
  final Event? event;
  const EventDetailPage({super.key, this.event});

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  @override
  Widget build(BuildContext context) {
    final Event event = widget.event!;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // AppBar con imagen de fondo
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: const Color(0xff142047),
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                event.nombre,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3,
                      color: Colors.white24,
                    ),
                  ],
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xff142047),
                      Color(0xff1a2859),
                      Color(0xff20306b),
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.event, size: 80, color: Colors.white30),
                ),
              ),
            ),
          ),
          // Contenido principal
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Estado del evento
                  _buildEstadoCard(event.estado ?? ''),
                  const SizedBox(height: 16),

                  // Información principal
                  _buildInfoCard(event),
                  const SizedBox(height: 16),

                  // Detalles del evento
                  _buildDetallesCard(event),
                  const SizedBox(height: 16),

                  // Requerimientos
                  _buildRequerimientosCard(event),
                  const SizedBox(height: 16),

                  // Anotaciones si existen
                  if (event.anotaciones != null &&
                      event.anotaciones!.isNotEmpty)
                    _buildAnotacionesCard(event.anotaciones!),

                  if ( event.estado == 'Pendiente')
                    const SizedBox(height: 100), // Espacio para el botón flotante
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(event),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildEstadoCard(String estado) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (estado.toLowerCase()) {
      case 'pendiente':
        backgroundColor = Colors.redAccent;
        textColor = Colors.white;
        icon = Icons.schedule;
        break;
      case 'en preparación':
        backgroundColor = Colors.amberAccent;
        textColor = Colors.white;
        icon = Icons.build;
        break;
      case 'en ejecución':
        backgroundColor = Colors.greenAccent;
        textColor = Colors.white;
        icon = Icons.play_arrow;
        break;
      case 'finalizado':
        backgroundColor = Colors.blueAccent;
        textColor = Colors.white;
        icon = Icons.check_circle;
        break;
      case 'cancelado':
        backgroundColor = Colors.redAccent;
        textColor = Colors.white;
        icon = Icons.cancel;
        break;
      default:
        backgroundColor = Colors.grey;
        textColor = Colors.white;
        icon = Icons.help;
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor, size: 24),
            const SizedBox(width: 12),
            Text(
              'Estado: $estado',
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(Event evento) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: const Color(0xff142047)),
                const SizedBox(width: 8),
                const Text(
                  'Información General',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.person,
              'Cliente',
              evento.nombreUsuario,
              Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.location_on,
              'Ubicación',
              evento.direccion,
              Colors.green,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.calendar_today,
              'Fecha de inicio',
              DateFormat('dd/MM/yyyy').format(evento.fechaIni),
              Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.event,
              'Fecha de fin',
              DateFormat('dd/MM/yyyy').format(evento.fechaFin),
              Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.access_time,
              'Duración',
              '${evento.duracion} horas',
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetallesCard(Event evento) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.assignment, color: const Color(0xff142047)),
                const SizedBox(width: 8),
                const Text(
                  'Detalles del Evento',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailSection(
              'Código del Evento',
              evento.cod,
              Icons.qr_code,
              Colors.teal,
            ),
            const SizedBox(height: 12),
            _buildDetailSection(
              'Tipo de Evento',
              evento.nombre ?? 'No especificado',
              Icons.category,
              Colors.indigo,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequerimientosCard(Event evento) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.list_alt, color: const Color(0xff142047)),
                const SizedBox(width: 8),
                const Text(
                  'Requerimientos',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildRequerimientoSection(
              'Material Solicitado',
              evento.descripcionMaterial ?? 'Sin materiales específicos',
              Icons.inventory,
              Colors.green,
            ),
            const SizedBox(height: 16),
            _buildRequerimientoSection(
              'Personal Solicitado',
              evento.descripcionPersonal ?? 'Sin personal específico',
              Icons.people,
              Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnotacionesCard(String anotaciones) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.note_alt, color: const Color(0xff142047)),
                const SizedBox(width: 8),
                const Text(
                  'Anotaciones Adicionales',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(
                anotaciones,
                style: const TextStyle(fontSize: 14, height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailSection(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequerimientoSection(
    String title,
    String content,
    IconData icon,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Text(content, style: const TextStyle(fontSize: 14)),
        ),
      ],
    );
  }

  Widget? _buildFloatingActionButton(Event evento) {
    if (evento.estado == 'Pendiente') {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: ElevatedButton.icon(
          onPressed: () async {
            final result = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (context) => VerifyAvailabilityPage(event: evento),
              ),
            );

            if (result == true && mounted) {
              // Actualizar la página padre si es necesario
              Navigator.pop(context, true);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xff142047),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 8,
          ),
          icon: const Icon(Icons.verified_outlined),
          label: const Text(
            'Verificar Disponibilidad',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      );
    } 
    // else if (evento.estado == 'En preparación') {
    //   return Container(
    //     width: double.infinity,
    //     margin: const EdgeInsets.symmetric(horizontal: 20),
    //     child: ElevatedButton.icon(
    //       onPressed: () {
    //         // TODO: Implementar lógica para iniciar ejecución
    //         ScaffoldMessenger.of(context).showSnackBar(
    //           const SnackBar(
    //             content: Text('Función de inicio de ejecución próximamente'),
    //             backgroundColor: Colors.blue,
    //           ),
    //         );
    //       },
    //       style: ElevatedButton.styleFrom(
    //         backgroundColor: Colors.green,
    //         foregroundColor: Colors.white,
    //         padding: const EdgeInsets.symmetric(vertical: 16),
    //         shape: RoundedRectangleBorder(
    //           borderRadius: BorderRadius.circular(12),
    //         ),
    //         elevation: 8,
    //       ),
    //       icon: const Icon(Icons.play_arrow),
    //       label: const Text(
    //         'Iniciar Ejecución',
    //         style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    //       ),
    //     ),
    //   );
    // }

    return null; // No mostrar botón para otros estados
  }
}
