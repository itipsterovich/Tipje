# Latest Updates & Best Practices (2024-07)

## 1. Custom Rules, Chores, and Rewards
- Parents can now create custom rules, chores, and rewards from the catalog modals.
- Custom items use the same color palette and assignment logic as curated items.
- After saving, custom items are immediately available in Admin, Home, and Shop, and are always kept in sync.
- The Save button for custom items is **disabled** unless the title is non-empty and the peanut value/cost is valid (1–9).
- The text input for custom item titles uses a multi-line `TextField` that wraps to fit the card/container, preventing endless single-line overflow.

## 2. Empty State Consistency
- All empty states (Home, Admin, Shop) use the same mascot (`mascot_ticket` or `mascot_empty` as appropriate), with consistent image height and `topPadding: 0` on iPad.
- The mascot and text are always vertically centered in the content area, not anchored to the top.
- Horizontal padding for empty state text is always `.padding(.horizontal, 24)` on iPad, matching Home and Admin.

## 3. Color Consistency
- All color assignments for rules, chores, and rewards (curated and custom) use the same palette and lookup logic:
  ```swift
  (catalog + custom).first { $0.id == item.id }?.color ?? fallback
  ```
- No index-based color assignment is used anywhere in the app.

## 4. Loading State Best Practice
- The custom `TipjeLoadingView` (with animated dots) is shown:
  - On app launch, until Firebase/Auth and onboarding state are ready.
  - After login, during any async onboarding or user state refresh.
  - During any async operation (login, registration, purchase, etc.) where a delay is possible.
- Use a local `@State var isLoading = false` and show `TipjeLoadingView` as a full-screen overlay when true.

## 5. Onboarding & Paywall Flow
- The app is free to download (“Get” button in App Store).
- New users receive a 7-day free trial with full access—no payment or subscription required to start.
- After the trial, users are shown a paywall and can choose between monthly or yearly auto-renewable subscriptions.
- No user is charged or auto-subscribed during the trial; billing only begins after explicit plan selection.

## 6. Device-Specific Layout Policy
- All main app views (Admin, Home, Shop, Main, etc.) have separate SwiftUI view structs for iPhone and iPad.
- The main entry point switches between these based on `horizontalSizeClass`.
- No inline size class checks in the body; all device-specific logic is handled in the appropriate struct.

## 7. Error State UI
- All error and empty states use the shared `ErrorStateView` component for consistency.
- Always provide a clear action for the user to recover (e.g., log in, retry, go to onboarding).

## 8. Git/Release Best Practice
- Always merge feature branches (e.g., `Develop`) into `main` before archiving or releasing.
- Confirm that all changes are present in `main` before submitting to the App Store.

---

# Changelog (2024-07)

- ChoreAdultCard and RewardAdultCard now have the same tap area separation as RuleAdultCard: left (text) area expands/collapses, right (icon/peanut) area archives/adds/removes, in both Admin and Catalog modals.
- RuleKidCard and ChoreKidCard now use the native iOS checkmark.circle.fill SF Symbol for completed state, sized 24x24pt on iPhone and 36x36pt on iPad, with color #799B44 (matching the toast), always at full opacity.
- The debug "Expire Trial" button has been removed from Settings.
- All tap/expand/archive logic for Rules, Chores, and Rewards is now consistent and spec-compliant across Admin and Catalog modals.

---

# Onboarding & Paywall Flow Update (2024-07)

**Important:**
- On every app launch, the root view must check authentication and onboarding state. If the user is not authenticated, all onboarding state flags (userId, didLogin, hasActiveSubscription, etc.) must be reset, and the onboarding flow must be shown. This ensures onboarding is always shown after logout, account deletion, or app relaunch.
- All Firestore and onboarding state calls must be guarded to ensure userId (and kidId, if relevant) are never empty. If an ID is empty, the function should return early and log a warning. This prevents 'Document path cannot be empty' errors and ensures robust onboarding navigation.
- After creating a kid profile, the user must immediately be routed to PIN setup (PinSetupView).
- After setting a PIN, the user must be routed to card setup (AdminView) and must add at least one rule, one chore, and one reward.
- Only after all three tabs have at least one card, the success modal is shown and the admin page is locked with the PIN.
- Only then does the user enter the main app.
- Skipping any of these steps is not allowed. The onboarding state machine and navigation must enforce this sequence strictly.
- **New:** After registration, users receive a 7-day free trial with full access. The paywall (subscription screen) is only shown after the 7-day trial expires and the user is not subscribed.

