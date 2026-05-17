# TrainTrack MVP

TrainTrack es una aplicación móvil (Flutter) con un backend (Node.js/Express) diseñada para registrar el bienestar diario, ajustar rutinas de entrenamiento dinámicamente según el estado físico (RPE, fatiga, sueño) y llevar un control del descanso muscular.

## 🛠 Arquitectura Tecnológica

* Frontend: Flutter / Dart
* Backend: Node.js / Express
* Base de Datos: MongoDB (Mongoose)
* Autenticación: JWT (JSON Web Tokens)
* Mailing: Brevo API (para códigos OTP de verificación)

---

## 📋 Requisitos Previos

Asegúrate de tener instalado lo siguiente en tu entorno local:

* Node.js (v18 o superior)
* Flutter SDK (v3.10.0 o superior)
* Emulador de Android/iOS o un dispositivo físico conectado.
* Una cuenta en MongoDB Atlas (o una instancia local de MongoDB).
* Una cuenta en Brevo para el envío de correos.

---

## 🚀 Instalación y Ejecución

El proyecto está dividido en dos directorios principales: `backend` y `app` (frontend). Debes ejecutar ambos para que la aplicación funcione correctamente.

### 1. Configuración del Backend

Abre una terminal y navega a la carpeta del backend:
> cd backend

Instala las dependencias:
> npm install

Crea un archivo `.env` en la raíz de la carpeta `backend` basándote en el siguiente formato:
PORT=3000
MONGO_URI=mongodb+srv://<usuario>:<password>@<cluster>.mongodb.net/?appName=TrainTrackBDD
JWT_SECRET=tu_secreto_super_seguro_y_largo
BREVO_API_KEY=tu_api_key_de_brevo

Levanta el servidor en modo desarrollo:
> npm run dev

El servidor debería indicar que está corriendo en el puerto 3000 y conectado a MongoDB.

### 2. Configuración del Frontend (App Flutter)

Abre una nueva pestaña en tu terminal y navega a la carpeta del frontend:
> cd app

Descarga las dependencias de Flutter:
> flutter pub get

⚠️ IMPORTANTE PARA PRUEBAS LOCALES:
Por defecto, la app está configurada para apuntar al backend en producción (Render). Si deseas probar con tu backend local, debes modificar el archivo `app/lib/services/api_service.dart`.

Cambia esto:
static const String baseUrl = 'https://train-track-mvp.onrender.com/api';

Por esto (si usas el emulador de Android):
static const String baseUrl = 'http://10.0.2.2:3000/api';

Inicia la aplicación en tu emulador o dispositivo:
> flutter run

---

## 🗂 Estructura del Proyecto

### Backend (`/backend`)
* `src/config/`: Conexión a la base de datos y scripts de inicialización.
* `src/controllers/` (Pendiente de refactorizar): Lógica de negocio.
* `src/middleware/`: Protección de rutas con JWT.
* `src/models/`: Esquemas de Mongoose (User, Exercise, WorkoutSession, Wellness, SystemConfig).
* `src/routes/`: Endpoints de la API REST.
* `src/services/`: Lógica pesada, envíos de correo y el motor de cálculo de carga.

### Frontend (`/app`)
* `lib/screens/`: Vistas de la aplicación (Login, Dashboard, Formulario de Bienestar, etc.).
* `lib/services/`: Clientes para consumir la API.
* `lib/utils/`: Funciones de apoyo estáticas (como la versión frontend del motor de carga).