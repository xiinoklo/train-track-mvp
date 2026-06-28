# API TrainTrack MVP

Base local recomendada:

```txt
http://127.0.0.1:3000/api
```

Para Android Emulator, usar:

```txt
http://10.0.2.2:3000/api
```

Las rutas protegidas requieren:

```http
Authorization: Bearer <jwt>
Content-Type: application/json
```

## Salud

`GET /health`

Devuelve estado basico del backend.

## Autenticacion

`POST /api/auth/register`

Crea un usuario no verificado y envia codigo OTP por email.

Body:

```json
{
  "email": "usuario@mail.com",
  "password": "secret123",
  "age": 22,
  "gender": "masculino",
  "experienceLevel": "principiante",
  "mainGoal": "fuerza"
}
```

`POST /api/auth/verify`

Verifica el codigo OTP y devuelve JWT.

```json
{
  "email": "usuario@mail.com",
  "code": "123456"
}
```

`POST /api/auth/login`

Autentica usuario verificado y devuelve JWT, rol e indicador admin.

```json
{
  "email": "usuario@mail.com",
  "password": "secret123"
}
```

## Perfil

`GET /api/profile/me`

Devuelve perfil, progreso, nivel, rango y datos visibles del usuario autenticado.

`PATCH /api/profile/me`

Actualiza `username` y/o `avatar`.

```json
{
  "username": "benja_train",
  "avatar": "avatar2"
}
```

## Bienestar

`POST /api/wellness`

Guarda bienestar diario.

```json
{
  "sleep": 4,
  "pain": 2,
  "fatigue": 3,
  "stress": 2,
  "mood": 4
}
```

`GET /api/wellness`

Devuelve historial de bienestar del usuario autenticado.

## Entrenamientos

`POST /api/workouts/generate`

Genera una sesion segun bienestar, nivel, grupo muscular objetivo y recuperacion.

```json
{
  "sleep": 4,
  "pain": 2,
  "fatigue": 3,
  "stress": 2,
  "mood": 4,
  "targetMuscleGroup": "full_body"
}
```

Respuesta relevante:

- `sessionId`
- `loadFactor`
- `recommendation`
- `exercises`
- `recoveryDetails`
- `canCustomizeWorkout`
- `canSaveCustomRoutine`

`POST /api/workouts/:sessionId/rpe`

Registra RPE final, marca sesion completada y calcula XP.

```json
{
  "rpe": 7,
  "exercises": [
    {
      "exerciseId": "id",
      "name": "Sentadilla",
      "muscleGroup": "piernas",
      "sets": 4,
      "reps": "10-12",
      "weight": "20 kg"
    }
  ]
}
```

## Recuperacion

`GET /api/recovery`

Devuelve estado de recuperacion por grupo muscular, con color, horas restantes, ultimo RPE y fecha de ultimo entrenamiento.

## Ejercicios

`GET /api/exercises`

Devuelve catalogo publico de ejercicios activos.

`GET /api/exercises/admin`

Devuelve catalogo completo para administradores.

`POST /api/exercises`

Crea ejercicio. Requiere admin.

`PUT /api/exercises/:id`

Actualiza ejercicio. Requiere admin.

En creacion y edicion, `videoUrl` es opcional. Si viene informado debe ser una URL valida de YouTube, YouTube Shorts o `youtu.be`.

## Rutinas guardadas

`GET /api/routines`

Lista rutinas guardadas del usuario autenticado.

`POST /api/routines`

Guarda rutina personalizada. Requiere usuario avanzado segun reglas de progreso.

`POST /api/routines/:id/start`

Inicia una rutina guardada y crea una nueva sesion.

`PUT /api/routines/:id`

Actualiza una rutina guardada.

`DELETE /api/routines/:id`

Elimina una rutina guardada.

## Administracion

Todas requieren JWT de usuario con rol `admin`.

- `POST /api/admin/login`
- `GET /api/admin/users`
- `GET /api/admin/stats`
- `GET /api/admin/users/:id/stats`
- `DELETE /api/admin/users/:id`
- `GET /api/admin/users/:id/routines`
- `DELETE /api/admin/routines/:type/:id`
- `GET /api/admin/exercises`
- `POST /api/admin/exercises`
- `PUT /api/admin/exercises/:id`
- `DELETE /api/admin/exercises/:id`

`GET /api/admin/users` devuelve cada usuario con contadores de rutinas y actividad, incluyendo:

- `workoutCount`
- `savedRoutineCount`
- `accessCount`
- `lastAccessAt`
- `lastAccessType`

El backend registra accesos al verificar cuenta, iniciar sesion normal y entrar como admin.
