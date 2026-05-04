// Ya no necesitamos importar 'brevo', usamos el fetch nativo de Node.js

const sendVerificationEmail = async (userEmail, code) => {
  try {
    const response = await fetch('https://api.brevo.com/v3/smtp/email', {
      method: 'POST',
      headers: {
        'accept': 'application/json',
        'api-key': process.env.BREVO_API_KEY, // Render inyectará tu llave aquí
        'content-type': 'application/json'
      },
      body: JSON.stringify({
        // IMPORTANTE: Cambia este correo por el que usaste para registrarte en Brevo
        sender: { name: "TrainTrack MVP", email: "joaquin1troncoso@gmail.com" }, 
        to: [{ email: userEmail }],
        subject: "Código de Verificación - TrainTrack",
        htmlContent: `
          <div style="font-family: Arial, sans-serif; text-align: center; padding: 20px;">
            <h2>¡Bienvenido a TrainTrack!</h2>
            <p>Para activar tu cuenta, ingresa el siguiente código de 6 dígitos en la aplicación:</p>
            <h1 style="color: #22C55E; letter-spacing: 5px;">${code}</h1>
            <p>Este código <strong>expirará en 10 minutos</strong>.</p>
          </div>
        `
      })
    });

    if (!response.ok) {
      const errorData = await response.json();
      console.error("[ERROR] La API de Brevo rechazó la petición:", errorData);
      return false;
    }

    console.log(`[+] Correo OTP enviado a ${userEmail} vía Brevo (Fetch Nativo)`);
    return true;
  } catch (error) {
    console.error("[ERROR] Excepción de red al contactar a Brevo:", error);
    return false;
  }
};

module.exports = { sendVerificationEmail };