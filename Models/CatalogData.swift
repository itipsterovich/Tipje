// Shared catalog for rules, used by both kids and adults.
import SwiftUI

struct CatalogRule: Identifiable, Equatable {
    let id: String
    let title: String
    let peanuts: Int
    let color: Color
}

let rulesCatalog: [CatalogRule] = [
    CatalogRule(id: "rule1", title: "Take off your shoes when you come in 👟 — it's how we care for the space we all share.", peanuts: 3, color: Color(hex: "#D5A412")),
    CatalogRule(id: "rule2", title: "Say 'please' and 'thank you' 🧡 — these little words make people feel seen and valued.", peanuts: 3, color: Color(hex: "#7FAD98")),
    CatalogRule(id: "rule3", title: "Use a calm voice when we're indoors 🤫 — it helps everyone feel peaceful and safe.", peanuts: 3, color: Color(hex: "#ADA57F")),
    CatalogRule(id: "rule4", title: "Wash your hands before eating 🧼🍽️ — your body deserves kindness and care.", peanuts: 3, color: Color(hex: "#D78C28")),
    CatalogRule(id: "rule5", title: "Brush your teeth every morning and night 🪥 — a loving habit for a strong, bright smile.", peanuts: 3, color: Color(hex: "#7F9BAD")),
    CatalogRule(id: "rule6", title: "Knock before entering someone's space 🚪 — we all feel better when our space is respected.", peanuts: 3, color: Color(hex: "#A7AD7F")),
    CatalogRule(id: "rule7", title: "Look into someone's eyes 👀 when they're talking — it shows your heart is listening.", peanuts: 3, color: Color(hex: "#AD807F")),
    CatalogRule(id: "rule8", title: "Put your toys away when you finish playing 🧸 — tidying is a way to say 'thank you' to your things.", peanuts: 3, color: Color(hex: "#D5A412")),
    CatalogRule(id: "rule9", title: "Say 'I'm sorry' 💬 when you hurt someone — it helps hearts feel safe again.", peanuts: 3, color: Color(hex: "#7FAD98")),
    CatalogRule(id: "rule10", title: "Use words when you're upset 😠➡️🗣️ — your feelings matter, and so do others'.", peanuts: 3, color: Color(hex: "#ADA57F")),
    CatalogRule(id: "rule11", title: "Be kind to younger kids 🧒 — they learn how to be from watching you.", peanuts: 3, color: Color(hex: "#D78C28")),
    CatalogRule(id: "rule12", title: "Tell the truth gently 💬✨ — being honest builds trust and closeness.", peanuts: 3, color: Color(hex: "#7F9BAD")),
    CatalogRule(id: "rule13", title: "Respect a 'no' ✋ — yours matters, and so does theirs.", peanuts: 3, color: Color(hex: "#A7AD7F")),
    CatalogRule(id: "rule14", title: "Wait your turn to speak 🗣️⏳ — everyone deserves to be heard.", peanuts: 3, color: Color(hex: "#AD807F")),
    CatalogRule(id: "rule15", title: "Sit with us during meals 🍽️ — it's a special time to feel together.", peanuts: 3, color: Color(hex: "#D5A412")),
    CatalogRule(id: "rule16", title: "Listen the first time someone asks 👂 — it shows you're paying attention.", peanuts: 3, color: Color(hex: "#7FAD98")),
    CatalogRule(id: "rule17", title: "Offer to help carry something heavy 🛍️ — kindness grows in small moments.", peanuts: 3, color: Color(hex: "#ADA57F")),
    CatalogRule(id: "rule18", title: "Hold hands near traffic or crowds ✋🚸 — staying close keeps us safe.", peanuts: 3, color: Color(hex: "#D78C28")),
    CatalogRule(id: "rule19", title: "Move slowly indoors 🚶 — it keeps bodies and feelings safe.", peanuts: 3, color: Color(hex: "#7F9BAD")),
    CatalogRule(id: "rule20", title: "Ask before using something that's not yours 🙋 — sharing feels better when it's offered.", peanuts: 3, color: Color(hex: "#A7AD7F")),
    CatalogRule(id: "rule21", title: "Put dirty clothes in the laundry basket 🧺 — it helps everyone stay on track.", peanuts: 3, color: Color(hex: "#AD807F")),
    CatalogRule(id: "rule22", title: "Say goodbye when you leave 👋 — it shows people they matter.", peanuts: 3, color: Color(hex: "#D5A412")),
    CatalogRule(id: "rule23", title: "Speak gently 🧘 — loud voices can feel too big inside.", peanuts: 3, color: Color(hex: "#7FAD98")),
    CatalogRule(id: "rule24", title: "Eat mindfully and with care 🍲 — slowing down helps your body and your mood.", peanuts: 3, color: Color(hex: "#ADA57F")),
    CatalogRule(id: "rule25", title: "Say 'excuse me' when interrupting 🙇 — it helps conversations stay kind.", peanuts: 3, color: Color(hex: "#D78C28")),
    CatalogRule(id: "rule26", title: "Be gentle with animals 🐶🐱 — they feel comfort, fear, and love too.", peanuts: 3, color: Color(hex: "#7F9BAD")),
    CatalogRule(id: "rule27", title: "Take deep breaths when you're upset 😤➡️🌬️ — your feelings are welcome, and breathing helps.", peanuts: 3, color: Color(hex: "#A7AD7F")),
    CatalogRule(id: "rule28", title: "Keep your backpack tidy 🎒 — so your things feel respected and are easy to find.", peanuts: 3, color: Color(hex: "#AD807F")),
    CatalogRule(id: "rule29", title: "Tell a grown-up if something feels wrong 🚨 — you don't have to hold it alone.", peanuts: 3, color: Color(hex: "#D5A412")),
    CatalogRule(id: "rule30", title: "Say hello to guests 🙋‍♂️ — it helps them feel like they belong.", peanuts: 3, color: Color(hex: "#7FAD98")),
    CatalogRule(id: "rule31", title: "Speak kindly about others 💗 — our words shape how the world feels.", peanuts: 3, color: Color(hex: "#ADA57F")),
    CatalogRule(id: "rule32", title: "Wipe up spills, even small ones 🧽 — it shows you're aware and caring.", peanuts: 3, color: Color(hex: "#D78C28")),
    CatalogRule(id: "rule33", title: "Stay at the table until mealtime is done 🍽️🪑 — being together makes food warmer.", peanuts: 3, color: Color(hex: "#7F9BAD")),
    CatalogRule(id: "rule34", title: "Ask for help when you need it 🙋‍♀️ — it's strong to ask, not weak.", peanuts: 3, color: Color(hex: "#A7AD7F")),
    CatalogRule(id: "rule35", title: "Say how you feel with words ❤️🗣️ — your voice matters.", peanuts: 3, color: Color(hex: "#AD807F")),
    CatalogRule(id: "rule36", title: "Give someone a compliment 🌟 — it can light up their whole day.", peanuts: 3, color: Color(hex: "#D5A412")),
    CatalogRule(id: "rule37", title: "Close doors gently 🚪🤲 — homes feel softer that way.", peanuts: 3, color: Color(hex: "#7FAD98")),
    CatalogRule(id: "rule38", title: "Do your jobs before screen time 📺🧹 — you'll enjoy the fun more afterwards.", peanuts: 3, color: Color(hex: "#ADA57F")),
    CatalogRule(id: "rule39", title: "Wear a helmet when biking 🚴‍♂️🪖 — your head is precious.", peanuts: 3, color: Color(hex: "#D78C28")),
    CatalogRule(id: "rule40", title: "Be curious with food 🥦👀 — a little taste is a brave step.", peanuts: 3, color: Color(hex: "#7F9BAD")),
    CatalogRule(id: "rule41", title: "Wear slippers or indoor shoes if needed 👟🏠 — it's how we care for shared space.", peanuts: 3, color: Color(hex: "#A7AD7F")),
    CatalogRule(id: "rule42", title: "Follow your bedtime routine 🌙🛏️ — your body loves rhythm and rest.", peanuts: 3, color: Color(hex: "#AD807F")),
    CatalogRule(id: "rule43", title: "Let others sleep 😴 — everyone's body needs peace and quiet.", peanuts: 3, color: Color(hex: "#D5A412")),
    CatalogRule(id: "rule44", title: "Let people finish talking 🗣️➡️🤫 — listening is a way of showing love.", peanuts: 3, color: Color(hex: "#7FAD98")),
    CatalogRule(id: "rule45", title: "Wipe your hands with a napkin, not your sleeve 🧻 — your clothes will thank you.", peanuts: 3, color: Color(hex: "#ADA57F")),
    CatalogRule(id: "rule46", title: "Keep your hands to yourself 🙌 — everyone deserves to feel safe.", peanuts: 3, color: Color(hex: "#D78C28")),
    CatalogRule(id: "rule47", title: "Share space and toys with friends 🎁🤝 — it helps everyone feel welcome.", peanuts: 3, color: Color(hex: "#7F9BAD")),
    CatalogRule(id: "rule48", title: "Say 'I love you' often 💞 — it never runs out.", peanuts: 3, color: Color(hex: "#A7AD7F")),
    CatalogRule(id: "rule49", title: "Line up your shoes neatly 👞👞 — small order brings big calm.", peanuts: 3, color: Color(hex: "#AD807F")),
    CatalogRule(id: "rule50", title: "Try again when something is hard 💪 — every try helps you grow.", peanuts: 3, color: Color(hex: "#D5A412")),
]

