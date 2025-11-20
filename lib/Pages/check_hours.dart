import 'package:flutter/material.dart';
import 'package:flutter_application_2/models/employee.dart';
import 'package:flutter_application_2/service/auth_service.dart';
import 'package:pie_chart/pie_chart.dart';

class Checkhours extends StatelessWidget {
  Checkhours({Key? key}) : super(key: key);

  @override
  @override
  Widget build(BuildContext context) {
    final AuthService _authService = AuthService();
    final size = MediaQuery.of(context).size;
    final employee = Employee();

    return Scaffold(
      appBar: AppBar(title: Text("Horas trabajadas")),
      body: FutureBuilder(
        future: _authService.getCurrentUser(),
        builder: (context, snapshot) {
          final dataMap = <String, double>{};
          final colorList = <Color>[];

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else {
            if (!snapshot.hasData) {
              return Center(child: Text("No se encontraron datos del usuario"));
            }
            final Map<String, dynamic> user = snapshot.data!;
            final double maxHours = 150.0;
            final double hoursWorked =
                user['contratosHoras']?.toDouble() ?? 0.0;
            final double hoursRemaining = maxHours - hoursWorked;

            // Validación para evitar división por cero y valores negativos
            if (hoursWorked < 0) {
              return Center(
                child: Text("El número de horas trabajadas no es válido."),
              );
            }

            final double percentageWorked = (hoursWorked / maxHours) * 100;

            dataMap['Horas trabajadas'] = hoursWorked;

            // Validación robusta: la suma de los valores debe ser mayor que 0 y no NaN
            final double totalData = dataMap.values.fold(0, (a, b) => a + b);
            if (totalData <= 0 || totalData.isNaN) {
              return Center(
                child: Text(
                  "No hay datos suficientes para mostrar el gráfico.",
                ),
              );
            }

            print("Porcentaje trabajado: $percentageWorked");

            if (percentageWorked > 100.0) {
              colorList.add(Colors.redAccent);
            } else if (percentageWorked > 75.0) {
              colorList.add(Colors.yellowAccent);
            } else {
              colorList.add(Colors.greenAccent);
            }

            return SafeArea(
              // maintainBottomViewPadding: true,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Empleado: ${employee.nombre} ${employee.apellidos}",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          Text(
                            "Horas trabajadas: ${hoursWorked.toStringAsFixed(2)}",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Horas restantes: ${hoursRemaining.toStringAsFixed(2)}",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Horas máximas permitidas: $maxHours",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Porcentaje de horas trabajadas: ${percentageWorked.toStringAsFixed(2)}%",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            "Distribución de horas trabajadas:",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          // Pie chart
                          SizedBox(
                            height: size.height * 0.3,
                            child: PieChart(
                              dataMap: dataMap,
                              chartType: ChartType.ring,
                              baseChartColor: Colors.grey[100]!,
                              colorList: colorList,
                              chartValuesOptions: ChartValuesOptions(
                                showChartValuesInPercentage: true,
                              ),
                              totalValue: maxHours,
                              animationDuration: const Duration(
                                milliseconds: 800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