**Recent Changes:**
- The onboarding flow is now managed by a single, centralized onboarding state machine (`OnboardingStateManager`).
- **Order of onboarding steps is now strictly enforced:**
    1. Intro slides
    2. Login/Registration (LoginView)
    3. 7-day Free Trial (full access, no paywall)
    4. Subscription Paywall (SubscriptionView, only after trial expires)
    5. Kids Profile (KidsProfileView)
    6. PIN Setup (PinSetupView)
    7. Card Setup (AdminView)
    8. Main App/Home
- After the intro slides, the user must log in or register. Only after successful authentication does the 7-day trial start. Only after the trial expires and if the user is not subscribed, the paywall is shown. Only after a successful subscription does the user proceed to kids profile, PIN, and card setup.
- Each onboarding step is only shown if needed, based on flags: `needsKidsProfile`, `needsPinSetup`, `needsCardsSetup`, and `onboardingComplete`.
- The paywall (subscription screen) is shown only after the 7-day trial expires and if required by the product spec.
- Once a step is completed, it is never shown again for that user (even after logout/login), unless the Firestore user profile is deleted.
- All onboarding navigation and state is managed centrally; no ad-hoc checks or navigation logic are allowed elsewhere in the app.
- This approach ensures the onboarding experience is robust, user-friendly, and always matches the product spec.

---

# Tipje App — Unified Standard for Rules, Chores, and Rewards (2024)

## 1. **Catalog-Driven Simplicity**
- All items (Rules, Chores, Rewards) are selected from a fixed, code-defined catalog.
- No custom input, editing, or categories. Parents can only select/deselect items; kids can only complete or redeem.
- Catalog is the single source of truth for display info (title, color, peanut value/cost).

## 2. **UI/UX Standards**

### A. Admin (Adult) Experience
#### AdminView (Rules, Chores, Rewards Tabs)
- Banner: Large colored banner with illustration at the top, white content container with 24pt rounded top corners overlaps the banner by 24pt.
- Header: Fixed at the top of the white container, includes:
  - Title (e.g., "Your mindful home") — 24pt top and horizontal padding.
  - Tabs (Rules, Chores, Rewards) — always visible, never scrolls away.
- List: Scrollable list of active items (Rules, Chores, Rewards).
- Add New: Floating "+" button opens the catalog modal.

#### Catalog Modals (e.g., Add Rules)
- Header: Fixed at the top, includes:
  - Title (e.g., "Rules Catalog") — 8pt top/bottom, 24pt horizontal padding.
  - Close button — right-aligned, same row as title.
- List: Scrollable, vertical list of catalog items.
  - Padding: 24pt horizontal, 24pt top/bottom.
- Card States:
  - Unselected: 20% opacity background, colored text/icons, plus icon.
  - Selected: Full opacity, white text/icons, trash icon.
  - Tap: Toggles selection (adds/removes from active list).

#### RuleAdultCard / ChoreAdultCard / RewardAdultCard
- Layout: Title · Divider · Peanut Value/Cost · Icon (plus/trash)
- States: Unselected (faded, plus), Selected (solid, trash)
- Interaction: Tap to select/deselect in modal; tap to archive in AdminView.

### B. Kid Experience (Home & Shop)
#### HomeView (Rules & Chores)
- Banner: Large colored banner with mascot illustration, balance number, and "peanuts earned" label, all spaced 80pt from the top.
- White container: 24pt rounded top corners, overlaps banner by 24pt.
- Header: Fixed, includes:
  - Title (e.g., "Marsel's Saturday") — 24pt top and horizontal padding.
  - Tabs: "Family Rules" / "Chores" — always visible.
- List: Scrollable, vertical list of active rules/chores.
- Card States (RuleKidCard/ChoreKidCard):
  - Default: Full opacity, colored background.
  - Completed: Only right section (peanut badge and dash) fades to 60% opacity, right section background to 30% opacity, dash to 30% opacity, and shows a colored "icon_complete" (not white). Left section remains 100% opacity.
  - Interaction: Tap to complete (if not done today), tap again to uncomplete (never allows negative balance).
  - Bounce animation on tap.
- Padding: 24pt horizontal for content, 14pt vertical between cards.

#### ShopView (Rewards & Basket)
- Banner: Same as Home, with shop illustration.
- Header: "Reward shop" title, 24pt top and horizontal padding.
- Tabs: "Rewards" / "Basket" — always visible.
- List: Scrollable, vertical list of rewards or basket items.
- RewardKidCard:
  - Default: Full opacity, colored background.
  - In Basket: Faded background (70% opacity).
  - Interaction: Tap to buy (if enough peanuts), disables if not enough.
