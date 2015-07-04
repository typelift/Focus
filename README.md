# Focus
Focus is an Optics library for Swift (where Optics includes `Lens`, `Prism`s, and `Iso`s) that is
inspired by Haskell's [Lens](https://github.com/ekmett/lens) library.

#Example

```swift
import struct Focus.Lens
import struct Focus.IxStore

//: A party has a host, who is a user.
final class Party {
    let host : User

    init(h : User) {
        host = h
    }

    class func lpartyHost() -> Lens<Party, Party, User, User> {
        let getter = { (party : Party) -> User in
            party.host
        }

        let setter = { (party : Party, host : User) -> Party in
            Party(h: host)
        }

        return Lens(get: getter, set: setter)
    }
}

//: A Lens for the User's name.
extension User {
    public class func luserName() -> Lens<User, User, String, String> {
        return Lens { user in IxStore(user.name) { User($0, user.age, user.tweets, user.attrs) } }
    }
}

//: Let's throw a party now.
let party = Party(h: User("max", 1, [], Dictionary()))

//: A lens for a party host's name.
let hostnameLens = Party.lpartyHost() • User.luserName()

//: Retrieve our gracious host's name.
let name = hostnameLens.get(party) // "max"

//: Our party seems to be lacking in proper nouns. 
let updatedParty = (Party.lpartyHost() • User.luserName()).set(party, "Max")
let properName = hostnameLens.get(updatedParty) // "Max"
```