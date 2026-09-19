# UTILIA

**Pequeñas herramientas. Grandes soluciones.**

UTILIA es una aplicación móvil de utilidades cotidianas. Resuelve tareas concretas en pocos toques, con una interfaz Material 3, cálculos deterministas y funcionamiento local por defecto.

## Estado actual

- Android primero, desarrollada con Flutter + Dart.
- `applicationId`: `com.utilia.app.utilia`.
- `minSdk`: 24.
- `targetSdk`: 36.
- `compileSdk`: 36.
- Java/Kotlin: 17.
- Sin cuenta ni backend propio.
- Favoritos, historial, idioma y tema persistidos localmente.
- Sin publicidad ni analítica integrada en la versión actual.
- Compartir resultados únicamente cuando el usuario lo solicita.
- Soporte de español, inglés, francés, alemán, italiano y portugués.
- Tema claro y oscuro.
- Tests unitarios, de persistencia, localización y accesibilidad.
- CI de producción con análisis, tests, validaciones Android, comprobación de secretos y generación/verificación de APK y AAB firmados.

## Categorías y herramientas

Categorías actuales: Dinero, Tiempo, Casa, Coche, Conversores, Salud, Estudio y Varios.

El catálogo incluye herramientas para porcentajes, descuentos, IVA, propinas, préstamos, edad, fechas, superficies, combustible, conversiones, IMC, medias, regla de tres y otras utilidades, además de calculadora estándar y científica.

## Privacidad y seguridad

UTILIA está diseñada para minimizar la transmisión de datos. No requiere cuenta ni backend propio. Los datos de funcionamiento de la aplicación se mantienen localmente y la aplicación no solicita permisos de acceso a contactos, ubicación, cámara o almacenamiento compartido.

La política de privacidad pública está en `docs/privacy-policy.html`.

La configuración Android deshabilita las copias de seguridad de la aplicación y el tráfico HTTP sin cifrar. Las credenciales de firma de producción nunca se almacenan en el repositorio.

## Calidad y release

La CI valida como mínimo:

- formato Dart;
- `flutter analyze`;
- `flutter test`;
- configuración Android/Google Play;
- `applicationId`, SDK y Java 17;
- ausencia de marcadores de desarrollo y endpoints locales;
- ausencia de patrones conocidos de secretos;
- keystore de producción mediante secretos de CI;
- APK release;
- AAB release;
- firma y certificado de producción;
- alineación de APK a 16 KiB;
- hashes SHA-256 de los artefactos.

Las claves privadas de firma deben permanecer bajo control seguro del propietario y fuera de Git.

## Documentación de publicación

Antes de enviar la aplicación a Google Play deben completarse con datos de la versión final la ficha de tienda, Data Safety, clasificación de contenido, público objetivo, política de privacidad y capturas reales de la aplicación. No se incluyen capturas ficticias en el repositorio.

## Licencia

Código propietario. No se concede licencia de reutilización, modificación o redistribución salvo autorización expresa del titular.
