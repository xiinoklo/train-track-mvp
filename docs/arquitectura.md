# Arquitectura TrainTrack MVP

TrainTrack esta dividido en dos capas principales: una app Flutter y una API REST en Node.js/Express conectada a MongoDB mediante Mongoose.

## Componentes

- `app/`: cliente Flutter. Contiene pantallas de autenticacion, dashboard, bienestar, historial, recuperacion muscular, entrenamiento, rutinas guardadas, perfil y panel administrador.
- `backend/`: API Express. Expone rutas de autenticacion, perfil, bienestar, rutinas, entrenamientos, recuperacion, ejercicios y administracion.
- `docs/`: documentacion de entrega del MVP.
- MongoDB: almacena usuarios, ejercicios, sesiones de entrenamiento, bienestar diario, rutinas guardadas y configuracion dinamica del motor de carga.

## Flujo principal

1. El usuario se registra en Flutter.
2. El backend crea una cuenta no verificada, genera un codigo OTP y lo envia por Brevo.
3. Al verificar el codigo, el backend emite un JWT de 30 dias.
4. Flutter guarda el token con `shared_preferences` y lo envia en `Authorization: Bearer <token>`.
5. El usuario registra bienestar diario: sueno, dolor, fatiga, estres y animo.
6. La API calcula el factor de carga, revisa recuperacion muscular y genera una sesion.
7. Al finalizar, el usuario registra RPE. La API marca la sesion como completada, calcula XP y actualiza progreso.

## Frontend

La app usa Material 3 y separa la interfaz por pantallas:

- `login_screen.dart`, `register_screen.dart`, `verification_screen.dart`: autenticacion y verificacion.
- `dashboard_screen.dart`: entrada principal, accesos rapidos y estado del usuario.
- `video_preload_screen.dart`: pantalla intermedia que verifica tutoriales y precarga miniaturas antes de abrir bienestar.
- `wellness_form_screen.dart`: formulario de bienestar y generacion de rutina.
- `workout_screen.dart`, `workout_summary_screen.dart`, `workout_blocked_screen.dart`: sesion, registro RPE y resultado.
- `history_screen.dart`: historial de bienestar.
- `recovery_screen.dart`: estado de recuperacion por grupo muscular.
- `saved_routines_screen.dart`: rutinas guardadas.
- `profile_screen.dart`, `username_setup_screen.dart`: perfil, avatar, tema y cierre de sesion.
- `admin_panel_screen.dart`: usuarios, estadisticas, ejercicios y rutinas desde rol admin.

La comunicacion HTTP esta centralizada en `app/lib/services/api_service.dart`.

## Backend

La API carga variables desde `backend/.env`, conecta a MongoDB y registra rutas bajo `/api`.

Rutas principales:

- `/api/auth`: registro, verificacion y login.
- `/api/profile`: perfil del usuario autenticado.
- `/api/wellness`: registro e historial de bienestar.
- `/api/workouts`: generacion de sesiones y registro de RPE.
- `/api/recovery`: recuperacion muscular.
- `/api/exercises`: catalogo de ejercicios.
- `/api/routines`: rutinas guardadas.
- `/api/admin`: panel administrador.

## Seguridad

- Contrasenas hasheadas con `bcryptjs`.
- Tokens JWT con expiracion de 30 dias.
- Middleware `protect` para rutas autenticadas.
- Middleware `requireAdmin` para rutas administrativas.
- `express-rate-limit` en registro y login.
- `express-mongo-sanitize` para reducir riesgo de inyeccion MongoDB.

## Estado actual

El MVP compila y tiene los flujos principales implementados. Incluye recordatorio local diario, cola offline de bienestar para sincronizacion diferida, registro de accesos y tutoriales mediante URL de YouTube. La subida binaria de videos queda fuera del alcance practico de Render gratis, porque el almacenamiento local del servicio no debe usarse como repositorio persistente de archivos.
