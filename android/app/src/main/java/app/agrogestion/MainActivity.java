package app.agrogestion;

import android.content.Intent;
import android.net.Uri;
import android.webkit.CookieManager;
import android.webkit.WebView;
import com.getcapacitor.BridgeActivity;

public class MainActivity extends BridgeActivity {

    // Must match server.url in capacitor.config.json and the App Links intent filter.
    private static final String APP_HOST = "agrogestion.app";

    // BridgeActivity also calls this on a cold start, with the launch intent, once the bridge
    // has started loading server.url.
    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        openAppLink(intent);
    }

    // The Better Auth session lives in HttpOnly cookies inside the WebView. Android writes them
    // to disk on its own schedule, so a session started right before the app is closed could
    // otherwise be lost.
    @Override
    public void onPause() {
        super.onPause();
        CookieManager.getInstance().flush();
    }

    // The web application lives at server.url, so an App Link (verification email, password
    // reset, invitation) is opened by loading that same page in the WebView, with the session
    // cookies it already has.
    private void openAppLink(Intent intent) {
        if (intent == null || !Intent.ACTION_VIEW.equals(intent.getAction())) return;
        Uri uri = intent.getData();
        if (uri == null || !"https".equals(uri.getScheme()) || !APP_HOST.equalsIgnoreCase(uri.getHost())) return;
        if (bridge == null) return;

        WebView webView = bridge.getWebView();
        webView.post(() -> webView.loadUrl(uri.toString()));
    }
}
