# UTILIA — Google Play release checklist

## Estado del proyecto

- Aplicación: `UTILIA`
- Application ID: `com.utilia.app.utilia`
- Versión de lanzamiento prevista: `0.6.0+12`
- `compileSdk`: 36
- `targetSdk`: 36
- Premium: compra única `2,99 €`, producto `utilia_premium`
- Gratis: publicidad mediante Google Mobile Ads con consentimiento
- Política de privacidad: `docs/privacy-policy.html`
- Ficha de Play: `docs/google-play-store-listing.md`
- Data Safety: `docs/google-play-data-safety-draft.md`

## Estado de código

- Premium integrado en la aplicación.
- Restauración de compras integrada.
- Los anuncios se desactivan cuando Premium está activo.
- Borde dorado sutil integrado en la versión Premium.
- Firma release configurada mediante secretos, sin claves privadas en Git.
- CI valida formato, análisis, tests, Android, firma, APK y AAB.

## Antes de publicar la versión Premium

1. Crear en Play Console el producto de compra única no consumible `utilia_premium`.
2. Establecer el precio de lanzamiento en `2,99 €` y comprobar que el producto está activo.
3. Configurar los identificadores reales de AdMob en los secretos de GitHub:
   - `UTILIA_ADMOB_APP_ID`
   - `UTILIA_ADMOB_ANDROID_BANNER_ID`
4. Mantener los identificadores de prueba de Google únicamente para desarrollo/pruebas.
5. Ejecutar CI y exigir resultado correcto.
6. Generar el AAB release firmado.
7. Subir el AAB a una prueba interna de Play Console y comprobar compra/restauración de Premium.
8. Comprobar que una cuenta gratuita muestra publicidad y que una cuenta Premium no muestra publicidad.
9. Comprobar que la compra restaurada mantiene Premium después de reinstalar/iniciar sesión con la misma cuenta de Google Play.
10. Revisar política de privacidad y Data Safety contra el comportamiento real de esta versión.
11. Capturar screenshots reales de la versión final.
12. Completar la ficha de Play y preparar el lanzamiento a producción cuando Google Play lo permita.

## Firma de Android

El proyecto usa:

- `UTILIA_KEYSTORE_FILE`
- `UTILIA_KEYSTORE_PASSWORD`
- `UTILIA_KEY_ALIAS`
- `UTILIA_KEY_PASSWORD`

El keystore y las contraseñas no deben entrar en Git. Si falta cualquier credencial de firma, el build release debe fallar deliberadamente.

## CI

El workflow `.github/workflows/flutter.yml` comprueba:

- Flutter estable fijado.
- Dependencias.
- Formato Dart.
- `flutter analyze`.
- Tests.
- Application ID y configuración Android.
- `compileSdk`, `targetSdk` y Java 17.
- Ausencia de secretos conocidos y marcadores de desarrollo.
- Firma de producción.
- APK release.
- AAB release.
- Verificación de firmas y huellas SHA-256.
- Artefactos de validación.

La rama `release-hardening` contiene además el endurecimiento para impedir que un build de producción utilice los IDs de prueba de AdMob.

## Bloqueadores externos

No dependen del código:

- Configuración de los IDs reales de AdMob en los secretos de GitHub.
- Creación/activación del producto `utilia_premium` en Play Console.
- Screenshots reales de la versión final.
- Formularios de Play Console.
- Finalización del período de prueba cerrada exigido por Google Play.

## Criterio de salida

UTILIA queda lista para subir a producción cuando:

- CI termina correctamente.
- AAB final está firmado y verificado.
- AdMob de producción está configurado.
- `utilia_premium` está activo en Play Console.
- Compra y restauración de Premium están verificadas.
- Anuncios funcionan para usuarios gratuitos y desaparecen para Premium.
- Data Safety y privacidad coinciden con el AAB final.
- Screenshots corresponden exactamente a la versión final.
- Google Play habilita el acceso a producción tras completar la prueba cerrada.
