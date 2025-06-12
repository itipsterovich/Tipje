# Changelog (2024-06-XX)

- Home banner now shows large balance number and 'peanuts earned' label, not BalanceChip.
- RuleKidCard now visually detaches and fades only the right side (peanut badge and dash) to 50% opacity when completed, matching the 'used ticket' look.
- Debug print statements added to HomeView for balance and rule completion state.
- No checkmark or full-card fade for completed rules.
- All changes match the product spec and user feedback as of this update.

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

## Onboarding Flow Standard (2024-06)

### The onboarding flow for Tipje must follow this exact sequence:

1. **OnboardingView.swift**  
   - Shows intro slides.

2. **LoginView.swift**  
   - User logs in or registers.
   - On success, userId is set and passed to subsequent steps.

3. **KidsProfileView.swift**  
   - User creates at least one kid profile.
   - Cannot proceed without at least one kid.

4. **PinSetupView.swift**  
   - User sets up their PIN.
   - Cannot proceed without setting a valid PIN.

5. **AdminView.swift**  
   - User must add at least one card to each tab (Rules, Chores, Rewards).
   - Cannot proceed until all three have at least one item.

6. **TipjeModal.swift**  
   - Shows a congrats modal: "Admin is now locked, cards are in the home view."
   - **Note:** This modal is only shown after the user has added at least one card to each tab in AdminView, not immediately after PIN setup. After dismissing the modal, the user remains in Admin and can leave if they want. From then on, Admin is PIN-locked (PinPadView/PinLockView) on future access.

7. **Main App/Home View**  
   - User is routed to the main app.
   - **PinPadView/PinLockView** is only shown when accessing the admin area after onboarding is complete.

**Rules:**
- Each step is shown only once, in order.
- No step is repeated or skipped.
- PIN entry is never required during onboarding, only when accessing admin after onboarding.
- The success modal is only shown after all three admin tabs have at least one card, not after PIN setup.
- After dismissing the success modal, the user remains in Admin and Admin is PIN-locked on future access.
- All state and navigation for onboarding is managed in `OnboardingView.swift` as a state machine.
- `TipjeApp.swift` only checks `didCompleteOnboarding` to decide whether to show onboarding or the main app.

**If you update the onboarding flow, update this section to match!**

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