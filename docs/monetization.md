# UTILIA — Monetización

## Modelo

UTILIA mantiene dos estados:

- **Gratis:** aplicación completa con publicidad.
- **Premium:** compra única de **2,99 €** que elimina los anuncios de forma permanente.

El producto de Google Play utilizado por la aplicación es:

`utilia_premium`

Debe crearse en Play Console como un **producto de compra única no consumible**. Google Play gestiona el cobro y la asociación de la compra con la cuenta del usuario.

## Publicidad

La integración utiliza `google_mobile_ads` y el mecanismo de consentimiento de Google para los anuncios.

Durante desarrollo y pruebas se utilizan identificadores de prueba de Google. Antes de publicar una versión que sirva publicidad real, hay que proporcionar:

- ID de aplicación AdMob para Android mediante la propiedad Gradle `UTILIA_ADMOB_APP_ID`.
- ID de unidad de anuncio banner mediante `--dart-define=UTILIA_ADMOB_ANDROID_BANNER_ID=...`.

Las credenciales privadas no forman parte de este repositorio.

## Comportamiento de Premium

La aplicación escucha las actualizaciones de compra de Google Play, reconoce `utilia_premium`, completa transacciones pendientes, restaura compras y desactiva los anuncios cuando Premium está activo.

La pantalla Premium muestra el precio devuelto por Google Play cuando el producto está disponible y utiliza **2,99 €** como referencia antes de consultar la tienda.
