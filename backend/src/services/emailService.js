const brevo = require('@getbrevo/brevo');

// Configuración del cliente de Brevo
const defaultClient = brevo.ApiClient.instance;
const apiKey = defaultClient.authentications['api-key'];
apiKey.apiKey = process.env.BREVO_API_KEY;

const apiInstance = new brevo.TransactionalEmailsApi();

const sendVerificationEmail = async (userEmail, code) => {
  try {
    const sendSmtpEmail = new brevo.SendSmtpEmail();
    
    // Aquí puedes poner cualquier correo como remitente
    sendSmtpEmail.sender = { name: "TrainTrack MVP", email: "tu_correo_real@gmail.com" }; 
    sendSmtpEmail.to = [{ email: userEmail }];
    sendSmtpEmail.subject = "Código de Verificación - TrainTrack";
    sendSmtpEmail.htmlContent = `
      <div style="font-family: Arial, sans-serif; text-align: center; padding: 20px;">
        <h2>¡Bienvenido a TrainTrack!</h2>
        <p>Para activar tu cuenta, ingresa el siguiente código de 6 dígitos en la aplicación:</p>
        <h1 style="color: #22C55E; letter-spacing: 5px;">${code}</h1>
        <p>Este código <strong>expirará en 10 minutos</strong>.</p>
      </div>
    `;

    await apiInstance.sendTransacEmail(sendSmtpEmail);
    console.log(`[+] Correo OTP enviado a ${userEmail} vía Brevo`);
    return true;
  } catch (error) {
    console.error("[ERROR] Fallo en la API de Brevo:", error);
    return false;
  }
};

module.exports = { sendVerificationEmail };