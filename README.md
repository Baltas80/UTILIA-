# UTILIA

**Pequeñas herramientas. Grandes soluciones.**

UTILIA es una aplicación móvil de utilidades cotidianas. El objetivo del producto es resolver tareas concretas en pocos toques, con una interfaz limpia y cálculos deterministas.

## Dirección del producto
- Android primero; arquitectura preparada para iOS.
- Flutter + Dart + Material 3.
- Sin cuenta ni backend en el MVP.
- Privacidad por defecto: cálculos locales.
- Monetización futura: publicidad no intrusiva y opción premium.
- Medir uso y retención antes de ampliar funciones complejas.

## MVP 0.2
Categorías: Dinero, Tiempo, Casa, Coche, Conversores, Salud, Estudio y Varios.

Herramientas previstas en el catálogo inicial:
- Porcentaje
- Descuentos
- IVA
- Propinas
- Préstamos
- Edad
- Diferencia de fechas
- Superficie
- Combustible
- Conversor de longitud
- Conversor de peso
- IMC
- Media de notas
- Regla de tres

## Calidad
- Tests unitarios para fórmulas críticas.
- CI en GitHub Actions para formato, análisis, tests y validación de release Android.
- CI valida `compileSdk 36`, `targetSdk 36`, `minSdk 24` y `applicationId com.utilia.app.utilia`.
- Los builds de release requieren firma mediante secretos de CI; las claves privadas no se almacenan en el repositorio.
- La CI comprueba APK/AAB, certificados de firma y hashes SHA-256 de los artefactos.
- No incorporar credenciales, claves API ni datos personales al repositorio.

## Roadmap
1. Consolidar navegación y catálogo.
2. Persistencia local real de favoritos e historial.
3. Completar las herramientas prioritarias y sus tests.
4. Tema claro/oscuro y accesibilidad.
5. Analítica de producto respetuosa con la privacidad.
6. Build firmado AAB y pruebas internas de Google Play.
7. Iterar según descargas, retención y herramientas más utilizadas.

## Licencia
Código propietario. No se concede licencia de reutilización, modificación o redistribución salvo autorización expresa del titular.
