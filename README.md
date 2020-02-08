## Gimme the dogs

Simple implementation of the Dog API for finding and displaying images.

This implementation contains a single external dependency: KingFisher. Caching and cache busting is a complicated enough topic that farming this out to a vendor is highly reasonable. Beside this dependency, every other component is built within the Swift language and the UIKit/Foundation frameworks. No Combine, no SwiftUI - just a sample of using core language features together.

Things that are here:
- An initial list of dog breeds is displayed on app launch
- A search box awaits user input; on entry, matching dog breeds are displayed along with sample images

Things that are a bit crusty:
- The DataManager and associated Operations are a bit kludgy, and could use a cleaner abstraction layer. (The DispatchGroup is kinda icky, for example)
- There isn't much of an architecture here; the abstractions are somewhat standalone, as implementing an entirely DI'd, MVVM'd, Tweakable solution is deemed far out of scope
- API Error handling is covered up with default, empty models. Makes the code easier to implement, but of course hides actual errors.

Things that are missing:
- Any test more complicated than 'does the instantiation hierarchy work?'
- Data mocking, UITests
- UI Error states

