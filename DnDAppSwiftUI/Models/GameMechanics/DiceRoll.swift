import Foundation

struct DiceRollResult {
    let rollSum: Int
    let modifier: Int
    let total: Int
}

func rollDice(_ expression: String) -> DiceRollResult {
    let trimmed = expression.trimmingCharacters(in: .whitespaces)
    // Parse formats: XdY+Z, XdY-Z, XdY, dY
    let pattern = try! NSRegularExpression(pattern: "^(\\d+)?d(\\d+)(?:\\s*([+-])\\s*(\\d+))?$", options: .caseInsensitive)
    let range = NSRange(trimmed.startIndex..., in: trimmed)
    guard let match = pattern.firstMatch(in: trimmed, options: [], range: range) else {
        return DiceRollResult(rollSum: 0, modifier: 0, total: 0)
    }

    let countStr = match.range(at: 1).location != NSNotFound ? String(trimmed[Range(match.range(at: 1), in: trimmed)!]) : nil
    let dieStr = String(trimmed[Range(match.range(at: 2), in: trimmed)!])
    let opStr = match.range(at: 3).location != NSNotFound ? String(trimmed[Range(match.range(at: 3), in: trimmed)!]) : nil
    let modStr = match.range(at: 4).location != NSNotFound ? String(trimmed[Range(match.range(at: 4), in: trimmed)!]) : nil

    let count = countStr.flatMap { Int($0) } ?? 1
    let die = Int(dieStr) ?? 0
    let modifier = modStr.flatMap { Int($0) } ?? 0
    let signedModifier = opStr == "-" ? -modifier : modifier

    var rollSum = 0
    for _ in 0..<count {
        rollSum += Int.random(in: 1...max(1, die))
    }

    return DiceRollResult(rollSum: rollSum, modifier: signedModifier, total: rollSum + signedModifier)
}
