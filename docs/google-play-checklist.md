# Preparación de UTILIA para Google Play

## Estado técnico

- [x] Android App Bundle (`.aab`) generado por CI
- [x] APK release generado por CI
- [x] Tests y análisis ejecutados en CI
- [x] `versionCode` gestionado desde `pubspec.yaml`
- [x] Configuración Gradle preparada para firma de subida mediante secretos de CI
- [ ] Configurar la clave de subida definitiva como secreto
- [ ] Activar Google Play App Signing en la primera publicación
- [ ] Subir el `.aab` firmado a Play Console
- [ ] Completar ficha de Play Store
- [ ] Completar Seguridad de los datos
- [ ] Publicar política de privacidad en una URL pública
- [ ] Completar clasificación de contenido
- [ ] Completar público objetivo y demás declaraciones de Play Console
- [ ] Realizar prueba interna
- [ ] Realizar prueba cerrada si la cuenta personal está sujeta al requisito de 12 testers/14 días
- [ ] Solicitar acceso a producción cuando corresponda

## Requisitos técnicos actuales

El proyecto está configurado para compilar y dirigirse a Android 16 (API 36), con `compileSdk = 36` y `targetSdk = 36`.

## Firma de subida

La clave de subida nunca debe almacenarse en el repositorio. La configuración Gradle acepta estas variables de entorno cuando se ejecute una compilación firmada:

- `UTILIA_KEYSTORE_FILE` — ruta al keystore dentro del runner.
- `UTILIA_KEYSTORE_PASSWORD` — contraseña del keystore.
- `UTILIA_KEY_ALIAS` — alias de la clave.
- `UTILIA_KEY_PASSWORD` — contraseña de la clave.

Sin esas variables, la compilación utiliza la firma de depuración únicamente para validación técnica local/CI. Esto permite seguir ejecutando tests y builds sin exponer secretos, pero ese AAB no debe subirse a producción.

Para la publicación definitiva, debe configurarse Google Play App Signing y una clave de subida protegida mediante los secretos de GitHub Actions o mediante el flujo seguro elegido para Play Console.

## Privacidad

UTILIA está planteada actualmente sin cuentas, sin analítica, sin publicidad y sin recopilación de datos en servidores propios. La declaración final de Seguridad de los datos debe revisarse siempre contra las bibliotecas y funciones presentes en la versión exacta que se publique.

## Versión

El `versionCode` debe aumentar en cada actualización. No reutilizar un `versionCode` ya publicado en Google Play.
