// Shared catalog for rules, used by both kids and adults.
import SwiftUI

struct CatalogRule: Identifiable, Equatable {
    var id: String
    var title: String
    var peanuts: Int
    var color: Color
    var colorHex: String? // for Firestore compatibility
    var isCustom: Bool // true for custom rules, false for curated
    // Failable initializer for Firestore
    init?(id: String, data: [String: Any]) {
        guard let title = data["title"] as? String,
              let peanuts = data["peanuts"] as? Int,
              let colorHex = data["color"] as? String else { return nil }
        self.id = id
        self.title = title
        self.peanuts = peanuts
        self.colorHex = colorHex
        self.color = Color(hex: colorHex)
        self.isCustom = true
    }
    // For curated rules
    init(id: String, title: String, peanuts: Int, color: Color, colorHex: String? = nil, isCustom: Bool = false) {
        self.id = id
        self.title = title
        self.peanuts = peanuts
        self.color = color
        self.colorHex = colorHex
        self.isCustom = isCustom
    }
}

let rulesCatalog: [CatalogRule] = [
    CatalogRule(id: "rule1", title: "Take off shoes at the door 👟 so our home stays clean and cozy", peanuts: 2, color: Color(hex: "#D5A412")),
    CatalogRule(id: "rule2", title: "Always ask before going out 🚶‍♂️ so we know you're safe and okay", peanuts: 5, color: Color(hex: "#7FAD98")),
    CatalogRule(id: "rule3", title: "Bring your smartwatch outside ⌚ so we can reach you anytime", peanuts: 4, color: Color(hex: "#ADA57F")),
    CatalogRule(id: "rule4", title: "Speak kindly to others 🧡 because your words can bring comfort", peanuts: 5, color: Color(hex: "#D78C28")),
    CatalogRule(id: "rule5", title: "Knock before entering a room 🚪 so others feel safe and respected", peanuts: 3, color: Color(hex: "#7F9BAD")),
    CatalogRule(id: "rule6", title: "Use a soft voice at home 🏡 so everyone feels peaceful and calm", peanuts: 3, color: Color(hex: "#A7AD7F")),
    CatalogRule(id: "rule7", title: "Say I'm sorry when you hurt 💗 it helps hearts feel safe again", peanuts: 4, color: Color(hex: "#AD807F")),
    CatalogRule(id: "rule8", title: "Respect quiet time 😴 it shows you care about others' rest", peanuts: 3, color: Color(hex: "#D5A412")),
    CatalogRule(id: "rule9", title: "Say please and thank you 🙏 it makes others feel appreciated", peanuts: 3, color: Color(hex: "#7FAD98")),
    CatalogRule(id: "rule10", title: "Tell the truth gently 🫶 so we can trust and feel close to you", peanuts: 5, color: Color(hex: "#ADA57F")),
    CatalogRule(id: "rule11", title: "Hold hands near roads 🚸 so we can stay together and feel safe", peanuts: 5, color: Color(hex: "#D78C28")),
    CatalogRule(id: "rule12", title: "Wait your turn to speak 🗣️ so everyone feels heard and valued", peanuts: 3, color: Color(hex: "#7F9BAD")),
    CatalogRule(id: "rule13", title: "Put toys away after playing 🧸 it keeps your space tidy and clear", peanuts: 2, color: Color(hex: "#A7AD7F")),
    CatalogRule(id: "rule14", title: "Use words when you're upset 😠 so people understand your feelings", peanuts: 4, color: Color(hex: "#AD807F")),
    CatalogRule(id: "rule15", title: "Say hello with kindness 🙋 it makes others feel welcome and seen", peanuts: 3, color: Color(hex: "#D5A412")),
    CatalogRule(id: "rule16", title: "Close doors softly 🚪 it helps our home feel quiet and peaceful", peanuts: 2, color: Color(hex: "#7FAD98")),
    CatalogRule(id: "rule17", title: "Keep hands to yourself ✋ it helps others feel calm and safe", peanuts: 4, color: Color(hex: "#ADA57F")),
    CatalogRule(id: "rule18", title: "Share toys and space 🤝 so everyone can enjoy playing together", peanuts: 3, color: Color(hex: "#D78C28")),
    CatalogRule(id: "rule19", title: "Put clothes in the basket 🧺 so they're ready to be cleaned soon", peanuts: 2, color: Color(hex: "#7F9BAD")),
    CatalogRule(id: "rule20", title: "Say goodbye when leaving 👋 it helps others feel loved and seen", peanuts: 3, color: Color(hex: "#A7AD7F")),
    CatalogRule(id: "rule21", title: "Eat slowly and mindfully 🍽️ so your body can feel full and calm", peanuts: 3, color: Color(hex: "#AD807F")),
    CatalogRule(id: "rule22", title: "Say excuse me when you interrupt 🙇 it shows you care and respect", peanuts: 3, color: Color(hex: "#D5A412")),
    CatalogRule(id: "rule23", title: "Take a deep breath when upset 🌬️ to help your feelings calm down", peanuts: 4, color: Color(hex: "#7FAD98")),
    CatalogRule(id: "rule24", title: "Be gentle with animals 🐾 so they feel safe and loved with you", peanuts: 4, color: Color(hex: "#ADA57F")),
    CatalogRule(id: "rule25", title: "Keep your backpack tidy 🎒 so you can find your things easily", peanuts: 2, color: Color(hex: "#D78C28")),
    CatalogRule(id: "rule26", title: "Tell us when something feels wrong 🚨 so we can help you right away", peanuts: 5, color: Color(hex: "#7F9BAD")),
    CatalogRule(id: "rule27", title: "Give kind compliments 🌟 it helps someone's day feel brighter", peanuts: 3, color: Color(hex: "#A7AD7F")),
    CatalogRule(id: "rule28", title: "Wipe spills when you see them 🧽 it keeps our space nice and clean", peanuts: 2, color: Color(hex: "#AD807F")),
    CatalogRule(id: "rule29", title: "Stay at the table during meals 🍽️ so we enjoy our time together", peanuts: 2, color: Color(hex: "#D5A412")),
    CatalogRule(id: "rule30", title: "Ask for help when you're stuck 🙋 it's okay to need support sometimes", peanuts: 4, color: Color(hex: "#7FAD98")),
    CatalogRule(id: "rule31", title: "Talk about how you feel 💬 so we know what's going on inside", peanuts: 4, color: Color(hex: "#ADA57F")),
    CatalogRule(id: "rule32", title: "Speak kindly about others 💛 it helps everyone feel safe with you", peanuts: 3, color: Color(hex: "#D78C28")),
    CatalogRule(id: "rule33", title: "Wear a helmet when biking 🚴 to protect your strong and smart head", peanuts: 5, color: Color(hex: "#7F9BAD")),
    CatalogRule(id: "rule34", title: "Try a small bite of new food 🥦 it's brave to try something unknown", peanuts: 3, color: Color(hex: "#A7AD7F")),
    CatalogRule(id: "rule35", title: "Follow your bedtime routine 🌙 it helps your body rest and grow", peanuts: 4, color: Color(hex: "#AD807F")),
    CatalogRule(id: "rule36", title: "Let others sleep in peace 😴 it shows care and kindness at night", peanuts: 3, color: Color(hex: "#D5A412")),
    CatalogRule(id: "rule37", title: "Use a napkin not your sleeve 🧻 it helps your clothes stay clean", peanuts: 2, color: Color(hex: "#7FAD98")),
    CatalogRule(id: "rule38", title: "Line up shoes near the door 👟 tidy spaces feel better and safer", peanuts: 2, color: Color(hex: "#ADA57F")),
    CatalogRule(id: "rule39", title: "Finish chores before screen time 📺 fun feels better after helping", peanuts: 3, color: Color(hex: "#D78C28")),
    CatalogRule(id: "rule40", title: "Ask questions when you're curious ❓ it helps your brain grow strong", peanuts: 3, color: Color(hex: "#7F9BAD")),
    CatalogRule(id: "rule41", title: "Offer help when someone needs it 🤝 kindness makes us feel close", peanuts: 3, color: Color(hex: "#A7AD7F")),
    CatalogRule(id: "rule42", title: "Be gentle when others mess up 🧡 grace helps us learn and feel safe", peanuts: 4, color: Color(hex: "#AD807F")),
    CatalogRule(id: "rule43", title: "Use a calm voice in the evening 🌃 it helps everyone rest easier", peanuts: 2, color: Color(hex: "#D5A412")),
    CatalogRule(id: "rule44", title: "Say I love you when you feel it 💞 love makes everyone feel supported", peanuts: 4, color: Color(hex: "#7FAD98")),
    CatalogRule(id: "rule45", title: "Walk instead of running inside 🚶 it helps everyone stay safe", peanuts: 2, color: Color(hex: "#ADA57F")),
    CatalogRule(id: "rule46", title: "Tell us something about your day 🗣️ we love hearing what you think", peanuts: 3, color: Color(hex: "#D78C28")),
    CatalogRule(id: "rule47", title: "Thank the person who cooked 🍲 gratitude makes food taste better", peanuts: 3, color: Color(hex: "#7F9BAD")),
    CatalogRule(id: "rule48", title: "Smile at yourself in the mirror 😊 you deserve kind thoughts too", peanuts: 4, color: Color(hex: "#A7AD7F")),
    CatalogRule(id: "rule49", title: "Try again when it's hard 💪 every try makes you stronger inside", peanuts: 5, color: Color(hex: "#AD807F")),
    CatalogRule(id: "rule50", title: "Let your heart lead with kindness 💗 kindness makes everything better", peanuts: 5, color: Color(hex: "#D5A412")),
]

