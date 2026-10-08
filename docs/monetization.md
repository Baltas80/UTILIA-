# UTILIA — Monetización

## Modelo definitivo

UTILIA ofrece tres opciones:

- **Premium mensual** — suscripción con renovación automática mensual.
- **Premium anual** — suscripción con renovación automática anual.
- **No Ads de por vida** — compra única no consumible que elimina la publicidad permanentemente.

Las tres modalidades eliminan la publicidad mientras el derecho correspondiente esté activo. La compra No Ads no caduca.

### Product IDs

| Producto | Tipo | Product ID |
|---|---|---|
| Premium mensual | Suscripción | `utilia_premium_monthly` |
| Premium anual | Suscripción | `utilia_premium_annual` |
| No Ads de por vida | Compra única no consumible | `utilia_no_ads` |

El antiguo `utilia_premium` se mantiene reconocido exclusivamente para conservar la titularidad de usuarios que hubieran comprado la versión anterior.

## Google Play Console

Crear y configurar:

1. `utilia_premium_monthly` como suscripción con plan de renovación automática mensual.
2. `utilia_premium_annual` como suscripción con plan de renovación automática anual.
3. `utilia_no_ads` como producto de compra única no consumible, inicialmente a **2,99 €**.

Los precios mensual y anual deben definirse en Play Console. La aplicación muestra el precio localizado que devuelve Google Play y no fija importes inventados para las suscripciones.

Las suscripciones se gestionan y cancelan desde Google Play. La aplicación restaura compras al iniciar y mediante el botón **Restaurar compras**.

Para control de producción con precisión sobre vencimientos, cancelaciones, problemas de pago y RTDN, Google recomienda validar las suscripciones en servidor; esta versión no inventa una fecha de expiración local.

## Publicidad

Los banners e intersticiales solo se cargan cuando no hay una modalidad Premium activa y el flujo UMP permite solicitar anuncios.
