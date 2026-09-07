# Preparación de UTILIA para Google Play

## Estado técnico

- [x] Android App Bundle (`.aab`) generado por CI
- [x] APK release generado por CI
- [x] Tests y análisis ejecutados en CI
- [x] `versionCode` gestionado desde `pubspec.yaml`
- [ ] Configurar firma de subida definitiva
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

A partir del 31 de agosto de 2026, las nuevas aplicaciones y las actualizaciones de Google Play deben tener como objetivo Android 16 (API 36) o superior. El proyecto CI debe compilar con `compileSdk` y `targetSdk` 36 o superior.

## Firma

La clave de subida no debe almacenarse en el repositorio. Debe mantenerse como secreto. Google Play App Signing debe utilizarse para proteger la clave de firma de la aplicación.

## Privacidad

UTILIA está planteada actualmente sin cuentas, sin analítica, sin publicidad y sin recopilación de datos en servidores propios. La declaración final de Seguridad de los datos debe revisarse siempre contra las bibliotecas y funciones presentes en la versión exacta que se publique.

## Versión

El `versionCode` debe aumentar en cada actualización. No reutilizar un `versionCode` ya publicado en Google Play.