- BasketCard: Same as RewardKidCard, with "remove" icon.

## 3. **Padding, Spacing, and Visual Details**
- Banner Height: 300pt (Home/Shop/Admin)
- White Container Overlap: 24pt overlap with banner (offset -24)
- Container Corner Radius: 24pt (top left/right)
- Header Padding: 24pt top/horizontal (Home/Admin), 8pt top/bottom + 24pt horizontal (Catalog modals)
- List Padding: 24pt horizontal, 24pt top/bottom (Catalog modals)
- Card Spacing: 14pt vertical between cards
- Card Corner Radius: 20pt
- Icon Sizes: 24pt (peanut, plus, trash), 36pt (icon_complete in completed state)
- Font: Inter Medium, 24pt for headings/cards

## 4. **Backend (Firestore) Structure**
- All data is under `/users/{userId}/kids/{kidId}`.
- Rules, Chores, Rewards are stored as subcollections:
  - `/rules/{ruleId}`: `{ title, peanutValue, isActive, completions: [timestamp], ... }`
  - `/chores/{choreId}`: `{ title, peanutValue, isActive, completions: [timestamp], ... }`
  - `/rewards/{rewardId}`: `{ title, cost, isActive, ... }`
- Only IDs present in the catalog are shown in the UI.
- isActive: true = shown, false = archived.
- Completions: Array of timestamps, one per day completed.
- Balance: Updated atomically with completions/rewards.
- No negative balances allowed.

## 5. **Interaction Summary**
- Adults: Can only select/deselect from the catalog. No editing, no custom input.
- Kids: See only active catalog items. Can complete rules/chores and redeem rewards.
- All UI and backend logic is catalog-driven and consistent.

**This is your single source of truth for Rules, Chores, and Rewards in Tipje.  
If you update the UI or backend, update this doc to match!**

---

# (All previous references to categories, custom input, or editing have been removed for clarity and accuracy.)

## Onboarding Flow (2024-06, Updated)

### **Stage 1: Intro & Account Creation**
- **Purpose:** For new users only. Shows intro slides and login/register screen.
- **When to show:**
  - Only if the user is not authenticated **and** has no Firestore user profile.
  - If the user is authenticated and a Firestore user profile exists, **never show Stage 1 again**.
- **Completion:**
  - Stage 1 is complete as soon as the user is authenticated and a Firestore user profile is created.
  - After this, the user never sees Stage 1 again, even if they log out and back in.

---

### **Stage 2: Sequential Onboarding Checks (After Login)**
After successful authentication and Firestore user profile creation, the app must perform the following checks in order. The user is always routed to the first incomplete step:

1. **Check for Kids:**
   - **Call:** `FirestoreManager.fetchKids(userId: uid)`
   - **If none:** Show KidsProfileView to create at least one kid.
   - **If at least one exists:** Continue.

2. **Check for PIN Code:**
   - **Check:** `user.pinHash != nil`
   - **If not set:** Show PinSetupView to set a PIN.
   - **If set:** Continue.

3. **Check for Cards (Rules, Chores, Rewards):**
   - **Call:** 
     - `FirestoreManager.fetchRules(userId: uid)` (active only)
     - `FirestoreManager.fetchChores(userId: uid)` (active only)
     - `FirestoreManager.fetchRewards(userId: uid)` (active only)
   - **If any tab is empty:** Show the admin view and prompt the user to add at least one card in each tab.
   - **If all have at least one:** Continue.

4. **Success Modal and Admin Lock:**
   - **When:** After at least one card is present in each tab.
   - **Action:** Show the success modal.
   - **After:** Lock the admin page with the PIN.
   - **Implementation Note:** The `adminOnboardingComplete` flag **must** be stored in UserDefaults with a user-specific key (e.g., `adminOnboardingComplete_<userId>`) to ensure correct behavior for multi-user support. All checks for admin lock in the main app must use this user-specific key.

5. **Navigating the User:**
   - **If all steps are complete:** User goes directly to the main home view on future launches.
   - **If any step is missing:** User resumes onboarding at the last incomplete step.

---

### **Best Practice**
- The app must never show the KidsProfileView if at least one kid profile exists.
- The app must never skip onboarding if the user, kid, PIN, or cards are missing.
- All onboarding state and navigation is managed by the onboarding state machine.
- After all onboarding is complete, the user always goes straight to the main app.

