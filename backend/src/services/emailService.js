const nodemailer = require("nodemailer");

const sendVerificationEmail = async (userEmail, code) => {
  try {
    const transporter = nodemailer.createTransport({
      service: "gmail",
      auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS,
      },
    });

    const mailOptions = {
      from: `"TrainTrack UXLAB" <${process.env.EMAIL_USER}>`,
      to: userEmail,
      subject: "Código de Verificación - TrainTrack",
      html: `
        <div style="font-family: Arial, sans-serif; text-align: center; padding: 20px;">
          <h2>¡Bienvenido a TrainTrack!</h2>
          <p>Para activar tu cuenta, ingresa el siguiente código de 6 dígitos en la aplicación:</p>
          <h1 style="color: #22C55E; letter-spacing: 5px;">${code}</h1>
          <p>Este código <strong>expirará en 10 minutos</strong>. Si no lo usas, tu registro será eliminado.</p>
        </div>
      `,
    };

    await transporter.sendMail(mailOptions);
    console.log(`[+] Correo OTP enviado a ${userEmail}`);
    return true;
  } catch (error) {
    console.error("[ERROR] Fallo al enviar correo:", error);
    return false;
  }
};

module.exports = { sendVerificationEmail };