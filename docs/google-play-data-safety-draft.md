# Seguridad de los datos — borrador para Google Play

Este documento es una guía de cumplimentación y debe comprobarse contra el AAB exacto antes de enviarlo a Google Play.

## Situación de la versión actual

Según la documentación y dependencias del proyecto:

- No hay cuentas de usuario de UTILIA.
- No hay backend propio.
- No hay analítica integrada actualmente.
- No hay publicidad integrada actualmente.
- No se prevé recopilar datos personales mediante servidores propios.
- Favoritos, historial, idioma y preferencias se almacenan localmente.
- La función de compartir permite al usuario enviar voluntariamente un resultado a otra aplicación mediante Android.
- La política de privacidad se abre mediante el navegador del dispositivo usando `url_launcher`; esta función no envía datos de los cálculos a un servidor propio.

## Declaración preliminar

La versión actual está planteada como una aplicación que **no recoge datos del usuario fuera del dispositivo mediante servidores propios**. Los favoritos, el historial, el idioma y el modo oscuro permanecen almacenados localmente.

La función de compartir se activa únicamente por una acción explícita del usuario. Las directrices actuales de Seguridad de los datos contemplan una excepción para determinadas transferencias iniciadas por el usuario; la respuesta final debe realizarse en Play Console sobre el AAB exacto.

Antes de enviar el formulario, revisar todas las bibliotecas incluidas en el AAB y cualquier comportamiento real de la aplicación. Si se incorpora publicidad, analítica, autenticación, servicios cloud u otra SDK que recopile o comparta datos, esta declaración debe actualizarse.

## Datos almacenados localmente

El almacenamiento local de preferencias e historial no debe confundirse con una base de datos propia en la nube. La información permanece en el dispositivo y se elimina al borrar los datos de la aplicación o desinstalarla, según corresponda.

## Revisión obligatoria antes de producción

1. Confirmar que el AAB publicado corresponde a la versión descrita aquí.
2. Revisar las dependencias y sus prácticas de datos.
3. Completar el formulario de Seguridad de los datos de Play Console con las respuestas que correspondan a la versión exacta.
4. Repetir la revisión cada vez que se añada una SDK o una función que procese datos.
