# Prismarium | Revisión visual V4

## Cambios de esta entrega

- Sustituidos los 30 PNG de `assets/entities/player_<id>.png` por ilustraciones distintas; las cartas de `assets/cards/<id>.png` y las miniaturas de `assets/cards/skin_<id>.png` reutilizan la misma ilustración del vehículo correspondiente.
- Eliminadas las referencias a cartas elementales/setes de la pantalla de tienda obsoleta.
- Barra de desplazamiento del álbum y barras estadísticas pasan a utilizar sprites PNG existentes.
- Ajustadas las filas de habilidades secundarias para evitar solapes con instrucciones inferiores.
- Actualizadas las pruebas automatizadas para el modelo de 30 cartas-vehículo, 3 sobres, duplicados y ranuras secundarias.

## Calidad artística y limitaciones

- Los diez primeros vehículos parten de ilustraciones independientes a resolución mayor.
- Los veinte siguientes proceden de iconos ilustrados independientes recortados de una lámina artística; tienen menor detalle y pueden necesitar una segunda ilustración individual a mayor resolución.
- Todos tienen identificadores, colores y siluetas diferentes, pero una revisión artística subjetiva debe realizarse en el juego real antes de considerarlos arte definitivo.
- Los test Lua usan simulaciones de la API gráfica de LÖVE. No sustituyen una partida en LÖVE real ni garantizan ausencia de errores.

## Comprobaciones

Ejecutar desde la raíz del proyecto (con `luatex` disponible):

```bash
for f in tests/*.lua; do luatex --luaonly "$f"; done
```

Abrir el archivo `.love` con LÖVE para validar renderizado, interfaz, efectos y rendimiento.
