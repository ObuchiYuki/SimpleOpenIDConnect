# SimpleOpenIDConnect

en: [English](README.md) | ja: [日本語](README_ja.md)

**SimpleOpenIDConnect** は、[OpenID Connect (OIDC)](https://openid.net/connect/) での認証をシンプルに実装するための Swift パッケージです。以下の機能をサポートしています:

- **PKCE を用いた Authorization Code Flow**  
- 安全な PKCE コード・バリファイアとチャレンジの生成  
- アクセストークン、リフレッシュトークン、ID トークンの取得  
- リフレッシュトークンを用いたトークンの更新  
- 追加のクエリパラメータを含む認可URLの生成

iOS、macOS、watchOS、tvOS に対応しています。

### インストール

#### Swift Package Manager

1. Xcode のメニューで **File** → **Add Packages...** を開きます  
2. `https://github.com/yourusername/SimpleOpenIDConnect.git` を入力してパッケージを追加します  
3. **SimpleOpenIDConnect** を選択してプロジェクトに組み込みます  

手動で **Package.swift** を編集する場合は、依存関係として以下を追加してください:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/SimpleOpenIDConnect.git", from: "1.0.0")
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

### 使い方

1. **ライブラリをインポート**します:

   ```swift
   import SimpleOpenIDConnect
   ```

2. **`OIDCAuthenticator` のインスタンスを作成**します:

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

   - `authorizationBaseURL` は必ず `https` スキームを使用してください。
   - `scopes` には OIDC の標準スコープやカスタムスコープを指定できます。

3. **認可URLを生成**して、ブラウザや WebView などで開きます。追加のパラメータを渡す場合は `extraQueryParams` を利用できます:

   ```swift
   if let authURL = authenticator.buildAuthorizationURL(
       extraQueryParams: ["prompt": "consent"]
   ) {
       // 生成したURLをWebブラウザやWebViewで開く
   }
   ```

4. **リダイレクトコールバックをハンドリング**します (iOS の場合は `SceneDelegate` や `AppDelegate` など)。コールバックで受け取ったURLを `acquireTokens(from:)` に渡してトークンを取得します:

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
               // エラー処理
           }
       }
   }
   ```

5. **リフレッシュトークン** を用いてトークンを更新する場合:

   ```swift
   Task {
       do {
           let tokens = try await authenticator.refreshTokens(refreshToken: existingRefreshToken)
           print("New access token:", tokens.accessToken)
       } catch {
           // エラー処理
       }
   }
   ```

### ライセンス

このライブラリは MIT License のもとで公開されています。詳細は [LICENSE](LICENSE) をご覧ください。