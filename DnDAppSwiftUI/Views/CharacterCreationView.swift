import SwiftUI

struct CharacterCreationView: View {
    @Environment(\.dismiss) private var dismiss
    var onSave: (PlayerCharacter) -> Void

    @State private var name = ""
    @State private var race = ""
    @State private var playerClass = ""
    @State private var level = 1
    @State private var background = ""
    @State private var size: CreatureSize = .medium
    @State private var alignment: Alignment = .trueNeutral

    @State private var armorClass = 10
    @State private var armorSource = ""
    @State private var maxHP = 10
    @State private var currentHP = 10
    @State private var hitDice = "1d8"
    @State private var initiative = 0.0
    @State private var proficiencyBonus = 2

    @State private var strength = 10
    @State private var dexterity = 10
    @State private var constitution = 10
    @State private var intelligence = 10
    @State private var wisdom = 10
    @State private var charisma = 10

    @State private var strSave = false
    @State private var dexSave = false
    @State private var conSave = false
    @State private var intSave = false
    @State private var wisSave = false
    @State private var chaSave = false

    @State private var walkSpeed = 30
    @State private var darkvision: Int? = nil
    @State private var passivePerception = 10

    @State private var spellSlots: [SpellSlot] = []
    @State private var languages = ""

    private var abilityScores: AbilityScores {
        AbilityScores(
            strength: strength,
            dexterity: dexterity,
            constitution: constitution,
            intelligence: intelligence,
            wisdom: wisdom,
            charisma: charisma
        )
    }

    private var savingThrows: SavingThrowProficiencies {
        SavingThrowProficiencies(
            strength: strSave,
            dexterity: dexSave,
            constitution: conSave,
            intelligence: intSave,
            wisdom: wisSave,
            charisma: chaSave
        )
    }

    private var speed: MovementSpeed {
        MovementSpeed(walk: walkSpeed)
    }

    private var senses: Senses {
        Senses(darkvision: darkvision, passivePerception: passivePerception)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Identity") {
                    TextField("Name", text: $name)
                    TextField("Race", text: $race)
                    TextField("Class", text: $playerClass)
                    Stepper(value: $level, in: 1...20) {
                        LabeledContent("Level", value: "\(level)")
                    }
                    TextField("Background", text: $background)
                    Picker("Size", selection: $size) {
                        ForEach([CreatureSize.tiny, .small, .medium, .large, .huge, .gargantuan], id: \.self) { s in
                            Text(s.rawValue).tag(s)
                        }
                    }
                    Picker("Alignment", selection: $alignment) {
                        ForEach([
                            Alignment.lawfulGood, .neutralGood, .chaoticGood,
                            .lawfulNeutral, .trueNeutral, .chaoticNeutral,
                            .lawfulEvil, .neutralEvil, .chaoticEvil, .unaligned
                        ], id: \.self) { a in
                            Text(a.rawValue).tag(a)
                        }
                    }
                }

                Section("Combat") {
                    Stepper(value: $maxHP, in: 1...999) {
                        LabeledContent("Max HP", value: "\(maxHP)")
                    }
                    Stepper(value: $currentHP, in: 0...maxHP) {
                        LabeledContent("Current HP", value: "\(currentHP)")
                    }
                    Stepper(value: $armorClass, in: 1...50) {
                        LabeledContent("Armor Class", value: "\(armorClass)")
                    }
                    TextField("Armor Source", text: $armorSource)
                    TextField("Hit Dice", text: $hitDice)
                    HStack {
                        Text("Initiative")
                        Spacer()
                        TextField("Initiative", value: $initiative, format: .number)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                    Stepper(value: $proficiencyBonus, in: 2...10) {
                        LabeledContent("Proficiency Bonus", value: "+\(proficiencyBonus)")
                    }
                }

                Section("Ability Scores") {
                    Stepper(value: $strength, in: 1...30) {
                        LabeledContent("Strength", value: "\(strength)")
                    }
                    Stepper(value: $dexterity, in: 1...30) {
                        LabeledContent("Dexterity", value: "\(dexterity)")
                    }
                    Stepper(value: $constitution, in: 1...30) {
                        LabeledContent("Constitution", value: "\(constitution)")
                    }
                    Stepper(value: $intelligence, in: 1...30) {
                        LabeledContent("Intelligence", value: "\(intelligence)")
                    }
                    Stepper(value: $wisdom, in: 1...30) {
                        LabeledContent("Wisdom", value: "\(wisdom)")
                    }
                    Stepper(value: $charisma, in: 1...30) {
                        LabeledContent("Charisma", value: "\(charisma)")
                    }
                }

                Section("Saving Throw Proficiencies") {
                    Toggle("Strength", isOn: $strSave)
                    Toggle("Dexterity", isOn: $dexSave)
                    Toggle("Constitution", isOn: $conSave)
                    Toggle("Intelligence", isOn: $intSave)
                    Toggle("Wisdom", isOn: $wisSave)
                    Toggle("Charisma", isOn: $chaSave)
                }

                Section("Speed & Senses") {
                    Stepper(value: $walkSpeed, in: 0...120) {
                        LabeledContent("Walk Speed", value: "\(walkSpeed) ft.")
                    }
                    HStack {
                        Text("Darkvision")
                        Spacer()
                        TextField("ft.", value: $darkvision, format: .number)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                    Stepper(value: $passivePerception, in: 1...50) {
                        LabeledContent("Passive Perception", value: "\(passivePerception)")
                    }
                }

                Section("Languages") {
                    TextField("Comma-separated (e.g. Common, Elvish)", text: $languages)
                }

                Section("Spell Slots") {
                    if spellSlots.isEmpty {
                        Text("No spell slots")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(spellSlots.indices, id: \.self) { index in
                            HStack {
                                Text("Level \(spellSlots[index].level)")
                                Spacer()
                                Stepper(value: $spellSlots[index].max, in: 1...20) {
                                    Text("\(spellSlots[index].max)")
                                }
                                .fixedSize()
                            }
                        }
                        .onDelete { indices in
                            spellSlots.remove(atOffsets: indices)
                        }
                    }
                    Button {
                        let nextLevel = (spellSlots.map(\.level).max() ?? 0) + 1
                        spellSlots.append(SpellSlot(level: nextLevel, max: 1, available: 1))
                        spellSlots.sort { $0.level < $1.level }
                    } label: {
                        Label("Add Slot Level", systemImage: "plus")
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle("New Character")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let player = PlayerCharacter(
                            name: name.isEmpty ? "Unnamed" : name,
                            race: race,
                            playerClass: playerClass,
                            level: level,
                            background: background,
                            size: size,
                            alignment: alignment,
                            armorClass: armorClass,
                            armorSource: armorSource,
                            currentHP: currentHP,
                            maxHP: maxHP,
                            hitDice: hitDice,
                            speed: speed,
                            abilityScores: abilityScores,
                            proficiencyBonus: proficiencyBonus,
                            savingThrowProficiencies: savingThrows,
                            skills: [],
                            damageVulnerabilities: [],
                            damageResistances: [],
                            damageImmunities: [],
                            conditionImmunities: [],
                            senses: senses,
                            languages: languages.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) },
                            specialAbilities: [],
                            actions: [],
                            spellSlots: spellSlots,
                            initiative: initiative,
                            status: nil
                        )
                        onSave(player)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
        .frame(minWidth: 480, minHeight: 600)
        .onChange(of: maxHP) { _, newMax in
            currentHP = min(currentHP, newMax)
        }
    }
}
