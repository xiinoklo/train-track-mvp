# Pruebas y verificacion

Este documento registra como verificar el MVP en entorno local.

## Requisitos

- Node.js 18 o superior.
- npm.
- Flutter SDK 3.10 o superior.
- MongoDB Atlas o MongoDB local.
- Variables de entorno en `backend/.env`.

## Backend

Instalar dependencias:

```powershell
cd backend
npm ci
```

Verificar sintaxis JavaScript:

```powershell
Get-ChildItem -Recurse -File -Include *.js -Path src | ForEach-Object { node --check $_.FullName }
```

Levantar servidor:

```powershell
npm run dev
```

Probar salud:

```powershell
Invoke-RestMethod http://127.0.0.1:3000/health
```

Resultado esperado:

```json
{
  "status": "ok",
  "app": "TrainTrack API"
}
```

## Frontend

Instalar dependencias:

```powershell
cd app
flutter pub get
```

Analisis estatico:

```powershell
flutter analyze
```

Resultado esperado:

```txt
No issues found!
```

Tests widget:

```powershell
flutter test
```

Resultado esperado:

```txt
All tests passed!
```

Build APK debug:

```powershell
flutter build apk --debug
```

Salida esperada:

```txt
build\app\outputs\flutter-apk\app-debug.apk
```

## Pruebas manuales recomendadas

1. Registro de usuario con email valido.
2. Recepcion y verificacion de codigo OTP.
3. Login con JWT guardado.
4. Completar perfil y username.
5. Registrar bienestar diario.
6. Generar rutina normal, reducida y bloqueada por descanso.
7. Registrar RPE y verificar XP/nivel.
8. Revisar historial de bienestar.
9. Revisar recuperacion muscular por colores.
10. Guardar rutina como usuario avanzado.
11. Entrar como admin y crear/editar/eliminar ejercicios.
12. Revisar estadisticas, accesos y rutinas de usuarios desde panel admin.
13. Activar y desactivar el recordatorio diario desde perfil en Android.
14. Cortar red al guardar bienestar y confirmar que queda en cola local para sincronizar al volver.
15. Crear ejercicio con URL valida de YouTube o Shorts y revisar miniatura/reproductor en rutina.
16. Intentar guardar una URL de video invalida y confirmar que el panel admin la rechaza.
17. Entrar a bienestar desde el dashboard y confirmar que aparece la preparacion de videos antes del formulario.

## Estado validado localmente

Al cierre de esta revision:

- `flutter analyze`: sin issues.
- `flutter test`: tests existentes pasan.
- `flutter build apk --debug`: genera APK debug.
- `node --check` en backend: sin errores de sintaxis.
- `npm audit --audit-level=moderate`: sin vulnerabilidades reportadas.

## Pendientes de QA

- Pruebas backend automatizadas con base de datos de test.
- Prueba end-to-end completa con MongoDB real y correo Brevo.
- Prueba en Android Emulator usando `API_BASE_URL=http://10.0.2.2:3000/api` cuando se quiera apuntar a backend local.
- Prueba en telefono fisico usando el backend de Render por defecto.
- Modo offline completo para generar rutinas sin backend; el MVP actual solo encola bienestar y sincroniza despues.
- Subida binaria de videos; el MVP usa enlaces de YouTube para evitar depender del disco efimero de Render gratis.
