//
//  worker.js
//  
//  Cloudflare worker
//
//  Created by Jacob on 6/28/25.
//

eexport default {
    //POST check
    async fetch(request, env, ctx) {
      if (request.method !== 'POST') {
        return new Response('Only POST requests are allowed', { status: 405 });
      }

      // Check API key
      const apiKey = request.headers.get("x-api-key");
      if (apiKey !== env.API_KEY) {
        return new Response('Unauthorized: Invalid API key', { status: 401 });
      }

      // Parse request body
      let phone;
      try {
        const body = await request.json();
        phone = body.phone;
        if (!phone || !/^\d{10}$/.test(phone)) {
          return new Response('Invalid phone number. Must be 10 digits.', { status: 400 });
        }
      } catch (err) {
        return new Response('Invalid JSON payload.', { status: 400 });
      }

      // Prepare Twilio SMS
      const messageBody = 'Join our beta with this TestFlight link: https://testflight.apple.com/join/abc123';
      const payload = new URLSearchParams({
        To: `+1${phone}`,
        From: env.TWILIO_FROM,
        Body: messageBody,
      });

      const auth = btoa(`${env.TWILIO_SID}:${env.TWILIO_AUTH_TOKEN}`);

      // Send SMS via Twilio
      const response = await fetch(
        `https://api.twilio.com/2010-04-01/Accounts/${env.TWILIO_SID}/Messages.json`,
        {
          method: 'POST',
          headers: {
            Authorization: `Basic ${auth}`,
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: payload,
        }
      );

      if (!response.ok) {
        const error = await response.text();
        return new Response(`Failed to send SMS: ${error}`, { status: 500 });
      }

      return new Response('SMS sent successfully!', { status: 200 });
    },
  };
