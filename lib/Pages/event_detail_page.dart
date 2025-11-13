import 'package:flutter/material.dart';
import 'package:flutter_application_2/models/event.dart';

class EventDetailPage extends StatefulWidget {
  final Event? requestEvent;
  const EventDetailPage({super.key, this.requestEvent});

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  @override
  Widget build(BuildContext context) {
    final evento = widget.requestEvent!.toJson();
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(title: Text('Detalles del Evento')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          "🎉 ${evento['nombre']}",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(),

                  // Información general
                  Text(
                    "📅 Fecha: ${evento['fechaIni'].toString().split('T').first} - "
                    "${evento['fechaFin'].toString().split('T').first}",
                  ),
                  Text("👤 Usuario: ${evento['nombreUsuario']}"),
                  Text("🏠 Dirección: ${evento['direccion']}"),
                  Text("🕓 Duración: ${evento['duracion']} horas"),
                  const SizedBox(height: 12),

                  // Material solicitado
                  const Text(
                    "📦 Material solicitado:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(evento['descripcionMaterial'] ?? "Sin materiales"),
                  const SizedBox(height: 12),

                  // Personal solicitado
                  const Text(
                    "👥 Personal solicitado:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    evento['descripcionPersonal'] ?? "Sin personal asignado",
                  ),
                  const SizedBox(height: 12),

                  // Anotaciones
                  const Text(
                    "🗒️ Anotaciones:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(evento['anotaciones'] ?? "Sin anotaciones"),
                  const SizedBox(height: 16),

                  // Botones de acción
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cerrar"),
                      ),
                      const SizedBox(width: 8),
                      if (evento['estado'] == 'Pendiente') ...[
                        ElevatedButton(
                          onPressed: () {
                            // Acción: verificar disponibilidad
                            // o iniciar preparación (según flujo)
                          },
                          child: const Text("Verificar disponibilidad"),
                        ),
                      ],
                      // ] else if (evento['estado'] == 'En preparación') ...[
                      //   ElevatedButton(
                      //     onPressed: () {
                      //       // Acción: iniciar ejecución
                      //     },
                      //     child: const Text("Iniciar ejecución"),
                      //   ),
                      // ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
