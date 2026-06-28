# Modelo de datos

La persistencia usa MongoDB con Mongoose. Todos los modelos principales guardan `createdAt` y `updatedAt` salvo que se indique lo contrario.

## User

Coleccion: `users`

Campos principales:

- `email`: unico, requerido, normalizado a minusculas.
- `password`: hash bcrypt.
- `username`: unico opcional, 3 a 20 caracteres, alfanumerico o `_`.
- `avatar`: avatar seleccionado, por defecto `avatar1`.
- `xp`: experiencia acumulada.
- `lastXpAwardedAt`: fecha del ultimo XP diario entregado.
- `level`: nivel numerico.
- `age`, `gender`, `experienceLevel`, `mainGoal`: datos de perfil deportivo.
- `role`: `user` o `admin`.
- `isVerified`: estado de verificacion por correo.
- `verificationCode`, `expireAt`: codigo temporal OTP y expiracion.

## Exercise

Coleccion: `exercises`

Campos:

- `name`: nombre del ejercicio.
- `level`: `principiante`, `intermedio` o `avanzado`.
- `muscleGroup`: grupo muscular.
- `description`: descripcion corta.
- `instructions`: indicaciones de ejecucion.
- `videoUrl`: enlace opcional a video/tutorial.
- `xp`: puntos otorgados, entre 0 y 100.
- `isActive`: visibilidad en catalogo.

Nota: `videoUrl` se valida como enlace de YouTube, YouTube Shorts o `youtu.be` desde el panel admin. Para el MVP se almacena la URL, no un archivo de video.

## Wellness

Coleccion: `wellness`

Representa un registro de bienestar del usuario.

- `userId`: id del usuario autenticado.
- `sleep`: calidad de sueno, 1 a 5.
- `pain`: dolor, 1 a 5.
- `fatigue`: fatiga, 1 a 5.
- `stress`: estres, 1 a 5.
- `mood`: animo, 1 a 5.

## WorkoutSession

Coleccion: `workoutsessions`

Representa una sesion generada por el motor de carga.

- `userId`: referencia a `User`.
- `targetMuscleGroup`: objetivo elegido, por defecto `full_body`.
- `trainedMuscleGroups`: grupos realmente entrenados.
- `loadFactor`: `0`, `0.5` o `1`.
- `recommendationLabel`: recomendacion textual.
- `exercises`: snapshot de ejercicios usados en la sesion.
- `rpe`: esfuerzo percibido final, 1 a 10.
- `xpAwarded`: XP otorgado al completar.
- `completedAt`: fecha de finalizacion.

## SavedRoutine

Coleccion: `savedroutines`

Rutinas personalizadas guardadas por el usuario.

- `userId`: referencia a `User`.
- `name`: nombre visible, maximo 60 caracteres.
- `exercises`: snapshot editable con ejercicio, grupo muscular, series, repeticiones, peso, video, instrucciones y XP.

## AccessLog

Coleccion: `accesslogs`

Registra accesos relevantes para auditoria basica.

- `userId`: referencia opcional a `User`.
- `email`: correo usado en el acceso.
- `role`: `user` o `admin`.
- `type`: `verification`, `login` o `admin_login`.
- `ip`: direccion IP detectada por Express.
- `userAgent`: agente del cliente.

## SystemConfig

Coleccion: `systemconfigs`

Permite modificar reglas del motor de carga desde base de datos.

- `restThresholds.pain`: dolor que fuerza descanso, por defecto 4.
- `restThresholds.fatigue`: fatiga que fuerza descanso, por defecto 5.
- `reducedThresholds.sleep`: sueno bajo que reduce carga, por defecto 2.
- `reducedThresholds.stress`: estres alto que reduce carga, por defecto 4.
- `reducedThresholds.fatigue`: fatiga moderada que reduce carga, por defecto 4.
- `reducedThresholds.mood`: animo bajo que reduce carga, por defecto 2.

## Relaciones

- `User` 1:N `Wellness`
- `User` 1:N `WorkoutSession`
- `User` 1:N `SavedRoutine`
- `User` 1:N `AccessLog`
- `Exercise` se copia como snapshot dentro de `WorkoutSession` y `SavedRoutine`.
- `SystemConfig` se lee al calcular recomendaciones de carga.