struct CatalogChore: Identifiable, Equatable {
    let id: String
    let title: String
    let peanuts: Int
    let color: Color
}

let choresCatalog: [CatalogChore] = [
    CatalogChore(id: "chore1", title: "Put away your toys after playing 🧸 — So your space feels calm and safe to move in.", peanuts: 2, color: cardPalette[0]),
    CatalogChore(id: "chore2", title: "Make your bed in the morning 🛏️ — It helps the room feel fresh and ready.", peanuts: 2, color: cardPalette[1]),
    CatalogChore(id: "chore3", title: "Help set the table 🍽️ — So everyone can enjoy mealtime together.", peanuts: 2, color: cardPalette[2]),
    CatalogChore(id: "chore4", title: "Put dirty clothes in the laundry basket 🧺 — That's how they get clean and ready again.", peanuts: 2, color: cardPalette[3]),
    CatalogChore(id: "chore5", title: "Help fold towels 🧻 — So the bathroom feels neat and cozy.", peanuts: 2, color: cardPalette[4]),
    CatalogChore(id: "chore6", title: "Wipe the table after meals 🧼 — It shows care for where we eat.", peanuts: 2, color: cardPalette[5]),
    CatalogChore(id: "chore7", title: "Water the indoor plants 🪴 — They need love and attention just like us.", peanuts: 2, color: cardPalette[6]),
    CatalogChore(id: "chore8", title: "Bring your dish to the sink 🍲 — It's one small way to help clean up.", peanuts: 3, color: cardPalette[0]),
    CatalogChore(id: "chore9", title: "Help match socks 🧦 — So your drawer is easy and tidy.", peanuts: 3, color: cardPalette[1]),
    CatalogChore(id: "chore10", title: "Dust the lower shelves 🧽 — It helps keep the space fresh.", peanuts: 3, color: cardPalette[2]),
    CatalogChore(id: "chore11", title: "Feed the pets with help 🐶 — So they stay full and happy.", peanuts: 3, color: cardPalette[3]),
    CatalogChore(id: "chore12", title: "Sort laundry by color 👕 — It helps clothes stay bright and clean.", peanuts: 3, color: cardPalette[4]),
    CatalogChore(id: "chore13", title: "Clean up crumbs from the floor 🍞 — To keep ants and messes away.", peanuts: 3, color: cardPalette[5]),
    CatalogChore(id: "chore14", title: "Vacuum a small room or spot 🧹 — So the floor feels nice and clean.", peanuts: 3, color: cardPalette[6]),
    CatalogChore(id: "chore15", title: "Put groceries on the shelf 🛒 — Helping hands make it go faster.", peanuts: 3, color: cardPalette[0]),
    CatalogChore(id: "chore16", title: "Hang your towel after a bath 🚿 — So it's dry for the next time.", peanuts: 3, color: cardPalette[1]),
    CatalogChore(id: "chore17", title: "Empty small trash bins 🗑️ — It keeps the room feeling fresh.", peanuts: 3, color: cardPalette[2]),
    CatalogChore(id: "chore18", title: "Unload plastic dishes from the dishwasher 🍽️ — That's teamwork after meals.", peanuts: 3, color: cardPalette[3]),
    CatalogChore(id: "chore19", title: "Line up shoes neatly at the door 👟 — So no one trips and it looks nice.", peanuts: 3, color: cardPalette[4]),
    CatalogChore(id: "chore20", title: "Place books back on the shelf 📚 — So they're ready for next time.", peanuts: 3, color: cardPalette[5]),
    CatalogChore(id: "chore21", title: "Help pack your lunch or snack 🥪 — It teaches independence and choice.", peanuts: 3, color: cardPalette[6]),
    CatalogChore(id: "chore22", title: "Peel veggies with help 🥕 — So dinner is ready faster.", peanuts: 4, color: cardPalette[0]),
    CatalogChore(id: "chore23", title: "Sweep with a kid-sized broom 🧹 — Little hands can make a big difference.", peanuts: 4, color: cardPalette[1]),
    CatalogChore(id: "chore24", title: "Carry light groceries 🛍️ — Because helping feels good.", peanuts: 4, color: cardPalette[2]),
    CatalogChore(id: "chore25", title: "Wipe the bathroom sink 🧼 — It keeps it fresh for the next person.", peanuts: 4, color: cardPalette[3]),
    CatalogChore(id: "chore26", title: "Clean the mirrors with help 🪞 — So we can see ourselves clearly.", peanuts: 4, color: cardPalette[4]),
    CatalogChore(id: "chore27", title: "Pick out and lay clothes for the next day 👕 — It makes the morning smoother.", peanuts: 4, color: cardPalette[5]),
    CatalogChore(id: "chore28", title: "Help rinse dishes at the sink 💧 — That's the first step to clean.", peanuts: 4, color: cardPalette[6]),
    CatalogChore(id: "chore29", title: "Bring in the mail ✉️ — Little jobs build big responsibility.", peanuts: 4, color: cardPalette[0]),
    CatalogChore(id: "chore30", title: "Wash fruit with help 🍎 — So it's ready to enjoy.", peanuts: 4, color: cardPalette[1]),
    CatalogChore(id: "chore31", title: "Organize your bookshelf 📚 — It's easier to find what you love.", peanuts: 4, color: cardPalette[2]),
    CatalogChore(id: "chore32", title: "Line up your boots or shoes 🥾 — A tidy hallway feels better.", peanuts: 4, color: cardPalette[3]),
    CatalogChore(id: "chore33", title: "Check if we need more toilet paper 🧻 — So no one is left without.", peanuts: 4, color: cardPalette[4]),
    CatalogChore(id: "chore34", title: "Take recycling to the bin ♻️ — It's good for the Earth.", peanuts: 4, color: cardPalette[5]),
    CatalogChore(id: "chore35", title: "Clean chair or table legs 🪑 — They like to feel clean too.", peanuts: 4, color: cardPalette[6]),
    CatalogChore(id: "chore36", title: "Help put away craft supplies 🎨 — So they're ready for next time.", peanuts: 4, color: cardPalette[0]),
    CatalogChore(id: "chore37", title: "Zip up your own jacket 🧥 — It keeps you warm and proud.", peanuts: 4, color: cardPalette[1]),
    CatalogChore(id: "chore38", title: "Help carry light bags from the car 🚗 — Every bit of help matters.", peanuts: 4, color: cardPalette[2]),
    CatalogChore(id: "chore39", title: "Check your lunchbox after school 🥪 — So it's ready for tomorrow.", peanuts: 4, color: cardPalette[3]),
    CatalogChore(id: "chore40", title: "Make sure the pet has water 🐾 — They count on you.", peanuts: 4, color: cardPalette[4]),
    CatalogChore(id: "chore41", title: "Brush the pet gently 🐕 — It helps them feel relaxed.", peanuts: 4, color: cardPalette[5]),
    CatalogChore(id: "chore42", title: "Pick up crumbs from the floor 🍪 — So it stays clean and cozy.", peanuts: 4, color: cardPalette[6]),
    CatalogChore(id: "chore43", title: "Fold your pajamas 👘 — It starts and ends the day calmly.", peanuts: 4, color: cardPalette[0]),
    CatalogChore(id: "chore44", title: "Put away clean socks or underwear 🧦 — Little tasks build good habits.", peanuts: 4, color: cardPalette[1]),
    CatalogChore(id: "chore45", title: "Clean light switches or door handles ✋ — They get touched a lot!", peanuts: 4, color: cardPalette[2]),
    CatalogChore(id: "chore46", title: "Tidy up board games 🎲 — So pieces don't get lost.", peanuts: 4, color: cardPalette[3]),
    CatalogChore(id: "chore47", title: "Add something to the donation box 🎁 — Sharing what you don't use helps others.", peanuts: 4, color: cardPalette[4]),
    CatalogChore(id: "chore48", title: "Change pillowcases with help 🛏️ — Fresh pillows feel better.", peanuts: 4, color: cardPalette[5]),
    CatalogChore(id: "chore49", title: "Shake out the door mat 🚪 — So dirt stays outside.", peanuts: 4, color: cardPalette[6]),
    CatalogChore(id: "chore50", title: "Straighten the pillows or blankets 🛋️ — It helps the room feel calm.", peanuts: 4, color: cardPalette[0]),
]

