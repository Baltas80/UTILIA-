# UTILIA — Google Play release checklist

## Estado del proyecto

- Aplicación: `UTILIA`
- Application ID: `com.utilia.app.utilia`
- Versión actual: `0.5.3+9`
- `compileSdk`: 36
- `targetSdk`: 36
- Flutter CI: validación automática de análisis, tests y builds Android
- Política de privacidad: `docs/privacy-policy.html`
- Ficha de Play: `docs/google-play-store-listing.md`
- Data Safety: `docs/google-play-data-safety-draft.md`

## Antes de subir a Play Console

1. Completar la verificación de identidad de la cuenta de desarrollador.
2. Asegurar que el repositorio o la política de privacidad estén disponibles mediante una URL pública HTTPS.
3. Configurar la clave de firma de lanzamiento de forma segura. Nunca subir el keystore ni contraseñas al repositorio.
4. Generar el AAB de lanzamiento firmado con la clave correcta.
5. Ejecutar una prueba interna en Google Play con el AAB firmado.
6. Revisar la aplicación instalada desde Play y comprobar navegación, cálculos, idioma, favoritos, historial, compartir y modo oscuro.
7. Capturar screenshots reales de la aplicación para la ficha de Play.
8. Completar la ficha de tienda usando `docs/google-play-store-listing.md`.
9. Completar Data Safety usando `docs/google-play-data-safety-draft.md` y verificarlo contra el AAB final.
10. Revisar la declaración de permisos y el contenido de la ficha antes de producción.

## Firma de Android

El proyecto admite variables de entorno para una firma de release:

- `UTILIA_KEYSTORE_FILE`
- `UTILIA_KEYSTORE_PASSWORD`
- `UTILIA_KEY_ALIAS`
- `UTILIA_KEY_PASSWORD`

Si estas variables están completas, Gradle usa la configuración `release`. Si no lo están, los builds de CI/locales pueden continuar con la firma de depuración para validación técnica. El AAB destinado a Google Play debe generarse con la clave de lanzamiento adecuada.

## CI

El workflow `.github/workflows/flutter.yml` comprueba:

- Flutter 3.35.7 estable.
- Dependencias.
- Formato Dart sin cambios pendientes.
- `flutter analyze`.
- Tests.
- `compileSdk = 36`.
- `targetSdk = 36`.
- Application ID.
- Build de APK release.
- Build de AAB release.
- Existencia y tamaño no nulo de ambos artefactos.

Los artefactos generados por CI se consideran **artefactos de validación** hasta que se confirme que el AAB está firmado con la clave de lanzamiento destinada a Google Play.

## Bloqueadores externos

Estos pasos no pueden completarse únicamente desde el repositorio:

- Verificación de identidad de Google Play Console.
- Alojamiento público de la política de privacidad.
- Gestión de la clave de firma y credenciales.
- Capturas reales del dispositivo.
- Carga del AAB en Play Console.
- Cuestionarios y formularios de Play Console.

## Criterio de salida

UTILIA se considera preparada para producción cuando:

- el CI termina correctamente;
- el AAB final está firmado correctamente;
- Play Console acepta el AAB en una prueba interna;
- Data Safety coincide con el comportamiento real del AAB;
- la política de privacidad es accesible públicamente;
- la ficha contiene screenshots reales y textos definitivos;
- las pruebas internas no muestran errores funcionales o de interfaz.