---

**If you update onboarding logic, update this section to match!**

## 6. **Kids Profile Editing & Profile Switch (2024-06)**

- **Kids can be edited after onboarding:**
  - In Settings, the "Edit" button in the kids section opens a full-screen modal (identical to onboarding) for editing kids' names, removing, or adding up to 2 kids.
  - Existing kid names are prefilled in the input fields. Editing a name updates it everywhere (including the main tab bar/profile switch).
  - Removing a kid automatically selects the remaining kid as active.
  - The button remains "Next" for both onboarding and editing.

- **Profile switch in main tab bar:**
  - If there are 2 kids, a round profile button appears on the right of the main tab bar.
  - The button uses Template1 for the first kid and Template2 for the second, based on their order in the kids array.
  - Tapping the button switches the active kid, updates the UI, and shows a modal: "You've switched to [Kid's Name]" with the correct template image.
  - The profile button matches the style and spacing of other tab bar buttons (same padding, size, and background).
  - If a kid is deleted, the profile button and selection update immediately.

- **PIN protection:**
  - The PIN is global for the parent and works for both profiles.
  - Switching kids does not affect PIN logic; admin access is always protected by the same PIN.

### Update (2024-06):
- The white background panel/safe area has been **removed** from all main content views (Home, Shop, Settings, Debug, etc.) for a unified look. The only backgrounds are banners and cards. The MainTabBar now always floats above the content, never pushed by it.

---

# Device-Specific Layout Policy (2024-06)

**All onboarding and layout changes (such as mascot offset, font size, scaling, and similar visual tweaks) must be applied conditionally:**

- **iPhone (compact size class):**
  - Apply adaptive changes (e.g., mascot offset, font scaling, padding adjustments) to improve usability and fit.
- **iPad (regular size class):**
  - Always retain the original layout, sizing, and visual design as specified in the initial iPad implementation.
  - No mascot offset, font size, or spacing changes should affect iPad views unless explicitly approved for both platforms.

**This rule is mandatory for all onboarding, admin, settings, and main app views.**

If you update any layout or visual logic, you must ensure iPad and iPhone are handled separately and update this doc to match.

## Handling Missing User Profile (2024-06)

- On app launch, if `Auth.auth().currentUser` is set but the Firestore user profile does not exist (e.g., the account was deleted from Firebase console or backend), the app must:
    - Reset onboarding state (set `didCompleteOnboarding` to false and onboarding step to `.slides` or first step).
    - Route the user to the beginning of onboarding (intro slides).
    - This ensures users who are signed in but have no profile are not stuck and can re-onboard cleanly.
- This logic should be implemented in the onboarding state check (see `OnboardingStateManager.swift`).
- If the user is not logged in (`Auth.auth().currentUser` is nil), show the login screen as usual.

## User and Kid Profile Definitions & Onboarding Logic (2024-06)

### Definitions

- **User Profile (Parent):**
  - The main account, authenticated via email/password or Google.
  - Stored in Firestore at `/users/{userId}`.
  - Contains parent info (email, displayName, etc.).

- **Kid Profile (Sub-user):**
  - Each kid is a sub-document: `/users/{userId}/kids/{kidId}`.
  - Contains the kid's name and other kid-specific data.
  - A parent can have up to 2 kid profiles.

### Onboarding and App Entry Logic

1. **On App Launch:**
    - If not logged in, show the login screen.
    - If logged in, check if the user profile exists in Firestore:
        - If not, start onboarding from the beginning (intro slides).
    - If user profile exists, check for kid profiles:
        - If none, show KidsProfileView to create a kid profile.
        - If at least one exists, proceed to the main app (Home/Admin).

2. **After Google Auth or Email Registration:**
    - If the user is new, create the user profile and start onboarding.
    - After login, always check for kid profiles:
        - If none, show KidsProfileView.
        - If at least one exists, skip KidsProfileView and go to the main app.

3. **If User Profile is Deleted or Missing:**
    - If the user is logged in but their Firestore user profile is missing, reset onboarding and start from the beginning.

### Best Practice

- The app must never show the KidsProfileView (profile page) if at least one kid profile exists.
- The app must never skip onboarding if the user or kid profile is missing.
- All onboarding state and navigation is managed by the onboarding state machine.

## 7. **Error State UI Standard (2024-06)**

