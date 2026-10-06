# UTILIA — Monetización

## Modelo

UTILIA mantiene dos estados:

- **Gratis:** aplicación completa con publicidad.
- **Premium:** compra única de **2,99 €** que elimina los anuncios de forma permanente.

El producto de Google Play utilizado por la aplicación es:

`utilia_premium`

Debe crearse en Play Console como un **producto de compra única no consumible**. Google Play gestiona el cobro y la asociación de la compra con la cuenta del usuario.

## Play Billing

La integración Android queda fijada a **Google Play Billing Library 9.1.0** mediante `com.android.billingclient:billing-ktx:9.1.0`. La versión 9.1.0 fue publicada por Google el 18 de junio de 2026.

La capa Flutter mantiene `in_app_purchase` como interfaz de compra. UTILIA:

- escucha `purchaseStream`;
- consulta `utilia_premium`;
- procesa compras y restauraciones;
- completa las transacciones pendientes;
- activa Premium únicamente para una compra/restauración de ese producto;
- desactiva inmediatamente la publicidad al activar Premium.

## AdMob / UMP

UTILIA utiliza `google_mobile_ads 9.1.0`. Esta versión integra Google Mobile Ads Android 25.4.0 y UMP Android 4.0.0.

El flujo de anuncios es:

1. Solicitar actualización del estado de consentimiento mediante UMP.
2. Mostrar el formulario de consentimiento cuando sea necesario.
3. Consultar `canRequestAds()`.
4. Inicializar Mobile Ads solamente cuando se permita solicitar anuncios.
5. Cargar el banner únicamente si Premium no está activo.
6. Exponer el formulario de opciones de privacidad cuando UMP lo requiera.

Durante desarrollo y pruebas se utilizan identificadores de prueba de Google. Antes de publicar una versión que sirva publicidad real, hay que proporcionar:

- ID de aplicación AdMob para Android mediante la propiedad Gradle `UTILIA_ADMOB_APP_ID`.
- ID de unidad de anuncio banner mediante `--dart-define=UTILIA_ADMOB_ANDROID_BANNER_ID=...`.

Las credenciales privadas no forman parte de este repositorio.

## Comportamiento de Premium

La aplicación muestra el precio devuelto por Google Play cuando el producto está disponible y utiliza **2,99 €** como referencia antes de consultar la tienda.

La compra es no consumible: no se implementa caducidad local ni un sistema de expiración inventado. La titularidad la determina Google Play y la restauración permite recuperar la compra en el mismo ecosistema de tienda.
