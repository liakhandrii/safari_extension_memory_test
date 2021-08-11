# Safari Extension Memory Test Project

1. Run the SafariTest target in Safari on a real device
2. Activate the extension
3. Refresh the page to enable the content script
4. It sends a native message to SafariWebExtensionHandler to cause a crash
5. Check the log in Xcode to see how absurd the situation is
