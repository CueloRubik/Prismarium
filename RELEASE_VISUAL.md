# Prismarium — Ornate UI y sprites

## Cambios visuales

- 12 ilustraciones PNG nuevas para HUD de energía, botín, progreso, jefe, tutorial, avisos, resultados y motivos decorativos (`assets/ui/ornate_*.png`).
- HUD reorganizado en tres secciones ornamentadas para evitar que se mezclen indicadores y botones.
- Barra de jefe con marco ilustrado y retrato de tamaño ajustado.
- Tutorial independiente con panel ilustrado tipo pergamino, manteniendo sus pasos interactivos.
- Estados de victoria/derrota y avisos flotantes con imágenes propias.
- Sellos de jefes, portales, zonas especiales, avisos de ataque y auras ahora muestran sprites en lugar de depender de polígonos simples.
- Se conserva el conjunto de sprites de enemigos específicos de los biomas (8 tipos y variantes de tutorial + 4 mapas), así como las naves, jefes y objetos ilustrados.
- Se corrigió la expresión `-angle or 0` para cristales dorados y se normalizó el tamaño en pantalla de los jefes.
- La fuente RPG suministrada se mantiene integrada mediante `font_helper.lua`.

## Comprobaciones

- 23 archivos Lua analizados sintácticamente.
- 8 suites de pruebas Lua exitosas, mediante ejecución simulada (no es el motor gráfico de LÖVE).
- 210 imágenes PNG/JPG verificadas después de retirar un recurso de tutorial que ya no se utilizaba.

Para probarlo visualmente, abre el archivo `.love` con LÖVE 11.4 o una versión posterior compatible.
