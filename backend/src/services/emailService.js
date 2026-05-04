const { Resend } = require('resend');

// Inicializas Resend con tu llave
const resend = new Resend(process.env.RESEND_API_KEY);

const sendVerificationEmail = async (userEmail, code) => {
  try {
    const { data, error } = await resend.emails.send({
      from: 'TrainTrack <joquin1troncoso@gmail.com>', // Resend te da este correo de prueba gratis
      to: [userEmail],
      subject: 'Código de Verificación - TrainTrack',
      html: `
        <div style="font-family: Arial, sans-serif; text-align: center; padding: 20px;">
          <h2>¡Bienvenido a TrainTrack!</h2>
          <p>Para activar tu cuenta, ingresa el siguiente código de 6 dígitos en la aplicación:</p>
          <h1 style="color: #22C55E; letter-spacing: 5px;">${code}</h1>
          <p>Este código <strong>expirará en 10 minutos</strong>. Si no lo usas, tu registro será eliminado.</p>
        </div>
      `,
    });

    if (error) {
      console.error("[ERROR] Fallo en la API de Resend:", error);
      return false;
    }

    console.log(`[+] Correo OTP enviado a ${userEmail} vía Resend`);
    return true;
  } catch (error) {
    console.error("[ERROR] Excepción al enviar correo:", error);
    return false;
  }
};

module.exports = { sendVerificationEmail };