# AGROGESTION APP (Capacitor)

Contenedor iOS y Android de `https://agrogestion.app`. La app no empaqueta el sitio: el WebView
carga la web en producción (`server.url` en `capacitor.config.json`), así que cada despliegue de
Vercel llega a la app sin publicar una versión nueva. Decisión y alcance: ADR 0038 en
`lacrus/agrogestion` (`docs/adr/0038-mobile-app-capacitor-shell.md`).

## Qué hace la parte nativa

| Tema | Dónde |
| --- | --- |
| Sesión Better Auth (cookies HttpOnly del mismo origen) | Sin cambios; Android las persiste en `MainActivity.onPause` |
| Descargas PDF/Excel → hoja de compartir | Plugins `@capacitor/filesystem` y `@capacitor/share`; los usa `components/native-shell/` de la webapp |
| Universal Links / App Links (verificación de email, reset de contraseña, invitaciones, ingreso) | `ios/App/App/SceneDelegate.swift`, `ios/App/App/App.entitlements`, `android/app/src/main/AndroidManifest.xml`, `MainActivity.java` |
| Sin conexión | `www/error.html` (`server.errorPath`) |
| Enlaces externos (WhatsApp, ARCA) | Capacitor los abre en el navegador del sistema porque su host no está en `allowNavigation` |

## Requisitos

- Node 22 o superior.
- iOS: macOS con Xcode 16+ (usa Swift Package Manager, no CocoaPods).
- Android: Android Studio con SDK 36 y JDK 21.

## Uso

```bash
npm install
npx cap sync          # después de cambiar capacitor.config.json o plugins
npm run open:ios      # abre Xcode
npm run open:android  # abre Android Studio
```

Para probar contra un entorno que no sea producción, cambiar temporalmente `server.url` (por ejemplo
`http://192.168.1.10:3000/ingresar`, con `"cleartext": true` en Android) y no commitearlo.

## Pendiente antes de publicar (supuestos marcados)

- **Bundle ID / package `app.agrogestion`**: supuesto; confirmarlo antes del primer upload, después
  no se puede cambiar.
- **Team ID de Apple**: configurarlo en Xcode (Signing & Capabilities) y en Vercel como
  `MOBILE_IOS_APP_IDS=<TEAMID>.app.agrogestion`.
- **Huellas SHA-256 de Android**: la de Play App Signing (y la del upload key) en
  `MOBILE_ANDROID_CERT_SHA256`, junto con `MOBILE_ANDROID_PACKAGE=app.agrogestion`.
- Íconos y splash: hoy son los de plantilla de Capacitor (`npx @capacitor/assets generate`).
- Política de privacidad, cuenta de prueba para la revisión y, probablemente, una función nativa
  más (push) para la guía 4.2 de App Store.
- Nada de esto se compiló todavía en Xcode ni en Android Studio.