struct CatalogChore: Identifiable, Equatable {
    var id: String
    var title: String
    var peanuts: Int
    var color: Color
    var colorHex: String? // for Firestore compatibility
    var isCustom: Bool // true for custom chores, false for curated
    // Failable initializer for Firestore
    init?(id: String, data: [String: Any]) {
        guard let title = data["title"] as? String,
              let peanuts = data["peanuts"] as? Int,
              let colorHex = data["color"] as? String else { return nil }
        self.id = id
        self.title = title
        self.peanuts = peanuts
        self.colorHex = colorHex
        self.color = Color(hex: colorHex)
        self.isCustom = true
    }
    // For curated chores
    init(id: String, title: String, peanuts: Int, color: Color, colorHex: String? = nil, isCustom: Bool = false) {
        self.id = id
        self.title = title
        self.peanuts = peanuts
        self.color = color
        self.colorHex = colorHex ?? color.toHexString()
        self.isCustom = isCustom
    }
}

let choresCatalog: [CatalogChore] = [
    CatalogChore(id: "chore1", title: "Put away your toys after playtime 🧸 to keep your space peaceful", peanuts: 1, color: cardPalette[0]),
    CatalogChore(id: "chore2", title: "Make your bed every morning 🛏️ it helps the room feel refreshed", peanuts: 1, color: cardPalette[1]),
    CatalogChore(id: "chore3", title: "Bring your dish to the sink 🍽️ so cleanup is quick and easy", peanuts: 1, color: cardPalette[2]),
    CatalogChore(id: "chore4", title: "Wipe down the table after meals 🧼 to keep it ready and clean", peanuts: 1, color: cardPalette[3]),
    CatalogChore(id: "chore5", title: "Hang your towel after bathing 🚿 so it dries and stays fresh", peanuts: 1, color: cardPalette[4]),
    CatalogChore(id: "chore6", title: "Put your dirty clothes in the basket 🧺 so they can be washed", peanuts: 1, color: cardPalette[5]),
    CatalogChore(id: "chore7", title: "Line up your shoes neatly 👟 so the hallway looks tidy and safe", peanuts: 1, color: cardPalette[6]),
    CatalogChore(id: "chore8", title: "Match up clean socks in pairs 🧦 it helps getting dressed go smooth", peanuts: 1, color: cardPalette[0]),
    CatalogChore(id: "chore9", title: "Pick up crumbs and small trash 🍪 to help keep the floor clean", peanuts: 1, color: cardPalette[1]),
    CatalogChore(id: "chore10", title: "Water a plant gently with help 🌿 they need care to grow strong", peanuts: 1, color: cardPalette[2]),
    CatalogChore(id: "chore11", title: "Fold clean towels or clothes 🧻 it makes shelves look tidy and soft", peanuts: 2, color: cardPalette[3]),
    CatalogChore(id: "chore12", title: "Pack your backpack for school 🎒 so you're ready in the morning", peanuts: 2, color: cardPalette[4]),
    CatalogChore(id: "chore13", title: "Dust the shelves with a soft cloth 🧽 so your room stays fresh", peanuts: 2, color: cardPalette[5]),
    CatalogChore(id: "chore14", title: "Check the toilet paper 🧻 and restock if the roll is almost empty", peanuts: 2, color: cardPalette[6]),
    CatalogChore(id: "chore15", title: "Unload plastic dishes from dishwasher 🍽️ to help with cleanup", peanuts: 2, color: cardPalette[0]),
    CatalogChore(id: "chore16", title: "Wipe the bathroom sink after use 🧼 it keeps it neat for others", peanuts: 2, color: cardPalette[1]),
    CatalogChore(id: "chore17", title: "Lay out your clothes for tomorrow 👕 it makes your morning easier", peanuts: 2, color: cardPalette[2]),
    CatalogChore(id: "chore18", title: "Bring in the mail from the mailbox ✉️ it helps everyone stay updated", peanuts: 2, color: cardPalette[3]),
    CatalogChore(id: "chore19", title: "Peel carrots or help wash veggies 🥕 to help make a tasty meal", peanuts: 2, color: cardPalette[4]),
    CatalogChore(id: "chore20", title: "Rinse dishes at the sink 💧 every bit of help keeps things moving", peanuts: 2, color: cardPalette[5]),
    CatalogChore(id: "chore21", title: "Sweep a small area with your broom 🧹 it helps your space feel fresh", peanuts: 2, color: cardPalette[6]),
    CatalogChore(id: "chore22", title: "Put away your books when done 📚 a tidy shelf is ready to explore", peanuts: 1, color: cardPalette[0]),
    CatalogChore(id: "chore23", title: "Feed the pet with support 🐶 so they feel cared for and full", peanuts: 3, color: cardPalette[1]),
    CatalogChore(id: "chore24", title: "Fill the water bowl for your pet 🐾 clean water helps them stay well", peanuts: 3, color: cardPalette[2]),
    CatalogChore(id: "chore25", title: "Brush your pet gently with care 🐕 they feel calm and cozy with you", peanuts: 3, color: cardPalette[3]),
    CatalogChore(id: "chore26", title: "Vacuum a small space with help 🧹 clean floors feel cozy and soft", peanuts: 3, color: cardPalette[4]),
    CatalogChore(id: "chore27", title: "Put away groceries at home 🛒 helping out makes it quicker for all", peanuts: 2, color: cardPalette[5]),
    CatalogChore(id: "chore28", title: "Wipe door handles or light switches ✋ they like to stay clean too", peanuts: 2, color: cardPalette[6]),
    CatalogChore(id: "chore29", title: "Sort your clean laundry by type 👖 it makes folding go faster", peanuts: 2, color: cardPalette[0]),
    CatalogChore(id: "chore30", title: "Shake out the front door mat 🚪 it keeps dirt outside the house", peanuts: 2, color: cardPalette[1]),
    CatalogChore(id: "chore31", title: "Prepare your snack or lunch 🍎 it helps build independence too", peanuts: 3, color: cardPalette[2]),
    CatalogChore(id: "chore32", title: "Sweep crumbs under the table 🧹 it keeps the floor ready for play", peanuts: 2, color: cardPalette[3]),
    CatalogChore(id: "chore33", title: "Take recycling to the right bin ♻️ it helps the Earth feel better", peanuts: 3, color: cardPalette[4]),
    CatalogChore(id: "chore34", title: "Clean spots on the mirror 🪞 so faces shine bright when we smile", peanuts: 2, color: cardPalette[5]),
    CatalogChore(id: "chore35", title: "Zip your jacket before heading out 🧥 it keeps you warm and ready", peanuts: 1, color: cardPalette[6]),
    CatalogChore(id: "chore36", title: "Help carry a small bag inside 🛍️ teamwork makes things feel easy", peanuts: 2, color: cardPalette[0]),
    CatalogChore(id: "chore37", title: "Check if your lunchbox is empty 🥪 it helps with daily routines", peanuts: 1, color: cardPalette[1]),
    CatalogChore(id: "chore38", title: "Fold your pajamas in the morning 👘 it helps start your day gently", peanuts: 1, color: cardPalette[2]),
    CatalogChore(id: "chore39", title: "Put clean socks in your drawer 🧦 so they're easy to find later", peanuts: 1, color: cardPalette[3]),
    CatalogChore(id: "chore40", title: "Wipe chair or table legs with care 🪑 small tasks show big kindness", peanuts: 2, color: cardPalette[4]),
    CatalogChore(id: "chore41", title: "Tidy up board games after play 🎲 so the next time is ready too", peanuts: 1, color: cardPalette[5]),
    CatalogChore(id: "chore42", title: "Choose a toy to donate this week 🎁 sharing makes hearts feel full", peanuts: 4, color: cardPalette[6]),
    CatalogChore(id: "chore43", title: "Change pillowcases with help 🛏️ fresh pillows help you sleep better", peanuts: 3, color: cardPalette[0]),
    CatalogChore(id: "chore44", title: "Fluff sofa pillows or fold blankets 🛋️ to keep the room cozy and neat", peanuts: 2, color: cardPalette[1]),
    CatalogChore(id: "chore45", title: "Replace an empty soap pump 🧴 it's kind to think of others", peanuts: 2, color: cardPalette[2]),
    CatalogChore(id: "chore46", title: "Help plan a fun dessert or treat 🍨 your ideas can bring sweet joy", peanuts: 4, color: cardPalette[3]),
    CatalogChore(id: "chore47", title: "Decorate cupcakes with sprinkles 🧁 fun baking makes sweet memories", peanuts: 4, color: cardPalette[4]),
    CatalogChore(id: "chore48", title: "Pick up toys left in the hallway 🚗 it helps everyone walk safely", peanuts: 1, color: cardPalette[5]),
    CatalogChore(id: "chore49", title: "Set out napkins or forks for meals 🍴 it makes the table feel complete", peanuts: 3, color: cardPalette[6]),
    CatalogChore(id: "chore50", title: "Light a candle with help 🕯️ it brings a warm feeling to our table", peanuts: 3, color: cardPalette[0]),
]

