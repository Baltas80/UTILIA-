# Ficha de Google Play — UTILIA

## Nombre de la aplicación
UTILIA

## Descripción breve
Pequeñas herramientas para cálculos cotidianos, rápidas, claras y útiles.

## Descripción completa
UTILIA reúne herramientas prácticas para resolver cálculos cotidianos desde el móvil, de forma rápida y sencilla.

Incluye 22 herramientas organizadas en categorías:

- Dinero: 6 herramientas — porcentajes, descuentos, IVA, propinas, préstamos e interés compuesto.
- Tiempo: 4 herramientas — edad, diferencia de fechas, horas trabajadas y cuenta atrás.
- Casa: 3 herramientas — superficie, pintura y consumo eléctrico.
- Coche: 2 herramientas — combustible y coste por kilómetro.
- Conversores: 2 herramientas — longitud y peso.
- Salud: 1 herramienta — IMC.
- Estudio: 1 herramienta — media de notas.
- Varios: 3 herramientas — regla de tres, calculadora y calculadora científica.

La versión 0.6.0 incorpora una opción Premium de compra única (`utilia_premium`) y publicidad para usuarios no Premium. La publicidad se prepara mediante Google Mobile Ads después de completar el flujo de consentimiento correspondiente, y se desactiva cuando Premium está activo.

UTILIA está diseñada para que cada cálculo sea directo: introduces los datos, obtienes el resultado y, cuando resulta útil, puedes compartirlo mediante la función de compartir de Android.

### Privacidad por defecto

UTILIA no requiere crear una cuenta. Los cálculos, favoritos, historial y preferencias se procesan o almacenan localmente en el dispositivo y la aplicación no mantiene un servidor propio para guardar estos datos.

La aplicación integra Google Mobile Ads para la publicidad y Google User Messaging Platform (UMP) para gestionar el consentimiento. También integra Google Play Billing para la compra y restauración de Premium.

Los identificadores de publicidad y el comportamiento de consentimiento deben reflejarse exactamente en la declaración de Seguridad de los datos de Google Play correspondiente al AAB que se publique.

UTILIA: pequeñas herramientas, grandes soluciones.

## Monetización

- Premium: compra única no consumible, producto `utilia_premium`.
- Precio de referencia en la aplicación: `2,99 €`; el precio mostrado al usuario debe proceder de Google Play.
- Publicidad: banners de Google Mobile Ads para usuarios que no tienen Premium.
- Consentimiento: UMP antes de solicitar anuncios cuando Google determina que es necesario.
- Restauración: la aplicación solicita la restauración de compras de Google Play al iniciar y permite restaurarla desde la interfaz de Premium.

## Categoría sugerida
Herramientas

## Etiquetas / enfoque
Calculadora, herramientas, utilidades, conversor, porcentajes, descuentos, IVA, propinas, préstamos, fechas, combustible, superficie, peso, longitud, IMC, notas.

## Política de privacidad
URL pública propuesta para Play Console:

https://raw.githubusercontent.com/Baltas80/UTILIA-/master/docs/privacy-policy.html

Debe comprobarse desde una red externa antes de introducirla en Play Console.

## Notas para Play Console
- Versión objetivo de esta ficha: **0.6.0 (versionCode 12)**.
- Aplicación gratuita con funciones Premium opcionales.
- Crear y activar en Play Console el producto de compra única `utilia_premium` antes de publicar una versión que permita compras reales.
- Configurar los identificadores reales de AdMob para producción; los identificadores de prueba solo deben utilizarse durante desarrollo/pruebas.
- Revisar Seguridad de los datos contra el AAB exacto que se vaya a publicar y sus dependencias.
- Verificar compra y restauración de Premium en una prueba interna de Google Play antes del lanzamiento a producción.
- Confirmar que los anuncios se muestran únicamente cuando corresponde y desaparecen al activar Premium.