import Foundation

struct AbilityScores {
    var strength: Int
    var dexterity: Int
    var constitution: Int
    var intelligence: Int
    var wisdom: Int
    var charisma: Int

    func modifier(for score: Int) -> Int { (score - 10) / 2 }
    var strMod: Int { modifier(for: strength) }
    var dexMod: Int { modifier(for: dexterity) }
    var conMod: Int { modifier(for: constitution) }
    var intMod: Int { modifier(for: intelligence) }
    var wisMod: Int { modifier(for: wisdom) }
    var chaMod: Int { modifier(for: charisma) }
}