### ErrorStateView Component
- All error states in the app must use the reusable `ErrorStateView` SwiftUI component for consistency.
- **Parameters:**
  - `headline` (String): Main message, e.g., "Welcome back!"
  - `bodyText` (String): Supporting message, e.g., "It looks like you were logged out. Please log in again to continue your journey with Tipje."
  - `buttonTitle` (String): Button label, e.g., "Log In"
  - `onButtonTap` (closure): Action to perform when the button is tapped (e.g., trigger login or onboarding flow)
  - `imageName` (String?): Optional asset name for an illustration (e.g., "mascot_empty_chores")
- **Styling:**
  - **Background:** Always white (`Color.white.ignoresSafeArea()`)
  - **Headline:** Inter-Regular_SemiBold, 32pt, #494646, center-aligned
  - **Body:** Inter-Regular_Medium, 20pt, #494646 at 0.5 opacity, center-aligned
  - **Button:** Uses `ButtonText` with primary variant, 24pt
  - **Image:** If provided, shown above the text, 180pt height, scaled to fit
- **Device-Specific Layout:**
  - iPhone (compact): All spacing, font sizes, and mascot scaling as above
  - iPad (regular): Use the same layout, font sizes, and mascot scaling as iPhone for error states (no iPad-specific overrides unless specified)
- **Usage Policy:**
  - Use `ErrorStateView` for all error, empty, or missing state screens (e.g., missing user, missing kid profile, network errors, etc.)
  - Never use ad-hoc or inline error UI; always use the shared component for consistency
  - Always provide a clear action for the user to recover (e.g., log in, retry, go to onboarding)

# Device-Specific View Struct Policy (2024-06)

**New Mandatory Policy:**

All main app views (including but not limited to `AdminView`, `ShopView`, `HomeView`, `MainView`, etc.) must have **separate SwiftUI view structs for iPhone (compact size class) and iPad (regular size class)**. This is already the standard in the Onboarding flow and must be followed everywhere else in the app.

- Each file must contain two clearly named view structs, e.g.:
  - `AdminViewiPhone` and `AdminViewiPad`
  - `ShopViewiPhone` and `ShopViewiPad`
  - `HomeViewiPhone` and `HomeViewiPad`
  - `MainViewiPhone` and `MainViewiPad`
- The main entry point (e.g., `AdminView`) should switch between these based on `horizontalSizeClass` or device type.
- **Add comments** at the top of each struct indicating "// iPhone layout" or "// iPad layout".
- All device-specific layout, font, spacing, and visual logic must be handled in the appropriate struct, not with inline `if horizontalSizeClass == .compact` checks.
- This policy is **mandatory** for all new and refactored code.
- Failing to follow this policy can break the app's layout and user experience, especially as device requirements diverge.

**Example:**
```swift
struct ShopView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    var body: some View {
        if horizontalSizeClass == .compact {
            ShopViewiPhone()
        } else {
            ShopViewiPad()
        }
    }
}

// iPhone layout
struct ShopViewiPhone: View { ... }

// iPad layout
struct ShopViewiPad: View { ... }
```

**This rule applies to:**
- AdminView
- ShopView
- HomeView
- MainView
- Any other main app view

**Onboarding already follows this pattern. All other areas must be updated to match.**

---

# Subscription Screen (2024-06)

## Device-Specific Layout & Struct Policy
- The subscription screen uses a main `SubscriptionView` entry point that switches between iPhone and iPad layouts using `@Environment(\.horizontalSizeClass)`.
- Two separate SwiftUI view structs are defined:
  - `SubscriptionViewiPhone` for compact size class (iPhone)
  - `SubscriptionViewiPad` for regular size class (iPad)
- All device-specific layout, font, and spacing logic is handled in the appropriate struct, with no inline size class checks in the body. This matches the mandatory device-specific struct policy for all main app views.

## Layout & UI Logic
- **Banner:**
  - Large colored background with mascot illustration (`il_admin`), scaled and offset per device.
- **Headline:**
  - Motivational headline at the top (e.g., "Raise Confident Kids. Build a Calm, Connected Home.")
  - Font size and padding are larger on iPad.
- **Feature List:**
  - Bullet list of app features (e.g., Mindful Parenting, Evidence-Based, etc.), styled and spaced per device.
- **Plan Cards:**
  - Two selectable cards: Monthly and Yearly.
  - Each card shows the plan name and a placeholder for the localized price (future: replace with actual price from StoreKit).
  - Selection is managed with a local `@State` property (`selectedPlan`).
  - Tapping a card updates the selection.
  - iPhone: Plan cards are stacked vertically with spacing.
  - iPad: Plan cards are arranged horizontally with spacing.
