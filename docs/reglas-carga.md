# Reglas de carga, recuperacion y progreso

Este documento resume las reglas implementadas en `backend/src/services`.

## Motor de carga

Entrada:

- `sleep`: sueno, 1 a 5.
- `pain`: dolor, 1 a 5.
- `fatigue`: fatiga, 1 a 5.
- `stress`: estres, 1 a 5.
- `mood`: animo, 1 a 5.

Las reglas se leen desde `SystemConfig`.

### Descanso recomendado

Devuelve:

```json
{
  "factor": 0,
  "label": "Descanso recomendado"
}
```

Se activa si:

- `pain >= restThresholds.pain`
- o `fatigue >= restThresholds.fatigue`

Valores por defecto:

- dolor >= 4
- fatiga >= 5

### Sesion reducida

Devuelve:

```json
{
  "factor": 0.5,
  "label": "Sesion reducida"
}
```

Se activa si:

- `sleep <= reducedThresholds.sleep`
- o `stress >= reducedThresholds.stress`
- o `fatigue >= reducedThresholds.fatigue`
- o `mood <= reducedThresholds.mood`

Valores por defecto:

- sueno <= 2
- estres >= 4
- fatiga >= 4
- animo <= 2

### Sesion normal

Devuelve:

```json
{
  "factor": 1,
  "label": "Sesion normal"
}
```

Se usa cuando no se activa descanso ni reduccion.

### Modo seguro

Si falla la lectura de configuracion en MongoDB, el backend devuelve factor `0.5` como fallback preventivo.

## Generacion de ejercicios

Cuando `loadFactor > 0`, el backend busca ejercicios activos y filtra por `targetMuscleGroup`.

Grupos soportados:

- `full_body`
- `tren_superior`
- `tren_inferior`
- grupos especificos como `pecho`, `espalda`, `piernas`, `hombros`, `brazos`, `core`, `biceps`, `triceps`, `gluteos`, `cuadriceps`, `isquios`, `femorales`, `pantorrillas`

Series:

- factor `1`: 4 series.
- factor `0.5`: 2 series.
- factor `0`: sin ejercicios de fuerza.

Cantidad de ejercicios:

- `full_body`: selecciona una rutina balanceada, no todo el catalogo. Usa hasta 6 ejercicios en sesion normal y hasta 4 en sesion reducida.
- `tren_superior` y `tren_inferior`: usan hasta 6 ejercicios en sesion normal y hasta 4 en sesion reducida.
- grupos especificos: usan hasta 4 ejercicios en sesion normal y hasta 3 en sesion reducida.

## Recuperacion muscular

La recuperacion se calcula desde sesiones completadas (`completedAt != null`).

Horas de descanso requeridas segun RPE:

- RPE no registrado o RPE <= 5: 24 horas.
- RPE 6 a 7: 48 horas.
- RPE 8 a 10: 72 horas.

Colores:

- `green`: listo para entrenar.
- `yellow`: aun falta descanso, pero ya paso al menos la mitad del tiempo requerido.
- `red`: requiere descanso.

Para usuarios principiantes, si un musculo objetivo necesita mas de 24 horas de descanso, la API bloquea la sesion y recomienda descanso activo.

## Progreso y XP

Constantes:

- `XP_PER_LEVEL`: 500.
- `MAX_LEVEL`: 9.
- `DAILY_XP_LIMIT`: 40.
- `BEGINNER_MIN_DAYS`: 45.

Nivel inicial por experiencia:

- principiante: nivel 1.
- intermedio: nivel 4.
- avanzado: nivel 7.

Calculo de XP al completar sesion:

1. Suma XP de ejercicios.
2. Aplica multiplicador por carga:
   - factor `1`: 100%.
   - factor `0.5`: 75%.
   - factor `0`: 0%.
3. Agrega bono de 5 XP si RPE esta entre 6 y 8.
4. Limita el primer XP diario a `DAILY_XP_LIMIT`.

Restriccion principiante:

- Aunque el XP alcance niveles superiores, un usuario principiante no sube de nivel 3 hasta tener al menos 45 dias de antiguedad.

Rangos:

- Niveles 1 a 3: Principiante 1-3.
- Niveles 4 a 6: Intermedio 1-3.
- Niveles 7 a 9: Avanzado 1-3.