struct CatalogReward: Identifiable, Equatable {
    let id: String
    let title: String
    let peanuts: Int
    let color: Color
}

let rewardsCatalog: [CatalogReward] = [
    CatalogReward(id: "reward1", title: "Pick a song and have a dance party 💃 — Full volume, full joy.", peanuts: 10, color: cardPalette[0]),
    CatalogReward(id: "reward2", title: "Get a sticker sheet or small craft item 🎨 — Fun and creative.", peanuts: 10, color: cardPalette[1]),
    CatalogReward(id: "reward3", title: "Choose a game to play with a parent 🎲 — Your rules, your pick.", peanuts: 10, color: cardPalette[2]),
    CatalogReward(id: "reward4", title: "Help bake something yummy 🍪 — And taste as you go.", peanuts: 10, color: cardPalette[3]),
    CatalogReward(id: "reward5", title: "Choose a movie for family night 🎬 — Everyone watches what you choose.", peanuts: 20, color: cardPalette[4]),
    CatalogReward(id: "reward6", title: "Stay up 15 minutes later 🕰️ — A calm way to end the day.", peanuts: 20, color: cardPalette[5]),
    CatalogReward(id: "reward7", title: "Pick what's for dinner 🍕 — Yes, even pancakes for dinner.", peanuts: 20, color: cardPalette[6]),
    CatalogReward(id: "reward8", title: "Extra ice cream scoop or bakery treat 🍦🧁 — A delicious reward.", peanuts: 20, color: cardPalette[0]),
    CatalogReward(id: "reward9", title: "Choose the weekend walk location 🧭 — Nature or the city, you decide.", peanuts: 20, color: cardPalette[1]),
    CatalogReward(id: "reward10", title: "New magazine or comic book 📖 — Something just for you.", peanuts: 30, color: cardPalette[2]),
    CatalogReward(id: "reward11", title: "Visit the thrift shop for a book or toy 📚🧸 — Pick a treasure.", peanuts: 30, color: cardPalette[3]),
    CatalogReward(id: "reward12", title: "Sleep in the living room (with cozy setup) 🛋️✨ — Adventure at home.", peanuts: 30, color: cardPalette[4]),
    CatalogReward(id: "reward13", title: "Special breakfast of your choice 🥞 — Something fun on a weekend morning.", peanuts: 30, color: cardPalette[5]),
    CatalogReward(id: "reward14", title: "One-on-one time with a parent ❤️ — Choose what you do together.", peanuts: 40, color: cardPalette[6]),
    CatalogReward(id: "reward15", title: "Build a blanket fort together 🏰 — Pillows, lights, and imagination.", peanuts: 40, color: cardPalette[0]),
    CatalogReward(id: "reward16", title: "Hot Wheels car or tiny toy 🚗 — A new thing just for you.", peanuts: 50, color: cardPalette[1]),
    CatalogReward(id: "reward17", title: "New coloring or activity book 🎨🖍️ — Fun that lasts.", peanuts: 50, color: cardPalette[2]),
    CatalogReward(id: "reward18", title: "Trip to a local play café or indoor playground 🛝 — A big day out.", peanuts: 60, color: cardPalette[3]),
    CatalogReward(id: "reward19", title: "Decorate a corner of your room ✨🖼️ — Posters, lights, or a small shelf.", peanuts: 60, color: cardPalette[4]),
    CatalogReward(id: "reward20", title: "Mystery envelope with a surprise or coupon 🎁 — Could be anything!", peanuts: 70, color: cardPalette[5]),
] 