- **Start Trial Button:**
  - Large, primary button labeled "Start your free trial".
  - Calls the `onPlanSelected` closure with the selected plan when tapped.
- **Legal/Disclaimer Text:**
  - Below the button, a disclaimer explains the 7-day free trial, auto-renewal, and cancellation policy.
  - Styled with smaller font and reduced opacity.

## Logic & Flow
- The user selects a plan (monthly or yearly) by tapping a card.
- Tapping the "Start your free trial" button triggers the provided `onPlanSelected` closure with the current selection.
- The actual purchase logic and StoreKit integration are handled outside this view (not shown here).
- The plan card price currently displays a placeholder ("Localized price"); this should be replaced with the actual localized price when StoreKit products are loaded.

## Previews
- The file includes SwiftUI previews for both iPhone and iPad devices, ensuring layout correctness across device types.

## Policy Compliance
- This implementation fully complies with the device-specific struct policy and layout standards described above.
- All future changes to the subscription screen must maintain this separation and update this documentation accordingly.

---

# Custom Rules, Chores, and Rewards Creation (2024-07)

## Overview
Parents can now create custom Rules, Chores, and Rewards directly from the respective catalog modals. This feature is available for all three item types and follows a unified, robust, and visually consistent flow.

## Frontend (FE)
- Each catalog modal (Rules, Chores, Rewards) has a “Create” button at the top.
- Tapping the button shows an editable card at the top for a new custom item.
- The editable card uses a `TextField` for the title with a placeholder (e.g., "Enter your new family rule 🏡"), styled to match the card border color, and wraps to 2 lines.
- The peanut value/cost is entered in a numeric `TextField` (1-9).
- Save/Cancel buttons are shown above the list, full width, matching card width.
- Only one editable card can be shown at a time.
- After saving, the new item appears at the top of the list and can be selected like any other item.
- Card color is assigned from the palette and is consistent across Admin, Home, and Shop.
- All text and placeholder logic is visually consistent and responsive.

## Backend (BE)
- When a new custom item is saved, it is written to Firestore under:
  - Rules: `/users/{userId}/customRules/{customRuleId}`
  - Chores: `/users/{userId}/customChores/{customChoreId}`
  - Rewards: `/users/{userId}/customRewards/{customRewardId}`
- When the user saves their selection, any selected custom items are also added to the kid’s collection:
  - Rules: `/users/{userId}/kids/{kidId}/rules`
  - Chores: `/users/{userId}/kids/{kidId}/chores`
  - Rewards: `/users/{userId}/kids/{kidId}/rewards`
- All custom items are fetched and shown in the catalog modal, and are available for selection and completion in both Admin and Home/Shop.

## Other
- All UI/UX, color, and data flow logic is robust and matches the product spec.
- Placeholder and input logic is visually polished and user-friendly.
- This is now the standard for all three item types in Tipje.

## Custom Chores
- Parents can create custom chores in addition to the curated catalog.
- "Create Chore" button appears at the top of the catalog modal.
- Tapping it shows an editable card at the top (border-only, TextField for title, numeric TextField for peanuts 1-9, no stepper).
- Save/Cancel buttons are full width, matching the card width.
- Custom chores are stored in Firestore under `/users/{userId}/customChores/{customChoreId}`.
- Custom chores appear at the top of the list, visually distinct from curated ones.
- Long-press on a custom card brings up a context menu for edit/delete.
- Color rotates from the palette; validation ensures title and price are valid.
- Only one editable card is shown at a time.
- Custom chores are available for selection and saving to the kid’s chores collection, and show up in Admin and Home.
- Placeholder text for custom chore input is styled to match the card border color and wraps to 2 lines.

## Onboarding & Login Localization (2024-07)

- All user-facing text in onboarding and login screens uses the `LocalizedText("key")` SwiftUI view, which observes the current language and always fetches the correct translation from the active bundle. This enables true runtime language switching.
- For all text field placeholders (e.g., email, password), use `NSLocalizedString("key", tableName: nil, bundle: Bundle.main, value: "", comment: "")` to ensure the placeholder updates instantly when the language changes.
- The language selector (globe button) is shown only on the first onboarding screen. When the user selects a language, the entire onboarding and login UI updates immediately to the chosen language, without restarting the app.
- All localization keys for onboarding and login are present in both `en.lproj/Localizable.strings` and `nl.lproj/Localizable.strings`.
- This approach ensures a seamless, user-friendly multilingual onboarding experience and is the standard for all future onboarding and login UI in Tipje.