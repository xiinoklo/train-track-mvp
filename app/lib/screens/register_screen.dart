import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'verification_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _ageController = TextEditingController();
  
  String _selectedGender = 'Masculino';
  String _selectedExperience = 'principiante';
  String _selectedGoal = 'Salud y bienestar';
  
  bool _isLoading = false;

  void _doRegister() async {
    final email = _emailController.text.trim();
    final pass = _passwordController.text.trim();
    final ageStr = _ageController.text.trim();

    if (email.isEmpty || pass.isEmpty || ageStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, llena todos los campos')));
      return;
    }

    final age = int.tryParse(ageStr);
    if (age == null || age < 10 || age > 99) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ingresa una edad válida')));
      return;
    }

    setState(() => _isLoading = true);

    bool success = await ApiService.registerUser(
      email: email,
      password: pass,
      age: age,
      gender: _selectedGender,
      experienceLevel: _selectedExperience,
      mainGoal: _selectedGoal,
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      // Reemplazamos el pop por un pushReplacement hacia la verificación
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => VerificationScreen(email: email),
        ),
      );
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error en el registro. El correo podría estar en uso.'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Cuenta'), backgroundColor: const Color(0xFF1E3A8A), foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Datos de Acceso', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
            const SizedBox(height: 12),
            TextField(controller: _emailController, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Contraseña', border: OutlineInputBorder())),
            
            const SizedBox(height: 32),
            const Text('Perfil Físico (Onboarding)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
            const SizedBox(height: 12),
            TextField(controller: _ageController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Edad', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: const InputDecoration(labelText: 'Género', border: OutlineInputBorder()),
              items: ['Masculino', 'Femenino', 'Otro'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
              onChanged: (val) => setState(() => _selectedGender = val!),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedExperience,
              decoration: const InputDecoration(labelText: 'Nivel de Experiencia', border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'principiante', child: Text('Principiante (0-6 meses)')),
                DropdownMenuItem(value: 'intermedio', child: Text('Intermedio (6m - 2 años)')),
                DropdownMenuItem(value: 'avanzado', child: Text('Avanzado (+2 años)')),
              ],
              onChanged: (val) => setState(() => _selectedExperience = val!),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedGoal,
              decoration: const InputDecoration(labelText: 'Objetivo Principal', border: OutlineInputBorder()),
              items: ['Salud y bienestar', 'Pérdida de grasa', 'Aumento de masa muscular', 'Rendimiento deportivo'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
              onChanged: (val) => setState(() => _selectedGoal = val!),
            ),

            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _doRegister,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF22C55E), padding: const EdgeInsets.symmetric(vertical: 16)),
              child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text('FINALIZAR REGISTRO', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}