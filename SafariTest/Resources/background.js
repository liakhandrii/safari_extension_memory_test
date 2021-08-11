browser.runtime.onMessage.addListener((request, sender, sendResponse) => {
    browser.runtime.sendNativeMessage("ignored", "test", function(response) {
        // This call just serves as a trigger for native code
    });
});

