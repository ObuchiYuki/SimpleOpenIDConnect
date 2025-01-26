# SimpleOpenIDConnect

en: [English](README.md) | ja: [日本語](README_ja.md)

![Swift](https://img.shields.io/badge/Swift-6.0-orange) ![Platforms](https://img.shields.io/badge/Platforms-iOS%20%7C%20macOS%20%7C%20watchOS%20%7C%20tvOS-lightgrey) ![License](https://img.shields.io/badge/License-MIT-blue)

**SimpleOpenIDConnect** is a Swift package that simplifies [OpenID Connect (OIDC)](https://openid.net/connect/) authentication by handling:

- **Authorization Code Flow with PKCE**  
- Generating secure PKCE code verifiers and challenges  
- Acquiring access tokens, refresh tokens, and ID tokens  
- Refreshing tokens using a refresh token  
- Building authorization URLs with additional custom query parameters

It is compatible with iOS, macOS, watchOS, and tvOS.

### Installation

#### Swift Package Manager

1. In Xcode, go to **File** → **Add Packages...**  
2. Enter the repository URL: `https://github.com/yourusername/SimpleOpenIDConnect.git`  
3. Choose the **SimpleOpenIDConnect** package and add it to your project.  

Then add this line to your target’s dependencies in your **Package.swift** (if you are using Swift Package Manager manually):

```swift
dependencies: [
    .package(url: "https://github.com/ObuchiYuki/SimpleOpenIDConnect.git", from: "1.0.0")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            .product(name: "SimpleOpenIDConnect", package: "SimpleOpenIDConnect")
        ]
    )
]
```

### Usage

1. **Import the library**:

    ```swift
    import SimpleOpenIDConnect
    ```

2. **Create an instance of `OIDCAuthenticator`**:

    ```swift
    let authenticator = OIDCAuthenticator(
        authorizationBaseURL: URL(string: "https://example.com")!,
        authorizeEndpointPath: "/oauth2/authorize",
        tokenEndpointPath: "/oauth2/token",
        clientID: "your_client_id",
        redirectURI: URL(string: "yourapp://callback")!,
        scopes: ["openid", "profile", "email"]
    )
    ```
   - `authorizationBaseURL` must use the `https` scheme.
   - The `scopes` array can include any valid OIDC or custom scopes.

3. **Build the authorization URL** and open it (for example, with `UIApplication.shared.open(_)` on iOS). Optionally, pass extra query parameters:

    ```swift
    if let authURL = authenticator.buildAuthorizationURL(
        extraQueryParams: ["prompt": "consent"]
    ) {
        // Present or open this URL in a browser or WebView
    }
    ```

4. **Handle the redirect callback** (for instance, in `SceneDelegate` or `AppDelegate` on iOS). Extract the callback URL and pass it to `acquireTokens(from:)`:

    ```swift
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        Task {
            do {
                let tokens = try await authenticator.acquireTokens(from: url)
                print("Access token:", tokens.accessToken)
                print("Refresh token:", tokens.refreshToken ?? "none")
                print("ID token:", tokens.idToken ?? "none")
            } catch {
                // Handle error
            }
        }
    }
    ```

5. **Refresh tokens** when needed:

    ```swift
    Task {
        do {
            let tokens = try await authenticator.refreshTokens(refreshToken: existingRefreshToken)
            print("New access token:", tokens.accessToken)
        } catch {
            // Handle error
        }
    }
    ```

### License

This library is released under the MIT License. See [LICENSE](LICENSE) for details.

