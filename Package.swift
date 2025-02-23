// swift-tools-version: 6.0

// WARNING:
// This file is automatically generated.
// Do not edit it by hand because the contents will be replaced.

import PackageDescription
import AppleProductTypes

let package = Package(
    name: "EchoWare",
    platforms: [
        .iOS("16.0")
    ],
    products: [
        .iOSApplication(
            name: "EchoWare",
            targets: ["AppModule"],
            bundleIdentifier: "com.example.EchoWare",
            teamIdentifier: "38CQNQ2ZCA",
            displayVersion: "1.0",
            bundleVersion: "1",
            appIcon: .placeholder(icon: .boat),
            accentColor: .presetColor(.indigo),
            supportedDeviceFamilies: [
                .pad,
                .phone
            ],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeRight,
                .landscapeLeft,
                .portraitUpsideDown(.when(deviceFamilies: [.pad]))
            ],
            capabilities: [
                .microphone(purposeString: "App need to use microphone as to work")
            ]
        )
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            path: "."
        )
    ],
    swiftLanguageVersions: [.version("6")]
)