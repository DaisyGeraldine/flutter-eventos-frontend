//Crear una funcion que reciba un DateTime y retorne un String con el formato dd/MM/yyyy
String? formatDate(DateTime? date) {
  return date != null
      ? '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}'
      : null;
}