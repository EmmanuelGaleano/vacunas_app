// =============================================================================
// vacuna.dart
// Modelo de una vacuna y un catálogo local de ejemplo.
//
// El catálogo es local (no viene de la API) porque su objetivo es demostrar
// la navegación con GoRouter: lista -> detalle usando un parámetro en la
// ruta (/vacunas/:id). Los datos son informativos y generales.
// =============================================================================

class Vacuna {
  const Vacuna({
    required this.id,
    required this.nombre,
    required this.protegeContra,
    required this.dosis,
    required this.requiereRefuerzo,
    required this.descripcion,
  });

  final String id;
  final String nombre;
  final String protegeContra;
  final String dosis;
  // Mismo concepto que el campo "RequiresBooster" de la API del profesor.
  final bool requiereRefuerzo;
  final String descripcion;
}

const List<Vacuna> catalogoVacunas = [
  Vacuna(
    id: '1',
    nombre: 'BCG',
    protegeContra: 'Formas graves de tuberculosis',
    dosis: 'Dosis única al nacer',
    requiereRefuerzo: false,
    descripcion: 'Se aplica a los recién nacidos y protege contra las formas '
        'más graves de la tuberculosis en la infancia.',
  ),
  Vacuna(
    id: '2',
    nombre: 'Hepatitis B',
    protegeContra: 'Hepatitis B',
    dosis: 'Primera dosis al nacer y luego un esquema de varias dosis',
    requiereRefuerzo: false,
    descripcion: 'Protege el hígado contra el virus de la hepatitis B, que se '
        'transmite por sangre y fluidos corporales.',
  ),
  Vacuna(
    id: '3',
    nombre: 'Triple viral (SRP)',
    protegeContra: 'Sarampión, rubéola y paperas',
    dosis: 'Dos dosis durante la infancia',
    requiereRefuerzo: true,
    descripcion: 'Una sola vacuna que protege contra tres enfermedades virales '
        'muy contagiosas.',
  ),
  Vacuna(
    id: '4',
    nombre: 'Fiebre amarilla',
    protegeContra: 'Fiebre amarilla',
    dosis: 'Dosis única',
    requiereRefuerzo: false,
    descripcion: 'Recomendada para quienes viven o viajan a zonas donde '
        'circula el virus de la fiebre amarilla.',
  ),
  Vacuna(
    id: '5',
    nombre: 'Influenza',
    protegeContra: 'Gripe estacional',
    dosis: 'Una dosis cada año',
    requiereRefuerzo: true,
    descripcion: 'El virus de la influenza cambia con frecuencia, por eso la '
        'vacuna se actualiza y se aplica cada año.',
  ),
  Vacuna(
    id: '6',
    nombre: 'Tétanos y difteria (Td)',
    protegeContra: 'Tétanos y difteria',
    dosis: 'Esquema inicial y refuerzos en la vida adulta',
    requiereRefuerzo: true,
    descripcion: 'Necesita refuerzos periódicos para mantener la protección '
        'a lo largo de la vida.',
  ),
];

// Busca una vacuna por id. Devuelve null si no existe, para que la pantalla
// de detalle pueda mostrar un mensaje cuando alguien escribe /vacunas/99.
Vacuna? buscarVacuna(String id) {
  for (final vacuna in catalogoVacunas) {
    if (vacuna.id == id) return vacuna;
  }
  return null;
}