struct CatalogReward: Identifiable, Equatable {
    var id: String
    var title: String
    var peanuts: Int
    var color: Color
    var colorHex: String? // for Firestore compatibility
    var isCustom: Bool // true for custom rewards, false for curated
    // Failable initializer for Firestore
    init?(id: String, data: [String: Any]) {
        guard let title = data["title"] as? String,
              let peanuts = data["peanuts"] as? Int,
              let colorHex = data["color"] as? String else { return nil }
        self.id = id
        self.title = title
        self.peanuts = peanuts
        self.colorHex = colorHex
        self.color = Color(hex: colorHex)
        self.isCustom = true
    }
    // For curated rewards
    init(id: String, title: String, peanuts: Int, color: Color, colorHex: String? = nil, isCustom: Bool = false) {
        self.id = id
        self.title = title
        self.peanuts = peanuts
        self.color = color
        self.colorHex = colorHex
        self.isCustom = isCustom
    }
}

let rewardsCatalog: [CatalogReward] = [
    CatalogReward(id: "reward1", title: "Extra scoop of your favorite ice cream 🍦", peanuts: 10, color: cardPalette[0]),
    CatalogReward(id: "reward2", title: "Small bag of crunchy chips or popcorn 🍿", peanuts: 10, color: cardPalette[1]),
    CatalogReward(id: "reward3", title: "Pastry or cookie from the bakery 🍪", peanuts: 10, color: cardPalette[2]),
    CatalogReward(id: "reward4", title: "Hot chocolate with whipped cream ☕", peanuts: 10, color: cardPalette[3]),
    CatalogReward(id: "reward5", title: "Surprise sticker or novelty eraser 🎟️", peanuts: 10, color: cardPalette[4]),
    CatalogReward(id: "reward6", title: "Pick a dance song and blast it at home 💃", peanuts: 10, color: cardPalette[5]),
    CatalogReward(id: "reward7", title: "Chips with guac or melted cheese dip 🥑", peanuts: 15, color: cardPalette[6]),
    CatalogReward(id: "reward8", title: "Smoothie or slushy from a shop 🥤", peanuts: 15, color: cardPalette[0]),
    CatalogReward(id: "reward9", title: "Colorful juice box and sweet snack combo 🧃", peanuts: 15, color: cardPalette[1]),
    CatalogReward(id: "reward10", title: "Choose any breakfast meal this weekend 🥞", peanuts: 15, color: cardPalette[2]),
    CatalogReward(id: "reward11", title: "Add fairy lights or wall stickers to your room ✨", peanuts: 15, color: cardPalette[3]),
    CatalogReward(id: "reward12", title: "Choose the movie for family movie night 🎬", peanuts: 20, color: cardPalette[4]),
    CatalogReward(id: "reward13", title: "Stay up 20 extra minutes past bedtime 🕰️", peanuts: 20, color: cardPalette[5]),
    CatalogReward(id: "reward14", title: "30 minutes extra screen time 📱", peanuts: 20, color: cardPalette[6]),
    CatalogReward(id: "reward15", title: "Pick a snack and show for solo chill time 🍿", peanuts: 20, color: cardPalette[0]),
    CatalogReward(id: "reward16", title: "Decorate cupcakes with icing and sprinkles 🧁", peanuts: 20, color: cardPalette[1]),
    CatalogReward(id: "reward17", title: "Buy a favorite treat from the grocery store 🛒", peanuts: 20, color: cardPalette[2]),
    CatalogReward(id: "reward18", title: "Grab a small dessert at the bakery or cafe 🍰", peanuts: 30, color: cardPalette[3]),
    CatalogReward(id: "reward19", title: "Magazine or comic from a newsstand 📖", peanuts: 30, color: cardPalette[4]),
    CatalogReward(id: "reward20", title: "Try a new drink at a café or bubble tea bar 🧋", peanuts: 30, color: cardPalette[5]),
    CatalogReward(id: "reward21", title: "Pick a mystery surprise from a grab bag 🎁", peanuts: 30, color: cardPalette[6]),
    CatalogReward(id: "reward22", title: "Choose new stickers or a tiny collectible 🎨", peanuts: 30, color: cardPalette[0]),
    CatalogReward(id: "reward23", title: "Pick out a small toy or Hot Wheels car 🚗", peanuts: 40, color: cardPalette[1]),
    CatalogReward(id: "reward24", title: "Buy a novelty pen, squishy or trinket ✍️", peanuts: 40, color: cardPalette[2]),
    CatalogReward(id: "reward25", title: "Frozen yogurt with toppings of your choice 🍨", peanuts: 40, color: cardPalette[3]),
    CatalogReward(id: "reward26", title: "Special bakery donut or cake pop 🍩", peanuts: 40, color: cardPalette[4]),
    CatalogReward(id: "reward27", title: "Sticker book or activity pad with theme 🖍️", peanuts: 50, color: cardPalette[5]),
    CatalogReward(id: "reward28", title: "Mini Lego set, fidget toy or pop-it 🧱", peanuts: 50, color: cardPalette[6]),
    CatalogReward(id: "reward29", title: "Small plush or toy figure you love 🧸", peanuts: 50, color: cardPalette[0]),
    CatalogReward(id: "reward30", title: "New book from the bookstore 📚", peanuts: 80, color: cardPalette[1]),
] 